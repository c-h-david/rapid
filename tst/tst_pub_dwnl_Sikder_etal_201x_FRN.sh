#!/bin/bash
#*******************************************************************************
#tst_pub_dwnl_Sikder_etal_201x_FRN.sh
#*******************************************************************************

#Purpose:
#This script downloads all the files corresponding to:
#Sikder, M. Safat, et al. (201x)
#xxx
#DOI: xx.xxxx/xxxxxx
#These files are available from:
#Sikder, M. Safat, et al. (201x)
#xxx
#DOI: xx.xxxx/xxxxxx
#The script returns the following exit codes
# - 0  if all downloads are successful 
# - 22 if there was a conversion problem
# - 44 if one download is not successful
#Author:
#Cedric H. David, 2018-2019.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#wget -nv -nc          --> Non-verbose (silent), No-clobber (don't overwrite) 


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Downloading files from:   http://dx.doi.org/xx.xxxx/xxxxxx"
echo "which correspond to   :   http://dx.doi.org/xx.xxxx/xxxxxx"
echo "These files are under a Creative Commons Attribution (CC BY) license."
echo "Please cite these two DOIs if using these files for your publications."
echo "********************"


#*******************************************************************************
#Location of the dataset
#*******************************************************************************
URL="https://zenodo.org/record/xxxxx/files"


#*******************************************************************************
#Download all input files
#*******************************************************************************
folder="../input/MIGBM_GGG"
list="                                           \
     "

mkdir -p $folder
for file in $list
do
     wget -nv -nc $URL/$file -P $folder
     if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done


#*******************************************************************************
#Download all output files
#*******************************************************************************
folder="../output/MIGBM_GGG"
list="                                           \
     "

mkdir -p $folder
for file in $list
do
     wget -nv -nc $URL/$file -P $folder
     if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done


#*******************************************************************************
#Convert legacy files
#*******************************************************************************
#N/A


#*******************************************************************************
#Done
#*******************************************************************************
