!*******************************************************************************
!Subroutine - rapid_cli
!*******************************************************************************
subroutine rapid_cli

!Purpose:
!Command line interface for RAPID.
!Authors: 
!Kel Markert and Cedric H. David, 2021-2024.


!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
use rapid_var, only :                                                          &
                   rank,                                                       &
                   YV_version,namelist_file
implicit none


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************
integer :: IS_arg, JS_arg
character(len=50) :: YV_arg


!*******************************************************************************
!Default namelist
!*******************************************************************************
namelist_file='./rapid_namelist' 


!*******************************************************************************
!Get the version of RAPID determined during build
!*******************************************************************************
#ifdef RAPID_VERSION
     YV_version=RAPID_VERSION
#else
     YV_version='unknown'
#endif
!Compilation examples: -D RAPID_VERSION="'v1.4.0'"  
!                      -D RAPID_VERSION="'20131114'" 


!*******************************************************************************
!Get number of command line arguments
!*******************************************************************************
IS_arg=command_argument_count()


!*******************************************************************************
!Evaluate command line options and perform associated action
!*******************************************************************************
do JS_arg=1,IS_arg
     call get_command_argument(JS_arg, YV_arg)
     !--------------------------------------------------------------------------
     !help
     !--------------------------------------------------------------------------
     if (YV_arg=='-h' .or. YV_arg=='--help') then
          if (rank==0) then
               print *, 'Help message to be added'
          end if
          call exit(0)
     end if
     !--------------------------------------------------------------------------
     !vesion
     !--------------------------------------------------------------------------
     if (YV_arg=='-v' .or. YV_arg=='--version') then
          if (rank==0) then
               print *, 'RAPID: ' // YV_version
          end if
          call exit(0)
     end if
     !--------------------------------------------------------------------------
     !namelist
     !--------------------------------------------------------------------------
     if (YV_arg=='-nl' .or. YV_arg=='--namelist') then
          if (JS_arg+1<=IS_arg) then
               call get_command_argument(JS_arg+1, YV_arg)
               namelist_file=YV_arg
          else
               print *, 'ERROR: Missing argument after -nl (or --namelist)'
               call exit(22)
          end if
     end if
     !--------------------------------------------------------------------------
     !
     !--------------------------------------------------------------------------
end do


!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_cli
