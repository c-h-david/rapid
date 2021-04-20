!*******************************************************************************
!Subroutine - rapid_kf_cov_mat
!*******************************************************************************
subroutine rapid_kf_cov_mat

!Purpose:
!Compute runoff error covariance matrices in Kalman gain
!ZM_HPbt = (ZM_Pb*ZM_H^(T))^(T)
!ZM_HPbHt = ZM_H*ZM_Pb*ZM_H^(T)
!Authors: 
!Charlotte M. Emery, and Cedric H. David, 2018-2021.


!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
#include <petsc/finclude/petscmat.h>
use petscmat
use rapid_var, only :                                                          &
                ZM_Pb,ZM_H,ZM_HPbt,ZM_HPbHt,ierr
implicit none


!*******************************************************************************
!Local variables
!*******************************************************************************

Mat :: ZM_Ht

!*******************************************************************************
!Compute matrix ZM_HPbt : H*Pb^(T) = H*Pb as Pb symmetric
!*******************************************************************************

call MatMatMult(ZM_H,                      &
                ZM_Pb,                     &
                MAT_INITIAL_MATRIX,        &
                PETSC_DEFAULT_REAL,        &
                ZM_HPbt,                   &
                ierr)

!*******************************************************************************
!Compute matrix ZM_HPbHt
!*******************************************************************************

call MatTranspose(ZM_H,MAT_INITIAL_MATRIX,ZM_Ht,ierr)

call MatMatMult(ZM_HPbt,                   &
                ZM_Ht,                     &
                MAT_INITIAL_MATRIX,        &
                PETSC_DEFAULT_REAL,        &
                ZM_HPbHt,                   &
                ierr)

call PetscPrintf(PETSC_COMM_WORLD,'Kalman Filter control error covariance matrix created'  &
                                  //char(10),ierr)

!*******************************************************************************
!Delete temporary variables
!*******************************************************************************
call MatDestroy(ZM_Ht,ierr)


!*******************************************************************************
!End subroutine 
!*******************************************************************************
call PetscPrintf(PETSC_COMM_WORLD,'--------------------------'//char(10),ierr)

end subroutine rapid_kf_cov_mat
