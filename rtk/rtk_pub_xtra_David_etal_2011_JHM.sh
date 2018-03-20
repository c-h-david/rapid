#!/bin/bash
#*******************************************************************************
#rtk_pub_xtra_David_etal_2011_JHM.sh
#*******************************************************************************

#Purpose:
#This script performs extra tests based on RAPID simulations that were used in 
#the writing of:
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
#Cedric H. David, 2017-2017.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************


#*******************************************************************************
#Publication message
#*******************************************************************************
echo "********************"
echo "Extra tests based on:   http://dx.doi.org/10.1175/2011JHM1345.1"
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
#Initialize test count
#*******************************************************************************
unt=0


#*******************************************************************************
#Clean namelist and create symbolic list to default namelist
#*******************************************************************************
./rtk_nml_tidy_San_Guad_JHM.sh
rm -f rapid_namelist
ln -s rapid_namelist_San_Guad_JHM rapid_namelist


#*******************************************************************************
#Test restart capability
#*******************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running test $unt/99"
test_file="tmp_unt_$unt.txt"
comp_file="tmp_unt_comp_$unt.txt"

#-------------------------------------------------------------------------------
#Split runoff file in parts and check their concatenation is the original file
#-------------------------------------------------------------------------------
echo "Extracting time steps"
ncks -O -h -d Time,0,5847                                                      \
     ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst.nc                    \
     ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_part1_rtk.nc          \
     > $test_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed extraction: $test_file" >&2 ; exit $x ; fi

echo "Extracting time steps"
ncks -O -h -d Time,5848,11685                                                  \
     ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst.nc                    \
     ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_part2_rtk.nc          \
     > $test_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed extraction: $test_file" >&2 ; exit $x ; fi

echo "Concatenating files"
ncrcat -O -h                                                                   \
     ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_part1_rtk.nc          \
     ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_part2_rtk.nc          \
     -o ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_parts_rtk.nc       \
     > $test_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed concatenation: $test_file" >&2 ; exit $x ; fi

echo "Comparing files"
cmp                                                                            \
     ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst.nc                    \
     ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_parts_rtk.nc          \
     > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi

#m3_riv has 11686 time steps. The first two years have (366+365)*8=5848 time 
#steps. There remains 11686-5848=5838 time steps for the last (almost) two years
#which corresponds to (365+365)*8-2=5838. The '-2' is because two 3-hourly time
#steps are removed in the conversion from UTC to CST.
#The following NCO options were used: -h (not updating 'history' attribute), -O

#-------------------------------------------------------------------------------
#Run two simulations, concatenate outputs, and compare files
#-------------------------------------------------------------------------------
echo "Running simulation"
Vlat_file='../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_part1_rtk.nc'
ZS_TauM=63158400
BS_opt_Qinit='.false.'
Qinit_file=''
BS_opt_Qfinal='.true.'
Qfinal_file='../output/San_Guad_JHM/Qfinal_San_Guad_1460days_p1_dtR900s_part1_rtk.nc'
Qout_file='../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_part1_rtk.nc'
sed -i -e "s|Vlat_file          =.*|Vlat_file          ='$Vlat_file'|"         \
       -e "s|ZS_TauM            =.*|ZS_TauM            =$ZS_TauM|"             \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =$BS_opt_Qinit|"        \
       -e "s|Qinit_file         =.*|Qinit_file         ='$Qinit_file'|"        \
       -e "s|BS_opt_Qfinal      =.*|BS_opt_Qfinal      =$BS_opt_Qfinal|"       \
       -e "s|Qfinal_file        =.*|Qfinal_file        ='$Qfinal_file'|"       \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $test_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed simulation: $test_file" >&2 ; exit $x ; fi

echo "Running simulation"
Vlat_file='../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_part2_rtk.nc'
ZS_TauM=62985600
BS_opt_Qinit='.true.'
Qinit_file='../output/San_Guad_JHM/Qfinal_San_Guad_1460days_p1_dtR900s_part1_rtk.nc'
BS_opt_Qfinal='.false.'
Qfinal_file=''
Qout_file='../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_part2_rtk.nc'
sed -i -e "s|Vlat_file          =.*|Vlat_file          ='$Vlat_file'|"         \
       -e "s|ZS_TauM            =.*|ZS_TauM            =$ZS_TauM|"             \
       -e "s|BS_opt_Qinit       =.*|BS_opt_Qinit       =$BS_opt_Qinit|"        \
       -e "s|Qinit_file         =.*|Qinit_file         ='$Qinit_file'|"        \
       -e "s|BS_opt_Qfinal      =.*|BS_opt_Qfinal      =$BS_opt_Qfinal|"       \
       -e "s|Qfinal_file        =.*|Qfinal_file        ='$Qfinal_file'|"       \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM  
sleep 3
mpiexec -n 1 ./rapid -ksp_type preonly > $test_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed simulation: $test_file" >&2 ; exit $x ; fi

echo "Concatenating files"
ncrcat -O -h                                                                   \
     ../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_part1_rtk.nc     \
     ../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_part2_rtk.nc     \
     -o ../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_parts_rtk.nc  \
     > $test_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed concatenation: $test_file" >&2 ; exit $x ; fi

echo "Comparing files"
./rtk_run_comp                                                                 \
     ../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s.nc               \
     ../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_parts_rtk.nc     \
     > $comp_file
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi

#-------------------------------------------------------------------------------
#End
#-------------------------------------------------------------------------------
rm ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_part1_rtk.nc
rm ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_part2_rtk.nc
rm ../input/San_Guad_JHM/m3_riv_San_Guad_2004_2007_cst_parts_rtk.nc
rm ../output/San_Guad_JHM/Qfinal_San_Guad_1460days_p1_dtR900s_part1_rtk.nc
rm ../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_part1_rtk.nc
rm ../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_part2_rtk.nc
rm ../output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_parts_rtk.nc
rm $test_file
rm $comp_file
echo "Success"
echo "********************"
fi


#*******************************************************************************
#Test Muskingum operator, regular simulation, threshold=0.0, 1 core
#*******************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Running test $unt/99"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_1.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_1.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_n1_operator_rtk.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s.nc'
IS_opt_routing=4
ZS_threshold=0.0
test_file="tmp_unt_$unt.txt"
comp_file="tmp_unt_comp_$unt.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =$IS_opt_routing|"      \
       -e "s|ZS_threshold       =.*|ZS_threshold       =$ZS_threshold|"        \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM  
sleep 3
mpiexec -n 1 ./rapid > $test_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $test_file
rm $comp_file
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi


#*******************************************************************************
#Test Muskingum operator, regular simulation, threshold=1e-12, 1 core
#*******************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Running test $unt/99"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_1.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_1.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_n1_operator_rtk.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s.nc'
IS_opt_routing=4
ZS_threshold=1e-12
test_file="tmp_unt_$unt.txt"
comp_file="tmp_unt_comp_$unt.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =$IS_opt_routing|"      \
       -e "s|ZS_threshold       =.*|ZS_threshold       =$ZS_threshold|"        \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM  
sleep 3
mpiexec -n 1 ./rapid > $test_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file 1e-1 1 > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $test_file
rm $comp_file
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi


#*******************************************************************************
#Test Muskingum operator, regular simulation, threshold=0.0, 2 cores
#*******************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Running test $unt/99"
k_file='../../rapid/input/San_Guad_JHM/k_San_Guad_2004_1.csv'
x_file='../../rapid/input/San_Guad_JHM/x_San_Guad_2004_1.csv'
Qout_file='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s_n2_operator_rtk.nc'
Qout_gold='../../rapid/output/San_Guad_JHM/Qout_San_Guad_1460days_p1_dtR900s.nc'
IS_opt_routing=4
ZS_threshold=0.0
test_file="tmp_unt_$unt.txt"
comp_file="tmp_unt_comp_$unt.txt"
sed -i -e "s|k_file             =.*|k_file             ='$k_file'   |"         \
       -e "s|x_file             =.*|x_file             ='$x_file'   |"         \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =$IS_opt_routing|"      \
       -e "s|ZS_threshold       =.*|ZS_threshold       =$ZS_threshold|"        \
       -e "s|Qout_file          =.*|Qout_file          ='$Qout_file'|"         \
          rapid_namelist_San_Guad_JHM  
sleep 3
mpiexec -n 2 ./rapid > $test_file
echo "Comparing files"
./rtk_run_comp $Qout_gold $Qout_file > $comp_file 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $comp_file" >&2 ; exit $x ; fi
rm $Qout_file
rm $test_file
rm $comp_file
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi


#*******************************************************************************
#Test Muskingum operator, optimization, threshold=0.0, 1 core
#*******************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Running test $unt/99"
ZS_knorm_init=2
ZS_xnorm_init=3
IS_opt_routing=4
ZS_threshold=0.0
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_1km_hour.csv'
test_file="tmp_unt_$unt.txt"
find_file="tmp_unt_find_$unt.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =$IS_opt_routing|"      \
       -e "s|ZS_threshold       =.*|ZS_threshold       =$ZS_threshold|"        \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 1 ./rapid -tao_gatol 0.01 -tao_grtol 0.0040 > $test_file
./rtk_opt_find.sh $test_file | cat > $find_file
./rtk_opt_comp.sh $find_file 0.1875 3.90625 6.33277 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $x ; fi
rm $test_file
rm $find_file
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi


#*******************************************************************************
#Test Muskingum operator, optimization, threshold=0.0, 2 cores
#*******************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Running test $unt/99"
ZS_knorm_init=2
ZS_xnorm_init=3
IS_opt_routing=4
ZS_threshold=0.0
kfac_file='../../rapid/input/San_Guad_JHM/kfac_San_Guad_1km_hour.csv'
test_file="tmp_unt_$unt.txt"
find_file="tmp_unt_find_$unt.txt"
sed -i -e "s|IS_opt_run         =.*|IS_opt_run         =2|"                    \
       -e "s|IS_opt_routing     =.*|IS_opt_routing     =$IS_opt_routing|"      \
       -e "s|ZS_threshold       =.*|ZS_threshold       =$ZS_threshold|"        \
       -e "s|ZS_knorm_init      =.*|ZS_knorm_init      =$ZS_knorm_init|"       \
       -e "s|ZS_xnorm_init      =.*|ZS_xnorm_init      =$ZS_xnorm_init|"       \
       -e "s|kfac_file          =.*|kfac_file          ='$kfac_file'|"         \
          rapid_namelist_San_Guad_JHM  

sleep 3
mpiexec -n 2 ./rapid -tao_gatol 0.01 -tao_grtol 0.0040 > $test_file
./rtk_opt_find.sh $test_file | cat > $find_file
./rtk_opt_comp.sh $find_file 0.1875 3.90625 6.33277 
x=$? && if [ $x -gt 0 ] ; then  echo "Failed comparison: $find_file" >&2 ; exit $x ; fi
rm $test_file
rm $find_file
./rtk_nml_tidy_San_Guad_JHM.sh
echo "Success"
echo "********************"
fi


#*******************************************************************************
#Remove symbolic list to default namelist and clean namelist
#*******************************************************************************
rm -f rapid_namelist
./rtk_nml_tidy_San_Guad_JHM.sh


#*******************************************************************************
#Done
#*******************************************************************************
echo "Success on all tests"
echo "********************"
