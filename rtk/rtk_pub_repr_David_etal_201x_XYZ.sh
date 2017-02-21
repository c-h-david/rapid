#!/bin/bash
#*******************************************************************************
#rtk_pub_repr_David_etal_201x_XYZ.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RAPID simulations that were used in the writing of:
#David, Cédric H., et al. (201x)
#xxx
#DOI: xx.xxxx/xxxxxx
#The files used are available from:
#David, Cédric H., et al. (201x)
#xxx
#DOI: xx.xxxx/xxxxxx
#The script returns the following exit codes
# - 0  if all experiments are successful 
# - 22 if some arguments are faulty 
# - 33 if a search failed 
# - 99 if a comparison failed 
#Author:
#Cedric H. David, 2015-2017.


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
sim=0
opt=0
unt=0


#*******************************************************************************
#Run all simulations
#*******************************************************************************

#-------------------------------------------------------------------------------
#Create symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist
ln -s rapid_namelist_WSWM_XYZ rapid_namelist

#-------------------------------------------------------------------------------
#Run simulations and compare output files (single core, 729 days)
#-------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Make sure RAPID is in regular run mode
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =1|"                    \
          rapid_namelist_WSWM_XYZ  

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 1/x
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_WSWM_XYZ.sh
echo "Running simul. $sim/x"
k_file='../../rapid/input/WSWM_XYZ/k_WSWM_ag.csv'
x_file='../../rapid/input/WSWM_XYZ/x_WSWM_ag.csv'
BS_opt_V=".true."
BS_opt_uq=".true."
Qout_file='../../rapid/output/WSWM_XYZ/Qout_WSWM_729days_p0_dtR900s_n1_preonly_rtk.nc'
Qout_gold='../../rapid/output/WSWM_XYZ/Qout_WSWM_729days_p0_dtR900s_n1_preonly_20170202.nc'
V_file='../../rapid/output/WSWM_XYZ/V_WSWM_729days_p0_dtR900s_n1_preonly_rtk.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|BS_opt_V           =.*|BS_opt_V           =$BS_opt_V|"            \
       -e "s|BS_opt_uq          =.*|BS_opt_uq          =$BS_opt_uq|"           \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|V_file             =.*|V_file             ='$V_file'|"            \
          rapid_namelist_WSWM_XYZ  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-40 1e-37 > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $V_file
rm $rapd_file
rm $comp_file
./rtk_nml_tidy_WSWM_XYZ.sh
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
