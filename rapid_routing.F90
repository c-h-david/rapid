!*******************************************************************************
!Subroutine - rapid_routing
!*******************************************************************************
subroutine rapid_routing(ZV_C1,ZV_C2,ZV_C3,ZV_Qext,                            &
                         ZV_QoutinitR,ZV_VinitR,                               &
                         ZV_QoutR,ZV_QoutbarR,ZV_VR,ZV_VbarR)

!PURPOSE
!Performs flow calculation in each reach of a river network using the Muskingum
!method (McCarthy 1938).  Also calculates the volume of each reach using a
!simple first order approximation
!Author: Cedric H. David, 2008 


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   ZS_dtR,IS_R,JS_R,                                           &
                   ZM_Net,                                                     &
                   ZV_b,ZV_b1,ZV_b2,ZV_b3,                                     &
                   ZV_QoutprevR,ZV_VprevR,ZV_VoutR,ZV_Vext,                    &
                   ierr,ksp,                                                   &
                   ZS_one,ZV_one,                                              &
                   vecscat,ZV_SeqZero,ZV_pointer,rank,                         &
                   IS_nc_status,IS_nc_id_fil_Qout,IS_nc_id_var_Qout,           &
                   IV_nc_start,IV_nc_count2,                                   &
                   IS_reachbas,JS_reachbas,IM_index_up,stage,                  &
                   IS_opt_routing,IV_nbup,IV_basin_index

implicit none


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

!IN/OUT
!Vec, intent(in)    :: ZV_C1,ZV_C2,ZV_C3,ZV_Qext,                               &
!                      ZV_QoutinitR,ZV_VinitR 
!Vec, intent(out)   :: ZV_QoutR,ZV_QoutbarR,ZV_VR,ZV_VbarR

Vec, intent(in)    :: ZV_C1,ZV_C2,ZV_C3,ZV_Qext,                               &
                      ZV_QoutinitR,ZV_VinitR 
Vec  :: ZV_QoutR,ZV_QoutbarR,ZV_VR,ZV_VbarR

PetscInt :: IS_localsize,JS_localsize
PetscScalar, pointer :: ZV_QoutR_p(:),ZV_QoutprevR_p(:),ZV_QoutinitR_p(:),     &
                        ZV_QoutbarR_p(:),ZV_Qext_p(:),ZV_C1_p(:),ZV_C2_p(:),   &
                        ZV_C3_p(:),ZV_b_p(:)


!*******************************************************************************
!Get local sizes for vectors
!*******************************************************************************
call VecGetLocalSize(ZV_QoutR,IS_localsize,ierr)

!*******************************************************************************
!Routing with PETSc using a matrix method
!*******************************************************************************
if (IS_opt_routing==1) then
!-------------------------------------------------------------------------------
!Set mean values to zero initialize QoutprevR with QoutinitR
!-------------------------------------------------------------------------------
call VecSet(ZV_QoutbarR,0*ZS_one,ierr)                     !Qoutbar=0 
!call VecSet(ZV_VbarR,0*ZS_one,ierr)                        !Vbar=0 
!set the means to zero at beginning of iterations over routing time step

call VecCopy(ZV_QoutinitR,ZV_QoutprevR,ierr)               !QoutprevR=QoutinitR
!call VecCopy(ZV_VinitR,ZV_VprevR,ierr)                     !VprevR=VinitR
!set the previous value to the initial value given as input to subroutine

do JS_R=1,IS_R
!-------------------------------------------------------------------------------
!Update mean
!-------------------------------------------------------------------------------
call VecAXPY(ZV_QoutbarR,ZS_one/IS_R,ZV_QoutprevR,ierr) 
!Qoutbar=Qoutbar+Qoutprev/IS_R
!call VecAXPY(ZV_VbarR,ZS_one/IS_R,ZV_VprevR,ierr)       
!Vbar=Vbar+Vprev/IS_R

!-------------------------------------------------------------------------------
!Calculation of the right hand size, b
!-------------------------------------------------------------------------------
!!calculation of the vector b for Ay=b, here Qext(t)=Qext(t+dt)
!call VecCopy(ZV_Qext,ZV_b1,ierr)                           !b1=Qext
!call VecPointwiseMult(ZV_b1,ZV_C1,ZV_b1,ierr)              !b1=C1.*b1
!!result b1=C1.*(Qext)
!
!!call MatMult(ZM_Net,ZV_QoutprevR,ZV_b2,ierr)               !b2=Net*Qoutprev
!call VecAXPY(ZV_b2,ZS_one,ZV_Qext,ierr)                    !b2=b2+1*Qext
!call VecPointwiseMult(ZV_b2,ZV_C2,ZV_b2,ierr)              !b2=C2.*b2
!!result b2=C2.*(Net*Qoutprev+Qext)
!
!call VecPointwiseMult(ZV_b3,ZV_C3,ZV_QoutprevR,ierr)       !b3=C3.*Qoutprev
!!result b3=C3.*Qoutprev
!
!call VecSet(ZV_b,0*ZS_one,ierr)                            !b=0
!call VecAXPY(ZV_b,ZS_one,ZV_b1,ierr)                       !b=b+b1
!call VecAXPY(ZV_b,ZS_one,ZV_b2,ierr)                       !b=b+b2
!call VecAXPY(ZV_b,ZS_one,ZV_b3,ierr)                       !b=b+b3
!!result b=b1+b2+b3


!call VecWAXPY(ZV_b1,ZS_one,ZV_C1,ZV_C2,ierr)               !b1=C1+C2
!call VecPointwiseMult(ZV_b,ZV_b1,ZV_Qext,ierr)             !b=b1.*Qext
!!result b=(C1+C2).*(Qext)
!
!!call MatMult(ZM_Net,ZV_QoutprevR,ZV_b2,ierr)               !b2=Net*Qoutprev
!call VecPointwiseMult(ZV_b2,ZV_C2,ZV_b2,ierr)              !b2=C2.*b2
!call VecAXPY(ZV_b,ZS_one,ZV_b2,ierr)
!!result b=b+C2.*(Net*Qoutprev)
!
!call VecPointwiseMult(ZV_b3,ZV_C3,ZV_QoutprevR,ierr)       !b3=C3.*Qoutprev
!call VecAXPY(ZV_b,ZS_one,ZV_b3,ierr)
!!result b=b+C3.*Qoutprev



call MatMult(ZM_Net,ZV_QoutprevR,ZV_b,ierr)                !b2=Net*Qoutprev

call VecGetArrayF90(ZV_b,ZV_b_p,ierr)
call VecGetArrayF90(ZV_C1,ZV_C1_p,ierr)
call VecGetArrayF90(ZV_C2,ZV_C2_p,ierr)
call VecGetArrayF90(ZV_C3,ZV_C3_p,ierr)
call VecGetArrayF90(ZV_QoutprevR,ZV_QoutprevR_p,ierr)
call VecGetArrayF90(ZV_Qext,ZV_Qext_p,ierr)

do JS_localsize=1,IS_localsize
     ZV_b_p(JS_localsize)=ZV_b_p(JS_localsize)*ZV_C2_p(JS_localsize)           &
                         +(ZV_C1_p(JS_localsize)+ZV_C2_p(JS_localsize))        &
                         *ZV_Qext_p(JS_localsize)                              &
                         +ZV_C3_p(JS_localsize)*ZV_QoutprevR_p(JS_localsize)
end do
call VecRestoreArrayF90(ZV_b,ZV_b_p,ierr)
call VecRestoreArrayF90(ZV_C1,ZV_C1_p,ierr)
call VecRestoreArrayF90(ZV_C2,ZV_C2_p,ierr)
call VecRestoreArrayF90(ZV_C3,ZV_C3_p,ierr)
call VecRestoreArrayF90(ZV_QoutprevR,ZV_QoutprevR_p,ierr)
call VecRestoreArrayF90(ZV_Qext,ZV_Qext_p,ierr)



!-------------------------------------------------------------------------------
!Calculation of Qout
!-------------------------------------------------------------------------------
call KSPSolve(ksp,ZV_b,ZV_QoutR,ierr)                      !solves A*Qout=b


!-------------------------------------------------------------------------------
!Calculation of V (this part can be commented to accelerate parameter 
!estimation in calibration mode)
!-------------------------------------------------------------------------------
!call VecCopy(ZV_QoutR,ZV_VoutR,ierr)                      !Vout=Qout
!call VecScale(ZV_VoutR,ZS_dtR,ierr)                       !Vout=Vout*dt
!!result Vout=Qout*dt
!
!call VecCopy(ZV_Qext,ZV_Vext,ierr)                        !Vext=Qext
!call VecScale(ZV_Vext,ZS_dtR,ierr)                        !Vext=Vext*dt
!!result Vext=Qext*dt
!
!call MatMult(ZM_Net,ZV_VoutR,ZV_VR,ierr)                  !V=Net*Vout
!call VecAXPY(ZV_VR,ZS_one,ZV_Vext,ierr)                   !V=V+Vext
!call VecAXPY(ZV_VR,-ZS_one,ZV_VoutR,ierr)                 !V=V-Vout
!call VecAXPY(ZV_VR,ZS_one,ZV_VprevR,ierr)                 !V=V+Vprev
!!result V=Vprev+(Net*Vout+Vext)-Vout


!-------------------------------------------------------------------------------
!Reset previous
!-------------------------------------------------------------------------------
call VecCopy(ZV_QoutR,ZV_QoutprevR,ierr)              !Qoutprev=Qout
!call VecCopy(ZV_VR,ZV_VprevR,ierr)                    !Vprev=V
!reset previous 

!call PetscPrintf(PETSC_COMM_WORLD,'QoutbarR' // char(10),ierr)
!call VecView(ZV_QoutbarR,PETSC_VIEWER_STDOUT_WORLD,ierr)
!call PetscPrintf(PETSC_COMM_WORLD,'C2' // char(10),ierr)
!call VecView(ZV_C2,PETSC_VIEWER_STDOUT_WORLD,ierr)

!-------------------------------------------------------------------------------
!optional write outputs
!-------------------------------------------------------------------------------
!call VecScatterBegin(vecscat,ZV_QoutR,ZV_SeqZero,                              &
!                     INSERT_VALUES,SCATTER_FORWARD,ierr)
!call VecScatterEnd(vecscat,ZV_QoutR,ZV_SeqZero,                                &
!                        INSERT_VALUES,SCATTER_FORWARD,ierr)
!call VecGetArrayF90(ZV_SeqZero,ZV_pointer,ierr)
!!if (rank==0) write (99,'(10e10.3)') ZV_pointer
!if (rank==0) IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_Qout,IS_nc_id_var_Qout,    &
!                                       ZV_pointer,                             &
!                     [IV_nc_start(1),(IV_nc_start(2)-1)*IS_R+JS_R],IV_nc_count2)
!call VecRestoreArrayF90(ZV_SeqZero,ZV_pointer,ierr)


end do
!-------------------------------------------------------------------------------
!End Routing with PETSc using a matrix method
!-------------------------------------------------------------------------------
end if


!*******************************************************************************
!Routing with Fortran using the traditional Muskingum method
!*******************************************************************************
if (IS_opt_routing==2) then
!-------------------------------------------------------------------------------
!Get all arrays
!-------------------------------------------------------------------------------
call VecGetArrayF90(ZV_C1,ZV_C1_p,ierr)
call VecGetArrayF90(ZV_C2,ZV_C2_p,ierr)
call VecGetArrayF90(ZV_C3,ZV_C3_p,ierr)
call VecGetArrayF90(ZV_QoutR,ZV_QoutR_p,ierr)
call VecGetArrayF90(ZV_QoutprevR,ZV_QoutprevR_p,ierr)
call VecGetArrayF90(ZV_QoutbarR,ZV_QoutbarR_p,ierr)
call VecGetArrayF90(ZV_QoutinitR,ZV_QoutinitR_p,ierr)
call VecGetArrayF90(ZV_Qext,ZV_Qext_p,ierr)

!-------------------------------------------------------------------------------
!!Set mean values to zero initialize QoutprevR with QoutinitR
!-------------------------------------------------------------------------------
do JS_reachbas=1,IS_reachbas
     ZV_QoutbarR_p(JS_reachbas)=0
     ZV_QoutprevR_p(JS_reachbas)=ZV_QoutinitR_p(JS_reachbas)
end do


do JS_R=1,IS_R
!-------------------------------------------------------------------------------
!Update mean
!-------------------------------------------------------------------------------
do JS_reachbas=1,IS_reachbas
    ZV_QoutbarR_p(JS_reachbas)=ZV_QoutbarR_p(JS_reachbas)+ZV_QoutprevR_p(JS_reachbas)/IS_R
end do
!Qoutbar=Qoutbar+Qoutprev/IS_R

!-------------------------------------------------------------------------------
!Calculation of Qout
!-------------------------------------------------------------------------------
!do JS_reachbas=1,IS_reachbas
!     ZV_QoutR_p(JS_reachbas)=                                                  &
!                ZV_C1_p(JS_reachbas)*                                          &
!                              (sum(ZV_QoutR_p(IM_index_up(JS_reachbas,:)))     &
!                               +ZV_Qext_p(JS_reachbas)                    )    &
!               +ZV_C2_p(JS_reachbas)*                                          &
!                              (sum(ZV_QoutprevR_p(IM_index_up(JS_reachbas,:))) &
!                               +ZV_Qext_p(JS_reachbas)                        )&
!               +ZV_C3_p(JS_reachbas)*ZV_QoutprevR_p(JS_reachbas)
!end do
!!Not taking into account the knowledge of how many upstream locations exist.
!!Similar to poor preallocation of network matrix

do JS_reachbas=1,IS_reachbas
     ZV_QoutR_p(JS_reachbas)=                                                  &
                ZV_C1_p(JS_reachbas)*                                          &
                   (sum(ZV_QoutR_p(IM_index_up(JS_reachbas,1:                  &
                                   IV_nbup(IV_basin_index(JS_reachbas)))))     & 
                    +ZV_Qext_p(JS_reachbas)                               )    &
               +ZV_C2_p(JS_reachbas)*                                          &
                   (sum(ZV_QoutprevR_p(IM_index_up(JS_reachbas,1:              &
                                       IV_nbup(IV_basin_index(JS_reachbas))))) &
                    +ZV_Qext_p(JS_reachbas)                                   )&
               +ZV_C3_p(JS_reachbas)*ZV_QoutprevR_p(JS_reachbas)
end do
!Taking into account the knowledge of how many upstream locations exist.
!Similar to better preallocation of network matrix

!-------------------------------------------------------------------------------
!Reset previous
!-------------------------------------------------------------------------------
do JS_reachbas=1,IS_reachbas
     ZV_QoutprevR_p(JS_reachbas)=ZV_QoutR_p(JS_reachbas)
end do
!Qoutprev=Qout

enddo


!-------------------------------------------------------------------------------
!Restore all arrays
!-------------------------------------------------------------------------------
call VecRestoreArrayF90(ZV_C1,ZV_C1_p,ierr)
call VecRestoreArrayF90(ZV_C2,ZV_C2_p,ierr)
call VecRestoreArrayF90(ZV_C3,ZV_C3_p,ierr)
call VecRestoreArrayF90(ZV_QoutR,ZV_QoutR_p,ierr)
call VecRestoreArrayF90(ZV_QoutprevR,ZV_QoutprevR_p,ierr)
call VecRestoreArrayF90(ZV_QoutbarR,ZV_QoutbarR_p,ierr)
call VecRestoreArrayF90(ZV_QoutinitR,ZV_QoutinitR_p,ierr)
call VecRestoreArrayF90(ZV_Qext,ZV_Qext_p,ierr)
!-------------------------------------------------------------------------------
!end Routing with Fortran using the traditional Muskingum method
!-------------------------------------------------------------------------------
end if


end subroutine rapid_routing

