#!/bin/bash
#*******************************************************************************
#rapid_install_prereqs.sh
#*******************************************************************************

#Purpose:
#This shell script installs all prerequisites for running RAPID on Linux.
#Author:
#Alan D. Snow and Cedric H. David, 2015-2024.


#*******************************************************************************
#Before installing
#*******************************************************************************
#Make sure this file has execute privileges.
# $ chmod u+x rapid_install_prereqs.sh
#
#Compilers for C and FORTRAN are needed in order to install the libraries used
#by RAPID. Here we use the GNU Compiler Collection (GCC). One can make sure that
#all necessary compilers are installed by executing:
# $ which gcc
# $ which gfortran
#
#If one or more of the compilers is missing, execute:
# $ yum install gcc gfortran (Red Hat)
# $ apt-get install gcc gfortran (Debian)
# $ brew install gcc (Mac)


#*******************************************************************************
#Get command line arguments
#*******************************************************************************

#-------------------------------------------------------------------------------
#Default arguments
#-------------------------------------------------------------------------------
INSTALLZ_DIR=$HOME/installz
#Default installation directory. This can be set from the command line using the
#'-i' option. This location can be updated as wished, but do not move anything 
#after running this script, or do so at your own risks!

FORCE_INSTALL_PETSC=false
#Installation of PETSc is not forced by default.

#-------------------------------------------------------------------------------
#Command line arguments
#-------------------------------------------------------------------------------
for i in "$@"
do
case $i in

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Display help message
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-h|--help)
echo "To install with defaults, ./install_rapid_prereqs.sh"
echo "-i=/path/to/installz | --installz=/path/to/installz | last argument /path/to/installz"
echo "To force installation of PETSc: -pf | --petsc_force"
exit
;;

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Installation directory
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-i=*|--installz=*)
INSTALLZ_DIR="${i#*=}"
shift
;;

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Forcing installation of PETSc
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-pf|--petsc_force)
FORCE_INSTALL_PETSC=true
shift
;;

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Unknown option
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*)
echo "Unknown option"
exit 22
;;

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#End command line options
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
esac
done

#-------------------------------------------------------------------------------
#Check if $INSTALLZ_DIR is a directory and if its path is absolute
#-------------------------------------------------------------------------------
if [ ! -d "$INSTALLZ_DIR" ]; then
    echo "ERROR: $INSTALLZ_DIR is not a directory" 1>&2
    exit 22
fi
#Check if $INSTALLZ_DIR is a directory

if [[ ! "$INSTALLZ_DIR" = /* ]]; then
    echo "ERROR: $INSTALLZ_DIR is not an absolute path" 1>&2
    exit 22
fi
#Check if $INSTALLZ_DIR is an absolute path

#-------------------------------------------------------------------------------
#Print options on standard output 
#-------------------------------------------------------------------------------
echo "Installing RAPID prereqs in: $INSTALLZ_DIR"

if $FORCE_INSTALL_PETSC ; then 
     echo "Forcing reinstallation of PETSc even if its directory exists." 
else 
     echo "Not forcing reinstallation of PETSc if its directory exists." 
fi 


#*******************************************************************************
#Installing prerequisites
#*******************************************************************************

#-------------------------------------------------------------------------------
#Installing PETSc 3.13.6
#-------------------------------------------------------------------------------
cd $INSTALLZ_DIR

if $FORCE_INSTALL_PETSC ; then 
    rm -rf petsc-3.13.6
fi
#Remove old PETSc directories if FORCE_INSTALL_PETSC

if [ ! -d petsc-3.13.6.tar.gz ] && [ ! -d petsc-3.13.6 ]; then
    wget "https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.13.6.tar.gz"
fi
#Download PETSc installation file if it does not exist

if [ ! -d petsc-3.13.6 ]; then
    tar -xzf petsc-3.13.6.tar.gz
fi
#Extract PETSc installation file if directory does not exist

if [ ! -d petsc-3.13.6/linux-gcc-c ]; then
    cd petsc-3.13.6
    python3 ./configure PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c --download-fblaslapack=1 --download-mpich=1 --with-cc=gcc --with-fc=gfortran --with-clanguage=c --with-debugging=0
    make PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c all
    make PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c check
else
    echo "- Skipped PETSc installation: petsc-3.13.6/linux-gcc-c directory"
    echo "  already exists."
    echo "  To force installation, run with -pf or --petsc_force."
fi
#Install PETSc if directory does not exist


#*******************************************************************************
#End
#*******************************************************************************
