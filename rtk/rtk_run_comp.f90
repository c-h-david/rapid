!*******************************************************************************
!Program - rtk_run_comp
!*******************************************************************************
program rtk_run_comp

!Purpose:
!This Fortran program allows omparing two netCDF files from RAPID simulations.
!A total of 2-4 argument must be provided:
! - Argument 1: Name of the 1st netCDF file
! - Argument 2: Name of the 2nd netCDF file
! - Argument 3: Acceptable relative tolerance (optional, default is 0)
! - Argument 4: Acceptable absolute tolerance (optional, default is 0)
!The program returns the following exit codes
! - 0  if all the comparisons are succesful
! - 22 if netCDF fonctions crash (arguments are faulty) 
! - 99 if one of the comparisons failed 
!Author:
!Cedric H. David, 2012-2018.


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use netcdf
implicit none

!-------------------------------------------------------------------------------
!Command line arguments
!-------------------------------------------------------------------------------
integer :: IS_arg

character(len=120) :: in_char1
character(len=120) :: in_char2
character(len=10) :: in_char3
character(len=10) :: in_char4

!-------------------------------------------------------------------------------
!netCDF-related variables 
!-------------------------------------------------------------------------------
integer :: IS_nc_status
integer :: IS_nc_id_fil_Qout_1, IS_nc_id_fil_Qout_2
!netCDF file ids
integer, parameter :: IS_nc_ndim_rap=2
!number of dimensions
integer, dimension(IS_nc_ndim_rap) :: IV_nc_start_rap,IV_nc_count_rap
!for reading and writing netCDF files
integer :: IS_nc_id_dim_rivid_1, IS_nc_id_dim_time_1,                          &
           IS_nc_id_dim_rivid_2, IS_nc_id_dim_time_2
!netCDF dimension ids
integer :: IS_nc_id_var_Qout_1, IS_nc_id_var_rivid_1,                          &
           IS_nc_id_var_Qout_2, IS_nc_id_var_rivid_2
!netCDF variable ids

!-------------------------------------------------------------------------------
!Other variables
!-------------------------------------------------------------------------------
character(len=120) :: Qout_1_nc_file 
character(len=120) :: Qout_2_nc_file 
double precision :: ZS_rtol
double precision :: ZS_atol

integer :: IS_riv_bas, JS_riv_bas
integer :: IS_riv_bas_1, IS_riv_bas_2
integer :: IS_R, JS_R
integer :: IS_R_1, IS_R_2
double precision :: ZS_rdif,ZS_rdif_max
double precision :: ZS_adif,ZS_adif_max

character(len=120) :: temp_char

double precision, allocatable, dimension(:) :: ZV_Qout_1
double precision, allocatable, dimension(:) :: ZV_Qout_2
double precision, allocatable, dimension(:) :: ZV_dQout_abs

integer, allocatable, dimension(:) :: IV_riv_bas_id_1
integer, allocatable, dimension(:) :: IV_riv_bas_id_2


!*******************************************************************************
!Initialize variables to null or empty 
!*******************************************************************************
IS_arg=0

in_char1=''
in_char2=''
in_char3=''
in_char4=''

Qout_1_nc_file=''
Qout_1_nc_file=''
ZS_rtol=0
ZS_atol=0

IS_riv_bas=0
JS_riv_bas=0
IS_riv_bas_1=0
IS_riv_bas_2=0
IS_R=0
JS_R=0
IS_R_1=0
IS_R_2=0
ZS_rdif=0
ZS_rdif_max=0
ZS_adif=0
ZS_adif_max=0


!*******************************************************************************
!Getting, assigning and printing information from command line at runtime
!*******************************************************************************

!-------------------------------------------------------------------------------
!Getting command line values
!-------------------------------------------------------------------------------
IS_arg=iargc()
call getarg(1,in_char1)
call getarg(2,in_char2)
call getarg(3,in_char3)
call getarg(4,in_char4)

!-------------------------------------------------------------------------------
!Assigning command line values to local variables 
!-------------------------------------------------------------------------------
Qout_1_nc_file=in_char1
Qout_2_nc_file=in_char2
if (in_char3/='') read(in_char3,*) ZS_rtol
if (in_char4/='') read(in_char4,*) ZS_atol

!-------------------------------------------------------------------------------
!Printing command line information on stdout 
!-------------------------------------------------------------------------------
print '(a31)'      , 'Comparing RAPID output files   '
print '(a31,i9)'   , 'Number of arguments used      :', IS_arg
print '(a31,a100)' , '1st Qout file                 :', Qout_1_nc_file
print '(a31,a100)' , '2nd Qout file                 :', Qout_2_nc_file
print '(a31,es9.2)', 'Acceptable relative tolerance :', ZS_rtol
print '(a31,es9.2)', 'Acceptable absolute tolerance :', ZS_atol
print '(a31)'      , '-------------------------------'


!*******************************************************************************
!Opening both netCDF files and get dimension and variable IDs
!*******************************************************************************
!This obtains the netCDF IDs for dimensions and variables: 
! - River reach ID (rivid, formerly COMID).
! - Simulation time (time, formerly Time).

!-------------------------------------------------------------------------------
!1st Qout file
!-------------------------------------------------------------------------------
IS_nc_status=NF90_OPEN(Qout_1_nc_file,NF90_NOWRITE,IS_nc_id_fil_Qout_1)
call nc_check_status(IS_nc_status)
if (NF90_INQ_DIMID(IS_nc_id_fil_Qout_1, 'COMID', IS_nc_id_dim_rivid_1)==0) then
IS_nc_status=NF90_INQ_DIMID(IS_nc_id_fil_Qout_1, 'COMID', IS_nc_id_dim_rivid_1)
call nc_check_status(IS_nc_status)
IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Qout_1, 'COMID', IS_nc_id_var_rivid_1)
call nc_check_status(IS_nc_status)
else
IS_nc_status=NF90_INQ_DIMID(IS_nc_id_fil_Qout_1, 'rivid', IS_nc_id_dim_rivid_1)
call nc_check_status(IS_nc_status)
IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Qout_1, 'rivid', IS_nc_id_var_rivid_1)
call nc_check_status(IS_nc_status)
end if
if (NF90_INQ_DIMID(IS_nc_id_fil_Qout_1, 'Time', IS_nc_id_dim_time_1)==0) then
IS_nc_status=NF90_INQ_DIMID(IS_nc_id_fil_Qout_1, 'Time', IS_nc_id_dim_time_1)
call nc_check_status(IS_nc_status)
else
IS_nc_status=NF90_INQ_DIMID(IS_nc_id_fil_Qout_1, 'time', IS_nc_id_dim_time_1)
call nc_check_status(IS_nc_status)
end if
IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Qout_1, 'Qout', IS_nc_id_var_Qout_1)
call nc_check_status(IS_nc_status)

!-------------------------------------------------------------------------------
!2nd Qout file
!-------------------------------------------------------------------------------
IS_nc_status=NF90_OPEN(Qout_2_nc_file,NF90_NOWRITE,IS_nc_id_fil_Qout_2)
call nc_check_status(IS_nc_status)
if (NF90_INQ_DIMID(IS_nc_id_fil_Qout_2, 'COMID', IS_nc_id_dim_rivid_2)==0) then
IS_nc_status=NF90_INQ_DIMID(IS_nc_id_fil_Qout_2, 'COMID', IS_nc_id_dim_rivid_2)
call nc_check_status(IS_nc_status)
IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Qout_2, 'COMID', IS_nc_id_var_rivid_2)
call nc_check_status(IS_nc_status)
else
IS_nc_status=NF90_INQ_DIMID(IS_nc_id_fil_Qout_2, 'rivid', IS_nc_id_dim_rivid_2)
call nc_check_status(IS_nc_status)
IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Qout_2, 'rivid', IS_nc_id_var_rivid_2)
call nc_check_status(IS_nc_status)
end if
if (NF90_INQ_DIMID(IS_nc_id_fil_Qout_2, 'Time', IS_nc_id_dim_time_2)==0) then
IS_nc_status=NF90_INQ_DIMID(IS_nc_id_fil_Qout_2, 'Time', IS_nc_id_dim_time_2)
call nc_check_status(IS_nc_status)
else
IS_nc_status=NF90_INQ_DIMID(IS_nc_id_fil_Qout_2, 'time', IS_nc_id_dim_time_2)
call nc_check_status(IS_nc_status)
end if
IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Qout_2, 'Qout', IS_nc_id_var_Qout_2)
call nc_check_status(IS_nc_status)


!*******************************************************************************
!Getting sizes of dimensions and checking consistency
!*******************************************************************************
IS_nc_status=NF90_INQUIRE_DIMENSION(IS_nc_id_fil_Qout_2, IS_nc_id_dim_rivid_1, & 
                                    temp_char, IS_riv_bas_1)
call nc_check_status(IS_nc_status)
IS_nc_status=NF90_INQUIRE_DIMENSION(IS_nc_id_fil_Qout_1, IS_nc_id_dim_time_1,  &
                                    temp_char, IS_R_1)
call nc_check_status(IS_nc_status)

IS_nc_status=NF90_INQUIRE_DIMENSION(IS_nc_id_fil_Qout_2, IS_nc_id_dim_rivid_2, &
                                    temp_char, IS_riv_bas_2)
call nc_check_status(IS_nc_status)
IS_nc_status=NF90_INQUIRE_DIMENSION(IS_nc_id_fil_Qout_2, IS_nc_id_dim_time_2,  &
                                    temp_char, IS_R_2)
call nc_check_status(IS_nc_status)

if (IS_riv_bas_1==IS_riv_bas_2) then
     IS_riv_bas=IS_riv_bas_1
     print '(a31,i9)' , 'Common size of rivid dimension:', IS_riv_bas
else
     print '(a35)'    , 'Different sizes for rivid dimension'
     stop 99
end if

if (IS_R_1==IS_R_2) then
     IS_R=IS_R_1
     print '(a31,i9)' , 'Common size of time dimension :', IS_R
else
     print '(a34)'    , 'Different sizes for time dimension'
     stop 99
end if
print '(a31)'    , '-------------------------------'


!*******************************************************************************
!Allocate variables
!*******************************************************************************
allocate(ZV_Qout_1(IS_riv_bas))
allocate(ZV_Qout_2(IS_riv_bas))
allocate(ZV_dQout_abs(IS_riv_bas))
allocate(IV_riv_bas_id_1(IS_riv_bas))
allocate(IV_riv_bas_id_2(IS_riv_bas))


!*******************************************************************************
!Checking that rivids are the same 
!*******************************************************************************
IV_riv_bas_id_1=0
IV_riv_bas_id_2=0

IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Qout_1,IS_nc_id_var_rivid_1,            &
                          IV_riv_bas_id_1) 
call nc_check_status(IS_nc_status)

IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Qout_2,IS_nc_id_var_rivid_2,            &
                          IV_riv_bas_id_2) 
call nc_check_status(IS_nc_status)

do JS_riv_bas=1,IS_riv_bas
     if (IV_riv_bas_id_1(JS_riv_bas)/=IV_riv_bas_id_2(JS_riv_bas)) then 
          print '(a31)'    , 'The lists of rivids differ'
          print '(a31)'    , '-------------------------------'
          stop 99
     end if
end do


!*******************************************************************************
!Checking that Qouts are the same 
!*******************************************************************************
IV_nc_start_rap = (/1,1/)
IV_nc_count_rap = (/IS_riv_bas,1/)

do JS_R=1,IS_R
!-------------------------------------------------------------------------------
!initializing
!-------------------------------------------------------------------------------
ZV_Qout_1=0
ZV_Qout_2=0
ZV_dQout_abs=0
ZS_rdif=0
ZS_adif=0

!-------------------------------------------------------------------------------
!Reading values
!-------------------------------------------------------------------------------
IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Qout_1,IS_nc_id_var_Qout_1,             &
                          ZV_Qout_1,IV_nc_start_rap,IV_nc_count_rap)
call nc_check_status(IS_nc_status)

IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Qout_2,IS_nc_id_var_Qout_2,             &
                          ZV_Qout_2,IV_nc_start_rap,IV_nc_count_rap)
call nc_check_status(IS_nc_status)

!-------------------------------------------------------------------------------
!Comparing values to tolerance
!-------------------------------------------------------------------------------
do JS_riv_bas=1,IS_riv_bas
     ZV_dQout_abs(JS_riv_bas)=abs(ZV_Qout_1(JS_riv_bas)-ZV_Qout_2(JS_riv_bas))
end do

ZS_rdif=sqrt(sum(ZV_dQout_abs*ZV_dQout_abs)/sum(ZV_Qout_1*ZV_Qout_1))
if (ZS_rdif>ZS_rdif_max) ZS_rdif_max=ZS_rdif

do JS_riv_bas=1,IS_riv_bas
     ZS_adif=ZV_dQout_abs(JS_riv_bas)
     if (ZS_adif>ZS_adif_max) ZS_adif_max=ZS_adif 
end do

!-------------------------------------------------------------------------------
!Ending loop
!-------------------------------------------------------------------------------
IV_nc_start_rap(2) = IV_nc_start_rap(2) + 1
end do

!-------------------------------------------------------------------------------
!Comparing values to tolerance
!-------------------------------------------------------------------------------
print '(a31,es9.2)', 'Max relative difference       :', ZS_rdif_max
print '(a31,es9.2)', 'Max absolute difference       :', ZS_adif_max
print '(a31)'      , '-------------------------------'

if (ZS_rdif_max>ZS_rtol) then
     print '(a31)'      , 'Unacceptable rel. difference!!!'
     print '(a31)'      , '-------------------------------'
     stop 99
end if

if (ZS_adif_max>ZS_atol) then
     print '(a31)'      , 'Unacceptable abs. difference!!!'
     print '(a31)'      , '-------------------------------'
     stop 99
end if


!*******************************************************************************
!End
!*******************************************************************************
print '(a31)'    , 'Passed all tests!!!            '
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

end program rtk_run_comp
