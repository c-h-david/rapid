#!/bin/bash
#*******************************************************************************
#rapid_install_prereqs.sh
#*******************************************************************************

#Purpose:
#This shell script installs programs required for RAPID on Linux, MAC, or Cygwin.
#Author:
#Alan D. Snow and Cedric H. David, 2015-2016, based on tutorial by Cedric H. David


#*******************************************************************************
#Before installing
#*******************************************************************************
#Make sure this file has execute privileges.
# $ chmod u+x rapid_install_prereqs.sh
#
#Compilers for C, C++ and FORTRAN are needed in order to install the libraries
#used by RAPID. Here we use the GNU Compiler Collection. Make all necessary
#compilers are installed by executing:
# $ which gcc
# $ which g++
# $ which gfortran
#
#If one or more of the compilers is missing, execute:
# $ apt-get install g++ gfortran (Debian)
# $ yum install g++ gfortran (Red Hat)


#*******************************************************************************
#Get command line args
#*******************************************************************************
#Installation directory
INSTALLZ_DIR=$HOME/installz
#Update the location of the installation directory as you wish, but do not move
#anything after running this script, or do so at your own risks!
HPC_MODE=NO
FORCE_INSTALL_NETCDF=NO
FORCE_INSTALL_PETSC=NO
for i in "$@"
do
case $i in
-i=*|--installz=*)
INSTALLZ_DIR="${i#*=}"
shift
;;
-hpc)
HPC_MODE=YES
shift
;;
-nf|--netcdf_force)
FORCE_INSTALL_NETCDF=YES
shift
;;
-pf|--petsc_force)
FORCE_INSTALL_PETSC=YES
shift
;;
-h|--help)
echo "To install with defaults, ./install_rapid_prereqs.sh"
echo "-i=/path/to/installz | --installz=/path/to/installz | last argument /path/to/installz"
echo "To force installation of NetCDF: -nf | --netcdf_force"
echo "To force installation of PETSc: -pf | --petsc_force"
exit
;;
*)
# unknown option
;;
esac
done

if [[ -n $1 ]]; then
    INSTALLZ_DIR=$1
fi

if [[ ! "$INSTALLZ_DIR" = /* ]]; then
    echo "ERROR: Relative install path given ($INSTALLZ_DIR). Install path must be absolute."
    exit 1
fi

echo "Installing RAPID prereqs in: $INSTALLZ_DIR"

if [ "$HPC_MODE" == "YES" ]; then
    #Additionally, we will use the mpi/sgimpt module. You will need to load this module
    # if it is missing. To check if it is missing, execute:
    # $ module list
    #To find available modules, execute:
    # $ module avail

    #*******************************************************************************
    #Load Required Modules
    #*******************************************************************************
    module load valgrind
    module load mpi/sgimpt

    #*******************************************************************************
    #SGI MPI Paths
    #*******************************************************************************
    # to find the paths required for your instance, execute:
    # $ module show mpi/sgimpt
    # look for a line like:
    # prepend-path	 PATH /p/home/apps/sgi/mpt-2.12-sgi712r26/bin
    # then go to the directory and find the modules
    SGI_MPIDIR=/p/home/apps/sgi/mpt-2.12-sgi712r26/bin
    SGI_MPICC=$SGI_MPIDIR/mpicc
    SGI_MPICXX=$SGI_MPIDIR/mpicxx
    SGI_MPIF90=$SGI_MPIDIR/mpif90
    SGI_MPIEXEC=$SGI_MPIDIR/mpiexec_mpt
fi

#*******************************************************************************
#Main script
#*******************************************************************************
mkdir -p $INSTALLZ_DIR

#-------------------------------------------------------------------------------
#netCDF
#-------------------------------------------------------------------------------
cd $INSTALLZ_DIR

#IF FORCE INSTALL, REMOVE OLD DIRECTORIES
if [ "$FORCE_INSTALL_NETCDF" == "YES" ]; then
    rm -rf netcdf-3.6.3
    rm -rf netcdf-3.6.3-install
fi

#DOWNLOAD IF DOES NOT EXIST
if [ ! -f netcdf-3.6.3.tar.gz ] && [ ! -d netcdf-3.6.3 ]; then
    if [ "$(uname)" == "Darwin" ]; then
        curl -o netcdf-3.6.3.tar.gz "http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-3.6.3.tar.gz"
    else
        wget -nc "http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-3.6.3.tar.gz"
    fi
fi

#EXTRACT & INSTALL
if [ ! -d netcdf-3.6.3 ]; then
    tar -xzf netcdf-3.6.3.tar.gz
fi

if [ ! -d netcdf-3.6.3-install ]; then
    mkdir -p netcdf-3.6.3-install
    cd netcdf-3.6.3
    ./configure CC=gcc CXX=g++ FC=gfortran --prefix=$INSTALLZ_DIR/netcdf-3.6.3-install
    make check > check.log
    make install > install.log
else
    echo "Skipping NetCDF installation because netcdf-3.6.3 and netcdf-3.6.3-install directories found. To force installation of NetCDF run with -nf | --netcdf_force option."
    echo "For example: ./rapid_install_prereqs -nf $INSTALLZ_DIR"
fi

#CLEANUP
if [ -f netcdf-3.6.3.tar.gz ]; then
    rm netcdf-3.6.3.tar.gz
fi

#-------------------------------------------------------------------------------
#Installing PETSc 3.6.2
#-------------------------------------------------------------------------------
cd $INSTALLZ_DIR

#IF FORCE INSTALL, REMOVE OLD DIRECTORY
if [ "$FORCE_INSTALL_PETSC" == "YES" ]; then
    rm -rf petsc-3.6.2
fi

#DOWNLOAD IF DOES NOT EXIST
if [ ! -d petsc-3.6.2.tar.gz ] && [ ! -d petsc-3.6.2 ]; then
    if [ "$(uname)" == "Darwin" ]; then
        curl -o petsc-3.6.2.tar.gz "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.6.2.tar.gz"
    else
        wget "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.6.2.tar.gz"
    fi
fi

#EXTRACT & INSTALL
if [ ! -d petsc-3.6.2 ]; then
    tar -xf petsc-3.6.2.tar.gz
    cd petsc-3.6.2
    if [ "$(expr substr $(uname -s) 1 9)" == "CYGWIN_NT" ]; then
        #CYGWIN
        ./configure PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c --download-fblaslapack=1 --download-mpich=1 --with-cc=gcc --with-cxx=g++ --with-fc=gfortran --with-clanguage=cxx --with-debugging=0 --with-windows-graphics=0
    elif [ "$HPC_MODE" == "YES" ]; then
        #HPC
        ./configure PETSC_DIR=$PWD PETSC_ARCH=llinux-gcc-c --download-fblaslapack=1 --with-cc=$SGI_MPICC --with-cxx=$SGI_MPICXX --with-clanguage=cxx  --with-mpi-f90=$SGI_MPIF90 --with-mpiexec=$SGI_MPIEXEC --with-debugging=0 CPPFLAGS=$CPPFLAGS LDFLAGS=$LDFLAGS
    else
        #Linux/Mac
        ./configure PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c --download-fblaslapack=1 --download-mpich=1 --with-cc=gcc --with-cxx=g++ --with-fc=gfortran --with-clanguage=cxx --with-debugging=0
    fi
    make PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c all
    make PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c test
else
    echo "Skipping PETSc installation because petsc-3.6.2 directory found. To force installation of PETSc run with -pf | --petsc_force option."
    echo "For example: ./rapid_install_prereqs -pf $INSTALLZ_DIR"
fi

#CLEANUP
if [ -f petsc-3.6.2.tar.gz ]; then
    rm petsc-3.6.2.tar.gz
fi

#-------------------------------------------------------------------------------
#Exporting environment variables
#-------------------------------------------------------------------------------
export TACC_NETCDF_LIB=$INSTALLZ_DIR/netcdf-3.6.3-install/lib
export TACC_NETCDF_INC=$INSTALLZ_DIR/netcdf-3.6.3-install/include
export PETSC_DIR=$INSTALLZ_DIR/petsc-3.6.2
export PETSC_ARCH='linux-gcc-c'

#-------------------------------------------------------------------------------
#Exporting directories with library-related executables to $PATH
#-------------------------------------------------------------------------------
export PATH=$PATH:$PETSC_DIR/$PETSC_ARCH/bin
export PATH=$PATH:$INSTALLZ_DIR/netcdf-3.6.3-install/bin
