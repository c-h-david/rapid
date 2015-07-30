!*******************************************************************************
!Subroutine - rapid_create_V_file
!*******************************************************************************
subroutine rapid_create_V_file(V_file) 

!Purpose:
!Create V_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2015.


!*******************************************************************************
!Global variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,                                                       &
                   IS_nc_status,IS_nc_id_fil_V,                                &
                   IS_nc_id_dim_time,IS_nc_id_dim_comid,IV_nc_id_dim,          &
                   IS_nc_id_var_V,IS_nc_id_var_comid,                          &
                   IV_riv_bas_id,IS_riv_bas
implicit none


!*******************************************************************************
!Includes
!*******************************************************************************


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************
character(len=*), intent(in):: V_file


!*******************************************************************************
!Open file
!*******************************************************************************
if (rank==0) then 

     IS_nc_status=NF90_CREATE(V_file,NF90_CLOBBER,IS_nc_id_fil_V)
     IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_V,'Time',NF90_UNLIMITED,           &
                               IS_nc_id_dim_time)
     IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_V,'COMID',IS_riv_bas,              &
                               IS_nc_id_dim_comid)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'COMID',NF90_INT,                &
                               IS_nc_id_dim_comid,IS_nc_id_var_comid)
     IV_nc_id_dim(1)=IS_nc_id_dim_comid
     IV_nc_id_dim(2)=IS_nc_id_dim_time
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'V',NF90_REAL,                   &
                               IV_nc_id_dim,IS_nc_id_var_V)
     IS_nc_status=NF90_ENDDEF(IS_nc_id_fil_V)
     IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_V,IS_nc_id_var_comid,              &
                               IV_riv_bas_id)
     IS_nc_status=NF90_CLOSE(IS_nc_id_fil_V)

end if


!*******************************************************************************
!End 
!*******************************************************************************

end subroutine rapid_create_V_file

