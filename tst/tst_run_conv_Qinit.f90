!*******************************************************************************
!Program - tst_run_conv_Qint
!*******************************************************************************
program tst_run_conv_Qinit

!Purpose:
!This Fortran program allows converting the initialization file for RAPID from
!the legacy format (csv) to the current format (netCDF). 
!A total of 2 arguments must be provided:
! - Argument 1: Name of the initialization file (csv)
! - Argument 2: Name of the initialization file (netCDF)
!The program returns the following exit codes
! - 0  if the conversion is succesful
! - 22 if arguments are faulty (e.g. netCDF function crash) 
!Author:
!Cedric H. David, 2017-2024.


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use netcdf
implicit none

!-------------------------------------------------------------------------------
!Command line arguments
!-------------------------------------------------------------------------------
integer :: IS_arg

character(len=100) :: in_char1
character(len=100) :: in_char2 

!-------------------------------------------------------------------------------
!netCDF-related variables 
!-------------------------------------------------------------------------------
integer :: IS_nc_status
integer :: IS_nc_id_fil_Qinit
!netCDF file ids
integer, parameter :: IS_nc_ndim=2
!number of dimensions
integer :: IS_nc_id_dim_rivid, IS_nc_id_dim_time
!netCDF dimension IDs
integer, dimension(IS_nc_ndim) :: IV_nc_id_dim
!netCDF combined dimension IDs
integer, dimension(IS_nc_ndim) :: IV_nc_start,IV_nc_count
!for reading and writing netCDF files
integer :: IS_nc_id_var_Qinit, IS_nc_id_var_rivid, IS_nc_id_var_time
!netCDF variable IDs

!-------------------------------------------------------------------------------
!Other variables
!-------------------------------------------------------------------------------
character(len=100) :: Qinit_csv 
character(len=100) :: Qinit_ncf 

integer :: IS_riv_tot, JS_riv_tot
double precision :: ZS_Qinit

double precision, allocatable, dimension(:) :: ZV_Qinit

!-------------------------------------------------------------------------------
!System variables
!-------------------------------------------------------------------------------
integer :: IS_iostat


!*******************************************************************************
!Initialize variables to null or empty 
!*******************************************************************************
IS_arg=0

Qinit_csv=''
Qinit_ncf=''

IS_riv_tot=0
JS_riv_tot=0


!*******************************************************************************
!Getting, assigning and printing information from command line at runtime
!*******************************************************************************

!-------------------------------------------------------------------------------
!Getting command line values
!-------------------------------------------------------------------------------
IS_arg=iargc()
if(IS_arg /= 2) then
     print *, 'ERROR - Two and only two arguments must be given'
     stop 22
end if

call getarg(1,in_char1)
call getarg(2,in_char2)

!-------------------------------------------------------------------------------
!Assigning command line values to local variables 
!-------------------------------------------------------------------------------
Qinit_csv=in_char1
Qinit_ncf=in_char2

!-------------------------------------------------------------------------------
!Printing command line information on stdout 
!-------------------------------------------------------------------------------
print '(a31)'      , 'Converting RAPID Qinit files   '
print '(a31,a100)' , 'Qinit_file (csv)              :', Qinit_csv
print '(a31,a100)' , 'Qinit_file (netCDF)           :', Qinit_ncf
print '(a31)'      , '-------------------------------'


!*******************************************************************************
!Count the number of lines and read values from Qinit_csv
!*******************************************************************************

!-------------------------------------------------------------------------------
!Count the number of lines in Qinit_csv
!-------------------------------------------------------------------------------
IS_iostat=0
IS_riv_tot=0
open(10,file=Qinit_csv,status='old')
do
     read(10,*,iostat=IS_iostat) ZS_Qinit
     if (IS_iostat/=0) exit
     IS_riv_tot=IS_riv_tot+1 
end do
close(10)

!-------------------------------------------------------------------------------
!Read values from Qinit_csv
!-------------------------------------------------------------------------------
allocate(ZV_Qinit(IS_riv_tot))

open(10,file=Qinit_csv,status='old')
read(10,*) ZV_Qinit
close(10)


!*******************************************************************************
!Create new netCDF file
!*******************************************************************************

!-------------------------------------------------------------------------------
!Create file
!-------------------------------------------------------------------------------
IS_nc_status=NF90_CREATE(Qinit_ncf,NF90_CLOBBER,IS_nc_id_fil_Qinit)
call nc_check_status(IS_nc_status)

!-------------------------------------------------------------------------------
!Define dimensions
!-------------------------------------------------------------------------------
IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_Qinit,'time',NF90_UNLIMITED,            &
                          IS_nc_id_dim_time)
call nc_check_status(IS_nc_status)

IS_nc_status=NF90_DEF_DIM(IS_nc_id_fil_Qinit,'rivid',IS_riv_tot,               &
                          IS_nc_id_dim_rivid)
call nc_check_status(IS_nc_status)

IV_nc_id_dim(1)=IS_nc_id_dim_rivid
IV_nc_id_dim(2)=IS_nc_id_dim_time

!-------------------------------------------------------------------------------
!Define variables
!-------------------------------------------------------------------------------
IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qinit,'Qout',NF90_DOUBLE,               &
                          IV_nc_id_dim,IS_nc_id_var_Qinit)
call nc_check_status(IS_nc_status)

IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qinit,'rivid',NF90_INT,                 &
                          IS_nc_id_dim_rivid,IS_nc_id_var_rivid)
call nc_check_status(IS_nc_status)

IS_nc_status=NF90_DEF_VAR(IS_nc_id_fil_Qinit,'time',NF90_INT,                  &
                          IS_nc_id_dim_time,IS_nc_id_var_time)
call nc_check_status(IS_nc_status)

!-------------------------------------------------------------------------------
!End definition
!-------------------------------------------------------------------------------
IS_nc_status=NF90_ENDDEF(IS_nc_id_fil_Qinit)
call nc_check_status(IS_nc_status)

!-------------------------------------------------------------------------------
!Populate variables
!-------------------------------------------------------------------------------
IS_nc_status=NF90_PUT_VAR(IS_nc_id_fil_Qinit,IS_nc_id_var_Qinit,         &
                          ZV_Qinit,(/1,1/),(/IS_riv_tot,1/))
call nc_check_status(IS_nc_status)

!-------------------------------------------------------------------------------
!Close file
!-------------------------------------------------------------------------------
IS_nc_status=NF90_CLOSE(IS_nc_id_fil_Qinit)
call nc_check_status(IS_nc_status)


!*******************************************************************************
!End
!*******************************************************************************
print '(a31)'    , 'Completed!!!                   '
print '(a31)'    , '-------------------------------'


!*******************************************************************************
!Subroutine
!*******************************************************************************
contains
subroutine nc_check_status(IS_nc_status)

integer, intent(in) :: IS_nc_status

if(IS_nc_status /= nf90_noerr) then
     print *, trim(nf90_strerror(IS_nc_status))
     stop 22
end if

end subroutine nc_check_status

end program tst_run_conv_Qinit
