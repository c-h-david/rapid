#!/bin/bash
#*******************************************************************************
#rtk_pub_repr_David_etal_2011_HP.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RAPID simulations that were used in the writing of:
#David, Cédric H., Florence Habets, David R. Maidment and Zong-Liang Yang 
#(2011), RAPID Applied to the SIM-France model, Hydrological Processes, 25(22), 
#3412-3425. 
#DOI: 10.1002/hyp.8070. 
#The files used are available from:
#David, Cédric H., Florence Habets, David R. Maidment and Zong-Liang Yang 
#(2011), RAPID input and output files corresponding to "RAPID Applied to the 
#SIM-France model", Zenodo.
#DOI: 10.5281/zenodo.30228
#The script returns the following exit codes
# - 0  if all experiments are successful 
# - 22 if some arguments are faulty 
# - 33 if a search failed 
# - 99 if a comparison failed 
#Author:
#Cedric H. David, 2015-2016


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Reproducing results of:   http://dx.doi.org/10.1002/hyp.8070"
echo "********************"


#*******************************************************************************
#Select which unit tests to perform based on inputs to this shell script
#*******************************************************************************
if [ "$#" = "0" ]; then
     fst=1
     lst=115
     echo "Performing all unit tests: 1-115"
     echo "********************"
fi 
#Perform all unit tests if no options are given 

if [ "$#" = "1" ]; then
     fst=$1
     lst=$1
     echo "Performing one unit test: $1"
     echo "********************"
fi 
#Perform one single unit test if one option is given 

if [ "$#" = "2" ]; then
     fst=$1
     lst=$2
     echo "Performing unit tests: $1-$2"
     echo "********************"
fi 
#Perform all unit tests between first and second option given (both included) 

if [ "$#" -gt "2" ]; then
     echo "A maximum of two options can be used" 1>&2
     exit 22
fi 
#Exit if more than two options are given 


#*******************************************************************************
#Initialize counts for number of RAPID regular, optimizations and unit tests
#*******************************************************************************
sim=0
opt=0
unt=0


#*******************************************************************************
#Run all simulations for France
#*******************************************************************************

#-------------------------------------------------------------------------------
#Create symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist
ln -s rapid_namelist_France_HP rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files (single core, 3653 days, no forcing)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Make sure RAPID is in regular run mode
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =1|"                    \
          rapid_namelist_France_HP  

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 1/8
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_1.csv'
x_file='../../rapid/input/France_HP/x_modcou_1.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_p1_dtR1800s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_p1_dtR1800s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 2/10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_2.csv'
x_file='../../rapid/input/France_HP/x_modcou_2.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_p2_dtR1800s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_p2_dtR1800s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 3/10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_3.csv'
x_file='../../rapid/input/France_HP/x_modcou_3.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_p3_dtR1800s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_p3_dtR1800s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 4/10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_4.csv'
x_file='../../rapid/input/France_HP/x_modcou_4.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_p4_dtR1800s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_p4_dtR1800s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 5/10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_a.csv'
x_file='../../rapid/input/France_HP/x_modcou_a.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_pa_dtR1800s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_pa_dtR1800s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 6/10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_b.csv'
x_file='../../rapid/input/France_HP/x_modcou_b.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_pb_dtR1800s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_pb_dtR1800s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 7/10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_c.csv'
x_file='../../rapid/input/France_HP/x_modcou_c.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_pc_dtR1800s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_3653days_pc_dtR1800s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#-------------------------------------------------------------------------------
#Run simulations and compare output files (single core, 366 days, forcing)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 8/10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_0.csv'
x_file='../../rapid/input/France_HP/x_modcou_0.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_366days_p0_dtR1800s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_366days_p0_dtR1800s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
ZS_TauM=31622400
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|ZS_TauM            =.*|ZS_TauM            =$ZS_TauM|"             \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 9/10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_b.csv'
x_file='../../rapid/input/France_HP/x_modcou_b.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_366days_pb_dtR1800s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_366days_pb_dtR1800s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
ZS_TauM=31622400
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|ZS_TauM            =.*|ZS_TauM            =$ZS_TauM|"             \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 10/10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running simul. $sim/10"
k_file='../../rapid/input/France_HP/k_modcou_b.csv'
x_file='../../rapid/input/France_HP/x_modcou_b.csv'
Qout_file='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_366days_pb_dtR1800s_pougny_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/France_HP/Qout_France_201101_c_zvol_ext_366days_pb_dtR1800s_pougny.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
BS_opt_for=".true."
ZS_TauM=31622400
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|BS_opt_for         =.*|BS_opt_for         =$BS_opt_for|"          \
       -e "s|ZS_TauM            =.*|ZS_TauM            =$ZS_TauM|"             \
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_France_HP.sh
echo "Success"
echo "********************"
fi

#-------------------------------------------------------------------------------
#Run optimizations and compare findings
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 1
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.188477 0.19141 0.1875)
ZS_xnorm_finals=(0.0307617 2.36026 0.40625)
ZS_phi_finals=(117.426 117.992 117.501)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=1
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_France.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.188477 0.0307617 117.426
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 2
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.348713 0.343369 0.365616)
ZS_xnorm_finals=(0.312801 0.0789909 0.237343)
ZS_phi_finals=(40767.054 40762.780 40761.756)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_France.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.365616 0.237343 40761.756
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 3
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(1.25 1.21732 1.25)
ZS_xnorm_finals=(0.375 1.93546 0.375)
ZS_phi_finals=(119.829 120.395 119.829)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_ttra_length.csv'
IS_opt_phi=1
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_France.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 1.25 0.375 119.829 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 4
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(1.96875 1.8125 2)
ZS_xnorm_finals=(0.140625 0.34375 0)
ZS_phi_finals=(40265.066 40336.969 40257.926)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_ttra_length.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_France.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 2 0 40257.926 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 5
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.368111 0.366452 0.375)
ZS_xnorm_finals=(0.515099 2.59388 0.3125)
ZS_phi_finals=(1452.236 1454.34 1452.146)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_adour.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.375 0.3125 1452.146 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 6
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.30986 0.307789 0.294052)
ZS_xnorm_finals=(0.96254 0.165772 0.00948334)
ZS_phi_finals=(6819.136 6807.200 6802.511)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_garonne.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.294052 0.00948334 6802.511
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 7
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.416943 0.414429 0.375)
ZS_xnorm_finals=(0.428013 0.196747 0.3125)
ZS_phi_finals=(11361.284 11355.138 11376.349)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_loire.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.414429 0.196747 11355.138
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 8
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.49765 0.504181 0.53125)
ZS_xnorm_finals=(0.491486 1.87363 0.234375)
ZS_phi_finals=(4062.416 4065.08 4062.069)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_seine.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.53125 0.234375 4062.069
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 9
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.253906 0.256366 0.265625)
ZS_xnorm_finals=(0.498047 0.117874 0.367188)
ZS_phi_finals=(6794.624 6792.728 6793.554)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_rhone.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.256366 0.117874 6792.728
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 10
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.398438 0.408875 0.382812)
ZS_xnorm_finals=(1.05078 2.0106 0.0585938)
ZS_phi_finals=(204.302 204.704 204.141)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_meuse.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.382812 0.0585938 204.141
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 11
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.375 0.363831 0.369629)
ZS_xnorm_finals=(4.8125 2.66035 4.90894)
ZS_phi_finals=(513.702 514.238 513.729)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_herault.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.375 4.8125 513.702
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 12
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.16201 0.375 0.160156)
ZS_xnorm_finals=(1.3885 0.125 0.419922)
ZS_phi_finals=(314.404 440.444 314.061)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_garonneariege.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.160156 0.419922 314.061
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 13
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.152344 0.15995 0.148438)
ZS_xnorm_finals=(0.673828 2.82207 0.425781)
ZS_phi_finals=(816.461 819.641 816.550)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_tarn.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.152344 0.673828 816.461
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 14
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.390625 0.394089 0.375)
ZS_xnorm_finals=(1.05469 0.112606 0.3125)
ZS_phi_finals=(1301.984 1300.646 1301.126)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_lot.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.394089 0.112606 1300.646
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 15
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.373291 0.338257 0.355804)
ZS_xnorm_finals=(2.7644 1.92966 0.0558929)
ZS_phi_finals=(1332.4 1331.59 1329.170)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_dordogne.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.355804 0.0558929 1329.170
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 16
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.385983 0.379902 0.375)
ZS_xnorm_finals=(0.145435 2.48614 0.3125)
ZS_phi_finals=(2785.886 2802.03 2786.918)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_vienne.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.385983 0.145435 2785.886
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.25 0.307755 0.375)
ZS_xnorm_finals=(0.375 2.67046 0.3125)
ZS_phi_finals=(1315.972 1306.25 1316.090)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_allier.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.307755 2.67046 1306.25
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 18
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.40475 0.393999 0.390625)
ZS_xnorm_finals=(0.406129 2.20254 0.304688)
ZS_phi_finals=(997.172 1000.930 996.783)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_loire_amont_nevers.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.390625 0.304688 996.783
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 19
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.451172 0.453125 0.453125)
ZS_xnorm_finals=(0.836914 0.273438 0.273438)
ZS_phi_finals=(2678.522 2677.687 2677.687)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_loir.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.453125 0.273438 2677.687
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 20
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.597473 0.578796 0.59375)
ZS_xnorm_finals=(0.248474 0.144882 0.203125)
ZS_phi_finals=(2974.585 2973.548 2974.213)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_seine_amont.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.578796 0.144882 2973.548
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.471405 0.46875 0.46875)
ZS_xnorm_finals=(3.09146 3.76562 3.76562)
ZS_phi_finals=(1046.89 1046.73 1046.73)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_oise.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.46875 3.76562 1046.73
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 22
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.236328 0.235992 0.234375)
ZS_xnorm_finals=(0.00683594 2.47492 0.382812)
ZS_phi_finals=(4581.497 4587.08 4582.609)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_saone.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.236328 0.00683594 4581.497
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 23
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.00012207 0.000244141 0.00012207)
ZS_xnorm_finals=(2.07416 0.218628 0.156189)
ZS_phi_finals=(285.793 285.998 285.789)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_ardeche.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type richardson > $rapd_file #########################
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.00012207 0.156189 285.789
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 24
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.5 0.470337 0.5)
ZS_xnorm_finals=(4.75 2.42484 2.25)
ZS_phi_finals=(5.59231 5.61004 5.62308)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_rhone_suisse.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.5 4.75 5.59231
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(1.3125 1.42719 1.4375)
ZS_xnorm_finals=(0.09375 0.376266 0.28125)
ZS_phi_finals=(1418.755 1417.889 1417.761)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_ttra_length.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_adour.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 1.4375 0.28125 1417.761
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 26
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(1.78125 1.75 2)
ZS_xnorm_finals=(0.671875 0.625 0)
ZS_phi_finals=(6688.803 6684.343 6708.924)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_ttra_length.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_garonne.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 1.75 0.625 6684.343
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 27
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(3 2.79688 2.5)
ZS_xnorm_finals=(0 0.640625 0)
ZS_phi_finals=(11146.357 11131.267 11132.954)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_ttra_length.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_loire.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 2.79688 0.640625 11131.267
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 28
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(1.21875 1.14612 1.1875)
ZS_xnorm_finals=(0.640625 1.93558 0.40625)
ZS_phi_finals=(4069.979 4071.19 4068.502)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_ttra_length.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_seine.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 1.1875 0.40625 4068.502
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 29
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(2.5 2.25 2.26562)
ZS_xnorm_finals=(0.25 0.375 0.1875)
ZS_phi_finals=(6624.380 6624.542 6622.473)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_ttra_length.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_rhone.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 2.26562 0.1875 6622.473
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 30
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(1.875 1.9375 2)
ZS_xnorm_finals=(2.5625 0.03125 0)
ZS_phi_finals=(217.279 216.681 216.689)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_ttra_length.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_meuse.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 1.9375 0.03125 216.681
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 31
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(1.9375 1.8125 1.875)
ZS_xnorm_finals=(3.03125 0.34375 0.0625)
ZS_phi_finals=(510.235 509.502 509.309)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_ttra_length.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_herault.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 1.875 0.0625 509.309
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 32
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.35099 0.386933 0.375)
ZS_xnorm_finals=(0.527702 0.109875 0.3125)
ZS_phi_finals=(2728.287 2720.664 2721.589)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_garonne_reste.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
BS_opt_for=".true."
Qfor_file='../../rapid/input/France_HP/Qfor_1995_1996_full_93.csv'
for_use_id_file='../../rapid/input/France_HP/forcinguse_id_garonne_reste.csv'
IS_for_use=`wc -l < $for_use_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|BS_opt_for         =.*|BS_opt_for         =$BS_opt_for|"          \
       -e "s|Qfor_file          =.*|Qfor_file          ='$Qfor_file'|"         \
       -e "s|for_use_id_file    =.*|for_use_id_file    ='$for_use_id_file'|"   \
       -e "s|IS_for_use         =.*|IS_for_use         =$IS_for_use|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly -tao_max_funcs 100 > $rapd_file #########
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.386933 0.109875 2720.664
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 33
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.419189 0.435547 0.4375)
ZS_xnorm_finals=(0.448975 0.0913086 0.28125)
ZS_phi_finals=(3454.709 3448.233 3450.165)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_loire_reste.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
BS_opt_for=".true."
Qfor_file='../../rapid/input/France_HP/Qfor_1995_1996_full_93.csv'
for_use_id_file='../../rapid/input/France_HP/forcinguse_id_loire_reste.csv'
IS_for_use=`wc -l < $for_use_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|BS_opt_for         =.*|BS_opt_for         =$BS_opt_for|"          \
       -e "s|Qfor_file          =.*|Qfor_file          ='$Qfor_file'|"         \
       -e "s|for_use_id_file    =.*|for_use_id_file    ='$for_use_id_file'|"   \
       -e "s|IS_for_use         =.*|IS_for_use         =$IS_for_use|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.435547 0.0913086 3448.233
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 34
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.03125 8.25439 0.03125)
ZS_xnorm_finals=(4.98438 3.67773 2.48438)
ZS_phi_finals=(1.01198 29.1573 1.01269)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_seine_reste.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
BS_opt_for=".true."
Qfor_file='../../rapid/input/France_HP/Qfor_1995_1996_full_93.csv'
for_use_id_file='../../rapid/input/France_HP/forcinguse_id_seine_reste.csv'
IS_for_use=`wc -l < $for_use_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|BS_opt_for         =.*|BS_opt_for         =$BS_opt_for|"          \
       -e "s|Qfor_file          =.*|Qfor_file          ='$Qfor_file'|"         \
       -e "s|for_use_id_file    =.*|for_use_id_file    ='$for_use_id_file'|"   \
       -e "s|IS_for_use         =.*|IS_for_use         =$IS_for_use|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.03125 4.98438 1.01198 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Series of optimization experiments 35
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
ZS_knorm_inits=(2 4 1)
ZS_xnorm_inits=(3 1 1)
ZS_knorm_finals=(0.390686 0.397179 0.375)
ZS_xnorm_finals=(0.184753 2.45637 0.3125)
ZS_phi_finals=(1854.941 1858.04 1855.791)
for ii in `seq 0 2`;
do
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_France_HP.sh
echo "Running optim. ${opt}.$ii/35"
kfac_file='../../rapid/input/France_HP/kfac_modcou_1km_hour.csv'
IS_opt_phi=2
riv_bas_id_file='../../rapid/input/France_HP/rivsurf_rhone_reste.csv'
IS_riv_bas=`wc -l < $riv_bas_id_file`
BS_opt_for=".true."
Qfor_file='../../rapid/input/France_HP/Qfor_1995_1996_full_93.csv'
for_use_id_file='../../rapid/input/France_HP/forcinguse_id_rhone_reste.csv'
IS_for_use=`wc -l < $for_use_id_file`
rapd_file="tmp_opt_${opt}.$ii.txt"
find_file="tmp_opt_find_${opt}.$ii.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =.true.|"               \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
       -e "s|IS_opt_phi         =.*|IS_opt_phi         =$IS_opt_phi|"          \
       -e "s|riv_bas_id_file    =.*|riv_bas_id_file    ='$riv_bas_id_file'|"   \
       -e "s|IS_riv_bas         =.*|IS_riv_bas         =$IS_riv_bas|"          \
       -e "s|BS_opt_for         =.*|BS_opt_for         =$BS_opt_for|"          \
       -e "s|Qfor_file          =.*|Qfor_file          ='$Qfor_file'|"         \
       -e "s|for_use_id_file    =.*|for_use_id_file    ='$for_use_id_file'|"   \
       -e "s|IS_for_use         =.*|IS_for_use         =$IS_for_use|"          \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =${ZS_knorm_inits[ii]}|"\
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =${ZS_xnorm_inits[ii]}|"\
          rapid_namelist_France_HP  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file ${ZS_knorm_finals[ii]} ${ZS_xnorm_finals[ii]} ${ZS_phi_finals[ii]} 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi
./rtk_nml_tidy_France_HP.sh
fi
done
if (("$unt-2" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Comparing best values"
pick_file="tmp_opt_pick_$opt.txt"
./rtk_opt_pick.sh tmp_opt_find_$opt*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.390686 0.184753 1854.941 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*$opt*.txt

#-------------------------------------------------------------------------------
#Remove symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist


#*******************************************************************************
#Done
#*******************************************************************************
echo "Success on all tests"
echo "********************"
