#!/bin/bash
#*******************************************************************************
#rtk_pub_repr_David_etal_2011_JHM.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RAPID simulations that were used in the writing of:
#David, Cédric H., David R. Maidment, Guo-Yue Niu, Zong- Liang Yang, Florence 
#Habets and Victor Eijkhout (2011), River network routing on the NHDPlus 
#dataset, Journal of Hydrometeorology, 12(5), 913-934. 
#DOI: 10.1175/2011JHM1345.1 
#The files used are available from:
#David, Cédric H., David R. Maidment, Guo-Yue Niu, Zong- Liang Yang, Florence 
#Habets and Victor Eijkhout (2011), RAPID input and output files corresponding 
#to "River Network Routing on the NHDPlus Dataset", Zenodo.
#DOI: 10.5281/zenodo.16565
#The script returns the following exit codes
# - 0  if all experiments are successful 
# - 22 if some arguments are faulty 
# - 33 if a search failed 
# - 99 if a comparison failed 
#Author:
#Cedric H. David, 2015


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Reproducing results of:   http://dx.doi.org/10.1175/2011JHM1345.1"
echo "********************"


#*******************************************************************************
#Initialize counts for number of RAPID regular runs and RAPID optimizations 
#*******************************************************************************
sim=0
opt=0


#*******************************************************************************
#Run all simulations for San Antonio and Guadalupe Basins 
#*******************************************************************************

#-------------------------------------------------------------------------------
#Reset RAPID namelist and make symbolic list to default namelist
#-------------------------------------------------------------------------------
./rtk_nml_tidy_San_Guad_JHM.sh

rm -f rapid_namelist
ln -s rapid_namelist_San_Guad_JHM rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files (single core)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Make sure RAPID is in regular run mode
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =1|"                    \
          rapid_namelist_San_Guad_JHM  

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 1/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sim=$((sim+1))
echo "Running simul. $sim/17"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_1.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_1.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"

sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file

echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
echo "Success"
echo "********************"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 2/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sim=$((sim+1))
echo "Running simul. $sim/17"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_2.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_2.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p2_dtR900s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p2_dtR900s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"

sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file

echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
echo "Success"
echo "********************"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 3/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sim=$((sim+1))
echo "Running simul. $sim/17"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_3.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_3.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"

sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file

echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
echo "Success"
echo "********************"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 4/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sim=$((sim+1))
echo "Running simul. $sim/17"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_4.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_4.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p4_dtR900s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p4_dtR900s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"

sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file

echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
echo "Success"
echo "********************"

#-------------------------------------------------------------------------------
#Run simulations and compare output files (multiple cores)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Reset RAPID to p3 parameters Make sure RAPID is in regular run mode
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_3.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_3.csv'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s.nc'
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
        rapid_namelist_San_Guad_JHM

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 5/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sim=$((sim+1))
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s_n1_muskingum_rtk.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =2|"                    \
        rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n 1 ./rapid > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
echo "Success"
echo "********************"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 6/17 - 9/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sed -i -e "s|IS_opt_routing     =.*|IS_opt_routing     =1|"                    \
        rapid_namelist_San_Guad_JHM

for proc in 1 2 4 8
do

sim=$((sim+1))
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s_n'$proc'_richardson_rtk.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
        rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n $proc ./rapid -ksp_type richardson > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
echo "Success"
echo "********************"

done

#-------------------------------------------------------------------------------
#Run optimizations and compare findings
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Make sure RAPID is in optimization mode
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
          rapid_namelist_San_Guad_JHM  

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#1st series of optimization experiments
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))
echo "Running optim. $opt/2"
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_1km_hour.csv'

sed -i -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM  

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
#1st set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
echo "Initial param. a)"
ZS_knorm_init=2
ZS_xnorm_init=3
rapd_file="tmp_opt_${opt}a.txt"
find_file="tmp_opt_find_${opt}a.txt"

sed -i -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file 0.1875 3.90625 6.33277 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
#2nd set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
echo "Initial param. b)"
ZS_knorm_init=4
ZS_xnorm_init=1
rapd_file="tmp_opt_${opt}b.txt"
find_file="tmp_opt_find_${opt}b.txt"

sed -i -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file 0.131042 2.58128 6.32834
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
#3rd set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
echo "Initial param. c)"
ZS_knorm_init=1
ZS_xnorm_init=1
rapd_file="tmp_opt_${opt}c.txt"
find_file="tmp_opt_find_${opt}c.txt"

sed -i -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file 0.125 0.9375 6.3315
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
#Compare results
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
echo "Comparing best values"
pick_file='tmp_opt_pick_1.txt'
./rtk_opt_pick.sh tmp_opt_find_1*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.131042 2.58128 6.32834  
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
rm tmp_opt_*1*.txt
echo "Success"
echo "********************"

#-------------------------------------------------------------------------------
#2nd series of optimization experiments
#-------------------------------------------------------------------------------
opt=$((opt+1))
echo "Running optim. $opt/2"
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_celerity.csv'

sed -i -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM  

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
#1st set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
echo "Initial param. a)"
ZS_knorm_init=2
ZS_xnorm_init=3
rapd_file="tmp_opt_${opt}a.txt"
find_file="tmp_opt_find_${opt}a.txt"

sed -i -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file 0.5 3.75 6.33895
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
#2nd set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
echo "Initial param. b)"
ZS_knorm_init=4
ZS_xnorm_init=1
rapd_file="tmp_opt_${opt}b.txt"
find_file="tmp_opt_find_${opt}b.txt"

sed -i -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file 0.617188 1.95898 6.32206
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
#3rd set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
echo "Initial param. c)"
ZS_knorm_init=1
ZS_xnorm_init=1
rapd_file="tmp_opt_${opt}c.txt"
find_file="tmp_opt_find_${opt}c.txt"

sed -i -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
./rtk_opt_find.sh $rapd_file | cat > $find_file
./rtk_opt_comp.sh $find_file 0.5 1.75 6.33788
if [ $? -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $? ; fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
#Compare results
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   - 
echo "Comparing best values"
pick_file='tmp_opt_pick_2.txt'
./rtk_opt_pick.sh tmp_opt_find_2*.txt | cat > $pick_file
./rtk_opt_comp.sh $pick_file 0.617188 1.95898 6.32206
if [ $? -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $? ; fi
rm tmp_opt_*2*.txt
echo "Success"
echo "********************"

#-------------------------------------------------------------------------------
#Reset RAPID namelist and remove symbolic list to default namelist
#-------------------------------------------------------------------------------
./rtk_nml_tidy_San_Guad_JHM.sh

rm -f rapid_namelist


#*******************************************************************************
#Run all simulations for Upper Mississippi Basin 
#*******************************************************************************

#-------------------------------------------------------------------------------
#Reset RAPID namelist and make symbolic list to default namelist
#-------------------------------------------------------------------------------
./rtk_nml_tidy_Reg07_JHM.sh

rm -f rapid_namelist
ln -s rapid_namelist_Reg07_JHM rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files (multiple cores)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Make sure RAPID is in regular run mode
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =1|"                    \
          rapid_namelist_Reg07_JHM  

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 10/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sim=$((sim+1))
Qout_gold='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s.nc'
Qout_file='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s_n1_muskingum_rtk.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =2|"                    \
        rapid_namelist_Reg07_JHM
sleep 3
mpiexec -n 1 ./rapid > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
echo "Success"
echo "********************"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 11/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sim=$((sim+1))
Qout_gold='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s.nc'
Qout_file='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s_n1_preonly_rtk.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =1|"                    \
        rapid_namelist_Reg07_JHM
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
echo "Success"
echo "********************"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 12/17 - 17/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Qout_gold='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s.nc'
for proc in 1 2 4 8 16 32
do

sim=$((sim+1))
Qout_file='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s_n'$proc'_richardson_rtk.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
        rapid_namelist_Reg07_JHM
sleep 3
mpiexec -n $proc ./rapid -ksp_type richardson > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
if [ $? -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $? ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
echo "Success"
echo "********************"

done

#-------------------------------------------------------------------------------
#Reset RAPID namelist and remove symbolic list to default namelist
#-------------------------------------------------------------------------------
./rtk_nml_tidy_Reg07_JHM.sh

rm -f rapid_namelist


#*******************************************************************************
#Done
#*******************************************************************************
echo "Success on all tests"
echo "********************"
