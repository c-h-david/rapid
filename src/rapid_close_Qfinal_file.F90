!*******************************************************************************
!Subroutine - rapid_close_Qfinal_file 
!*******************************************************************************
subroutine rapid_close_Qfinal_file

!Purpose:
!Close Qfinal_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2017-2024.


!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,IS_nc_status,IS_nc_id_fil_Qfinal
implicit none


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************


!*******************************************************************************
!Close file
!*******************************************************************************
if (rank==0) IS_nc_status=NF90_CLOSE(IS_nc_id_fil_Qfinal)


!*******************************************************************************
!End subroutine
!*******************************************************************************
end subroutine rapid_close_Qfinal_file
