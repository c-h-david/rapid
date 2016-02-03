!*******************************************************************************
!Subroutine - rapid_create_Qout_file
!*******************************************************************************
subroutine rapid_create_Qout_file(Qout_file) 

!Purpose:
!Create Qout_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2013-2016.


!*******************************************************************************
!Global variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,                                                       &
                   IS_nc_status,IS_nc_id_fil_Qout,                             &
                   IS_nc_id_dim_time,IS_nc_id_dim_rivid,IV_nc_id_dim,          &
                   IS_nc_id_var_Qout,IS_nc_id_var_rivid,                       &
                   IS_nc_id_var_time,IS_nc_id_var_lon,IS_nc_id_var_lat,        &
                   IV_riv_bas_id,IS_riv_bas,                                   &
                   YV_now,YV_version

implicit none


!*******************************************************************************
!Includes
!*******************************************************************************


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************
character(len=*), intent(in):: Qout_file


!*******************************************************************************
!Create file
!*******************************************************************************
if (rank==0) then 

!-------------------------------------------------------------------------------
!Create file
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_CREATE(Qout_file,NF90_CLOBBER,IS_nc_id_fil_Qout)

!-------------------------------------------------------------------------------
!Define dimensions
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_Qout,'time',NF90_UNLIMITED,        &
                               IS_nc_id_dim_time)
     IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_Qout,'rivid',IS_riv_bas,           &
                               IS_nc_id_dim_rivid)
     IV_nc_id_dim(1)=IS_nc_id_dim_rivid
     IV_nc_id_dim(2)=IS_nc_id_dim_time

!-------------------------------------------------------------------------------
!Define variables
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qout,'Qout',NF90_REAL,             &
                               IV_nc_id_dim,IS_nc_id_var_Qout)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qout,'time',NF90_INT,              &
                               IS_nc_id_dim_time,IS_nc_id_var_time)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qout,'rivid',NF90_INT,             &
                               IS_nc_id_dim_rivid,IS_nc_id_var_rivid)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qout,'lon',NF90_REAL,              &
                               IS_nc_id_dim_rivid,IS_nc_id_var_lon)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qout,'lat',NF90_REAL,              &
                               IS_nc_id_dim_rivid,IS_nc_id_var_lat)

!-------------------------------------------------------------------------------
!Define variable attributes
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_Qout,            &
                               'standard_name','water_volume_transport')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_Qout,            &
                               'long_name','river discharge at the outlet of ' &
                               // 'each river reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_Qout,            &
                               'units','m^3/s')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_Qout,            &
                               'cell_methods','time: mean')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_time,            &
                               'standard_name','time')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_time,            &
                               'long_name','time')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_time,            &
                               'units','get from namelist')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_rivid,           &
                               'long_name','unique identifier for each river'  &
                               // 'reach')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_lon,             &
                               'standard_name','longitude')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_lon,             &
                               'long_name','longitude of a point located '     &
                               // 'within each river reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_lon,             &
                               'units','degrees_east')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_lat,             &
                               'standard_name','latitute')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_lat,             &
                               'long_name','latitude of a point located '      &
                               // 'within each river reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,IS_nc_id_var_lat,             &
                               'units','degrees_north')

!-------------------------------------------------------------------------------
!Define global attributes
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'Conventions','CF-1.6')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'title','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'institution','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'source','RAPID: '//YV_version)
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'history','date_created: '//YV_now)
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'references','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'comment','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'featureType','timeSeries')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'grid_mapping_name','Latitude-Longitude')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'semi_major_axis','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_Qout,NF90_GLOBAL,                  &
                               'inverse_flattening','get from namelist')

!-------------------------------------------------------------------------------
!End definition and close file
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_ENDDEF(IS_nc_id_fil_Qout)
     IS_nc_status=NF90_CLOSE(IS_nc_id_fil_Qout)

!-------------------------------------------------------------------------------
!End create file
!-------------------------------------------------------------------------------
end if


!*******************************************************************************
!Populate variables
!*******************************************************************************
if (rank==0) then 

!-------------------------------------------------------------------------------
!Open file
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_OPEN(Qout_file,NF90_WRITE,IS_nc_id_fil_Qout)

!-------------------------------------------------------------------------------
!Populate variables
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_Qout,IS_nc_id_var_rivid,           &
                               IV_riv_bas_id)

!-------------------------------------------------------------------------------
!Close file
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_CLOSE(IS_nc_id_fil_Qout)

!-------------------------------------------------------------------------------
!End populate variables
!-------------------------------------------------------------------------------
end if


!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_create_Qout_file
