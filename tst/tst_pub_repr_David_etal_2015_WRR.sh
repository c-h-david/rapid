#!/bin/bash
#*******************************************************************************
#tst_pub_repr_David_etal_2015_WRR.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RAPID simulations that were used in the writing of:
#David, Cédric H., James S. Famiglietti, Zong-Liang Yang, and Victor Eijkhout 
#(2015), Enhanced fixed-size parallel speedup with the Muskingum method using a 
#trans-boundary approach and a large sub-basins approximation, Water Resources 
#Research, 51(9), 1-25, 
#DOI: 10.1002/2014WR016650.
#These files are available from:
#David, Cédric H., James S. Famiglietti, Zong-Liang Yang, and Victor Eijkhout 
#(2015), 
#xxx
#DOI: xx.xxxx/xxxxxx
#The script returns the following exit codes
# - 0  if all experiments are successful 
# - 22 if some arguments are faulty 
# - 33 if a search failed 
# - 99 if a comparison failed 
#Author:
#Cedric H. David, 2018-2023.


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
ln -s rapid_namelist_HSmsp_WRR rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Test 1/x - simulation
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_HSmsp_WRR.sh
echo "Running test $unt/x - simulation"

test_file="tmp_run_$unt.txt"
comp_file="tmp_run_comp_$unt.txt"
Qout_gold='../output/HSmsp_WRR/Qout_HSmsp_2000_2009_VIC_NASA_sgl_pa_guess_n1_preonly_ilu.nc'

Qout_file='../output/HSmsp_WRR/Qout_HSmsp_2000_2009_VIC_NASA_sgl_pa_guess_n1_preonly_ilu_tst.nc'
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_HSmsp_WRR  
sleep 3

mpiexec -n 1 ./rapid -ksp_type preonly > $test_file

echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file 1e-12 1e-10 > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi

rm $Qout_file
rm $test_file
rm $comp_file
./tst_nml_tidy_HSmsp_WRR.sh
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
