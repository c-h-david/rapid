!*******************************************************************************
!Subroutine - rapid_read_Qobs_file
!*******************************************************************************
subroutine rapid_read_Qobs_file

!Purpose:
!Read Qobs_file from Fortran.
!Author: 
!Cedric H. David, 2013-2024.


!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
#include <petsc/finclude/petscvec.h>
use petscvec
use rapid_var, only :                                                          &
                   rank,ierr,                                                  &
                   ZV_Qobs,IS_obs_bas,IV_obs_loc1,IV_obs_index,ZV_read_obs_tot
implicit none


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************


!*******************************************************************************
!Read file
!*******************************************************************************
if (rank==0) read(33,*) ZV_read_obs_tot


!*******************************************************************************
!Set values in PETSc vector
!*******************************************************************************
if (rank==0) then
call VecSetValues(ZV_Qobs,IS_obs_bas,IV_obs_loc1,                              &
                  ZV_read_obs_tot(IV_obs_index),INSERT_VALUES,ierr)
                  !here we only look at the observations within the basin
                  !studied
end if


!*******************************************************************************
!Assemble PETSc vector
!*******************************************************************************
call VecAssemblyBegin(ZV_Qobs,ierr)
call VecAssemblyEnd(ZV_Qobs,ierr)


!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_read_Qobs_file
