!*******************************************************************************
!Subroutine - rapid_get_Qdam
!*******************************************************************************
subroutine rapid_get_Qdam

!Purpose:
!Communicate with a dam subroutine to exchange inflows and outflows.
!Author: 
!Cedric H. David, 2013.


!*******************************************************************************
!Global variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   rank,ierr,vecscat,ZV_pointer,ZV_SeqZero,ZS_one,             &
                   IS_dam_bas,                                                 &
                   ZM_Net,ZV_Qext,ZV_Qdam,                                     &
                   ZV_Qin_dam,ZV_Qout_dam,ZV_Qin_dam_prev,ZV_Qout_dam_prev,    &
                   ZV_QoutbarR,ZV_QinbarR,                                     &
                   IV_dam_loc2,IV_dam_index,IV_dam_pos


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
!Compute inflow into dams
!*******************************************************************************
call MatMult(ZM_Net,ZV_QoutbarR,ZV_QinbarR,ierr)           
call VecAXPY(ZV_QinbarR,ZS_one,ZV_Qext,ierr)
!QinbarR=Net*QoutbarR+Qext


!*******************************************************************************
!Set values from PETSc vector into Fortran vector 
!*******************************************************************************
if (rank==0) ZV_Qin_dam=0 
call VecScatterBegin(vecscat,ZV_QinbarR,ZV_SeqZero,                            &
                     INSERT_VALUES,SCATTER_FORWARD,ierr)
call VecScatterEnd(vecscat,ZV_QinbarR,ZV_SeqZero,                              &
                        INSERT_VALUES,SCATTER_FORWARD,ierr)
call VecGetArrayF90(ZV_SeqZero,ZV_pointer,ierr)
if (rank==0) ZV_Qin_dam=ZV_pointer(IV_dam_pos) 
call VecRestoreArrayF90(ZV_SeqZero,ZV_pointer,ierr)
!Get values from ZV_QinbarR (PETSc) into ZV_Qin_dam (Fortran)


!*******************************************************************************
!Compute outflow from dams
!*******************************************************************************
!-------------------------------------------------------------------------------
!If dam module does not exit, outflow is saCompute outflow from subroutine
!-------------------------------------------------------------------------------
if (rank==0) then 
     ZV_Qout_dam=ZV_Qin_dam
end if

!!-------------------------------------------------------------------------------
!!If dam module does exist, use it
!!-------------------------------------------------------------------------------
!if (rank==0) then 
!     call dam_linear(ZV_Qin_dam_prev,ZV_Qout_dam_prev,ZV_Qout_dam)
!end if

!-------------------------------------------------------------------------------
!Re-initialize values
!-------------------------------------------------------------------------------
if (rank==0) then 
     ZV_Qin_dam_prev=ZV_Qin_dam
     ZV_Qout_dam_prev=ZV_Qout_dam
end if


!*******************************************************************************
!Set values from Fortran vector into PETSc vector 
!*******************************************************************************
if (rank==0) then
     call VecSetValues(ZV_Qdam,IS_dam_bas,IV_dam_loc2,                         &
                       ZV_Qout_dam(IV_dam_index),INSERT_VALUES,ierr)
end if

call VecAssemblyBegin(ZV_Qdam,ierr)
call VecAssemblyEnd(ZV_Qdam,ierr)           


!*******************************************************************************
!Optional - Write information in stdout 
!*******************************************************************************
!if (rank==0) print *, 'Qin_dam_prev  =', ZV_Qin_dam_prev
!if (rank==0) print *, 'Qout_dam_prev =', ZV_Qout_dam_prev
!if (rank==0) print *, 'Qin_dam       =', ZV_Qin_dam
!if (rank==0) print *, 'Qout_dam      =', ZV_Qout_dam
!call VecView(ZV_Qdam,PETSC_VIEWER_STDOUT_WORLD,ierr)


!*******************************************************************************
!End 
!*******************************************************************************

end subroutine rapid_get_Qdam
