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
#Simulation 19/21 UQ daily
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_24H_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_24H.nc"
Vlat_file="../../rapid/input/San_Guad_JHM2/m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_err24H_R286.nc"
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
#Simulation 20/21 UQ daily rescaled
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_24Hscaled_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_24Hscaled.nc"
Vlat_file="../../rapid/input/San_Guad_JHM2/m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_scalederr24H_R286.nc"
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
#Simulation 21/21 UQ monthly
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_M_n1_preonly_tst.nc"
Qout_gold="../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run00_UQ_M.nc"
Vlat_file="../../rapid/input/San_Guad_JHM2/m3_riv_NLDAS_VIC0125_3H_2010_2013_utc_errM_R286.nc"
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
#Simulation 2/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run01_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run01.nc'
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
#Simulation 3/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run02_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run02.nc'
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
#Simulation 4/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run03_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run03.nc'
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
#Simulation 5/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run04_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run04.nc'
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
#Simulation 6/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run05_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run05.nc'
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
#Simulation 7/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run06_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run06.nc'
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
#Simulation 8/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run07_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run07.nc'
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
#Simulation 9/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run08_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run08.nc'
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
#Simulation 10/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run09_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run09.nc'
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
#Simulation 11/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run10_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run10.nc'
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
#Simulation 12/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run11_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run11.nc'
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
#Simulation 13/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run12_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run12.nc'
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
#Simulation 14/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run13_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run13.nc'
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
#Simulation 15/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run14_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run14.nc'
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
#Simulation 16/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run15_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run15.nc'
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
#Simulation 17/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run16_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run16.nc'
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
#Simulation 18/21
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unt=$((unt+1))
sim=$((sim+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./tst_nml_tidy_San_Guad_JHM2.sh
echo "Running simul. $sim/21"
Qout_file='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run17_n1_preonly_tst.nc'
Qout_gold='../../rapid/output/San_Guad_JHM2/Qout_San_Guad_DA_run17.nc'
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

#-------------------------------------------------------------------------------
#Remove symbolic list to default namelist
#-------------------------------------------------------------------------------
rm -f rapid_namelist


#*******************************************************************************
#Done
#*******************************************************************************
echo "Success on all tests"
echo "********************"
