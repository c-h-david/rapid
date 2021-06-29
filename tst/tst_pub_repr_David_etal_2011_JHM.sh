#!/bin/bash
#*******************************************************************************
#tst_pub_repr_David_etal_2011_JHM.sh
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
#The following are the possible arguments:
# - No argument: all unit tests are run
# - One unique unit test number: this test is run
# - Two unit test numbers: all tests between those (included) are run
#The script returns the following exit codes
# - 0  if all experiments are successful
# - 22 if some arguments are faulty
# - 33 if a search failed
# - 99 if a comparison failed
#Author:
#Cedric H. David, 2015-2021.


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
#Select which unit tests to perform based on inputs to this shell script
#*******************************************************************************
if [ "$#" = "0" ]; then
     fst=1
     lst=23
     echo "Performing all unit tests: 1-23"
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
#Run all simulations for San Antonio and Guadalupe Basins
#*******************************************************************************

#-------------------------------------------------------------------------------
#Create symbolic list to default namelist
#-------------------------------------------------------------------------------
# rm -f rapid_namelist
# ln -s rapid_namelist_San_Guad_JHM rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files (single core)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 1/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running simul. $sim/17"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_1.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_1.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 2/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running simul. $sim/17"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_2.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_2.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p2_dtR900s_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p2_dtR900s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 3/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running simul. $sim/17"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_3.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_3.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 4/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running simul. $sim/17"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_4.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_4.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p4_dtR900s_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p4_dtR900s.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM

sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi

#-------------------------------------------------------------------------------
#Run simulations and compare output files (multiple cores)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 5/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_3.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_3.csv'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s.nc'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s_n1_muskingum_tst.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =2|"                    \
        rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n 1 ./rapid > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 6/17 - 9/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sed -i -e "s|IS_opt_routing     =.*|IS_opt_routing     =1|"                    \
        rapid_namelist_San_Guad_JHM

for proc in 1 2 4 8
do

unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_3.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_3.csv'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s.nc'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p3_dtR900s_n'$proc'_richardson_tst.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
        rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n $proc ./rapid -nl rapid_namelist_San_Guad_JHM richardson > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi

done

#-------------------------------------------------------------------------------
#Run optimizations and compare findings
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#1st series of optimization experiments
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
opt=$((opt+1))

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
#1st set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running optim. ${opt}.0/2"
ZS_knorm_init=2
ZS_xnorm_init=3
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_1km_hour.csv'
rapd_file="tmp_opt_${opt}.0.txt"
find_file="tmp_opt_find_${opt}.0.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM

sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly -tao_gatol 0.01 -tao_grtol 0.0040 > $rapd_file
./tst_opt_find.sh $rapd_file | cat > $find_file
./tst_opt_comp.sh $find_file 0.1875 3.90625 6.33277
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $x ; fi
./tst_nml_tidy_San_Guad_JHM.sh
fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
#2nd set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running optim. ${opt}.1/2"
ZS_knorm_init=4
ZS_xnorm_init=1
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_1km_hour.csv'
rapd_file="tmp_opt_${opt}.1.txt"
find_file="tmp_opt_find_${opt}.1.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM

sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly -tao_gatol 0.01 -tao_grtol 0.0040 > $rapd_file
./tst_opt_find.sh $rapd_file | cat > $find_file
./tst_opt_comp.sh $find_file 0.131042 2.58128 6.32834
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $x ; fi
./tst_nml_tidy_San_Guad_JHM.sh
fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
#3rd set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running optim. ${opt}.2/2"
ZS_knorm_init=1
ZS_xnorm_init=1
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_1km_hour.csv'
rapd_file="tmp_opt_${opt}.2.txt"
find_file="tmp_opt_find_${opt}.2.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly -tao_gatol 0.01 -tao_grtol 0.0040 > $rapd_file
./tst_opt_find.sh $rapd_file | cat > $find_file
./tst_opt_comp.sh $find_file 0.125 0.9375 6.3315
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $x ; fi
./tst_nml_tidy_San_Guad_JHM.sh
fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
#Compare results
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
if (("10" >= "$fst")) && (("12" <= "$lst")) ; then
echo "Comparing best values"
pick_file='tmp_opt_pick_1.txt'
./tst_opt_pick.sh tmp_opt_find_1*.txt | cat > $pick_file
./tst_opt_comp.sh $pick_file 0.131042 2.58128 6.32834
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $x ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*1*.txt

#-------------------------------------------------------------------------------
#2nd series of optimization experiments
#-------------------------------------------------------------------------------
opt=$((opt+1))

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
#1st set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running optim. ${opt}.0/2"
ZS_knorm_init=2
ZS_xnorm_init=3
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_celerity.csv'
rapd_file="tmp_opt_${opt}.0.txt"
find_file="tmp_opt_find_${opt}.0.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM

sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly -tao_gatol 0.01 -tao_grtol 0.0040 > $rapd_file
./tst_opt_find.sh $rapd_file | cat > $find_file
./tst_opt_comp.sh $find_file 0.5 3.75 6.33895
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $x ; fi
./tst_nml_tidy_San_Guad_JHM.sh
fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
#2nd set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running optim. ${opt}.1/2"
ZS_knorm_init=4
ZS_xnorm_init=1
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_celerity.csv'
rapd_file="tmp_opt_${opt}.1.txt"
find_file="tmp_opt_find_${opt}.1.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly -tao_gatol 0.01 -tao_grtol 0.0040 > $rapd_file
./tst_opt_find.sh $rapd_file | cat > $find_file
./tst_opt_comp.sh $find_file 0.617188 1.95898 6.32206
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $x ; fi
./tst_nml_tidy_San_Guad_JHM.sh
fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
#3rd set of initial parameters
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM.sh
echo "Running optim. ${opt}.2/2"
ZS_knorm_init=1
ZS_xnorm_init=1
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_celerity.csv'
rapd_file="tmp_opt_${opt}.2.txt"
find_file="tmp_opt_find_${opt}.2.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM
sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly -tao_gatol 0.01 -tao_grtol 0.0040 > $rapd_file
./tst_opt_find.sh $rapd_file | cat > $find_file
./tst_opt_comp.sh $find_file 0.5 1.75 6.33788
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $x ; fi
./tst_nml_tidy_San_Guad_JHM.sh
fi

#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
#Compare results
#  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
if (("13" >= "$fst")) && (("15" <= "$lst")) ; then
echo "Comparing best values"
pick_file='tmp_opt_pick_2.txt'
./tst_opt_pick.sh tmp_opt_find_2*.txt | cat > $pick_file
./tst_opt_comp.sh $pick_file 0.617188 1.95898 6.32206
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $pick_file" >&2 ; exit $x ; fi
echo "Success"
echo "********************"
fi
rm -f tmp_opt_*2*.txt

#-------------------------------------------------------------------------------
#Remove symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist


#*******************************************************************************
#Run all simulations for Upper Mississippi Basin
#*******************************************************************************

#-------------------------------------------------------------------------------
#Create symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist
ln -s rapid_namelist_Reg07_JHM rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files (multiple cores)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 10/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_Reg07_JHM.sh
Qout_gold='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s.nc'
Qout_file='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s_n1_muskingum_tst.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =2|"                    \
        rapid_namelist_Reg07_JHM
sleep 3
mpiexec -n 1 ./rapid > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_Reg07_JHM.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 11/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_Reg07_JHM.sh
Qout_gold='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s.nc'
Qout_file='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s_n1_preonly_tst.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =1|"                    \
        rapid_namelist_Reg07_JHM
sleep 3
mpiexec -n 1 ./rapid -nl rapid_namelist_San_Guad_JHM preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_Reg07_JHM.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 12/17 - 17/17
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Qout_gold='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s.nc'
for proc in 1 2 4 8 16 32
do

unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_Reg07_JHM.sh
Qout_file='../../rapid/output/Reg07_JHM/Qout_Reg07_100days_pfac_dtR900s_n'$proc'_richardson_tst.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
echo "Running simul. $sim/17"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
        rapid_namelist_Reg07_JHM
sleep 3
mpiexec -n $proc ./rapid -nl rapid_namelist_San_Guad_JHM richardson > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_Reg07_JHM.sh
echo "Success"
echo "********************"
fi
done

#-------------------------------------------------------------------------------
#Remove symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist


#*******************************************************************************
#Done
#*******************************************************************************
echo "Success on all tests performed"
echo "********************"
