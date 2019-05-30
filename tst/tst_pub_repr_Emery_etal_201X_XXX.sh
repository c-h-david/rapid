#!/bin/bash
#*******************************************************************************
#tst_pub_repr_Emery_etal_201X_XXX.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RAPID simulations that were used in the writing of:
#Emery, Charlotte M., David Cedric H., Turmon Michael, Hobbs Jonathan, 
#Andreadis Kostas, Reager John T., Famiglietti James, Beighley Edward R., 
#Rodell Matthew
#DOI:
#The files used are available from:
#DOI:
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
#Charlotte M. Emery, Cedric H. David, 2015-2019.

#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Reproducing results of:"
echo "********************"

#*******************************************************************************
#Initialize counts for number of RAPID regular, optimizations and unit tests
#*******************************************************************************
sim=0
unt=0

#*******************************************************************************
#Select which unit tests to perform based on inputs to this shell script
#*******************************************************************************
if [ "$#" = "0" ]; then
     fst=1
     lst=8
     echo "Performing all unit tests: 1-8"
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
#Run all simulations for San Antonio and Guadalupe Basins 
#*******************************************************************************

#-------------------------------------------------------------------------------
#Create symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist
ln -s rapid_namelist_San_Guad_DA_XXX rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files (single core)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 1/8
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Running simul. $sim/8"
Qout_file='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Openloop_20100101_20100131_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Openloop_20100101_20100131.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_DA_XXX  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Success"
echo "********************"
fi


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 2/8
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Running simul. $sim/8"
Qout_file='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.50_tauTe-03_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.50_tauTe-03.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_inflation       =.*|ZS_inflation       =1.50|"                 \
       -e "s|ZS_threshold       =.*|ZS_threshold       =0.001|"                \
          rapid_namelist_San_Guad_DA_XXX  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Success"
echo "********************"
fi


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 3/8
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Running simul. $sim/8"
Qout_file='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.50_tauT0_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.50_tauT0.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_inflation       =.*|ZS_inflation       =1.50|"                 \
       -e "s|ZS_threshold       =.*|ZS_threshold       =0.0|"                  \
          rapid_namelist_San_Guad_DA_XXX  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Success"
echo "********************"
fi


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 4/8
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Running simul. $sim/8"
Qout_file='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.00_tauTe-03_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.00_tauTe-03.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_inflation       =.*|ZS_inflation       =1.0|"                  \
       -e "s|ZS_threshold       =.*|ZS_threshold       =0.001|"                \
          rapid_namelist_San_Guad_DA_XXX  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Success"
echo "********************"
fi

#-------------------------------------------------------------------------------
#Run simulations and compare output files (multiple cores)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulations 5/8 - 8/8
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

for proc in 1 2 4 8
do

unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Running simul. $sim/8"
Qout_file='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.50_tauTe-03_n'$proc'_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_DA_XXX/Qout_San_Guad_Analysis_20100101_20100131_tauR30_tauI1.50_tauTe-03.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_inflation       =.*|ZS_inflation       =1.50|"   \
       -e "s|ZS_threshold       =.*|ZS_threshold       =0.001|"   \
          rapid_namelist_San_Guad_DA_XXX  
sleep 3
mpiexec -n $proc ./rapid -ksp_type richardson > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file 0.0001 0.01 > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_DA_XXX.sh
echo "Success"
echo "********************"
fi

done

