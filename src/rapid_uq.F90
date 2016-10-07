!*******************************************************************************
!Subroutine - rapid_uq
!*******************************************************************************
subroutine rapid_uq

!Purpose:
!This subroutine generates river flow uncertainty based on the standard 
!deviation of the combined surface/subsurface flow into the river network.  
!Author: 
!Cedric H. David, 2016-2016.


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   IS_riv_tot,JS_riv_tot,IS_riv_bas,JS_riv_bas,JS_uq,IS_uq,    &
                   IV_riv_index,IV_riv_loc1,                                   &
                   ZS_TauR,                                                    &
                   ZS_rnd_uni1,ZS_rnd_uni2,ZS_rnd_norm,ZS_pi,                  &
                   ZV_dQlat,ZV_sQlat,ZV_dQout,ZV_sQout,ZM_Net,ZM_A,            &
                   ZV_riv_tot_dQlat,ZV_riv_tot_sQlat,ZV_riv_bas_sQout,         &
                   ZV_SeqZero,ZV_pointer,ZS_one,temp_char,                     &
                   ierr,rank,vecscat,rnd,ksp 

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

call VecSet(ZV_dQlat,0*ZS_one,ierr)
!Make sure the perturbation of lateral inflow is initialized to zero.

call VecSet(ZV_sQout,0*ZS_one,ierr)
!Make sure the standard deviation of outflow is initialized to zero.

call VecSet(ZV_dQout,0*ZS_one,ierr)
!Make sure the perturbation of outflow is initialized to zero.


!*******************************************************************************
!Computing the linear system matrix
!*******************************************************************************
call MatCopy(ZM_Net,ZM_A,DIFFERENT_NONZERO_PATTERN,ierr)   !A=Net
call MatScale(ZM_A,-ZS_one,ierr)                           !A=-A
call MatShift(ZM_A,ZS_one,ierr)                            !A=A+1*I
!Result:A=I-Net


!*******************************************************************************
!Setting the matrix in the linear system solver
!*******************************************************************************
call KSPSetOperators(ksp,ZM_A,ZM_A,ierr)
!Set KSP to use matrix ZM_A


!!*******************************************************************************
!!Compute uncertainty using a normally-distributed ensemble of perturbations
!!*******************************************************************************
!
!!-------------------------------------------------------------------------------
!!Initialize random numbers
!!-------------------------------------------------------------------------------
!call PetscRandomGetValue(rnd,ZS_rnd_uni1,ierr) 
!ZS_rnd_uni1=1-ZS_rnd_uni1
!!Two random numbers at a time are needed below, one is recycled and has to be 
!!initialized. The 1-x operation converts the range from [0,1[ to ]0,1] because
!!of the use of a natural logarithm in the transformation used.  
!
!!-------------------------------------------------------------------------------
!!Start ensemble loop
!!-------------------------------------------------------------------------------
!do JS_uq=1,IS_uq
!
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!!Initialize vectors of each ensemble to zero
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!ZV_riv_tot_dQlat=0
!call VecSet(ZV_dQlat,0*ZS_one,ierr)
!call VecSet(ZV_dQout,0*ZS_one,ierr)
!
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!!Compute a random perturbation from the standard deviation of lateral inflow
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!if (rank==0) then
!do JS_riv_tot=1,IS_riv_tot
!     call PetscRandomGetValue(rnd,ZS_rnd_uni2,ierr)
!     ZS_rnd_uni2=1-ZS_rnd_uni2
!     ZS_rnd_norm=sqrt(-2*log(ZS_rnd_uni1))*cos(2*ZS_pi*ZS_rnd_uni2)
!     ZS_rnd_uni1=ZS_rnd_uni2
!     !A normally distributed pseudo-random number is computed from two uniformly 
!     !distributed pseudo-random numbers using the Box-Muller transform
!     ZV_riv_tot_dQlat(JS_riv_tot)=ZS_rnd_norm*ZV_riv_tot_sQlat(JS_riv_tot)
!     !Each value of standard deviation in Qlat is multiplied by the random
!     !number to produce a random perturbation
!end do
!end if
!
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!!Apply this perturbation to the sub-basin of interest 
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!if (rank==0) then
!     call VecSetValues(ZV_dQlat,IS_riv_bas,IV_riv_loc1,                        &
!                       ZV_riv_tot_dQlat(IV_riv_index),INSERT_VALUES,ierr)
!end if
!call VecAssemblyBegin(ZV_dQlat,ierr)
!call VecAssemblyEnd(ZV_dQlat,ierr)  
!
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!!Compute the perturbation in outflow from the perturbation in lateral inflow
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!call KSPSolve(ksp,ZV_dQlat,ZV_dQout,ierr)
!!solves A*dQout=dQlat
!
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!!Update the square of the standard deviation in outflow
!!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!call VecPointwiseMult(ZV_dQout,ZV_dQout,ZV_dQout,ierr)
!call VecAXPY(ZV_sQout,ZS_one,ZV_dQout)
!
!!-------------------------------------------------------------------------------
!!End ensemble loop
!!-------------------------------------------------------------------------------
!end do
!
!!-------------------------------------------------------------------------------
!!Divide the sum of squares by ensemble size, compute the square root each value
!!-------------------------------------------------------------------------------
!call VecScale(ZV_sQout,ZS_one/IS_uq,ierr)
!call VecSqrtAbs(ZV_sQout,ierr)
!
!!-------------------------------------------------------------------------------
!!Write type of pseudo-random number generator in standard output 
!!-------------------------------------------------------------------------------
!!call PetscRandomGetType(rng,temp_char,ierr)                                   !######
!!call PetscPrintf(PETSC_COMM_WORLD,'type of PRNG  : '//temp_char//char(10),ierr)######


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
!Compute the variance in lateral inflow from its standard deviation
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
call VecPointwiseMult(ZV_sQlat,ZV_sQlat,ZV_sQlat,ierr)

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!Compute the variance in outflow from the variance in lateral inflow
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
call KSPSolve(ksp,ZV_sQlat,ZV_sQout,ierr)
!solves A*sQout=sQlat

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!Compute the standard deviation in outflow from its variance
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
!End subroutine
!*******************************************************************************
call PetscPrintf(PETSC_COMM_WORLD,'Uncertainty quantification completed'       &
                 //char(10),ierr)
call PetscPrintf(PETSC_COMM_WORLD,'--------------------------'//char(10),ierr)

end subroutine rapid_uq
