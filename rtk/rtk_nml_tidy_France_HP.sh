#!/bin/bash
#*******************************************************************************
#rtk_nml_tidy_France_HP.sh
#*******************************************************************************

#Purpose:
#This script resets the namelist of the corresponding publication to default 
#values.
#Author:
#Cedric H. David, 2015-2018.


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
          rapid_namelist_France_HP  

#*******************************************************************************
#Temporal information
#*******************************************************************************
sed -i -e "s|ZS_TauM            =.*|ZS_TauM            =315619200|"             \
       -e "s|ZS_dtM             =.*|ZS_dtM             =86400|"                 \
       -e "s|ZS_TauO            =.*|ZS_TauO            =13132800|"              \
       -e "s|ZS_dtO             =.*|ZS_dtO             =86400|"                 \
       -e "s|ZS_TauR            =.*|ZS_TauR            =10800|"                 \
       -e "s|ZS_dtR             =.*|ZS_dtR             =1800|"                  \
       -e "s|ZS_dtF             =.*|ZS_dtF             =86400|"                 \
          rapid_namelist_France_HP  

#*******************************************************************************
#Domain in which input data is available
#*******************************************************************************
sed -i -e "s|IS_riv_tot         =.*|IS_riv_tot         =24264|"                \
       -e "s|rapid_connect_file =.*|rapid_connect_file ='../../rapid/input/France_HP/rapid_connect_France.csv'|" \
       -e "s|IS_max_up          =.*|IS_max_up          =4|"                    \
       -e "s|Vlat_file          =.*|Vlat_file          ='../../rapid/input/France_HP/m3_riv_France_1995_2005_ksat_201101_c_zvol_ext.nc'|" \
          rapid_namelist_France_HP  

#*******************************************************************************
#Domain in which model runs
#*******************************************************************************
sed -i -e "s|IS_riv_bas         =.*|IS_riv_bas         =24264|"                \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='../../rapid/input/France_HP/rivsurf_France.csv'|"\
          rapid_namelist_France_HP  

#*******************************************************************************
#Initialization
#*******************************************************************************
sed -i -e "s|Qinit_file         =.*|Qinit_file         ='../../rapid/input/France_HP/Qinit_93.nc'|" \
          rapid_namelist_France_HP  

#*******************************************************************************
#Available dam data
#*******************************************************************************
sed -i -e "s|IS_dam_tot         =.*|IS_dam_tot         =0|"                    \
       -e "s|dam_tot_id_file    =.*|dam_tot_id_file    =''|"                   \
          rapid_namelist_France_HP

#*******************************************************************************
#Dam data used
#*******************************************************************************
sed -i -e "s|IS_dam_use         =.*|IS_dam_use         =0|"                    \
       -e "s|dam_use_id_file    =.*|dam_use_id_file    =''|"                   \
          rapid_namelist_France_HP

#*******************************************************************************
#Available forcing data
#*******************************************************************************
sed -i -e "s|IS_for_tot         =.*|IS_for_tot         =493|"                  \
       -e "s|for_tot_id_file    =.*|for_tot_id_file    ='../../rapid/input/France_HP/forcingtot_id_1995_1996_full.csv'|" \
       -e "s|Qfor_file          =.*|Qfor_file          ='../../rapid/input/France_HP/Qfor_1995_1996_full.csv'|" \
          rapid_namelist_France_HP  

#*******************************************************************************
#Forcing data used as model runs
#*******************************************************************************
sed -i -e "s|IS_for_use         =.*|IS_for_use         =1|" \
       -e "s|for_use_id_file    =.*|for_use_id_file    ='../../rapid/input/France_HP/forcinguse_id_rhone_pougny.csv'|" \
          rapid_namelist_France_HP  

#*******************************************************************************
#File where max (min) of absolute values of b (QoutR) are stored
#*******************************************************************************
sed -i -e "s|babsmax_file       =.*|babsmax_file       =''|"                   \
       -e "s|QoutRabsmin_file   =.*|QoutRabsmin_file   =''|"                   \
       -e "s|QoutRabsmax_file   =.*|QoutRabsmax_file   =''|"                   \
          rapid_namelist_France_HP  

#*******************************************************************************
#Uncertainty quantification
#*******************************************************************************
sed -i -e "s|ZS_alpha_uq        =.*|ZS_alpha_uq        =0.5|"                  \
          rapid_namelist_France_HP  

#*******************************************************************************
#Muskingum operator and data assimilation
#*******************************************************************************
sed -i -e "s|ZS_threshold       =.*|ZS_threshold       =0.0|"                  \
          rapid_namelist_France_HP  

#*******************************************************************************
#Regular model run
#*******************************************************************************
sed -i -e "s|k_file             =.*|k_file             ='../../rapid/input/France_HP/k_modcou_b.csv'|" \
       -e "s|x_file             =.*|x_file             ='../../rapid/input/France_HP/x_modcou_b.csv'|" \
       -e "s|Qout_file          =.*|Qout_file          ='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_pb_dtR1800s_nx_method.nc'|" \
       -e "s|V_file             =.*|V_file             =''|"                   \
          rapid_namelist_France_HP  

#*******************************************************************************
#Optimization
#*******************************************************************************
sed -i -e "s|ZS_phifac          =.*|ZS_phifac          =0.001|"                \
          rapid_namelist_France_HP  
#-------------------------------------------------------------------------------
#Routing parameters
#-------------------------------------------------------------------------------
sed -i -e "s|kfac_file          =.*|kfac_file          ='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'|" \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =2|"                    \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =3|"                    \
          rapid_namelist_France_HP  

#-------------------------------------------------------------------------------
#Gage observations
#-------------------------------------------------------------------------------
sed -i -e "s|IS_obs_tot         =.*|IS_obs_tot         =291|"                  \
       -e "s|obs_tot_id_file    =.*|obs_tot_id_file    ='../../rapid/input/France_HP/gage_id_1995_1996_full_nash.csv'|" \
       -e "s|Qobs_file          =.*|Qobs_file          ='../../rapid/input/France_HP/Qobs_1995_1996_full_nash_93.csv'|" \
       -e "s|Qobsbarrec_file    =.*|Qobsbarrec_file    ='../../rapid/input/France_HP/Qobsbarrec_1995_1996_full_nash.csv'|" \
       -e "s|IS_obs_use         =.*|IS_obs_use         =291|"                  \
       -e "s|obs_use_id_file    =.*|obs_use_id_file    ='../../rapid/input/France_HP/gage_id_1995_1996_full_nash.csv'|" \
       -e "s|IS_strt_opt        =.*|IS_strt_opt        =737|"                  \
          rapid_namelist_France_HP  

#*******************************************************************************
#End name list
#*******************************************************************************
