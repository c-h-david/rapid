#!/bin/bash
#*******************************************************************************
#tst_pub_dwnl_Emery_etal_201x_JHM.sh
#*******************************************************************************

#Purpose:
#This script downloads all the files corresponding to:
#Emery, Charlotte M., Cedric H. David, Kostas M. Andreadis, Michael J. Turmon,
#John T. Reager, Jonathan M. Hobbs, Ming Pan, James S. Famiglietti,
#R. Edward Beighley, and Matthew Rodell (201x), Underlying Fundamentals of
#Kalman Filtering for River Network Modeling,
#DOI: xx.xxxx/xxxxxxxxxxxx
#These files are available from:
#Emery, Charlotte M., Cedric H. David, Kostas M. Andreadis, Michael J. Turmon,
#John T. Reager, Jonathan M. Hobbs, Ming Pan, James S. Famiglietti,
#R. Edward Beighley, and Matthew Rodell (201x), RRR/RAPID input and output files
#for "Underlying Fundamentals of Kalman Filtering for River Network Modeling",
#Zenodo.
#DOI: xx.xxxx/xxxxxxxxxxxx
#The script returns the following exit codes
# - 0  if all downloads are successful 
# - 22 if there was a conversion problem
# - 44 if one download is not successful
#Authors:
#Charlotte M. Emery, Cedric H. David, 2017-2019.

#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#wget -nv -nc          --> Non-verbose (silent), No-clobber (don't overwrite) 


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Downloading files from:   http://dx.doi.org/xx.xxxx/xxxxxxxxxxxx"
echo "which correspond to   :   http://dx.doi.org/xx.xxxx/xxxxxxxxxxxx"
echo "These files are under a Creative Commons Attribution (CC BY) license."
echo "Please cite these two DOIs if using these files for your publications."
echo "********************"

#*******************************************************************************
#Location of the dataset
#*******************************************************************************
URL="http://rapid-hub.org/data/CI/San_Guad_JHM2/"


#*******************************************************************************
#Download all input files
#*******************************************************************************
folder="../input/San_Guad_DA_XXX"
list="                                                                \
      rapid_connect_San_Guad.csv                                      \
      m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_err_radius_infinity.nc    \
      k_San_Guad_DA.csv                                               \
      x_San_Guad_DA.csv                                               \
      basin_id_San_Guad_hydroseq.csv                                  \
      obs_tot_id_San_Guad_2010_2013_full.csv                          \
      gage_id_San_Guad_2010_2013_subset.csv                           \
      Qobs_San_Guad_2010_2013_full.csv                                \
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
folder="../output/San_Guad_DA_XXX"
list="                                                                           \
      Qout_San_Guad_Openloop_20100101_20100131.nc                                \
      Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.00_tauTe-03.nc       \
      Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.50_tauT0.nc          \
      Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.50_tauTe-03.nc       \
     "

mkdir -p $folder
for file in $list
do
     wget -nv -nc $URL/$file -P $folder
     if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done

#*******************************************************************************
#Done
#*******************************************************************************
