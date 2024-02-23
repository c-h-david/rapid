#*******************************************************************************
#Dockerfile
#*******************************************************************************

#Purpose:
#This file describes the operating system prerequisites for RAPID, and is used
#by the Docker software.
#Author:
#Cedric H. David, 2018-2023.


#*******************************************************************************
#Usage
#*******************************************************************************
#docker build -t ubuntu:rapid -f Dockerfile .            #Create image
#docker run --rm --name ubuntu_rapid -it ubuntu:rapid    #Run image in container
#docker save -o ubuntu_rapid.tar ubuntu:rapid            #Save a copy of image
#docker load -i ubuntu_rapid.tar                         #Load a saved image


#*******************************************************************************
#Operating System
#*******************************************************************************
FROM debian:11.7-slim


#*******************************************************************************
#Copy files into Docker image (this ignores the files listed in .dockerignore)
#*******************************************************************************
WORKDIR /home/rapid/
COPY . . 


#*******************************************************************************
#Operating System Requirements
#*******************************************************************************
RUN  apt-get update && \
     apt-get install -y --no-install-recommends $(grep -v -E '(^#|^$)' requirements.apt) && \
     rm -rf /var/lib/apt/lists/*


#*******************************************************************************
#Other Software Requirements
#*******************************************************************************

#-------------------------------------------------------------------------------
#Install other software
#-------------------------------------------------------------------------------
ENV  INSTALLZ_DIR=/home/installz
#Directory where software is installed

RUN  mkdir $INSTALLZ_DIR && \
     ./rapid_install_prereqs.sh -i=$INSTALLZ_DIR

#-------------------------------------------------------------------------------
#Update environment (ENV variables are available in Docker images & containers)
#-------------------------------------------------------------------------------
ENV  NETCDF_LIB='-L /usr/lib -lnetcdff'
ENV  NETCDF_INCLUDE='-I /usr/include'
#netCDF

ENV  PETSC_DIR=$INSTALLZ_DIR/petsc-3.13.6
ENV  PETSC_ARCH=linux-gcc-c
ENV  PATH=$PATH:$PETSC_DIR/$PETSC_ARCH/bin
#PETSc


#*******************************************************************************
#Build RAPID
#*******************************************************************************
RUN  cd ./src/ && \
     make rapid && \
     cd ../tst/ && \
     gfortran -o tst_run_comp tst_run_comp.f90 $NETCDF_INCLUDE $NETCDF_LIB && \
     gfortran -o tst_run_cerr tst_run_cerr.f90 $NETCDF_INCLUDE $NETCDF_LIB && \
     gfortran -o tst_run_conv_Qinit tst_run_conv_Qinit.f90 $NETCDF_INCLUDE $NETCDF_LIB


#*******************************************************************************
#Intended (default) command at execution of image (not used during build)
#*******************************************************************************
CMD  /bin/bash


#*******************************************************************************
#End
#*******************************************************************************
