#!/bin/bash
#*******************************************************************************
#rtk_pub_dwnl_David_etal_2011_HP.sh
#*******************************************************************************

#Purpose:
#This script downloads all the files corresponding to:
#David, Cédric H., Florence Habets, David R. Maidment and Zong- Liang Yang 
#(2011), RAPID applied to the SIM-France model, Hydrological Processes, 25, 
#3412-3425.
#DOI: 10.1002/hyp.8070
#These files are available from:
#David, Cédric H., Florence Habets, David R. Maidment and Zong- Liang Yang 
#(2011), RAPID input and output files correspondong to "RAPID applied to the 
#SIM-France model", Zenodo. 
#DOI: 10.5281/zenodo.30228
#The script returns the following exit codes
# - 0  if all downloads are successful 
# - 44 if one download is not successful
#Author:
#Cedric H. David, 2015


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#wget -nv -nc          --> Non-verbose (silent), No-clobber (don't overwrite) 


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Downloading files from:   http://dx.doi.org/10.5281/zenodo.30228"
echo "which correspond to   :   http://dx.doi.org/10.1002/hyp.8070"
echo "These files are under a Creative Commons Attribution (CC BY) license."
echo "Please cite these two DOIs if using these files for your publications."
echo "********************"


#*******************************************************************************
#Command line option
#*******************************************************************************
if [ "$#" -gt "1" ]; then
     echo "A maximum of one argument can be given" 1>&2
     exit 22
fi
#Make sure a maximum of one command land line option was given

if [ "$#" -eq "1" ]; then
     if [ "$1" == "sim1" ] || [ "$1" == "sim2" ] || [ "$1" == "sim3" ] ||      \
        [ "$1" == "sim4" ] || [ "$1" == "sim5" ] || [ "$1" == "sim6" ] ||      \
        [ "$1" == "sim7" ] || [ "$1" == "sim8" ] || [ "$1" == "sim9" ] ||      \
        [ "$1" == "sim10" ] || [ "$1" == "opt" ]; then 
          dwnl=$1
     else
          echo "The option $1 does not exist" 1>&2
          exit 22
     fi
fi
#Make sure the command line option given exists


#*******************************************************************************
#Location of the dataset
#*******************************************************************************
URL="https://zenodo.org/record/30228/files"


#*******************************************************************************
#Download all input files
#*******************************************************************************
folder="../input/France_HP"
list="                                                           \
      Qfor_1995_1996_full.csv                                    \
      Qfor_1995_1996_full_93.csv                                 \
      Qinit_93.csv                                               \
      Qobs_1995_1996_full.csv                                    \
      Qobs_1995_1996_full_nash.csv                               \
      Qobs_1995_1996_full_nash_93.csv                            \
      Qobs_1995_2005_70.csv                                      \
      Qobsbarrec_1995_1996_full_nash.csv                         \
      forcingtot_id_1995_1996_full.csv                           \
      forcinguse_id_garonne_reste.csv                            \
      forcinguse_id_loire_reste.csv                              \
      forcinguse_id_rhone_pougny.csv                             \
      forcinguse_id_rhone_reste.csv                              \
      forcinguse_id_seine_reste.csv                              \
      gage_id_1995_1996_full.csv                                 \
      gage_id_1995_1996_full_nash.csv                            \
      gage_id_1995_2005_70.csv                                   \
      k_modcou_0.csv                                             \
      k_modcou_1.csv                                             \
      k_modcou_2.csv                                             \
      k_modcou_3.csv                                             \
      k_modcou_4.csv                                             \
      k_modcou_a.csv                                             \
      k_modcou_b.csv                                             \
      k_modcou_c.csv                                             \
      kfac_modcou_1km_hour.csv                                   \
      kfac_modcou_ttra_length.csv                                \
      m3_riv_France_1995_2005_ksat_201101_c_zvol_ext.nc          \
      rapid_connect_France.csv                                   \
      rivsurf_France.csv                                         \
      rivsurf_adour.csv                                          \
      rivsurf_allier.csv                                         \
      rivsurf_ardeche.csv                                        \
      rivsurf_dordogne.csv                                       \
      rivsurf_garonneariege.csv                                  \
      rivsurf_garonne.csv                                        \
      rivsurf_garonne_reste.csv                                  \
      rivsurf_herault.csv                                        \
      rivsurf_loir.csv                                           \
      rivsurf_loire_amont_nevers.csv                             \
      rivsurf_loire_reste.csv                                    \
      rivsurf_loire.csv                                          \
      rivsurf_lot.csv                                            \
      rivsurf_meuse.csv                                          \
      rivsurf_oise.csv                                           \
      rivsurf_rhone_reste.csv                                    \
      rivsurf_rhone_suisse.csv                                   \
      rivsurf_rhone.csv                                          \
      rivsurf_saone.csv                                          \
      rivsurf_seine_amont.csv                                    \
      rivsurf_seine_reste.csv                                    \
      rivsurf_seine.csv                                          \
      rivsurf_tarn.csv                                           \
      rivsurf_vienne.csv                                         \
      x_modcou_0.csv                                             \
      x_modcou_1.csv                                             \
      x_modcou_2.csv                                             \
      x_modcou_3.csv                                             \
      x_modcou_4.csv                                             \
      x_modcou_a.csv                                             \
      x_modcou_b.csv                                             \
      x_modcou_c.csv                                             \
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
folder="../output/France_HP"
list=""
if [ "$dwnl" == "sim1" ] || [ "$dwnl" == "" ]; then
     list=$list"Qout_France_201101_c_zvol_ext_3653days_p1_dtR1800s.nc "
fi
if [ "$dwnl" == "sim2" ] || [ "$dwnl" == "" ]; then
     list=$list$list"Qout_France_201101_c_zvol_ext_3653days_p2_dtR1800s.nc "
fi
if [ "$dwnl" == "sim3" ] || [ "$dwnl" == "" ]; then
     list=$list"Qout_France_201101_c_zvol_ext_3653days_p3_dtR1800s.nc "
fi
if [ "$dwnl" == "sim4" ] || [ "$dwnl" == "" ]; then
     list=$list"Qout_France_201101_c_zvol_ext_3653days_p4_dtR1800s.nc "
fi
if [ "$dwnl" == "sim5" ] || [ "$dwnl" == "" ]; then
     list=$list"Qout_France_201101_c_zvol_ext_3653days_pa_dtR1800s.nc "
fi
if [ "$dwnl" == "sim6" ] || [ "$dwnl" == "" ]; then
     list=$list"Qout_France_201101_c_zvol_ext_3653days_pb_dtR1800s.nc "
fi
if [ "$dwnl" == "sim7" ] || [ "$dwnl" == "" ]; then
     list=$list"Qout_France_201101_c_zvol_ext_3653days_pc_dtR1800s.nc "
fi
if [ "$dwnl" == "sim8" ] || [ "$dwnl" == "" ]; then
     list=$list"Qout_France_201101_c_zvol_ext_366days_p0_dtR1800s.nc "
fi
if [ "$dwnl" == "sim9" ] || [ "$dwnl" == "" ]; then
     list=$list"Qout_France_201101_c_zvol_ext_366days_pb_dtR1800s.nc "
fi
if [ "$dwnl" == "sim10" ] || [ "$dwnl" == "" ]; then
     list=$list"Qout_France_201101_c_zvol_ext_366days_pb_dtR1800s_pougny.nc "
fi

mkdir -p $folder
for file in $list
do
     wget -nv -nc $URL/$file -P $folder
     if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done


#*******************************************************************************
#Done
#*******************************************************************************
