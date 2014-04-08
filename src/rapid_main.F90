!*******************************************************************************
!RAPID main program
!*******************************************************************************
program rapid_main

!Purpose:
!Allows to route water through a river network, and to estimate optimal 
!parameters using the inverse method 
!Author: 
!Cedric H. David, 2008.


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   namelist_file,                                              &
                   IV_riv_bas_id,IV_riv_index,IV_riv_loc1,                     &
                   Vlat_file,Qfor_file,                                        &
                   Qout_file,V_file,                                           &
                   IS_M,JS_M,JS_RpM,IS_RpM,IS_RpF,                             &
                   ZS_TauR,                                                    &
                   ZV_pnorm,                                                   &
                   ZV_C1,ZV_C2,ZV_C3,                                          &
                   ZV_Qext,ZV_Qfor,ZV_Qlat,ZV_Qhum,ZV_Qdam,                    &
                   ZV_Vlat,                                                    &
                   ZV_QoutR,ZV_QoutinitR,ZV_QoutbarR,                          &
                   ZV_VR,ZV_VinitR,ZV_VbarR,                                   &
                   ZS_phi,                                                     &
                   ierr,rank,stage,temp_char,temp_char2,                       &
                   ZS_one,                                                     &
                   ZV_read_riv_tot,ZV_read_for_tot,                            &
                   IS_riv_tot,IS_riv_bas,IS_for_bas,IS_dam_bas,                &
                   IV_for_index,IV_for_loc2,                                   &
                   ZS_time1,ZS_time2,ZS_time3,                                 &
                   IS_nc_status,IS_nc_id_fil_Vlat,IS_nc_id_fil_Qout,           &
                   IS_nc_id_var_Vlat,IS_nc_id_var_Qout,IS_nc_id_var_comid,     &
                   IS_nc_id_dim_time,IS_nc_id_dim_comid,IV_nc_id_dim,          &
                   IV_nc_start,IV_nc_count,IV_nc_count2,                       &
                   BS_opt_for,BS_opt_hum,BS_opt_dam,IS_opt_run

#ifndef NO_TAO
use rapid_var, only :                                                          &
                   tao
#endif

implicit none


external rapid_phiroutine
!because the subroutine is called by a function


!*******************************************************************************
!Includes
!*******************************************************************************
#include "finclude/petscsys.h"       
!base PETSc routines
#include "finclude/petscvec.h"  
#include "finclude/petscvec.h90"
!vectors, and vectors in Fortran90 
#include "finclude/petscmat.h"    
!matrices
#include "finclude/petscksp.h"    
!Krylov subspace methods
#include "finclude/petscpc.h"     
!preconditioners
#include "finclude/petscviewer.h"
!viewers (allows writing results in file for example)
#include "finclude/petsclog.h" 
!PETSc log

#ifndef NO_TAO
#include "finclude/taosolver.h" 
!TAO solver
#endif


!*******************************************************************************
!Initialize
!*******************************************************************************
namelist_file='./rapid_namelist' 
call rapid_init


!*******************************************************************************
!OPTION 1 - use to calculate flows and volumes and generate output data 
!*******************************************************************************
if (IS_opt_run==1) then

!-------------------------------------------------------------------------------
!Create Qout file
!-------------------------------------------------------------------------------
call rapid_create_Qout_file(Qout_file)

!-------------------------------------------------------------------------------
!Open files          
!-------------------------------------------------------------------------------
call rapid_open_Qout_file(Qout_file)
call rapid_open_Vlat_file(Vlat_file)
if (BS_opt_for) call rapid_open_Qfor_file(Qfor_file)

!-------------------------------------------------------------------------------
!Read, compute and write          
!-------------------------------------------------------------------------------
call PetscLogStageRegister('Read Comp Write',stage,ierr)
call PetscLogStagePush(stage,ierr)
ZS_time3=0

IV_nc_start=(/1,1/)
IV_nc_count=(/IS_riv_tot,1/)
IV_nc_count2=(/IS_riv_bas,1/)

do JS_M=1,IS_M

do JS_RpM=1,IS_RpM

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Run dam model based on previous values of QoutbarR and Qext to get Qdam
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
if (BS_opt_dam .and. IS_dam_bas>0) then

call rapid_get_Qdam

end if

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Read/set human forcing
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!To be added

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Read/set upstream forcing
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
if (BS_opt_for .and. IS_for_bas>0                                              &
                   .and. mod((JS_M-1)*IS_RpM+JS_RpM,IS_RpF)==1) then

call rapid_read_Qfor_file

end if 

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Read/set surface and subsurface volumes 
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call rapid_read_Vlat_file

call VecCopy(ZV_Vlat,ZV_Qlat,ierr)            !Qlat=Vlat
call VecScale(ZV_Qlat,1/ZS_TauR,ierr)         !Qlat=Qlat/TauR

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!calculation of Qext
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call VecCopy(ZV_Qlat,ZV_Qext,ierr)                            !Qext=Qlat
if (BS_opt_for) call VecAXPY(ZV_Qext,ZS_one,ZV_Qfor,ierr)     !Qext=Qext+1*Qfor
if (BS_opt_dam) call VecAXPY(ZV_Qext,ZS_one,ZV_Qdam,ierr)     !Qext=Qext+1*Qdam
if (BS_opt_hum) call VecAXPY(ZV_Qext,ZS_one,ZV_Qhum,ierr)     !Qext=Qext+1*Qhum

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Routing procedure
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call PetscGetTime(ZS_time1,ierr)

call rapid_routing(ZV_C1,ZV_C2,ZV_C3,ZV_Qext,                                  &
                   ZV_QoutinitR,ZV_VinitR,                                     &
                   ZV_QoutR,ZV_QoutbarR,ZV_VR,ZV_VbarR)

call PetscGetTime(ZS_time2,ierr)
ZS_time3=ZS_time3+ZS_time2-ZS_time1

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Update variables
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call VecCopy(ZV_QoutR,ZV_QoutinitR,ierr)
call VecCopy(ZV_VR,ZV_VinitR,ierr)
     
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!write outputs         
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call rapid_write_Qout_file

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Update netCDF location         
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
if (rank==0) IV_nc_start(2)=IV_nc_start(2)+1
!do not comment out if writing directly from the routing subroutine


end do
end do

!-------------------------------------------------------------------------------
!Performance statistics
!-------------------------------------------------------------------------------
call PetscPrintf(PETSC_COMM_WORLD,'Cumulative time for routing only'           &
                                  //char(10),ierr)
write(temp_char ,'(i10)')   rank
write(temp_char2,'(f10.2)') ZS_time3
call PetscSynchronizedPrintf(PETSC_COMM_WORLD,'Rank     :'//temp_char //', '// &
                                              'Time     :'//temp_char2//       &
                                               char(10),ierr)
call PetscSynchronizedFlush(PETSC_COMM_WORLD,ierr)

call PetscLogStagePop(ierr)
call PetscPrintf(PETSC_COMM_WORLD,'Output data created'//char(10),ierr)


!-------------------------------------------------------------------------------
!Close files          
!-------------------------------------------------------------------------------
call rapid_close_Qout_file
call rapid_close_Vlat_file
if (BS_opt_for) call rapid_close_Qfor_file(Qfor_file)


!-------------------------------------------------------------------------------
!End of OPTION 1
!-------------------------------------------------------------------------------
end if


!*******************************************************************************
!OPTION 2 - Optimization 
!*******************************************************************************
if (IS_opt_run==2) then
#ifndef NO_TAO

!-------------------------------------------------------------------------------
!Only one computation of phi - For testing purposes only
!-------------------------------------------------------------------------------
!call PetscLogStageRegister('One comp of phi',stage,ierr)
!call PetscLogStagePush(stage,ierr)
!!do JS_M=1,5
!call rapid_phiroutine(tao,ZV_pnorm,ZS_phi,PETSC_NULL,ierr)
!!enddo
!call PetscLogStagePop(ierr)

!-------------------------------------------------------------------------------
!Optimization procedure
!-------------------------------------------------------------------------------
call PetscLogStageRegister('Optimization   ',stage,ierr)
call PetscLogStagePush(stage,ierr)
call TaoSetObjectiveRoutine(tao,rapid_phiroutine,PETSC_NULL_OBJECT,ierr)
call TaoSetInitialVector(tao,ZV_pnorm,ierr)
call TaoSetTolerances(tao,1.0d-4,1.0d-4,PETSC_NULL_OBJECT,PETSC_NULL_OBJECT,   &
                      PETSC_NULL_OBJECT,ierr)
call TaoSolve(tao,ierr)

call TaoView(tao,PETSC_VIEWER_STDOUT_WORLD,ierr)
call PetscPrintf(PETSC_COMM_WORLD,'final normalized p=(k,x)'//char(10),ierr)
call VecView(ZV_pnorm,PETSC_VIEWER_STDOUT_WORLD,ierr)
call PetscLogStagePop(ierr)

!-------------------------------------------------------------------------------
!End of OPTION 2
!-------------------------------------------------------------------------------
#else
if (rank==0)                                         print '(a70)',            &
        'ERROR: The optimization mode requires RAPID to be compiled with TAO   '
#endif
end if


!*******************************************************************************
!Finalize
!*******************************************************************************
call rapid_final


!*******************************************************************************
!End
!*******************************************************************************
end program rapid_main