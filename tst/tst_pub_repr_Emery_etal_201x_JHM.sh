#!/bin/bash
#*******************************************************************************
#tst_pub_repr_Emery_etal_201x_JHM.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RAPID simulations that were used in the writing of:
#Emery, Charlotte M., Cedric H. David, Kostas M. Andreadis, Michael J. Turmon,
#John T. Reager, Jonathan M. Hobbs, Ming Pan, James S. Famiglietti,
#R. Edward Beighley, and Matthew Rodell (201x), Underlying Fundamentals of
#Kalman Filtering for River Network Modeling,
#DOI: xx.xxxx/xxxxxxxxxxxx
#The files used are available from:
#Emery, Charlotte M., Cedric H. David, Kostas M. Andreadis, Michael J. Turmon,
#John T. Reager, Jonathan M. Hobbs, Ming Pan, James S. Famiglietti,
#R. Edward Beighley, and Matthew Rodell (201x), RRR/RAPID input and output files
#for "Underlying Fundamentals of Kalman Filtering for River Network Modeling",
#Zenodo.
#DOI: xx.xxxx/xxxxxxxxxxxx
#The following are the possible arguments:
# - No argument: all unit tests are run
# - One unique unit test number: this test is run
# - Two unit test numbers: all tests between those (included) are run
#The script returns the following exit codes
# - 0  if all experiments are successful
# - 22 if some arguments are faulty
# - 33 if a search failed
# - 99 if a comparison failed
#Authors:
#Charlotte M. Emery, Cedric H. David, 2017-2019.

#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Reproducing results of:   http://dx.doi.org/xx.xxxx/xxxxxxxxxxxx"
echo "********************"


#*******************************************************************************
#Select which unit tests to perform based on inputs to this shell script
#*******************************************************************************
if [ "$#" = "0" ]; then
     fst=1
     lst=21
     echo "Performing all unit tests: 1-20"
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
unt=0

#*******************************************************************************
#Run all simulations for San Antonio and Guadalupe Basins
#*******************************************************************************

#-------------------------------------------------------------------------------
#Create symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist
ln -s rapid_namelist_San_Guad_JHM2 rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files (single core)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 1/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =1|"                    \
          rapid_namelist_San_Guad_JHM2
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 2/21 - 9/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run=0

for IS_radius in 40 30 25 20 15 10 5 0
do

unt=$((unt+1))
sim=$((sim+1))
run=$((run+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
if (($run < 10)) ; then
run_st="0$run"
else
run_st="$run"
fi
#echo $run_st $IS_radius
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run${run_st}_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run${run_st}.nc"
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_radius          =.*|IS_radius          =$IS_radius|"           \
          rapid_namelist_San_Guad_JHM2
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success"
echo "********************"
fi

done

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 10/21 - 13/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

for ZS_inflation in 1.00 2.58 3.00 5.00
do

unt=$((unt+1))
sim=$((sim+1))
run=$((run+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
if (($run < 10)) ; then
run_st="0$run"
else
run_st="$run"
fi
#echo $run_st $ZS_inflation
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run${run_st}_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run${run_st}.nc"
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|ZS_inflation       =.*|ZS_inflation       =$ZS_inflation|"        \
          rapid_namelist_San_Guad_JHM2
#echo $Qout_gold
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success"
echo "********************"
fi

done

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 14/21 - 18/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

for ZS_threshold in 0.00001 0.0001 0.001 0.01 0.1
do

unt=$((unt+1))
sim=$((sim+1))
run=$((run+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
if (($run < 10)) ; then
run_st="0$run"
else
run_st="$run"
fi
#echo $run_st $ZS_threshold
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run${run_st}_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run${run_st}.nc"
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|ZS_threshold       =.*|ZS_threshold       =$ZS_threshold|"        \
          rapid_namelist_San_Guad_JHM2
#echo $Qout_gold
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success"
echo "********************"
fi

done

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 19 - UQ daily
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

unt=$((unt+1))
sim=$((sim+1))
run=$((run+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_24H_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_24H.nc"
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =1|"                    \
       -e "s|BS_opt_uq          =.*|BS_opt_uq          =.true.|"               \
       -e "s|Vlat_file          =.*|Vlat_file          ='../../rapid/input/San_Guad_JHM2/m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_err24H_R286.nc'|" \
          rapid_namelist_San_Guad_JHM2
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
echo "Success Qout"
rm $comp_file
./tst_run_cerr $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success Qerr"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 20 - UQ daily rescaled
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

unt=$((unt+1))
sim=$((sim+1))
run=$((run+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_24Hscaled_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_24Hscaled.nc"
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =1|"                    \
       -e "s|BS_opt_uq          =.*|BS_opt_uq          =.true.|"               \
       -e "s|Vlat_file          =.*|Vlat_file          ='../../rapid/input/San_Guad_JHM2/m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_scalederr24H_R286.nc'|" \
          rapid_namelist_San_Guad_JHM2
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
echo "Success Qout"
rm $comp_file
./tst_run_cerr $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success Qerr"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 21 - UQ monthly
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

unt=$((unt+1))
sim=$((sim+1))
run=$((run+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_M_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_M.nc"
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =1|"                    \
       -e "s|BS_opt_uq          =.*|BS_opt_uq          =.true.|"               \
       -e "s|Vlat_file          =.*|Vlat_file          ='../../rapid/input/San_Guad_JHM2/m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_errM_R286.nc'|" \
       -e "s|ZS_dtUQ            =.*|ZS_dtUQ            =2628028.8|"            \
          rapid_namelist_San_Guad_JHM2
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
echo "Success Qout"
rm $comp_file
./tst_run_cerr $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success Qerr"
echo "********************"
fi

#-------------------------------------------------------------------------------
#Remove symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist


#*******************************************************************************
#Done
#*******************************************************************************
echo "Success on all tests"
echo "********************"
