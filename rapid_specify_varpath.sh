#!/bin/bash
#*******************************************************************************
#rapid_specify_varpath.sh
#*******************************************************************************

#Purpose:
#This shell script specifies the environment variables and updates the PATH for 
#use by RAPID. 
#The usage is the following: 
# - source ./rapid_specify_varpath.sh /path/to/directory
# or 
# - source ./rapid_specify_varpath.sh $HOME/installz
# or 
# - source ./rapid_specify_varpath.sh (uses the default above)
#Author:
#Cedric H. David, 2016-2018.


#*******************************************************************************
#Update from default value if an argument is provided
#*******************************************************************************
if [ "$1" == "" ]; then
     INSTALLZ_DIR=$HOME/installz
     #Default installation directory. 
else
     INSTALLZ_DIR=$1
     #First argument can be provided instead of default directory
fi 


#*******************************************************************************
#Check if $INSTALLZ_DIR is a directory and if its path is absolute
#*******************************************************************************
if [ ! -d "$INSTALLZ_DIR" ]; then
     echo "ERROR: $INSTALLZ_DIR is not a directory" 1>&2
     exit 22
fi
#Check if $INSTALLZ_DIR is a directory

if [[ "$INSTALLZ_DIR" != /* ]]; then
     #The double brackets allow for not expanding the /* into /bin /dev /etc...
     echo "ERROR: $INSTALLZ_DIR is not an absolute path" 1>&2
     exit 22
fi
#Check if $INSTALLZ_DIR is an absolute path


#*******************************************************************************
#Exporting environment variables 
#*******************************************************************************
export TACC_NETCDF_LIB=$INSTALLZ_DIR/netcdf-4.1.3-install/lib
export TACC_NETCDF_INC=$INSTALLZ_DIR/netcdf-4.1.3-install/include
export PETSC_DIR=$INSTALLZ_DIR/petsc-3.6.2
export PETSC_ARCH='linux-gcc-c'


#*******************************************************************************
#Exporting directories with library-related executables to $PATH
#*******************************************************************************
export PATH=$PATH:/$PETSC_DIR/$PETSC_ARCH/bin
export PATH=$PATH:$INSTALLZ_DIR/netcdf-4.1.3-install/bin


#*******************************************************************************
#End
#*******************************************************************************
