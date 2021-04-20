#!/bin/bash
#*******************************************************************************
#rapid_petsc_includes.sh
#*******************************************************************************

#Purpose:
#Determine which Fortran 90 files need which PETSc modules and includes.
#Author:
#Cedric H. David, 2020-2021.


#*******************************************************************************
#Tao
#*******************************************************************************
echo '********************'
echo '- List of Fortran files that need petsctao.h'
grep -l 'Tao' *.F90


#*******************************************************************************
#KSP
#*******************************************************************************
echo '********************'
echo '- List of Fortran files that need petscksp.h'
grep -L 'Tao' *.F90 | xargs -r grep -l 'KSP'


#*******************************************************************************
#PC
#*******************************************************************************
echo '********************'
echo '- List of Fortran files that need petscpc.h'
grep -L 'Tao' *.F90 | xargs -r grep -L 'KSP' | xargs -r grep -l 'PC'


#*******************************************************************************
#Mat
#*******************************************************************************
echo '********************'
echo '- List of Fortran files that need petscmat.h'
grep -L 'Tao' *.F90 | xargs -r grep -L 'KSP' | xargs -r grep -L 'PC' | xargs -r grep -l 'Mat'


#*******************************************************************************
#Vec
#*******************************************************************************
echo '********************'
echo '- List of Fortran files that need petscvec.h'
grep -L 'Tao' *.F90 | xargs -r grep -L 'KSP' | xargs -r grep -L 'PC' | xargs -r grep -L 'Mat' | xargs -r grep -l 'Vec'


#*******************************************************************************
#Sys
#*******************************************************************************
echo '********************'
echo '- List of Fortran files that need petscsys.h'
grep -L 'Tao' *.F90 | xargs -r grep -L 'KSP' | xargs -r grep -L 'PC' | xargs -r grep -L 'Mat' | xargs -r grep -L 'Vec' | xargs -r grep -l 'ierr'


#*******************************************************************************
#No PETSc
#*******************************************************************************
echo '********************'
echo '- List of Fortran files that do not need PETSc includes'
grep -L 'Tao' *.F90 | xargs -r grep -L 'KSP' | xargs -r grep -L 'PC' | xargs -r grep -L 'Mat' | xargs -r grep -L 'Vec' | xargs -r grep -L 'ierr'


#*******************************************************************************
#end
#*******************************************************************************
echo '********************'
