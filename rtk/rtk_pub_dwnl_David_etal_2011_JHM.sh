#!/bin/bash
#*******************************************************************************
#rtk_pub_dwnl_David_etal_2011_JHM.sh
#*******************************************************************************

#Purpose:
#This script downloads all the files corresponding to:
#David, Cédric H., David R. Maidment, Guo-Yue Niu, Zong- Liang Yang, Florence 
#Habets and Victor Eijkhout (2011), River network routing on the NHDPlus 
#dataset, Journal of Hydrometeorology, 12(5), 913-934. 
#DOI: 10.1175/2011JHM1345.1 
#These files are available from:
#David, Cédric H., David R. Maidment, Guo-Yue Niu, Zong- Liang Yang, Florence 
#Habets and Victor Eijkhout (2011), RAPID input and output files corresponding 
#to "River Network Routing on the NHDPlus Dataset", Zenodo.
#DOI: 10.5281/zenodo.16565
#The script returns the following exit codes
# - 0  if all downloads are successful 
# - 22 if there was a conversion problem
# - 44 if one download is not successful
#Author:
#Cedric H. David, 2015-2018.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#wget -nv -nc          --> Non-verbose (silent), No-clobber (don't overwrite) 


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Downloading files from:   http://dx.doi.org/10.5281/zenodo.16565"
echo "which correspond to   :   http://dx.doi.org/10.1175/2011JHM1345.1"
echo "These files are under a Creative Commons Attribution (CC BY) license."
echo "Please cite these two DOIs if using these files for your publications."
echo "********************"


#*******************************************************************************
#Location of the dataset
#*******************************************************************************
URL="https://zenodo.org/record/16565/files"


#*******************************************************************************
#Download all input files corresponding to the San Antonio and Guadalupe Basins
#*******************************************************************************
folder="../input/San_Guad_JHM"
list="                                           \
      rapid_connect_San_Guad.csv                 \
      m3_riv_San_Guad_2004_2007_cst.nc           \
      kfac_San_Guad_1km_hour.csv                 \
      kfac_San_Guad_celerity.csv                 \
      k_San_Guad_2004_1.csv                      \
      k_San_Guad_2004_2.csv                      \
      k_San_Guad_2004_3.csv                      \
      k_San_Guad_2004_4.csv                      \
      x_San_Guad_2004_1.csv                      \
      x_San_Guad_2004_2.csv                      \
      x_San_Guad_2004_3.csv                      \
      x_San_Guad_2004_4.csv                      \
      basin_id_San_Guad_hydroseq.csv             \
      gage_id_San_Guad_2004_2007_full.csv        \
      Qobs_San_Guad_2004_2007_full.csv           \
     "

mkdir -p $folder
for file in $list
do
     wget -nv -nc $URL/$file -P $folder
     if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done


#*******************************************************************************
#Download all output files corresponding to the San Antonio and Guadalupe Basins
#*******************************************************************************
folder="../output/San_Guad_JHM"
list="                                           \
      Qout_San_Guad_1460days_p1_dtR900s.nc       \
      Qout_San_Guad_1460days_p2_dtR900s.nc       \
      Qout_San_Guad_1460days_p3_dtR900s.nc       \
      Qout_San_Guad_1460days_p4_dtR900s.nc       \
      QoutR_San_Guad_182days_p1_dtR900s.nc       \
      QoutR_San_Guad_182days_p2_dtR900s.nc       \
      QoutR_San_Guad_182days_p3_dtR900s.nc       \
      QoutR_San_Guad_182days_p4_dtR900s.nc       \
     "

mkdir -p $folder
for file in $list
do
     wget -nv -nc $URL/$file -P $folder
     if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done


#*******************************************************************************
#Download all input files corresponding to the Upper Mississippi Basin
#*******************************************************************************
folder="../input/Reg07_JHM"
list="                                           \
      rapid_connect_Reg07.csv                    \
      m3_riv_Reg07_100days_dummy.nc              \
      kfac_Reg07_2.5ms.csv                       \
      xfac_Reg07_0.3.csv                         \
      basin_id_Reg07_hydroseq.csv                \
     "

mkdir -p $folder
for file in $list
do
     wget -nv -nc $URL/$file -P $folder
     if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done


#*******************************************************************************
#Download all output files corresponding to the Upper Mississippi Basin
#*******************************************************************************
folder="../output/Reg07_JHM"
list="                                           \
      Qout_Reg07_100days_pfac_dtR900s.nc         \
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
