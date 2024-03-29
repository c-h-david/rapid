!*******************************************************************************
!Subroutine - rapid_open_Qout_file
!*******************************************************************************
subroutine rapid_open_Qout_file(Qout_file) 

!Purpose:
!Open Qout_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2013-2024.


!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,IS_nc_status,IS_nc_id_fil_Qout,IS_nc_id_var_Qout
implicit none


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************
character(len=*), intent(in):: Qout_file


!*******************************************************************************
!Open file
!*******************************************************************************
if (rank==0) then 
     open(99,file=Qout_file,status='old')
     close(99)
     IS_nc_status=NF90_OPEN(Qout_file,NF90_WRITE,IS_nc_id_fil_Qout)
     IS_nc_status=NF90_INQ_VARID(IS_nc_id_fil_Qout,'Qout',IS_nc_id_var_Qout)
end if


!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_open_Qout_file
