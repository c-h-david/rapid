#!/bin/bash
#*******************************************************************************
#rtk_pub_dwnl_David_etal_2015_WRR.sh
#*******************************************************************************

#Purpose:
#This script downloads all the files corresponding to:
#David, Cédric H., James S. Famiglietti, Zong-Liang Yang, and Victor Eijkhout 
#(2015), Enhanced fixed-size parallel speedup with the Muskingum method using a 
#trans-boundary approach and a large sub-basins approximation, Water Resources 
#Research, 51(9), 1-25, 
#DOI: 10.1002/2014WR016650.
#These files are available from:
#David, Cédric H., James S. Famiglietti, Zong-Liang Yang, and Victor Eijkhout 
#(2015), 
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
echo "which correspond to   :   http://dx.doi.org/10.1002/2014WR016650"
echo "These files are under a Creative Commons Attribution (CC BY) license."
echo "Please cite these four DOIs if using these files for your publications."
echo "********************"


#*******************************************************************************
#Location of the dataset
#*******************************************************************************
URL="http://rapid-hub.org/data/CI/HSmsp_WRR"


#*******************************************************************************
#Download all input files
#*******************************************************************************
folder="../input/HSmsp_WRR"
list="                                                                         \
      k_HSmsp_pa_guess.csv                                                     \
      k_HSmsp_pa_phi1_2008_0.csv                                               \
      k_HSmsp_pa_phi1_2008_1.csv                                               \
      kfac_HSmsp_1km_hour.csv                                                  \
      m3_riv_HSmsp_2000_2009_cst_VIC_NASA.nc                                   \
      obs_tot_id_HSmsp_2000_2009.csv                                           \
      Qobs_HSmsp_2000_2009.csv                                                 \
      rapid_connect_HSmsp.csv                                                  \
      riv_bas_id_HSmsp_topo.csv                                                \
      x_HSmsp_pa_guess.csv                                                     \
      x_HSmsp_pa_phi1_2008_0.csv                                               \
      x_HSmsp_pa_phi1_2008_1.csv                                               \
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
list="                                                                         \
     Qout_HSmsp_2000_2009_VIC_NASA_sgl_pa_guess_n1_preonly_ilu.nc              \
     Qout_HSmsp_2000_2009_VIC_NASA_sgl_pa_phi1_2008_0_n1_preonly_ilu.nc        \
     Qout_HSmsp_2000_2009_VIC_NASA_sgl_pa_phi1_2008_1_n1_preonly_ilu.nc        \
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
