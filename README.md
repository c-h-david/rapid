# RAPID
[![DOI](https://zenodo.org/badge/11296/c-h-david/rapid.svg)](https://zenodo.org/badge/latestdoi/11296/c-h-david/rapid)

[![License (3-Clause BSD)](https://img.shields.io/badge/license-BSD%203--Clause-yellow.svg)](https://github.com/c-h-david/rapid/blob/master/LICENSE)

[![Build Status](https://travis-ci.org/c-h-david/rapid.svg?branch=master)](https://travis-ci.org/c-h-david/rapid)

The Routing Application for Parallel computatIon of Discharge (RAPID) is a river
network routing model. Given surface and groundwater inflow to rivers, this 
model can compute flow and volume of water everywhere in river networks made out 
of many thousands of reaches. 

For further information on RAPID including peer-reviewed publications, tutorials, 
sample input/output data, sample processing scripts and animations of model 
results, please go to: 
[http://rapid-hub.org/](http://rapid-hub.org/).

## Installation on Ubuntu
This document was written and tested on a machine with a **clean** image of 
[Ubuntu 14.04.0 Desktop 64-bit](http://old-releases.ubuntu.com/releases/14.04.0/ubuntu-14.04-desktop-amd64.iso)
installed, *i.e.* **no update** was performed, and **no upgrade** either. 

Note that the experienced users may find more up-to-date installation 
instructions in
[.travis.yml](https://github.com/c-h-david/rapid/blob/master/.travis.yml).

### Download RAPID
First, make sure that `git` is installed: 

```
$ sudo apt-get install -y git
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
[requirements.apt](https://github.com/c-h-david/rapid/blob/master/requirements.apt)
and can be installed with `apt-get`. All packages can be installed at once using:

```
$ sudo apt-get install -y $(grep -v -E '(^#|^$)' requirements.apt)
```

> Alternatively, one may install the APT packages listed in 
> [requirements.apt](https://github.com/c-h-david/rapid/blob/master/requirements.apt)
> one by one, for example:
>
> ```
> $ sudo apt-get install -y gfortran
>```

### Install NCL
The NCAR Command Language (NCL) can be downloaded using:

```
$ mkdir $HOME/installz
$ cd $HOME/installz
$ wget "https://www.earthsystemgrid.org/download/fileDownload.html?logicalFileId=8201fa1a-cd9b-11e4-bb80-00c0f03d5b7c" -O ncl_ncarg-6.3.0.Linux_Debian6.0_x86_64_nodap_gcc445.tar.gz
$ mkdir ncl_ncarg-6.3.0-install
$ tar -xf ncl_ncarg-6.3.0.Linux_Debian6.0_x86_64_nodap_gcc445.tar.gz --directory=ncl_ncarg-6.3.0-install
```

Then, the environment should be updated using:

```
$ export NCARG_ROOT=$HOME/installz/ncl_ncarg-6.3.0-install
$ export PATH=$PATH:$NCARG_ROOT/bin
```

> Note that these two lines can also be added in `~/.bash_aliases` so that the 
> environment variables persist.

## Testing on Ubuntu
Testing scripts are currently under development.

Note that the experienced users may find more up-to-date testing instructions 
in
[.travis.yml](https://github.com/c-h-david/rapid/blob/master/.travis.yml).

