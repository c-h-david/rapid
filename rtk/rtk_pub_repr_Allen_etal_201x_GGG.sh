#!/bin/bash
#*******************************************************************************
#rtk_pub_repr_Allen_etal_201x_GGG.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RAPID simulations that were used in the writing of:
#Allen, George H., et al. (201x)
#xxx
#DOI: xx.xxxx/xxxxxx
#The files used are available from:
#Allen, George H., et al. (201x)
#xxx
#DOI: xx.xxxx/xxxxxx
#The script returns the following exit codes
# - 0  if all experiments are successful 
# - 22 if some arguments are faulty 
# - 33 if a search failed 
# - 99 if a comparison failed 
#Author:
#Cedric H. David, 2018-2018.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Reproducing results of:   http://dx.doi.org/xx.xxxx/xxxxxx"
echo "********************"


#*******************************************************************************
#Select which unit tests to perform based on inputs to this shell script
#*******************************************************************************
if [ "$#" = "0" ]; then
     fst=1
     lst=99
     echo "Performing all unit tests: 1-99"
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
unt=0


#*******************************************************************************
#Run all simulations
#*******************************************************************************

#-------------------------------------------------------------------------------
#Create symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist
ln -s rapid_namelist_MIGBM_GGG rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Test 1/x - simulation
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_MIGBM_GGG.sh
echo "Running test $unt/x - simulation"

test_file="tmp_run_$unt.txt"
comp_file="tmp_run_comp_$unt.txt"
Qout_gold='../output/MIGBM_GGG/Qout_MIGBM_20000101_20091231_utc_p0_dtR1800s_n1_preonly.nc'

Qout_file='../output/MIGBM_GGG/Qout_MIGBM_20000101_20091231_utc_p0_dtR1800s_n1_preonly_rtk.nc'
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_MIGBM_GGG  
sleep 3

mpiexec -n 1 ./rapid -ksp_type preonly > $test_file

echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-6 1e-3 > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi

rm $Qout_file
rm $test_file
rm $comp_file
./rtk_nml_tidy_MIGBM_GGG.sh
echo "Success"
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
