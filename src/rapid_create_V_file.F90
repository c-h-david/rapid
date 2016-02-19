!*******************************************************************************
!Subroutine - rapid_create_V_file
!*******************************************************************************
subroutine rapid_create_V_file(V_file) 

!Purpose:
!Create V_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2015-2016.


!*******************************************************************************
!Global variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,                                                       &
                   IS_nc_status,IS_nc_id_fil_V,                                &
                   IS_nc_id_dim_time,IS_nc_id_dim_rivid,IV_nc_id_dim,          &
                   IS_nc_id_dim_nv,                                            &
                   IS_nc_id_var_V,IS_nc_id_var_rivid,                          &
                   IS_nc_id_var_time,IS_nc_id_var_lon,IS_nc_id_var_lat,        &
                   IS_nc_id_var_time_bnds,IS_nc_id_var_crs,                    &
                   IV_riv_bas_id,IS_riv_bas,                                   &
                   YV_now,YV_version

implicit none


!*******************************************************************************
!Includes
!*******************************************************************************


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************
character(len=*), intent(in):: V_file


!*******************************************************************************
!Create file
!*******************************************************************************
if (rank==0) then 

!-------------------------------------------------------------------------------
!Create file
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_CREATE(V_file,NF90_CLOBBER,IS_nc_id_fil_V)

!-------------------------------------------------------------------------------
!Define dimensions
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_V,'time',NF90_UNLIMITED,           &
                               IS_nc_id_dim_time)
     IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_V,'rivid',IS_riv_bas,              &
                               IS_nc_id_dim_rivid)
     IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_V,'nv',2,                          &
                               IS_nc_id_dim_nv)
     IV_nc_id_dim(1)=IS_nc_id_dim_rivid
     IV_nc_id_dim(2)=IS_nc_id_dim_time

!-------------------------------------------------------------------------------
!Define variables
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'V',NF90_REAL,                   &
                               IV_nc_id_dim,IS_nc_id_var_V)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'rivid',NF90_INT,                &
                               IS_nc_id_dim_rivid,IS_nc_id_var_rivid)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'time',NF90_INT,                 &
                               IS_nc_id_dim_time,IS_nc_id_var_time)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'time_bnds',NF90_INT,            &
                               (/IS_nc_id_dim_nv,IS_nc_id_dim_time/),          &
                               IS_nc_id_var_time_bnds)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'lon',NF90_DOUBLE,               &
                               IS_nc_id_dim_rivid,IS_nc_id_var_lon)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'lat',NF90_DOUBLE,               &
                               IS_nc_id_dim_rivid,IS_nc_id_var_lat)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'crs',NF90_INT,                  &
                               IS_nc_id_var_crs)

!-------------------------------------------------------------------------------
!Define variable attributes
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_V,                  &
                               'long_name','average river water volume '       &
                               // 'inside of each river reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_V,                  &
                               'units','m3')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_V,                  &
                               'coordinates','lon lat')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_V,                  &
                               'grid_mapping','crs')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_V,                  &
                               'cell_methods','time: mean')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_rivid,              &
                               'long_name','unique identifier for each river ' &
                               // 'reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_rivid,              &
                               'units','1')  
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_rivid,              &
                               'cf_role','timeseries_id')  

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               'standard_name','time')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               'long_name','time')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               'units','get from Vlat_file')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               'calendar','gregorian')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               'axis','T')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               'bounds','time_bnds')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lon,                &
                               'standard_name','longitude')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lon,                &
                               'long_name','longitude of a point related '     &
                               // 'to each river reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lon,                &
                               'units','degrees_east')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lon,                &
                               'axis','X')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lat,                &
                               'standard_name','latitude')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lat,                &
                               'long_name','latitude of a point related '      &
                               // 'to each river reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lat,                &
                               'units','degrees_north')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lat,                &
                               'axis','Y')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_crs,                &
                               'grid_mapping_name','latitude_longitude')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_crs,                &
                               'semi_major_axis','get from Vlat_file')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_crs,                &
                               'inverse_flattening','get from Vlat_file')

!-------------------------------------------------------------------------------
!Define global attributes
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'Conventions','CF-1.6')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'title','get from Vlat_file')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'institution','get from Vlat_file')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'source','RAPID: '//YV_version//', water ' //   &
                               'inflow: get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'history','date_created: '//YV_now)
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'references','https://github.com/c-h-david/ra'//&
                                'pid/, http://dx.doi.org/10.1175/2011JHM1345.1')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'comment','get from Vlat_file')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'featureType','timeSeries')

!-------------------------------------------------------------------------------
!End definition and close file
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_ENDDEF(IS_nc_id_fil_V)
     IS_nc_status=NF90_CLOSE(IS_nc_id_fil_V)

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
     IS_nc_status=NF90_OPEN(V_file,NF90_WRITE,IS_nc_id_fil_V)

!-------------------------------------------------------------------------------
!Populate variables
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_V,IS_nc_id_var_rivid,              &
                               IV_riv_bas_id)

!-------------------------------------------------------------------------------
!Close file
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_CLOSE(IS_nc_id_fil_V)

!-------------------------------------------------------------------------------
!End populate variables
!-------------------------------------------------------------------------------
end if


!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_create_V_file
