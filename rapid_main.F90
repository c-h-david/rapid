!*******************************************************************************
!RAPID main program
!*******************************************************************************
program rapid_main

!PURPOSE
!Allows to route water through a river network, and to estimate optimal 
!parameters using the inverse method 
!Author: Cedric H. David, 2008 


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   namelist_file,                                              &
                   IS_reachbas,                                                &
                   IV_basin_id,IV_basin_index,IV_basin_loc,                    &
                   m3_nc_file,Qfor_file,                                       &
                   Qout_file,V_file,Qout_nc_file,                              &
                   IS_M,JS_M,JS_RpM,IS_RpM,                                    &
                   ZS_TauR,                                                    &
                   ZV_pnorm,                                                   &
                   ZV_C1,ZV_C2,ZV_C3,                                          &
                   ZV_Qext,ZV_Qfor,ZV_Qlat,                                    &
                   ZV_Vlat,                                                    &
                   ZV_QoutR,ZV_QoutinitR,ZV_QoutbarR,                          &
                   ZV_VR,ZV_VinitR,ZV_VbarR,                                   &
                   ZS_phi,                                                     &
                   ierr,vecscat,rank,stage,                                    &
                   ZV_pointer, ZS_one,                                         &
                   ZV_read_reachtot,ZV_read_forcingtot,                        &
                   ZV_SeqZero,                                                 &
                   IS_reachtot,IS_forcingbas,                                  &
                   IV_forcing_index,IV_forcing_loc,                            &
                   ZS_time1,ZS_time2,ZS_time3,                                 &
                   IS_nc_status,IS_nc_id_fil_m3,IS_nc_id_fil_Qout,             &
                   IS_nc_id_var_m3,IS_nc_id_var_Qout,IS_nc_id_var_comid,       &
                   IS_nc_id_dim_time,IS_nc_id_dim_comid,IV_nc_id_dim,          &
                   IV_nc_start,IV_nc_count,IV_nc_count2,                       &
                   BS_opt_forcing,IS_opt_run

#ifndef NO_TAO
use rapid_var, only :                                                          &
                   tao,taoapp
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
#include "finclude/tao_solver.h" 
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
if (rank==0) then 
IS_nc_status=NF90_CREATE(Qout_nc_file,NF90_CLOBBER,IS_nc_id_fil_Qout)
IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_Qout,'Time',NF90_UNLIMITED,             &
                          IS_nc_id_dim_time)
IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_Qout,'COMID',IS_reachbas,               &
                          IS_nc_id_dim_comid)
IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qout,'COMID',NF90_INT,                  &
                          IS_nc_id_dim_comid,IS_nc_id_var_comid)
IV_nc_id_dim(1)=IS_nc_id_dim_comid
IV_nc_id_dim(2)=IS_nc_id_dim_time
IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qout,'Qout',NF90_REAL,                  &
                          IV_nc_id_dim,IS_nc_id_var_Qout)
IS_nc_status=NF90_ENDDEF(IS_nc_id_fil_Qout)
IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_Qout,IS_nc_id_var_comid,IV_basin_id)
if (rank==0) IS_nc_status=NF90_CLOSE(IS_nc_id_fil_Qout)
end if

!-------------------------------------------------------------------------------
!Open files          
!-------------------------------------------------------------------------------
if (rank==0) then 
open(99,file=m3_nc_file,status='old')
close(99)
IS_nc_status=NF90_OPEN(m3_nc_file,NF90_NOWRITE,IS_nc_id_fil_m3)
IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_m3,'m3_riv',IS_nc_id_var_m3)
end if
if (rank==0) then 
open(99,file=Qout_nc_file,status='old')
close(99)
IS_nc_status=NF90_OPEN(Qout_nc_file,NF90_WRITE,IS_nc_id_fil_Qout)
IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Qout,'Qout',IS_nc_id_var_Qout)
end if
if (BS_opt_forcing) open(34,file=Qfor_file,status='old')

!open(40,file=Qout_file)
!open(41,file=V_file)
!open(99,file='QoutR_900s.dat')
!if (BS_opt_forcing) open(34,file=Qfor_file,status='old')

!-------------------------------------------------------------------------------
!Read, compute and write          
!-------------------------------------------------------------------------------
call PetscLogStageRegister('Read Comp Write',stage,ierr)
call PetscLogStagePush(stage,ierr)
ZS_time3=0

IV_nc_start=(/1,1/)
IV_nc_count=(/IS_reachtot,1/)
IV_nc_count2=(/IS_reachbas,1/)

do JS_M=1,IS_M

!- + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - +  
!Read/set upstream forcing
!- + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - +  
if (BS_opt_forcing .and. IS_forcingbas > 0) then 
read(34,*) ZV_read_forcingtot
call VecSetValues(ZV_Qfor,IS_forcingbas,IV_forcing_loc,                        &
                  ZV_read_forcingtot(IV_forcing_index),INSERT_VALUES,ierr)
                  !here we only look at the forcing within the basin studied 
call VecAssemblyBegin(ZV_Qfor,ierr)
call VecAssemblyEnd(ZV_Qfor,ierr)           !set Qfor based on reading a file
!Qfor is only available everyday, this is why it's not included in the following 
!loop.
!call PetscPrintf(PETSC_COMM_WORLD,'ZV_Qfor' // char(10),ierr)
!call VecView(ZV_Qfor,PETSC_VIEWER_STDOUT_WORLD,ierr)
!call VecSet(ZV_Qfor,0*ZS_one,ierr)
end if

do JS_RpM=1,IS_RpM

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Read/set surface and subsurface volumes 
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!read(31,*) ZV_read_reachtot
if (rank==0) then
IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_m3,IS_nc_id_var_m3,                     &
                          ZV_read_reachtot,IV_nc_start,IV_nc_count)
call VecSetValues(ZV_Vlat,IS_reachbas,IV_basin_loc,                            &
                  ZV_read_reachtot(IV_basin_index),INSERT_VALUES,ierr)
end if
call VecAssemblyBegin(ZV_Vlat,ierr)
call VecAssemblyEnd(ZV_Vlat,ierr)           !set Vlat based on reading a file

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!calculation of Q based on V (here first order explicit approx) 
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call VecCopy(ZV_Vlat,ZV_Qlat,ierr)            !Qlat=Vlat
call VecScale(ZV_Qlat,1/ZS_TauR,ierr)         !Qlat=Qlat/TauR

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!calculation of Qext
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call VecWAXPY(ZV_Qext,ZS_one,ZV_Qlat,ZV_Qfor,ierr)           !Qext=1*Qlat+Qfor
!Result: Qext=Qlat+Qfor

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
call VecScatterBegin(vecscat,ZV_QoutbarR,ZV_SeqZero,                           &
                     INSERT_VALUES,SCATTER_FORWARD,ierr)
call VecScatterEnd(vecscat,ZV_QoutbarR,ZV_SeqZero,                             &
                        INSERT_VALUES,SCATTER_FORWARD,ierr)
call VecGetArrayF90(ZV_SeqZero,ZV_pointer,ierr)
if (rank==0) IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_Qout,IS_nc_id_var_Qout,    &
                                       ZV_pointer,IV_nc_start,IV_nc_count2)
call VecRestoreArrayF90(ZV_SeqZero,ZV_pointer,ierr)

if (rank==0) IV_nc_start(2)=IV_nc_start(2)+1
!do not comment out if writing directly from the routing subroutine

!call VecScatterBegin(vecscat,ZV_QoutbarR,ZV_SeqZero,                           &
!                     INSERT_VALUES,SCATTER_FORWARD,ierr)
!call VecScatterEnd(vecscat,ZV_QoutbarR,ZV_SeqZero,                             &
!                        INSERT_VALUES,SCATTER_FORWARD,ierr)
!if (rank==0) write (40,'(10e10.3)') ZV_pointer
!if (rank==0) IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_Qout,IS_nc_id_var_Qout,    &
!                                       ZV_pointer,IV_nc_start,IV_nc_count2)
!call VecRestoreArrayF90(ZV_SeqZero,ZV_pointer,ierr)

!call VecScatterBegin(vecscat,ZV_VbarR,ZV_SeqZero,                              &
!                     INSERT_VALUES,SCATTER_FORWARD,ierr)
!call VecScatterEnd(vecscat,ZV_VbarR,ZV_SeqZero,                                &
!                        INSERT_VALUES,SCATTER_FORWARD,ierr)
!call VecGetArrayF90(ZV_SeqZero,ZV_pointer,ierr)
!if (rank==0) write (41,'(10e10.3)') ZV_pointer
!call VecRestoreArrayF90(ZV_SeqZero,ZV_pointer,ierr)

!call VecView(ZV_QoutbarR,PETSC_VIEWER_STDOUT_WORLD,ierr)

end do
end do

!-------------------------------------------------------------------------------
!Performance statistics
!-------------------------------------------------------------------------------
call PetscPrintf(PETSC_COMM_WORLD,'Cumulative time for routing only'           &
                                  //char(10),ierr)
print *, 'rank=', rank, 'time=', ZS_time3

call PetscLogStagePop(ierr)
call PetscPrintf(PETSC_COMM_WORLD,'Output data created'//char(10),ierr)


!-------------------------------------------------------------------------------
!Close files          
!-------------------------------------------------------------------------------
if (rank==0) IS_nc_status=NF90_CLOSE(IS_nc_id_fil_m3)
if (rank==0) IS_nc_status=NF90_CLOSE(IS_nc_id_fil_Qout)
if (BS_opt_forcing) close(34)

!close(40)
!close(41)
!close(99)
!if (BS_opt_forcing) close(34)


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
!call rapid_phiroutine(taoapp,ZV_pnorm,ZS_phi,ierr)
!!enddo
!call PetscLogStagePop(ierr)

!-------------------------------------------------------------------------------
!Optimization procedure
!-------------------------------------------------------------------------------
call PetscLogStageRegister('Optimization   ',stage,ierr)
call PetscLogStagePush(stage,ierr)
call TaoAppSetObjectiveAndGradientRo(taoapp,rapid_phiroutine,TAO_NULL_OBJECT,  &
                                     ierr)
call TaoAppSetInitialSolutionVec(taoapp,ZV_pnorm,ierr)
call TaoSetTolerances(tao,1.0d-4,1.0d-4,TAO_NULL_OBJECT,TAO_NULL_OBJECT,ierr)
call TaoSetOptions(taoapp,tao,ierr)

call TaoSolveApplication(taoapp,tao,ierr)

call TaoView(tao,ierr)
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
