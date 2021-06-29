!*******************************************************************************
!Subroutine - rapid_clihelp
!*******************************************************************************

subroutine rapid_clihelp
    print '(a)', 'usage: ./rapid [-v | -o | -nl <namelist_file>]'
    print '(a)', ''
    print '(a)', 'rapid options:'
    print '(a)', ''
    print '(a)', '  -v,  --version  :   print version information and exit'
    print '(a)', '  -h,  --help     :   print usage information and exit'
    print '(a)', '  -nl, --namelist :   execute rapid routing model using specified namelist config.'
    print '(a)', '                      <namelist_file> is a file that contains all needed model'
    print '(a)', '                      parameters as well as model option flags, and the names and'
    print '(a)', '                      locations of all input files.'

!*******************************************************************************
!End subroutine
!*******************************************************************************
end subroutine rapid_clihelp
