#!/bin/bash
#*******************************************************************************
#rapid_install_prereqs_linux.sh
#*******************************************************************************

#Purpose:
#This shell script installs programs required for RAPID.
#Author:
#Alan D. Snow and Cedric H. David, 2015-2016, based on tutorial by Cedric H. David


#*******************************************************************************
#Before installing
#*******************************************************************************
#Make sure this file has execute privileges.
# $ chmod u+x rapid_install_prereqs_linux.sh
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
#Installation directory
#*******************************************************************************
INSTALLZ_DIR=$HOME/installz
#Update the location of the installation directory as you wish, but do not move
#anything after running this script, or do so at your own risks!


#*******************************************************************************
#Main script
#*******************************************************************************
mkdir -p $INSTALLZ_DIR

#-------------------------------------------------------------------------------
#netCDF
#-------------------------------------------------------------------------------
cd $INSTALLZ_DIR
wget -nc "http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-3.6.3.tar.gz"
tar -xzf netcdf-3.6.3.tar.gz
rm netcdf-3.6.3.tar.gz
mkdir -p netcdf-3.6.3-install
cd netcdf-3.6.3
./configure CC=gcc CXX=g++ FC=gfortran --prefix=$INSTALLZ_DIR/netcdf-3.6.3-install
make check > check.log
make install > install.log

#-------------------------------------------------------------------------------
#Installing PETSc 3.6.2
#-------------------------------------------------------------------------------
cd $INSTALLZ_DIR
wget "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.6.2.tar.gz"
tar -xf petsc-3.6.2.tar.gz
rm petsc-3.6.2.tar.gz
cd petsc-3.6.2
./configure PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-cxx --download-fblaslapack=1 --download-mpich=1 --with-cc=gcc --with-cxx=g++ --with-fc=gfortran --with-clanguage=cxx --with-debugging=0
make PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-cxx all
make PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-cxx test

#-------------------------------------------------------------------------------
#Exporting environment variables
#-------------------------------------------------------------------------------
export TACC_NETCDF_LIB=$INSTALLZ_DIR/netcdf-3.6.3-install/lib
export TACC_NETCDF_INC=$INSTALLZ_DIR/netcdf-3.6.3-install/include
export PETSC_DIR=$INSTALLZ_DIR/petsc-3.6.2
export PETSC_ARCH='linux-gcc-cxx'

#-------------------------------------------------------------------------------
#Exporting directories with library-related executables to $PATH
#-------------------------------------------------------------------------------
export PATH=$PATH:$PETSC_DIR/$PETSC_ARCH/bin
export PATH=$PATH:$INSTALLZ_DIR/netcdf-3.6.3-install/bin
