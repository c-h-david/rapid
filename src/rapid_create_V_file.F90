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
                   IS_nc_id_var_V,IS_nc_id_var_rivid,                          &
                   IS_nc_id_var_time,IS_nc_id_var_lon,IS_nc_id_var_lat,        &
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
     IV_nc_id_dim(1)=IS_nc_id_dim_rivid
     IV_nc_id_dim(2)=IS_nc_id_dim_time

!-------------------------------------------------------------------------------
!Define variables
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'V',NF90_REAL,                   &
                               IV_nc_id_dim,IS_nc_id_var_V)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'time',NF90_INT,                 &
                               IS_nc_id_dim_time,IS_nc_id_var_time)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'rivid',NF90_INT,                &
                               IS_nc_id_dim_rivid,IS_nc_id_var_rivid)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'lon',NF90_REAL,                 &
                               IS_nc_id_dim_rivid,IS_nc_id_var_lon)
     IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_V,'lat',NF90_REAL,                 &
                               IS_nc_id_dim_rivid,IS_nc_id_var_lat)

!-------------------------------------------------------------------------------
!Define variable attributes
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_V,                  &
                               'standard_name','water_volume')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_V,                  &
                               'long_name','total river water volume in '      &
                               // 'each river reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_V,                  &
                               'units','m^3')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_V,                  &
                               'cell_methods','time: mean')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               'standard_name','time')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               'long_name','time')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_time,               &
                               'units','get from namelist')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_rivid,              &
                               'long_name','unique identifier for each river'  &
                               // 'reach')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lon,                &
                               'standard_name','longitude')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lon,                &
                               'long_name','longitude of a point located '     &
                               // 'within each river reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lon,                &
                               'units','degrees_east')

     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lat,                &
                               'standard_name','latitute')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lat,                &
                               'long_name','latitude of a point located '      &
                               // 'within each river reach')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,IS_nc_id_var_lat,                &
                               'units','degrees_north')

!-------------------------------------------------------------------------------
!Define global attributes
!-------------------------------------------------------------------------------
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'Conventions','CF-1.6')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'title','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'institution','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'source','get from namelist and shell')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'history','get from shell')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'references','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'comment','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'featureType','timeSeries')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'grid_mapping_name','Latitude-Longitude')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'semi_major_axis','get from namelist')
     IS_nc_status=NF90_PUT_ATT(IS_nc_id_fil_V,NF90_GLOBAL,                     &
                               'inverse_flattening','get from namelist')

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
