!*******************************************************************************
!Subroutine - rapid_clihelp 
!*******************************************************************************

subroutine rapid_clihelp
    print '(a)', 'usage: ./rapid [OPTIONS]'
    print '(a)', ''
    print '(a)', 'rapid options:'
    print '(a)', ''
    print '(a)', '  -v, --version     print version information and exit'
    print '(a)', '  -h, --help        print usage information and exit'
    print '(a)', '  -nl, --namelist   execute rapid routing model using specified namelist config.'

!*******************************************************************************
!End subroutine
!*******************************************************************************
end subroutine rapid_clihelp

