!*******************************************************************************
!Subroutine - rapid_meta_Vlat_file
!*******************************************************************************
subroutine rapid_meta_Vlat_file(Vlat_file) 

!Purpose:
!Read metadata for Vlat_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2016-2016.


!*******************************************************************************
!Global variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,IS_nc_status,IS_nc_id_fil_Vlat,                        &
                   IS_nc_id_var_time,IS_nc_id_var_crs,                         &
                   IS_nc_id_var_lon,IS_nc_id_var_lat,                          &
                   IS_riv_tot,IS_riv_bas,                                      &
                   YV_title,YV_institution,YV_comment,                         &
                   YV_time_units,YV_crs_sma,YV_crs_iflat,                      &
                   ZV_riv_tot_lon,ZV_riv_tot_lat

implicit none


!*******************************************************************************
!Includes
!*******************************************************************************


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************
character(len=*), intent(in):: Vlat_file


!*******************************************************************************
!Read global attributes
!*******************************************************************************
if (rank==0) then 
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,NF90_GLOBAL,                  \
                  "title", YV_title)
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,NF90_GLOBAL,                  \
                  "institution", YV_institution)
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,NF90_GLOBAL,                  \
                  "comment", YV_comment)
end if


!*******************************************************************************
!Read variable attributes
!*******************************************************************************
if (rank==0) then 
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,IS_nc_id_var_time,            \
                  "units", YV_time_units)
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,IS_nc_id_var_crs,             \
                  "semi_major_axis", YV_crs_sma)
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,IS_nc_id_var_crs,             \
                  "inverse_flattening", YV_crs_iflat)
end if


!*******************************************************************************
!Read coordinates
!*******************************************************************************
if (rank==0) then 
     !print *, ZV_riv_tot_lon
     IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Vlat,IS_nc_id_var_lon,             \
                               ZV_riv_tot_lon,(/1/),(/IS_riv_tot/))
     !print *, IS_nc_status
     !print *, ZV_riv_tot_lon
     
     IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Vlat,IS_nc_id_var_lat,             \
                               ZV_riv_tot_lat,(/1/),(/IS_riv_tot/))
end if


!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_meta_Vlat_file
