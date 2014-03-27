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
                   IS_reachbas,                                                &
                   IV_basin_id,IV_basin_index,IV_basin_loc,                    &
                   kfac_file,                                                  &
                   k_file,x_file,                                              &
                   m3_sur_file,m3_nc_file,Qobs_file,Qinit_file,Qfor_file,      &
                   Qobsbarrec_file,                                            &
                   Qout_file,V_file,Qout_nc_file,                              &
                   ZS_knorm_init,ZS_xnorm_init,ZS_kfac,ZS_xfac,ZS_k,ZS_x,      &
                   ZS_Qout0,ZS_V0,                                             &
                   IS_M,JS_M,JS_RpM,IS_RpM,                                    &
                   ZS_dtR,ZS_TauR,                                             &
                   ZM_Net,                                                     &
                   IV_gage_id,IV_gage_index,IV_gage_loc,IS_iter,               &
                   ZV_kfac,                                                    &
                   ZM_A,                                                       &
                   ZV_k,ZV_x,ZV_p,                                             &
                   ZV_pnorm,                                                   &
                   ZV_pfac,                                                    &
                   ZV_C1,ZV_C2,ZV_C3,ZV_Cdenom,                                &
                   ZV_b,ZV_b1,ZV_b2,ZV_b3,                                     &
                   ZV_Qext,ZV_Qfor,ZV_Qlat,                                    &
                   ZV_Vext,ZV_Vfor,ZV_Vlat,                                    &
                   ZV_VinitM,ZV_QoutinitM,                                     &
                   ZV_QoutinitO,ZV_QoutbarO,                                   &
                   ZV_QoutR,ZV_QoutinitR,ZV_QoutprevR,ZV_QoutbarR,             &
                   ZV_VR,ZV_VinitR,ZV_VprevR,ZV_VbarR,ZV_VoutR,                &
                   ZM_Obs,ZV_Qobs,ZV_temp1,ZV_temp2,ZS_phitemp,ZS_phi,ZS_norm, &
                   ZV_Qobsbarrec,                                              &
                   ierr,ksp,pc,tao,taoapp,reason,vecscat,rank,stage,           &
                   ZV_pointer, ZS_one,ZV_one,IS_one,                           &
                   ZV_read_reachtot,ZV_read_forcingtot,                        &
                   ZV_SeqZero,temp_char,ZV_1stIndex,ZV_2ndIndex,               &
                   IS_reachtot,IS_forcingtot,JS_forcingtot,IS_forcingbas,      &
                   IV_forcing_index,IV_forcing_loc,IV_forcingtot_id,           &
                   IV_forcinguse_id,ZS_time1,ZS_time2,ZS_time3,                &
                   ZV_read_gagetot,IS_gagebas,                                 &
                   IS_nc_status,IS_nc_id_fil_m3,IS_nc_id_fil_Qout,             &
                   IS_nc_id_var_m3,IS_nc_id_var_Qout,IS_nc_id_var_comid,       &
                   IS_nc_id_dim_time,IS_nc_id_dim_comid,IV_nc_id_dim,          &
                   IV_nc_start,IV_nc_count            



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
#include "finclude/tao_solver.h" 
!TAO solver
#include "finclude/petsclog.h" 
!TAO solver


!*******************************************************************************
!Initialize libraries and create objects
!*******************************************************************************
call rapid_create_obj
!Initialize libraries and create PETSc and TAO objects (Mat,Vec,taoapp...)

call MPI_Comm_rank(PETSC_COMM_WORLD,rank,ierr)
!Determine number associated with each processor


!*******************************************************************************
!Calculate Network matrix (only once)
!*******************************************************************************
call rapid_net_mat
!Create network matrix


!*******************************************************************************
!calculates initial flows and volumes
!*******************************************************************************
call VecSet(ZV_QoutinitM,ZS_Qout0,ierr)
!OR
!open(30,file=Qinit_file,status='old')
!read(30,*) ZV_read_reachtot
!close(30)
!call VecSetValues(ZV_QoutinitM,IS_reachbas,IV_basin_loc,                       &
!                  ZV_read_reachtot(IV_basin_index),INSERT_VALUES,ierr)
!                  !here we use the output of a simulation as the intitial 
!                  !flow rates.  The simulation has to be made on the entire
!                  !domain, the initial value is taken only for the considered
!                  !basin thanks to the vector IV_basin_index
!call VecAssemblyBegin(ZV_QoutinitM,ierr)
!call VecAssemblyEnd(ZV_QoutinitM,ierr)  
!Set initial flowrates for Main procedure


call VecSet(ZV_VinitM,ZS_V0,ierr)
!Set initial volumes for Main procedure


!*******************************************************************************
!MAIN
!*******************************************************************************

!-------------------------------------------------------------------------------
!OPTION 1 - use to calculate flows and volumes and generate output data 
!-------------------------------------------------------------------------------
open(20,file=k_file,status='old')
read(20,*) ZV_read_reachtot
call VecSetValues(ZV_k,IS_reachbas,IV_basin_loc,                               &
                  ZV_read_reachtot(IV_basin_index),INSERT_VALUES,ierr)
call VecAssemblyBegin(ZV_k,ierr)
call VecAssemblyEnd(ZV_k,ierr)
close(20)
!get values for k in a file and create the corresponding ZV_k vector

open(21,file=x_file,status='old')
read(21,*) ZV_read_reachtot
call VecSetValues(ZV_x,IS_reachbas,IV_basin_loc,                               &
                  ZV_read_reachtot(IV_basin_index),INSERT_VALUES,ierr)
call VecAssemblyBegin(ZV_x,ierr)
call VecAssemblyEnd(ZV_x,ierr)
close(21)
!get values for x in a file and create the corresponding ZV_x vector

call VecCopy(ZV_QoutinitM,ZV_QoutinitR,ierr)
call VecCopy(ZV_VinitM,ZV_VinitR,ierr)
!copy main initial values into routing initial values 

call rapid_routing_param(ZV_k,ZV_x,ZV_C1,ZV_C2,ZV_C3,ZM_A)
!calculate Muskingum parameters and matrix ZM_A

call KSPSetOperators(ksp,ZM_A,ZM_A,DIFFERENT_NONZERO_PATTERN,ierr)
call KSPSetType(ksp,KSPCGS,ierr)                           !default is CGS
!call KSPSetInitialGuessNonZero(ksp,PETSC_TRUE,ierr)
!call KSPSetInitialGuessKnoll(ksp,PETSC_TRUE,ierr)
call KSPSetFromOptions(ksp,ierr)                           !if runtime options


!-------------------------------------------------------------------------------
if (rank==0) then 
open(99,file=m3_nc_file,status='old')
close(99)
IS_nc_status=NF90_OPEN(m3_nc_file,NF90_NOWRITE,IS_nc_id_fil_m3)
IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_m3,'m3_riv',IS_nc_id_var_m3)
IV_nc_start=(/1,1/)
IV_nc_count=(/IS_reachtot,1/)
end if
!-------------------------------------------------------------------------------
!-------------------------------------------------------------------------------
if (rank==0) then 
IS_nc_status=NF90_CREATE(Qout_nc_file,NF90_CLOBBER,IS_nc_id_fil_Qout)
IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_Qout,'Time',NF90_UNLIMITED,             &
                          IS_nc_id_dim_time)
IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_Qout,'COMID',IS_reachtot,               &
                          IS_nc_id_dim_comid)
IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qout,'COMID',NF90_INT,                  &
                          IS_nc_id_dim_comid,IS_nc_id_var_comid)
IV_nc_id_dim(1)=IS_nc_id_dim_comid
IV_nc_id_dim(2)=IS_nc_id_dim_time
IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qout,'Qout',NF90_REAL,                  &
                          IV_nc_id_dim,IS_nc_id_var_Qout)
IS_nc_status=NF90_ENDDEF(IS_nc_id_fil_Qout)
IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_Qout,IS_nc_id_var_comid,IV_basin_id)
end if
!-------------------------------------------------------------------------------

call PetscLogStageRegister('Read Comp Write',stage,ierr)
call PetscLogStagePush(stage,ierr)
ZS_time3=0

!open(31,file=m3_sur_file,status='old')
open(34,file=Qfor_file,status='old')
!open(40,file=Qout_file)
!open(41,file=V_file)
!open(99,file='QoutR_900s.dat')

if (IS_forcingbas > 0) then 
call PetscPrintf(PETSC_COMM_WORLD,'WARNING: Forcing used during model run, '   &
                 //'outputs calculated with flows measured at stations '       &
                 //'located on reach ID:'//char(10),ierr)
if (rank==0) print *, 'IV_forcingtot_id   =', IV_forcingtot_id
if (rank==0) print *, 'IV_forcinguse_id   =', IV_forcinguse_id
if (rank==0) print *, 'IS_forcingbas      =', IS_forcingbas
if (rank==0) print *, 'IV_forcing_index   =', IV_forcing_index
if (rank==0) print *, 'IV_forcing_loc     =', IV_forcing_loc
end if
!Warning about forcing downstream basins

do JS_M=1,IS_M

!can be commented out if no need for upstream forcing---------------------------
!call VecSet(ZV_Qfor,0*ZS_one,ierr)
if (IS_forcingbas > 0) then 
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
end if
!-------------------------------------------------------------------------------

do JS_RpM=1,IS_RpM

!read input surface and subsurface volumes
!read(31,*) ZV_read_reachtot
if (rank==0) then
IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_m3,IS_nc_id_var_m3,                     &
                          ZV_read_reachtot,IV_nc_start,IV_nc_count)
call VecSetValues(ZV_Vlat,IS_reachbas,IV_basin_loc,                            &
                  ZV_read_reachtot(IV_basin_index),INSERT_VALUES,ierr)
end if
call VecAssemblyBegin(ZV_Vlat,ierr)
call VecAssemblyEnd(ZV_Vlat,ierr)           !set Vlat based on reading a file

!calculation of Q based on V (here first order explicit approx) 
call VecCopy(ZV_Vlat,ZV_Qlat,ierr)            !Qlat=Vlat
call VecScale(ZV_Qlat,1/ZS_TauR,ierr)         !Qlat=Qlat/TauR

!calculation of Qext
call VecWAXPY(ZV_Qext,ZS_one,ZV_Qlat,ZV_Qfor,ierr)           !Qext=1*Qlat+Qfor
!Result: Qext=Qlat+Qfor

call PetscGetTime(ZS_time1,ierr)

call rapid_routing(ZV_C1,ZV_C2,ZV_C3,ZV_Qext,                                  &
                   ZV_QoutinitR,ZV_VinitR,                                     &
                   ZV_QoutR,ZV_QoutbarR,ZV_VR,ZV_VbarR)

call PetscGetTime(ZS_time2,ierr)
ZS_time3=ZS_time3+ZS_time2-ZS_time1


call VecCopy(ZV_QoutR,ZV_QoutinitR,ierr)
call VecCopy(ZV_VR,ZV_VinitR,ierr)
     
!write outputs         
!call VecView(ZV_QoutbarR,PETSC_VIEWER_STDOUT_WORLD,ierr)
call VecScatterBegin(vecscat,ZV_QoutbarR,ZV_SeqZero,                           &
                     INSERT_VALUES,SCATTER_FORWARD,ierr)
call VecScatterEnd(vecscat,ZV_QoutbarR,ZV_SeqZero,                             &
                        INSERT_VALUES,SCATTER_FORWARD,ierr)
call VecGetArrayF90(ZV_SeqZero,ZV_pointer,ierr)
!if (rank==0) write (40,'(10e10.3)') ZV_pointer
if (rank==0) IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_Qout,IS_nc_id_var_Qout,    &
                                       ZV_pointer,IV_nc_start,IV_nc_count)
call VecRestoreArrayF90(ZV_SeqZero,ZV_pointer,ierr)

if (rank==0) IV_nc_start(2)=IV_nc_start(2)+1
!do not comment out if writing directly from the routing subroutine

!call VecScatterBegin(vecscat,ZV_VbarR,ZV_SeqZero,                              &
!                     INSERT_VALUES,SCATTER_FORWARD,ierr)
!call VecScatterEnd(vecscat,ZV_VbarR,ZV_SeqZero,                                &
!                        INSERT_VALUES,SCATTER_FORWARD,ierr)
!call VecGetArrayF90(ZV_SeqZero,ZV_pointer,ierr)
!if (rank==0) write (41,'(10e10.3)') ZV_pointer
!call VecRestoreArrayF90(ZV_SeqZero,ZV_pointer,ierr)


end do
end do

!close(31)
close(34)
!close(40)
!close(41)
!close(99)
if (rank==0) IS_nc_status=NF90_CLOSE(IS_nc_id_fil_m3)
if (rank==0) IS_nc_status=NF90_CLOSE(IS_nc_id_fil_Qout)

call PetscPrintf(PETSC_COMM_WORLD,'Cumulative time for routing only'           &
                                  //char(10),ierr)
print *, 'rank=', rank, 'time=', ZS_time3

call PetscLogStagePop(ierr)


call PetscPrintf(PETSC_COMM_WORLD,'Output data created'//char(10),ierr)




!!-------------------------------------------------------------------------------
!!OPTION 2 - Optimization 
!!-------------------------------------------------------------------------------
!call rapid_obs_mat
!!Create observation matrix
!
!call VecSetValues(ZV_pnorm,IS_one,IS_one-1,ZS_knorm_init,INSERT_VALUES,ierr)
!call VecSetValues(ZV_pnorm,IS_one,IS_one,ZS_xnorm_init,INSERT_VALUES,ierr)
!call VecAssemblyBegin(ZV_pnorm,ierr)
!call VecAssemblyEnd(ZV_pnorm,ierr)
!!set pnorm to pnorm=(knorm,xnorm)
!
!call VecSetValues(ZV_pfac,IS_one,IS_one-1,ZS_kfac,INSERT_VALUES,ierr)
!call VecSetValues(ZV_pfac,IS_one,IS_one,ZS_xfac,INSERT_VALUES,ierr)
!call VecAssemblyBegin(ZV_pnorm,ierr)
!call VecAssemblyEnd(ZV_pnorm,ierr)
!!set pfac to pfac=(kfac,xfac)
!
!call VecPointWiseMult(ZV_p,ZV_pfac,ZV_pnorm,ierr)
!!set p to p=pfac.*pnorm
!
!open(22,file=kfac_file,status='old')
!read(22,*) ZV_read_reachtot
!close(22)
!call VecSetValues(ZV_kfac,IS_reachbas,IV_basin_loc,                            &
!                  ZV_read_reachtot(IV_basin_index),INSERT_VALUES,ierr)
!                  !only looking at basin, doesn't have to be whole domain here 
!call VecAssemblyBegin(ZV_kfac,ierr)
!call VecAssemblyEnd(ZV_kfac,ierr)  
!!reads kfac and assigns to ZV_kfac
!
!open(35,file=Qobsbarrec_file,status='old')
!read(35,*) ZV_read_gagetot
!close(35)
!call VecSetValues(ZV_Qobsbarrec,IS_gagebas,IV_gage_loc,                        &
!                  ZV_read_gagetot(IV_gage_index),INSERT_VALUES,ierr)
!                  !here we only look at the observations within the basin
!                  !studied
!call VecAssemblyBegin(ZV_Qobsbarrec,ierr)
!call VecAssemblyEnd(ZV_Qobsbarrec,ierr)  
!!reads Qobsbarrec and assigns to ZV_Qobsbarrec
!!call VecView(ZV_Qobsbarrec,PETSC_VIEWER_STDOUT_WORLD,ierr)
!
!
!!!-------------------------------------------------------------------------------
!!call PetscLogStageRegister('One comp of phi',stage,ierr)
!!call PetscLogStagePush(stage,ierr)
!!!do JS_M=1,5
!!call rapid_phiroutine(taoapp,ZV_pnorm,ZS_phi,ierr)
!!!enddo
!!call PetscLogStagePop(ierr)
!!!-------------------------------------------------------------------------------
!
!
!!-------------------------------------------------------------------------------
!if (IS_forcingbas > 0) then 
!call PetscPrintf(PETSC_COMM_WORLD,'WARNING: Forcing used during optimization, '&
!                 //'cost function calculated with flows measured at stations ' &
!                 //'located on reach ID:'//char(10),ierr)
!!if (rank==0) print *, 'IV_forcingtot_id   =', IV_forcingtot_id
!if (rank==0) print *, 'IV_forcinguse_id   =', IV_forcinguse_id
!if (rank==0) print *, 'IS_forcingbas      =', IS_forcingbas
!if (rank==0) print *, 'IV_forcing_index   =', IV_forcing_index
!if (rank==0) print *, 'IV_forcing_loc     =', IV_forcing_loc
!end if
!!Warning about forcing downstream basins
!
!call PetscLogStageRegister('Optimization   ',stage,ierr)
!call PetscLogStagePush(stage,ierr)
!call TaoAppSetObjectiveAndGradientRo(taoapp,rapid_phiroutine,TAO_NULL_OBJECT,  &
!                                     ierr)
!call TaoAppSetInitialSolutionVec(taoapp,ZV_pnorm,ierr)
!call TaoSetTolerances(tao,1.0d-4,1.0d-4,TAO_NULL_OBJECT,TAO_NULL_OBJECT,ierr)
!call TaoSetOptions(taoapp,tao,ierr)
!
!call TaoSolveApplication(taoapp,tao,ierr)
!
!call TaoView(tao,ierr)
!call PetscPrintf(PETSC_COMM_WORLD,'final normalized p=(k,x)'//char(10),ierr)
!call VecView(ZV_pnorm,PETSC_VIEWER_STDOUT_WORLD,ierr)
!call PetscLogStagePop(ierr)
!!-------------------------------------------------------------------------------



!*******************************************************************************
!End
!*******************************************************************************
call PetscPrintf(PETSC_COMM_WORLD,'--------------------------'//char(10),ierr)
call VecGetType(ZV_k,temp_char,ierr)
call PetscPrintf(PETSC_COMM_WORLD,'type of vector: '//temp_char//char(10),ierr)
call MatGetType(ZM_A,temp_char,ierr)
call PetscPrintf(PETSC_COMM_WORLD,'type of matrix: '//temp_char//char(10),ierr)
call KSPGetType(ksp,temp_char,ierr)
call PetscPrintf(PETSC_COMM_WORLD,'type of KSP   : '//temp_char//char(10),ierr)
call KSPGetPC(ksp,pc,ierr)
call PCGetType(pc,temp_char,ierr)
call PetscPrintf(PETSC_COMM_WORLD,'type of PC    : '//temp_char//char(10),ierr)
call PetscPrintf(PETSC_COMM_WORLD,char(10)//char(10)//char(10)//char(10),ierr)

call rapid_destro_obj
!destroy PETSc and TAO objects (Mat,Vec,taoapp...), finalizes the libraries


end program rapid_main
