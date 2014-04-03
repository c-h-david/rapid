!*******************************************************************************
!Subroutine - rapid_read_Qfor_file
!*******************************************************************************
subroutine rapid_read_Qfor_file

!PURPOSE
!Author: Cedric H. David, 2013


!*******************************************************************************
!Global variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   rank,ierr,ZV_read_forcingtot,                                                  &
                   ZV_Qfor,IS_forcingbas,IV_forcing_loc,IV_forcing_index,ZV_read_forcingtot


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
#include "finclude/petsclog.h" 
!PETSc log


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************


!*******************************************************************************
!Read file
!*******************************************************************************
if (rank==0) read(34,*) ZV_read_forcingtot


!*******************************************************************************
!Set values in PETSc vector
!*******************************************************************************
if (rank==0) then
call VecSetValues(ZV_Qfor,IS_forcingbas,IV_forcing_loc,                        &
                  ZV_read_forcingtot(IV_forcing_index),INSERT_VALUES,ierr)
                  !here we only look at the forcing within the basin studied 
end if

!*******************************************************************************
!Assemble PETSc vector
!*******************************************************************************
call VecAssemblyBegin(ZV_Qfor,ierr)
call VecAssemblyEnd(ZV_Qfor,ierr)


!*******************************************************************************
!End 
!*******************************************************************************

end subroutine rapid_read_Qfor_file
