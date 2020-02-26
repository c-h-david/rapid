#!/bin/bash
#*******************************************************************************
#tst_pub_dwnl_Emery_etal_201x_JHM2.sh
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
#Charlotte M. Emery, Cedric H. David, 2017-2020.

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
URL="http://rapid-hub.org/data/CI/San_Guad_JHM2"


#*******************************************************************************
#Download all input files
#*******************************************************************************
folder="../input/San_Guad_JHM2"
list="                                                                         \
      k_San_Guad_2004_1.csv                                                    \
      m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_R286_err_D_scl.nc                  \
      m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_R286_err_D.nc                      \
      m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_R286_err_M.nc                      \
      obs_tot_id_San_Guad_2010_2013_full.csv                                   \
      obs_use_id_San_Guad_2010_2013_23.csv                                     \
      Qobs_San_Guad_2010_2013_full.csv                                         \
      rapid_connect_San_Guad.csv                                               \
      riv_bas_id_San_Guad_hydroseq.csv                                         \
      x_San_Guad_2004_1.csv                                                    \
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
folder="../output/San_Guad_JHM2"
list="                                                                         \
      Qout_San_Guad_exp00_err_D_scl.nc                                         \
      Qout_San_Guad_exp00_err_D.nc                                             \
      Qout_San_Guad_exp00_err_M.nc                                             \
      Qout_San_Guad_exp00.nc                                                   \
      Qout_San_Guad_exp01.nc                                                   \
      Qout_San_Guad_exp02.nc                                                   \
      Qout_San_Guad_exp03.nc                                                   \
      Qout_San_Guad_exp04.nc                                                   \
      Qout_San_Guad_exp05.nc                                                   \
      Qout_San_Guad_exp06.nc                                                   \
      Qout_San_Guad_exp07.nc                                                   \
      Qout_San_Guad_exp08.nc                                                   \
      Qout_San_Guad_exp09.nc                                                   \
      Qout_San_Guad_exp10.nc                                                   \
      Qout_San_Guad_exp11.nc                                                   \
      Qout_San_Guad_exp12.nc                                                   \
      Qout_San_Guad_exp13.nc                                                   \
      Qout_San_Guad_exp14.nc                                                   \
      Qout_San_Guad_exp15.nc                                                   \
      Qout_San_Guad_exp16.nc                                                   \
      Qout_San_Guad_exp17.nc                                                   \
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
