!*******************************************************************************
!Subroutine - rapid_open_Vlat_file
!*******************************************************************************
subroutine rapid_open_Vlat_file(Vlat_file) 

!Purpose:
!Open Vlat_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2013-2021.


!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,IS_nc_status,IS_nc_id_fil_Vlat,IS_nc_id_var_Vlat,      &
                   IS_nc_id_var_time,IS_nc_id_var_time_bnds,IS_nc_id_var_crs,  &
                   IS_nc_id_var_lon,IS_nc_id_var_lat, IS_nc_id_var_Vlat_err
implicit none


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************
character(len=*), intent(in):: Vlat_file


!*******************************************************************************
!Open file
!*******************************************************************************
if (rank==0) then 
     open(99,file=Vlat_file,status='old')
     close(99)
     IS_nc_status=NF90_OPEN(Vlat_file,NF90_NOWRITE,IS_nc_id_fil_Vlat)
     IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Vlat,'m3_riv',IS_nc_id_var_Vlat)
     if (IS_nc_status<0) IS_nc_id_var_Vlat=-9999
     IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Vlat,'time',IS_nc_id_var_time)
     if (IS_nc_status<0) IS_nc_id_var_time=-9999
     IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Vlat,'time_bnds',                \
                                 IS_nc_id_var_time_bnds)
     if (IS_nc_status<0) IS_nc_id_var_time_bnds=-9999
     IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Vlat,'lon',IS_nc_id_var_lon)
     if (IS_nc_status<0) IS_nc_id_var_lon=-9999
     IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Vlat,'lat',IS_nc_id_var_lat)
     if (IS_nc_status<0) IS_nc_id_var_lat=-9999
     IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Vlat,'crs',IS_nc_id_var_crs)
     if (IS_nc_status<0) IS_nc_id_var_crs=-9999
     IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Vlat,'m3_riv_err',               \
                                 IS_nc_id_var_Vlat_err)
     if (IS_nc_status<0) IS_nc_id_var_Vlat_err=-9999
     !A negative value for IS_nc_id_var_* is used if the variable doesn't exist,
     !this is because the default value of "1" might match another existing 
     !variable.  
end if


!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_open_Vlat_file
