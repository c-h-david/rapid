!*******************************************************************************
!Subroutine - rapid_write_V_file
!*******************************************************************************
subroutine rapid_write_V_file

!Purpose:
!Write into V_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2015.


!*******************************************************************************
!Global variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,ierr,vecscat,ZV_SeqZero,ZV_pointer,                    &
                   IS_nc_status,IS_nc_id_fil_V,IS_nc_id_var_V,                 &
                   IV_nc_start,IV_nc_count2,                                   &
                   ZV_VbarR

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
!Gather PETSc vector on processor zero
!*******************************************************************************
call VecScatterBegin(vecscat,ZV_VbarR,ZV_SeqZero,                              &
                     INSERT_VALUES,SCATTER_FORWARD,ierr)
call VecScatterEnd(vecscat,ZV_VbarR,ZV_SeqZero,                                &
                        INSERT_VALUES,SCATTER_FORWARD,ierr)


!*******************************************************************************
!Get array from PETSc vector
!*******************************************************************************
if (rank==0) call VecGetArrayF90(ZV_SeqZero,ZV_pointer,ierr)


!*******************************************************************************
!Write data
!*******************************************************************************
if (rank==0) IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_V,IS_nc_id_var_V,          &
                                       ZV_pointer,IV_nc_start,IV_nc_count2)


!*******************************************************************************
!Restore array to PETSc vector
!*******************************************************************************
if (rank==0) call VecRestoreArrayF90(ZV_SeqZero,ZV_pointer,ierr)


!*******************************************************************************
!End 
!*******************************************************************************

end subroutine rapid_write_V_file