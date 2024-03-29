!*******************************************************************************
!Subroutine - rapid_write_V_file
!*******************************************************************************
subroutine rapid_write_V_file

!Purpose:
!Write into V_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2015-2024.


!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
#include <petsc/finclude/petscvec.h>
use petscvec
use netcdf
use rapid_var, only :                                                          &
                   rank,ierr,vecscat,ZV_SeqZero,ZV_pointer,                    &
                   IS_nc_status,IS_nc_id_fil_V,IS_nc_id_var_V,                 &
                   IV_nc_start,IV_nc_count2,                                   &
                   IS_nc_id_var_time,IS_nc_id_var_time_bnds,                   &
                   IV_time,IM_time_bnds,                                       &
                   ZV_VbarR
implicit none


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

if (rank==0 .and. IV_time(1)/=-9999) then 
     !The default value for 'no data' in rapid_init.F90 is -9999 for time
     IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               IV_time(IV_nc_start(2)),(/IV_nc_start(2)/))
end if

if (rank==0 .and. IM_time_bnds(1,1)/=-9999) then 
     !The default value for 'no data' in rapid_init.F90 is -9999 for time_bnds
     IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_V,IS_nc_id_var_time_bnds,          &
                               IM_time_bnds(1:2,IV_nc_start(2)),               &
                               (/1,IV_nc_start(2)/),(/2,1/))
end if


!*******************************************************************************
!Restore array to PETSc vector
!*******************************************************************************
if (rank==0) call VecRestoreArrayF90(ZV_SeqZero,ZV_pointer,ierr)


!*******************************************************************************
!End subroutine
!*******************************************************************************
end subroutine rapid_write_V_file
