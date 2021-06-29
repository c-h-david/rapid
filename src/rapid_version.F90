!*******************************************************************************
!Subroutine - rapid_init 
!*******************************************************************************
subroutine rapid_version


use rapid_var, only :                                                          &
              YV_version
!-------------------------------------------------------------------------------
!Get the version of RAPID determined during build
!-------------------------------------------------------------------------------
#ifdef RAPID_VERSION
    YV_version=RAPID_VERSION
#else
    YV_version='unknown'
#endif
!Compilation examples: -D RAPID_VERSION="'v1.4.0'"  
!                      -D RAPID_VERSION="'20131114'" 

!*******************************************************************************
!End subroutine
!*******************************************************************************
end subroutine rapid_version
