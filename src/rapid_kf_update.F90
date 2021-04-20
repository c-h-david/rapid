!*******************************************************************************
!Subroutine - rapid_kf_updade
!*******************************************************************************
subroutine rapid_kf_update

!Purpose:
!Compute the Kalman filter update:
! dQeb = Pb*H^(T)*( H*Pb*H^(T) + R )^(-1)(Qobs-HQeb)
!Authors: 
!Charlotte M. Emery, and Cedric H. David, 2018-2021.

!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
#include <petsc/finclude/petscksp.h>
use petscksp
use rapid_var, only :                                                          &
                ierr,ksp2,                                                     &
                ZS_one,ZS_stdobs,                                              &
                IS_obs_bas,                                                    &
                ZV_dQeb,ZV_Qbmean,ZV_Qobs,                                     &
                ZM_S,ZM_HPbt,ZM_HPbHt    
implicit none


!*******************************************************************************
!Local variables
!*******************************************************************************

Vec :: ZV_D
Vec :: ZV_R
Vec :: ZV_xb
Mat :: ZM_HPbHt_R

!*******************************************************************************
!Build innovation
!*******************************************************************************

!-------------------------------------------------------------------------------
!Build innovation in control space
!-------------------------------------------------------------------------------

call VecAYPX(ZV_Qbmean,-ZS_one,ZV_Qobs,ierr)
!ZV_Qb = ZV_Qobs-ZV_Qb


!-------------------------------------------------------------------------------
!Create innovation vector in observation space
!-------------------------------------------------------------------------------

call VecCreate(PETSC_COMM_WORLD,ZV_D,ierr)
call VecSetSizes(ZV_D,PETSC_DECIDE,IS_obs_bas,ierr)
call VecSetFromOptions(ZV_D,ierr)

!-------------------------------------------------------------------------------
!Build innovation in observation space
!-------------------------------------------------------------------------------

call MatMult(ZM_S,ZV_Qbmean,ZV_D,ierr)
!ZV_D = ZM_S*(ZV_Qobs-ZV_Qb)

!*******************************************************************************
!Build observation error vector
!*******************************************************************************

!-------------------------------------------------------------------------------
!Build observation error vector in control space
!------------------------------------------------------------------------------

call VecScale(ZV_Qobs,ZS_stdobs,ierr)
call VecPow(ZV_Qobs,2*ZS_one,ierr)

!-------------------------------------------------------------------------------
!Create observation error vector in observation space
!-------------------------------------------------------------------------------

call VecCreate(PETSC_COMM_WORLD,ZV_R,ierr)
call VecSetSizes(ZV_R,PETSC_DECIDE,IS_obs_bas,ierr)
call VecSetFromOptions(ZV_R,ierr)

!-------------------------------------------------------------------------------
!Build observation error vector in observation space
!-------------------------------------------------------------------------------

call MatMult(ZM_S,ZV_Qobs,ZV_R,ierr)
!ZV_R = ZM_S*(ZS_stdobs*ZV_Qobs)


!*******************************************************************************
!Build ( HPbHt+R )^(-1)*ZV_D
!*******************************************************************************

!-------------------------------------------------------------------------------
!Set matrix for linear system
!-------------------------------------------------------------------------------

call MatDuplicate(ZM_HPbHt,MAT_COPY_VALUES,ZM_HPbHt_R,ierr)
call MatDiagonalSet(ZM_HPbHt_R,ZV_R,ADD_VALUES,ierr)
!HPbHt+R

call KSPSetOperators(ksp2,ZM_HPbHt_R,ZM_HPbHt_R,ierr)
!Set KSP2 to use matrix ZM_HPbHt

!-------------------------------------------------------------------------------
!Create linear system unknown vector
!-------------------------------------------------------------------------------

call VecCreate(PETSC_COMM_WORLD,ZV_xb,ierr)
call VecSetSizes(ZV_xb,PETSC_DECIDE,IS_obs_bas,ierr)
call VecSetFromOptions(ZV_xb,ierr)

!-------------------------------------------------------------------------------
!Solve linear system
!-------------------------------------------------------------------------------

call KSPSolve(ksp2,ZV_D,ZV_xb,ierr)
!ZV_xb = ( ZM_HPbHt+diag(ZV_R) )^(-1)*ZV_D
!ZV_xb = ( HPbHt+R )^(-1)*(yo-Hxb)


!*******************************************************************************
!Compute kalman update
!*******************************************************************************

call MatMultTranspose(ZM_HPbt,ZV_xb,ZV_dQeb,ierr)
!ZV_dQeb = [ZM_HPbt]^(T)*ZV_xb
!ZV_dQeb = ZM_Pb*ZM_Ht*( HPbHt+R )^(-1)*(yo-Hxb)


!*******************************************************************************
!Delete temporary variables
!*******************************************************************************

call VecDestroy(ZV_D,ierr)
call VecDestroy(ZV_R,ierr)
call VecDestroy(ZV_xb,ierr)

call MatDestroy(ZM_HPbHt_R,ierr)

!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_kf_update
