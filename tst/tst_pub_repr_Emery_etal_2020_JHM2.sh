#!/bin/bash
#*******************************************************************************
#tst_pub_repr_Emery_etal_2020_JHM2.sh
#*******************************************************************************

#Purpose:
#This script reproduces all RAPID simulations that were used in the writing of:
#Emery, Charlotte M., Cedric H. David, Kostas M. Andreadis, Michael J. Turmon,
#John T. Reager, Jonathan M. Hobbs, Ming Pan, James S. Famiglietti,
#R. Edward Beighley, and Matthew Rodell (2020), Underlying Fundamentals of
#Kalman Filtering for River Network Modeling,
#DOI: 10.1175/JHM-D-19-0084.1
#The files used are available from:
#Emery, Charlotte M., Cedric H. David, Kostas M. Andreadis, Michael J. Turmon,
#John T. Reager, Jonathan M. Hobbs, Ming Pan, James S. Famiglietti,
#R. Edward Beighley, and Matthew Rodell (2020), RRR/RAPID input and output files
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
#Charlotte M. Emery, Cedric H. David, 2017-2020.

#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Reproducing results of:   http://dx.doi.org/10.1175/JHM-D-19-0084.1"
echo "********************"


#*******************************************************************************
#Select which unit tests to perform based on inputs to this shell script
#*******************************************************************************
if [ "$#" = "0" ]; then
     fst=1
     lst=25
     echo "Performing all unit tests: 1-25"
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
#Simulation 1/25 UQ daily
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp00_err_D_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp00_err_D.nc"
Vlat_file="../../rapid/input/San_Guad_JHM2/m3_riv_San_Guad_20100101_20131231_VIC0125_3H_utc_err_R286_D.nc"
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|BS_opt_uq          =.*|BS_opt_uq          =.true.|"               \
       -e "s|Vlat_file          =.*|Vlat_file          ='$Vlat_file'|"         \
          rapid_namelist_San_Guad_JHM2
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
echo "Comparing uncertainty"
./tst_run_cerr $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 2/25 UQ daily rescaled
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp00_err_D_scl_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp00_err_D_scl.nc"
Vlat_file="../../rapid/input/San_Guad_JHM2/m3_riv_San_Guad_20100101_20131231_VIC0125_3H_utc_err_R286_D_scl.nc"
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|BS_opt_uq          =.*|BS_opt_uq          =.true.|"               \
       -e "s|Vlat_file          =.*|Vlat_file          ='$Vlat_file'|"         \
          rapid_namelist_San_Guad_JHM2
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
echo "Comparing uncertainty"
./tst_run_cerr $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 3/25 UQ monthly
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp00_err_M_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp00_err_M.nc"
Vlat_file="../../rapid/input/San_Guad_JHM2/m3_riv_San_Guad_20100101_20131231_VIC0125_3H_utc_err_R286_M.nc"
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|BS_opt_uq          =.*|BS_opt_uq          =.true.|"               \
       -e "s|Vlat_file          =.*|Vlat_file          ='$Vlat_file'|"         \
       -e "s|ZS_dtUQ            =.*|ZS_dtUQ            =2628028.8|"            \
          rapid_namelist_San_Guad_JHM2
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $rapd_file
echo "Comparing files"
./tst_run_comp $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
echo "Comparing uncertainty"
./tst_run_cerr $Qout_gold $Qout_file > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $rapd_file
rm $comp_file
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Success"
echo "********************"
fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Simulation 4/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp00_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp00.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
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
#Simulation 5/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp01_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp01.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =40|"                   \
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
#Simulation 6/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp02_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp02.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =30|"                   \
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
#Simulation 7/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp03_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp03.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =25|"                   \
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
#Simulation 8/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp04_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp04.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =20|"                   \
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
#Simulation 9/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp05_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp05.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =15|"                   \
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
#Simulation 10/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp06_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp06.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =10|"                   \
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
#Simulation 11/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp07_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp07.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =5|"                    \
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
#Simulation 12/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp08_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp08.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =0|"                    \
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
#Simulation 13/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp09_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp09.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_inflation       =.*|ZS_inflation       =1.00|"                 \
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
#Simulation 14/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp10_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp10.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_inflation       =.*|ZS_inflation       =2.58|"                 \
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
#Simulation 15/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp11_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp11.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_inflation       =.*|ZS_inflation       =3.00|"                 \
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
#Simulation 16/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp12_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp12.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_inflation       =.*|ZS_inflation       =5.00|"                 \
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
#Simulation 17/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp13_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp13.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_threshold       =.*|ZS_threshold       =1e-5|"                 \
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
#Simulation 18/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp14_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp14.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_threshold       =.*|ZS_threshold       =1e-4|"                 \
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
#Simulation 19/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp15_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp15.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_threshold       =.*|ZS_threshold       =1e-3|"                 \
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
#Simulation 20/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp16_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp16.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_threshold       =.*|ZS_threshold       =1e-2|"                 \
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
#Simulation 21/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp17_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp17.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|ZS_threshold       =.*|ZS_threshold       =1e-1|"                 \
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
#Simulation 22/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp18_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp18.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =30|"                   \
       -e "s|IS_obs_use         =.*|IS_obs_use         =36|"                   \
       -e "s|obs_use_id_file    =.*|obs_use_id_file    ='../../rapid/input/San_Guad_JHM2/obs_tot_id_San_Guad_2010_2013_full.csv'|" \
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
#Simulation 23/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp19_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp19.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =20|"                   \
       -e "s|IS_obs_use         =.*|IS_obs_use         =36|"                   \
       -e "s|obs_use_id_file    =.*|obs_use_id_file    ='../../rapid/input/San_Guad_JHM2/obs_tot_id_San_Guad_2010_2013_full.csv'|" \
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
#Simulation 24/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp20_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp20.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =10|"                   \
       -e "s|IS_obs_use         =.*|IS_obs_use         =36|"                   \
       -e "s|obs_use_id_file    =.*|obs_use_id_file    ='../../rapid/input/San_Guad_JHM2/obs_tot_id_San_Guad_2010_2013_full.csv'|" \
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
#Simulation 25/25
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/25"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp21_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_exp21.nc'
rapd_file="tmp_run_$sim.txt"
comp_file="tmp_run_comp_$sim.txt"
sed -i -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
       -e "s|IS_opt_run         =.*|IS_opt_run         =3|"                    \
       -e "s|IS_radius          =.*|IS_radius          =0|"                    \
       -e "s|IS_obs_use         =.*|IS_obs_use         =36|"                   \
       -e "s|obs_use_id_file    =.*|obs_use_id_file    ='../../rapid/input/San_Guad_JHM2/obs_tot_id_San_Guad_2010_2013_full.csv'|" \
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

#-------------------------------------------------------------------------------
#Remove symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist


#*******************************************************************************
#Done
#*******************************************************************************
echo "Success on all tests"
echo "********************"
