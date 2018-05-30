!*******************************************************************************
!Subroutine - rapid_uq
!*******************************************************************************
subroutine rapid_uq

!Purpose:
!This subroutine generates river flow uncertainty based on the standard 
!deviation of the combined surface/subsurface flow into the river network.  
!Author: 
!Cedric H. David, 2016-2018.


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   IS_riv_tot,JS_riv_tot,IS_riv_bas,JS_riv_bas,                &
                   IV_riv_index,IV_riv_loc1,                                   &
                   ZS_TauR,                                                    &
                   ZV_vQlat,ZV_sQlat,ZV_vQout,ZV_sQout,ZS_alpha_uq,            & 
                   ZM_Net,ZM_A,ZV_C1,ZV_one,                                   &
                   ZV_riv_tot_vQlat,ZV_riv_tot_sQlat,ZV_riv_bas_sQout,         &
                   ZV_SeqZero,ZV_pointer,ZS_one,temp_char,                     &
                   ierr,rank,vecscat,ksp

implicit none


!*******************************************************************************
!Includes
!*******************************************************************************
#include "petsc/finclude/petscsys.h"       
!base PETSc routines
#include "petsc/finclude/petscvec.h"  
#include "petsc/finclude/petscvec.h90"
!vectors, and vectors in Fortran90 
#include "petsc/finclude/petscmat.h"    
!matrices
#include "petsc/finclude/petscksp.h"    
!Krylov subspace methods
#include "petsc/finclude/petscpc.h"     
!preconditioners
#include "petsc/finclude/petscviewer.h"
!viewers (allows writing results in file for example)


!*******************************************************************************
!Initialize variables
!*******************************************************************************
call VecSet(ZV_sQlat,0*ZS_one,ierr)
!Make sure the standard deviation of lateral inflow is initialized to zero.

call VecSet(ZV_vQlat,0*ZS_one,ierr)
!Make sure the perturbation of lateral inflow is initialized to zero.

call VecSet(ZV_sQout,0*ZS_one,ierr)
!Make sure the standard deviation of outflow is initialized to zero.

call VecSet(ZV_vQout,0*ZS_one,ierr)
!Make sure the perturbation of outflow is initialized to zero.


!*******************************************************************************
!Modifying the linear system matrix for UQ and setting it in the solver
!*******************************************************************************
call MatCopy(ZM_Net,ZM_A,DIFFERENT_NONZERO_PATTERN,ierr)   !A=Net
call MatScale(ZM_A,-ZS_one,ierr)                           !A=-A
call MatShift(ZM_A,ZS_one,ierr)                            !A=A+1*I
!Result:A=I-Net

call KSPSetOperators(ksp,ZM_A,ZM_A,ierr)
!Set KSP to use matrix ZM_A


!*******************************************************************************
!Check that standard error provided is always positive
!*******************************************************************************
if (minval(ZV_riv_tot_sQlat) < 0) then
     print *, 'ERROR - The standard error provided includes negative values'
     stop 99
end if


!*******************************************************************************
!Compute uncertainty using formula 
!*******************************************************************************

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!Apply the standard deviation to the sub-basin of interest 
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if (rank==0) then
     call VecSetValues(ZV_sQlat,IS_riv_bas,IV_riv_loc1,                        &
                       ZV_riv_tot_sQlat(IV_riv_index),INSERT_VALUES,ierr)
end if
call VecAssemblyBegin(ZV_sQlat,ierr)
call VecAssemblyEnd(ZV_sQlat,ierr)  

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!Compute the variance in lateral inflow from its standard error
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
call VecPointwiseMult(ZV_vQlat,ZV_sQlat,ZV_sQlat,ierr)

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!Compute the variance in outflow if only bias in lateral inflow 
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
call KSPSolve(ksp,ZV_sQlat,ZV_sQout,ierr)
!solves A*sQout=sQlat

call VecPointwiseMult(ZV_sQout,ZV_sQout,ZV_sQout,ierr)
!Pointwise square of each element to go from standard error to variance

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!Compute the variance in outflow if only random errors in lateral inflow 
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
call KSPSolve(ksp,ZV_vQlat,ZV_vQout,ierr)
!solves A*vQout=vQlat

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!Compute the standard error in outflow from its variance
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if (ZS_alpha_uq < 0 .and. ZS_alpha_uq > 1) then
     print '(a32)','ZS_alpha_uq must belong to [0,1]'
     stop 99
end if

call VecScale(ZV_sQout,ZS_alpha_uq,ierr)
call VecScale(ZV_vQout,ZS_one-ZS_alpha_uq,ierr)
call VecAXPY(ZV_sQout,ZS_one,ZV_vQout,ierr)
call VecSqrtAbs(ZV_sQout,ierr)


!*******************************************************************************
!Gather PETSc vector on processor zero and get the values of the array
!*******************************************************************************
call VecScatterBegin(vecscat,ZV_sQout,ZV_SeqZero,                              &
                     INSERT_VALUES,SCATTER_FORWARD,ierr)
call VecScatterEnd(vecscat,ZV_sQout,ZV_SeqZero,                                &
                   INSERT_VALUES,SCATTER_FORWARD,ierr)
!Gather PETSc vector

if (rank==0) call VecGetArrayF90(ZV_SeqZero,ZV_pointer,ierr)
!Get array from PETSc vector

if  (rank==0) ZV_riv_bas_sQout=ZV_pointer
!Copy values into the variable that will be written in netCDF file


!*******************************************************************************
!Recomputing the linear system matrix for RAPID and setting it in the solver
!*******************************************************************************
call MatCopy(ZM_Net,ZM_A,DIFFERENT_NONZERO_PATTERN,ierr)   !A=Net
call MatDiagonalScale(ZM_A,ZV_C1,ZV_one,ierr)              !A=diag(C1)*A
call MatScale(ZM_A,-ZS_one,ierr)                           !A=-A
call MatShift(ZM_A,ZS_one,ierr)                            !A=A+1*I
!Result:A=I-diag(C1)*Net

call KSPSetOperators(ksp,ZM_A,ZM_A,ierr)
!Set KSP to use matrix ZM_A. This is because this UQ subroutine had modified the
!matrix that was computed in rapid_init and that is later needed for routing. 


!*******************************************************************************
!End subroutine
!*******************************************************************************
call PetscPrintf(PETSC_COMM_WORLD,'Uncertainty quantification completed'       &
                 //char(10),ierr)
call PetscPrintf(PETSC_COMM_WORLD,'--------------------------'//char(10),ierr)

end subroutine rapid_uq
