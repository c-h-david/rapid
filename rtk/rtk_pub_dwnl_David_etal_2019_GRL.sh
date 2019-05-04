#!/bin/bash
#*******************************************************************************
#rtk_pub_dwnl_David_etal_2019_GRL.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RAPID simulations that were used in the writing of:
#David, Cédric H., Jonathan M. Hobbs, Michael J. Turmon, Charlotte M. Emery,
#John T. Reager, and James S. Famiglietti (2019), Analytical Propagation of
#Runoff Uncertainty into Discharge Uncertainty through a Large River Network,
#Geophysical Research Letters.
#DOI: xx.xxxx/xxxxxx
#The files used are available from:
#David, Cédric H., Jonathan M. Hobbs, Michael J. Turmon, Charlotte M. Emery,
#John T. Reager, and James S. Famiglietti (2019), RRR/RAPID input and output
#files corresponding to "Analytical Propagation of Runoff Uncertainty into
#Discharge Uncertainty through a Large River Network", Zenodo.
#DOI: 10.5281/zenodo.2665084
#The script returns the following exit codes
# - 0  if all downloads are successful 
# - 22 if there was a conversion problem
# - 44 if one download is not successful
#Author:
#Cedric H. David, 2015-2019.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#wget -nv -nc          --> Non-verbose (silent), No-clobber (don't overwrite) 


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Downloading files from:   http://dx.doi.org/10.5281/zenodo.2665084"
echo "which correspond to   :   http://dx.doi.org/xx.xxxx/xxxxxx"
echo "These files are under a Creative Commons Attribution (CC BY) license."
echo "Please cite these two DOIs if using these files for your publications."
echo "********************"


#*******************************************************************************
#Location of the dataset
#*******************************************************************************
URL="https://zenodo.org/record/2665084/files"


#*******************************************************************************
#Download all input files
#*******************************************************************************
folder="../input/WSWM_GRL"
list="                                                                         \
      rapid_connect_WSWM.csv                                                   \
      m3_riv_WSWM_19970101_19981231_VIC0125_cst_err.nc                         \
      k_WSWM_ag.csv                                                            \
      x_WSWM_ag.csv                                                            \
      riv_bas_id_WSWM_hydroseq.csv                                             \
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
folder="../output/WSWM_GRL"
list="                                                                         \
      Qout_WSWM_729days_pag_dtR900s_n1_preonly.nc                              \
      Qfinal_WSWM_729days_pag_dtR900s_n1_preonly.nc                            \
      Qout_WSWM_729days_pag_dtR900s_n1_preonly_init_err.nc                     \
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
