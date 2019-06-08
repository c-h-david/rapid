#!/bin/bash
#*******************************************************************************
#rtk_nml_tidy_San_Guad_JHM2.sh
#*******************************************************************************

#Purpose:
#This script resets the namelist of the corresponding publication to default 
#values.
#Authors:
#Charlotte M. Emery, Cedric H. David, 2017-2019.

#*******************************************************************************
#Runtime options 
#*******************************************************************************
sed -i -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.false.|"              \
       -e "s|BS_opt_Qfinal      =.*|BS_opt_Qfinal      =.false.|"              \
       -e "s|BS_opt_V           =.*|BS_opt_V           =.false.|"              \
       -e "s|BS_opt_for         =.*|BS_opt_for         =.false.|"              \
       -e "s|BS_opt_dam         =.*|BS_opt_dam         =.false.|"              \
       -e "s|BS_opt_influence   =.*|BS_opt_influence   =.false.|"              \
       -e "s|BS_opt_uq          =.*|BS_opt_uq          =.false.|"              \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =1|"                    \
       -e "s|IS_opt_run         =.*|IS_opt_run         =1|"                    \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =1|"                    \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Temporal information
#*******************************************************************************
sed -i -e "s|ZS_TauM            =.*|ZS_TauM            =126230400|"            \
       -e "s|ZS_dtM             =.*|ZS_dtM             =86400|"                \
       -e "s|ZS_TauO            =.*|ZS_TauO            =0|"                    \
       -e "s|ZS_dtO             =.*|ZS_dtO             =0|"                    \
       -e "s|ZS_TauR            =.*|ZS_TauR            =10800|"                \
       -e "s|ZS_dtR             =.*|ZS_dtR             =900|"                  \
       -e "s|ZS_dtF             =.*|ZS_dtF             =0|"                    \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Domain in which input data is available
#*******************************************************************************
sed -i -e "s|IS_riv_tot         =.*|IS_riv_tot         =5175|"                 \
       -e "s|rapid_connect_file =.*|rapid_connect_file ='../../rapid/input/San_Guad_JHM2/rapid_connect_San_Guad.csv'|" \
       -e "s|IS_max_up          =.*|IS_max_up          =4|"                    \
       -e "s|Vlat_file          =.*|Vlat_file          ='../../rapid/input/San_Guad_JHM2/m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_R286_err_D.nc'|" \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Domain in which model runs
#*******************************************************************************
sed -i -e "s|IS_riv_bas         =.*|IS_riv_bas         =5175|"                 \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='../../rapid/input/San_Guad_JHM2/riv_bas_id_San_Guad_hydroseq.csv'|" \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Initialization
#*******************************************************************************
sed -i -e "s|Qinit_file         =.*|Qinit_file         =''|"                   \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Available dam data
#*******************************************************************************
sed -i -e "s|IS_dam_tot         =.*|IS_dam_tot         =0|"                    \
       -e "s|dam_tot_id_file    =.*|dam_tot_id_file    =''|"                   \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Dam data used
#*******************************************************************************
sed -i -e "s|IS_dam_use         =.*|IS_dam_use         =0|"                    \
       -e "s|dam_use_id_file    =.*|dam_use_id_file    =''|"                   \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Available forcing data
#*******************************************************************************
sed -i -e "s|IS_for_tot         =.*|IS_for_tot         =0|"                    \
       -e "s|for_tot_id_file    =.*|for_tot_id_file    =''|"                   \
       -e "s|Qfor_file          =.*|Qfor_file          =''|"                   \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Forcing data used
#*******************************************************************************
sed -i -e "s|IS_for_use         =.*|IS_for_use         =0|"                    \
       -e "s|for_use_id_file    =.*|for_use_id_file    =''|"                   \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#File where max (min) of absolute values of b (QoutR) are stored
#*******************************************************************************
sed -i -e "s|babsmax_file       =.*|babsmax_file       =''|"                   \
       -e "s|QoutRabsmin_file   =.*|QoutRabsmin_file   =''|"                   \
       -e "s|QoutRabsmax_file   =.*|QoutRabsmax_file   =''|"                   \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Uncertainty quantification
#*******************************************************************************
sed -i -e "s|ZS_dtUQ            =.*|ZS_dtUQ            =86400.0|"              \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Muskingum operator and data assimilation
#*******************************************************************************
sed -i -e "s|ZS_inflation       =.*|ZS_inflation       =2.58|"                 \
       -e "s|ZS_threshold       =.*|ZS_threshold       =0.0|"                  \
       -e "s|IS_radius          =.*|IS_radius          =20|"                   \
       -e "s|ZS_stdobs          =.*|ZS_stdobs          =0.1|"                  \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Regular model run
#*******************************************************************************
sed -i -e "s|k_file             =.*|k_file             ='../../rapid/input/San_Guad_JHM2/k_San_Guad_2004_1.csv'|" \
       -e "s|x_file             =.*|x_file             ='../../rapid/input/San_Guad_JHM2/x_San_Guad_2004_1.csv'|" \
       -e "s|Qout_file          =.*|Qout_file          ='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_nx_method.nc'|" \
       -e "s|V_file             =.*|V_file             =''|"                   \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#Optimization
#*******************************************************************************
sed -i -e "s|ZS_phifac          =.*|ZS_phifac          =0.001|"                \
          rapid_namelist_San_Guad_JHM2
#-------------------------------------------------------------------------------
#Routing parameters
#-------------------------------------------------------------------------------
sed -i -e "s|kfac_file          =.*|kfac_file          =''|" \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =2|"                    \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =3|"                    \
          rapid_namelist_San_Guad_JHM2

#-------------------------------------------------------------------------------
#Gage observations
#-------------------------------------------------------------------------------
sed -i -e "s|IS_obs_tot         =.*|IS_obs_tot         =36|"                   \
       -e "s|obs_tot_id_file    =.*|obs_tot_id_file    ='../../rapid/input/San_Guad_JHM2/obs_tot_id_San_Guad_2010_2013_full.csv'|" \
       -e "s|Qobs_file          =.*|Qobs_file          ='../../rapid/input/San_Guad_JHM2/Qobs_San_Guad_2010_2013_full.csv'|" \
       -e "s|Qobsbarrec_file    =.*|Qobsbarrec_file    =''|"                   \
       -e "s|IS_obs_use         =.*|IS_obs_use         =23|"                   \
       -e "s|obs_use_id_file    =.*|obs_use_id_file    ='../../rapid/input/San_Guad_JHM2/obs_use_id_San_Guad_2010_2013_23.csv'|" \
       -e "s|IS_strt_opt        =.*|IS_strt_opt        =1|"                    \
          rapid_namelist_San_Guad_JHM2

#*******************************************************************************
#End name list
#*******************************************************************************
