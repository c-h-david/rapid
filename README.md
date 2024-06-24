# RAPID
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.593867.svg)](https://doi.org/10.5281/zenodo.593867)

[![License (3-Clause BSD)](https://img.shields.io/badge/license-BSD%203--Clause-yellow.svg)](https://github.com/c-h-david/rapid/blob/main/LICENSE)

[![Docker Images](https://img.shields.io/badge/docker-images-blue?logo=docker)](https://hub.docker.com/r/chdavid/rapid/tags)

[![GitHub CI Status](https://github.com/c-h-david/rapid/actions/workflows/github_actions_CI.yml/badge.svg)](https://github.com/c-h-david/rapid/actions/workflows/github_actions_CI.yml)

[![GitHub CD Status](https://github.com/c-h-david/rapid/actions/workflows/github_actions_CD.yml/badge.svg)](https://github.com/c-h-david/rapid/actions/workflows/github_actions_CD.yml)

The Routing Application for Parallel computatIon of Discharge (RAPID) is a river
network routing model. Given surface and groundwater inflow to rivers, this 
model can compute flow and volume of water everywhere in river networks made out 
of many thousands of reaches. 

For further information on RAPID including peer-reviewed publications, tutorials, 
sample input/output data, sample processing scripts and animations of model 
results, please go to: 
[http://rapid-hub.org/](http://rapid-hub.org/).

## Installation with Docker
Installing RAPID is **by far the easiest with Docker**. This document was
written and tested using
[Docker Community Edition](https://www.docker.com/community-edition#/download)
which is available for free and can be installed on a wide variety of operating
systems. To install it, follow the instructions in the link provided above.

Note that the experienced users may find more up-to-date installation
instructions in
[Dockerfile](https://github.com/c-h-david/rapid/blob/main/Dockerfile).

### Download RAPID
Downloading RAPID with Docker can be done using:

```
$ docker pull chdavid/rapid
```

> The images for RAPID on Docker Hub support CPU architectures for both AMD64
> and ARM64!

### Install packages
The beauty of Docker is that there is **no need to install anymore packages**.
RAPID is ready to go! To run it, just use:

```
$ docker run --rm --name rapid -it chdavid/rapid
```

## Testing with Docker
Testing scripts are currently under development.

Note that the experienced users may find more up-to-date testing instructions
in
[docker.test.yml](https://github.com/c-h-david/rapid/blob/main/docker.test.yml).

## Installation on Debian
This document was written and tested on a machine with a **clean** image of 
[Debian 11.7.0 ARM64](https://cdimage.debian.org/cdimage/archive/11.7.0/arm64/iso-cd/debian-11.7.0-arm64-netinst.iso)
installed, *i.e.* **no update** was performed, and **no upgrade** either. 
Similar steps **may** be applicable for Ubuntu.

Note that the experienced users may find more up-to-date installation 
instructions in
[github\_actions\_CI.yml](https://github.com/c-h-david/rapid/blob/main/.github/workflows/github_actions_CI.yml).

### Download RAPID
First, make sure that `git` is installed: 

```
$ sudo apt-get install -y --no-install-recommends git
```

Then download RAPID:

```
$ git clone https://github.com/c-h-david/rapid
```

Finally, enter the rapid directory:

```
$ cd rapid/
```

### Install APT packages
Software packages for the Advanced Packaging Tool (APT) are summarized in 
[requirements.apt](https://github.com/c-h-david/rapid/blob/main/requirements.apt)
and can be installed with `apt-get`. All packages can be installed at once using:

```
$ sudo apt-get install -y --no-install-recommends $(grep -v -E '(^#|^$)' requirements.apt)
```

> Alternatively, one may install the APT packages listed in 
> [requirements.apt](https://github.com/c-h-david/rapid/blob/main/requirements.apt)
> one by one, for example:
>
> ```
> $ sudo apt-get install -y --no-install-recommends gfortran
>```

### Install netCDF
The Network Common Data Form (NetCDF) was already installed with `apt-get`.

However, the environment should be updated using:

```
$ export NETCDF_LIB='-L /usr/lib -lnetcdff'
$ export NETCDF_INCLUDE='-I /usr/include'
```

> Note that these four lines can also be added in `~/.bash_aliases` so that the 
> environment variables persist.

### Install PETSc
The Portable, Extensible Toolkit for Scientific Computation (PETSc)
can be installed using:

```
$ mkdir $HOME/installz
$ cd $HOME/installz
$ wget "https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.13.6.tar.gz"
$ tar -xzf petsc-3.13.6.tar.gz
$ cd petsc-3.13.6
$ python3 ./configure PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c --download-fblaslapack=1 --download-mpich=1 --with-cc=gcc --with-fc=gfortran --with-clanguage=c --with-debugging=0
$ make PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c all > all.log
$ make PETSC_DIR=$PWD PETSC_ARCH=linux-gcc-c check > check.log
```

> Note that the following can be used as a replacement for the above code block:
>
> ```
> $ mkdir $HOME/installz
> $ ./rapid_install_prereqs.sh --installz=$HOME/installz
> ```

Then, the environment should be updated using:

```
$ export PETSC_DIR=$HOME/installz/petsc-3.13.6
$ export PETSC_ARCH=linux-gcc-c
$ export PATH=$PATH:$PETSC_DIR/$PETSC_ARCH/bin
```

> Note that these three lines can also be added in `~/.bash_aliases` so that the 
> environment variables persist.
> 

### Build RAPID

```
$ cd rapid/
$ cd src/
$ make rapid
```

## Testing on Debian
Testing scripts are currently under development.

```
$ cd rapid/
$ cd tst/
$ gfortran -o tst_run_comp tst_run_comp.f90 $NETCDF_INCLUDE $NETCDF_LIB
$ gfortran -o tst_run_cerr tst_run_cerr.f90 $NETCDF_INCLUDE $NETCDF_LIB
$ gfortran -o tst_run_conv_Qinit tst_run_conv_Qinit.f90 $NETCDF_INCLUDE $NETCDF_LIB
```

Note that the experienced users may find more up-to-date testing instructions 
in
[github\_actions\_CI.yml](https://github.com/c-h-david/rapid/blob/main/.github/workflows/github_actions_CI.yml).
