#*******************************************************************************
#Dockerfile
#*******************************************************************************

#Purpose:
#This file describes the operating system prerequisites for RAPID, and is used
#by the Docker software.
#Author:
#Cedric H. David, 2018-2019.


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
FROM ubuntu:trusty


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
ENV  TACC_NETCDF_DIR=$INSTALLZ_DIR/netcdf-4.1.3-install
ENV  TACC_NETCDF_LIB=$TACC_NETCDF_DIR/lib
ENV  TACC_NETCDF_INC=$TACC_NETCDF_DIR/include
ENV  LD_LIBRARY_PATH=$TACC_NETCDF_LIB
ENV  PATH=$PATH:$TACC_NETCDF_DIR/bin
#netCDF

ENV  PETSC_DIR=$INSTALLZ_DIR/petsc-3.6.2
ENV  PETSC_ARCH=linux-gcc-c
ENV  PATH=$PATH:$PETSC_DIR/$PETSC_ARCH/bin
#PETSc


#*******************************************************************************
#Build RAPID
#*******************************************************************************
RUN  cd ./src/ && \
     make rapid && \
     cd ../tst/ && \
     gfortran -o tst_run_comp tst_run_comp.f90 -I $TACC_NETCDF_INC -L $TACC_NETCDF_LIB -lnetcdff && \
     gfortran -o tst_run_cerr tst_run_cerr.f90 -I $TACC_NETCDF_INC -L $TACC_NETCDF_LIB -lnetcdff && \
     gfortran -o tst_run_conv_Qinit tst_run_conv_Qinit.f90 -I $TACC_NETCDF_INC -L $TACC_NETCDF_LIB -lnetcdff


#*******************************************************************************
#Intended (default) command at execution of image (not used during build)
#*******************************************************************************
CMD  /bin/bash


#*******************************************************************************
#End
#*******************************************************************************
