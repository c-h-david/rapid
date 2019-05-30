#!/bin/bash
#*******************************************************************************
#rtk_nml_tidy_HSmsp_WRR.sh
#*******************************************************************************

#Purpose:
#This script resets the namelist of the corresponding publication to default 
#values.
#Author:
#Cedric H. David, 2015-2019.


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
          rapid_namelist_HSmsp_WRR

#*******************************************************************************
#Temporal information
#*******************************************************************************
sed -i -e "s|ZS_TauM            =.*|ZS_TauM            =315532800|"            \
       -e "s|ZS_dtM             =.*|ZS_dtM             =86400|"                \
       -e "s|ZS_TauO            =.*|ZS_TauO            =31622400|"             \
       -e "s|ZS_dtO             =.*|ZS_dtO             =86400|"                \
       -e "s|ZS_TauR            =.*|ZS_TauR            =10800|"                \
       -e "s|ZS_dtR             =.*|ZS_dtR             =1800|"                 \
       -e "s|ZS_dtF             =.*|ZS_dtF             =86400|"                \
          rapid_namelist_HSmsp_WRR

#*******************************************************************************
#Domain in which input data is available
#*******************************************************************************
sed -i -e "s|IS_riv_tot         =.*|IS_riv_tot         =102229|"               \
       -e "s|rapid_connect_file =.*|rapid_connect_file ='../../rapid/input/HSmsp_WRR/rapid_connect_HSmsp.csv'|" \
       -e "s|IS_max_up          =.*|IS_max_up          =4|"                    \
       -e "s|Vlat_file          =.*|Vlat_file          ='../../rapid/input/HSmsp_WRR/m3_riv_HSmsp_2000_2009_cst_VIC_NASA.nc'|" \
          rapid_namelist_HSmsp_WRR

#*******************************************************************************
#Domain in which model runs
#*******************************************************************************
sed -i -e "s|IS_riv_bas         =.*|IS_riv_bas         =102229|"               \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='../../rapid/input/HSmsp_WRR/riv_bas_id_HSmsp_topo.csv'|" \
          rapid_namelist_HSmsp_WRR

#*******************************************************************************
#Initialization
#*******************************************************************************
sed -i -e "s|Qinit_file         =.*|Qinit_file         =''|"                   \
          rapid_namelist_HSmsp_WRR

#*******************************************************************************
#Available dam data
#*******************************************************************************
sed -i -e "s|IS_dam_tot         =.*|IS_dam_tot         =0|"                    \
       -e "s|dam_tot_id_file    =.*|dam_tot_id_file    =''|"                   \
          rapid_namelist_HSmsp_WRR

#*******************************************************************************
#Dam data used
#*******************************************************************************
sed -i -e "s|IS_dam_use         =.*|IS_dam_use         =0|"                    \
       -e "s|dam_use_id_file    =.*|dam_use_id_file    =''|"                   \
          rapid_namelist_HSmsp_WRR

#*******************************************************************************
#Available forcing data
#*******************************************************************************
sed -i -e "s|IS_for_tot         =.*|IS_for_tot         =0|"                    \
       -e "s|for_tot_id_file    =.*|for_tot_id_file    =''|"                   \
       -e "s|Qfor_file          =.*|Qfor_file          =''|"                   \
          rapid_namelist_HSmsp_WRR

#*******************************************************************************
#Forcing data used
#*******************************************************************************
sed -i -e "s|IS_for_use         =.*|IS_for_use         =0|"                    \
       -e "s|for_use_id_file    =.*|for_use_id_file    =''|"                   \
          rapid_namelist_HSmsp_WRR  

#*******************************************************************************
#File where max (min) of absolute values of b (QoutR) are stored
#*******************************************************************************
sed -i -e "s|babsmax_file       =.*|babsmax_file       ='../../rapid/output/HSmsp_WRR/babsmax_HSmsp_2000_2009_VIC_NASA_pa_phi1_2008_1.csv'|" \
       -e "s|QoutRabsmin_file   =.*|QoutRabsmin_file   ='../../rapid/output/HSmsp_WRR/QoutRabsmin_HSmsp_2000_2009_VIC_NASA_pa_phi1_2008_1.csv'|" \
       -e "s|QoutRabsmax_file   =.*|QoutRabsmax_file   ='../../rapid/output/HSmsp_WRR/QoutRabsmax_HSmsp_2000_2009_VIC_NASA_pa_phi1_2008_1.csv'|" \
          rapid_namelist_HSmsp_WRR  

#*******************************************************************************
#Uncertainty quantification
#*******************************************************************************

#*******************************************************************************
#Muskingum operator and data assimilation
#*******************************************************************************
sed -i -e "s|ZS_threshold       =.*|ZS_threshold       =0.0|"                  \
          rapid_namelist_HSmsp_WRR  

#*******************************************************************************
#Regular model run
#*******************************************************************************
sed -i -e "s|k_file             =.*|k_file             ='../../rapid/input/HSmsp_WRR/k_HSmsp_pa_guess.csv'|" \
       -e "s|x_file             =.*|x_file             ='../../rapid/input/HSmsp_WRR/x_HSmsp_pa_guess.csv'|" \
       -e "s|Qout_file          =.*|Qout_file          ='../../rapid/output/HSmsp_WRR/Qout_HSmsp_2000_2009_VIC_NASA_sgl_pa_guess_nx_method.nc'|" \
       -e "s|V_file             =.*|V_file             ='../../rapid/output/HSmsp_WRR/V_HSmsp_2000_2009_VIC_NASA_sgl_pa_guess_nx_method.nc'|"                   \
          rapid_namelist_HSmsp_WRR  

#*******************************************************************************
#Optimization
#*******************************************************************************
sed -i -e "s|ZS_phifac          =.*|ZS_phifac          =0.0001|"               \
          rapid_namelist_HSmsp_WRR  
#-------------------------------------------------------------------------------
#Routing parameters
#-------------------------------------------------------------------------------
sed -i -e "s|kfac_file          =.*|kfac_file          ='../../rapid/input/HSmsp_WRR/kfac_HSmsp_1km_hour.csv'|" \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =1|"                    \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =1|"                    \
          rapid_namelist_HSmsp_WRR  

#-------------------------------------------------------------------------------
#Gage observations
#-------------------------------------------------------------------------------
sed -i -e "s|IS_obs_tot         =.*|IS_obs_tot         =14|"                   \
       -e "s|obs_tot_id_file    =.*|obs_tot_id_file    ='../../rapid/input/HSmsp_WRR/obs_tot_id_HSmsp_2000_2009.csv'|" \
       -e "s|Qobs_file          =.*|Qobs_file          ='../../rapid/input/HSmsp_WRR/Qobs_HSmsp_2000_2009_2923.csv'|" \
       -e "s|Qobsbarrec_file    =.*|Qobsbarrec_file    ='../../rapid/input/HSmsp_WRR/Qobsbarrec_HSmsp_2000_2009_x0.01.csv'|" \
       -e "s|IS_obs_use         =.*|IS_obs_use         =14|"                   \
       -e "s|obs_use_id_file    =.*|obs_use_id_file    ='../../rapid/input/HSmsp_WRR/obs_tot_id_HSmsp_2000_2009.csv'|" \
       -e "s|IS_strt_opt        =.*|IS_strt_opt        =23377|"                    \
          rapid_namelist_HSmsp_WRR  

#*******************************************************************************
#End name list
#*******************************************************************************
