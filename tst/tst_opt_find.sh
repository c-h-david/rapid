#!/bin/bash
#*******************************************************************************
#tst_opt_find.sh
#*******************************************************************************

#Purpose:
#This script finds the optimal acceptable values of Lamba k, Lambda x and Phi in
#a RAPID optimization text file.  
#A total of 1 argument must be provided:
# - Argument 1: Name of the text file
#The script returns the following exit codes
# - 0  if the script found the desired answer
# - 22 if arguments are faulty 
# - 33 if the search failed 
#Author:
#Cedric H. David, 2015-2020.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#grep -A5 "str" file   --> extracts 5 lines after any line of "file" with "str" 
#grep -B5 "str" file   --> extracts 5 lines before any line of "file" with "str" 
#sed "/str/d" file     --> removes any line that contains "str" from "file"
#sed -n "3p" file      --> extracts the 1+3 line of "file"
#echo "0 <= 5" | bc -l --> gives "1" if statement is true, "0" if not 


#*******************************************************************************
#Extract information from .txt files created by RAPID in optimization mode
#*******************************************************************************
#-------------------------------------------------------------------------------
#Make sure 1 file is given as input, exists, and seems valid RAPID optimization  
#-------------------------------------------------------------------------------
if [ "$#" != "1" ]; then
     echo "One and only one argument must be given" 1>&2
     exit 22
else
     echo "Using: " $1
fi
#Make sure a unique input file was given

if [ ! -e "$1" ]; then
     echo "Input file doesn't exist" 1>&2
     exit 22
fi
#Make sure input file exists 

grep -q 'RAPID mode: optimizing parameters' $1
if [ "$?" != "0" ]; then
     echo "Input file doesn't seem to be a RAPID optimization file" 1>&2
     exit 22
fi
#Make sure the input file looks like a RAPID optimization file

grep -q 'final normalized p=(k,x)' $1
if [ "$?" != "0" ]; then
     echo "RAPID optimization doesn't look like it converged" 1>&2
     exit 22
fi
#Make sure the RAPID optimization converged 

#-------------------------------------------------------------------------------
#Determine final results from RAPID optimization, even if unacceptable values
#-------------------------------------------------------------------------------
lkf=`grep -A6 "final normalized" $1 | sed "/Process/d" | sed -n '4p'`
lxf=`grep -A6 "final normalized" $1 | sed "/Process/d" | sed -n '5p'`
phif=`grep -B4 "final normalized" $1 | sed -n '1p' | sed "s|Objective value=||"`

#echo $lkf
#echo $lxf
#echo $phif

#-------------------------------------------------------------------------------
#Determine acceptable parameters leading to the smallest cost function
#-------------------------------------------------------------------------------
awk '/Observation matrix created/,/Tao Object/' $1 \
    | sed "/Observation matrix created/d" \
    | sed "/Tao Object/d" \
    | sed "/Process/d" \
    >tmp_opt_find.txt
nn=`wc -l < tmp_opt_find.txt`
nn=`echo $((nn-1))`
nn=`echo $((nn/8))`
#nn is the number of simulations with different RAPID parameters

jj=0
#jj is the last simulation with valid RAPID parameters

phio=1000000
lko=0
lxo=0
#Initialization of "optimal" values for cost function and parameters 

for ii in `seq 1 $nn`
do
     loc=`echo $((ii*8))`
     lkc=`sed -n $((loc-3))p tmp_opt_find.txt`     
     lxc=`sed -n $((loc-2))p tmp_opt_find.txt`     
     phic=`sed -n $((loc-0))p tmp_opt_find.txt`
     #The current values of the cost function and parameters out of many trials

     lkc=`echo $lkc | sed -e 's|e-|*10^-|g'`
     lkc=`echo $lkc | sed -e 's|e+|*10^|g'`
     lxc=`echo $lxc | sed -e 's|e-|*10^-|g'`
     lxc=`echo $lxc | sed -e 's|e+|*10^|g'`
     phic=`echo $phic | sed -e 's|e-|*10^-|g'`
     phic=`echo $phic | sed -e 's|e+|*10^|g'`
     #If variables include engineering notation which bc does not understand 

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool=`echo "$lkc > 0" | bc -l`
if [ "$bool" = "1" ]; then
#Making sure Lambda k is strictly positive
bool=`echo "$lxc >= 0" | bc -l`
if [ "$bool" = "1" ]; then
#Making sure Lambda x is positive
bool=`echo "$lxc <= 5" | bc -l`
if [ "$bool" = "1" ]; then
#Making sure Lambda k is smaller than 5
jj=$ii
if [ "$phic" != "**********" ]; then
#Avoiding potential NaNs in cost function value
bool=`echo "$phic < $phio" | bc -l`
if [ "$bool" = "1" ]; then
#Checking if the current phi is smaller than the current optimal phi 
     phio=$phic
     lko=`sed -n $((loc-3))p tmp_opt_find.txt`     
     lxo=`sed -n $((loc-2))p tmp_opt_find.txt`     
fi
fi
fi
fi
fi
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
done
rm tmp_opt_find.txt

#echo $lko
#echo $lxo
#echo $phio
#Best optimal values found by RAPID, only acceptable values included 

#-------------------------------------------------------------------------------
#Determine if search for optimal acceptable values was successful 
#-------------------------------------------------------------------------------
bool=`echo "$lko == 0" | bc -l`
if [ "$bool" = "1" ]; then
#Making sure optimal Lambda k is not default value 
bool=`echo "$lxo == 0" | bc -l`
if [ "$bool" = "1" ]; then
#Making sure optimal Lambda x is not default value 
bool=`echo "$phio == 1000000" | bc -l`
if [ "$bool" = "1" ]; then
#Making sure optimal Phi is not default value 
     successfulsearch=0
fi
fi
fi

if [ "$successfulsearch" = "0" ]; then
     echo "The search for optimal acceptable values was not successful" 1>&2
     exit 33
fi

#-------------------------------------------------------------------------------
#Output the optimal acceptable values
#-------------------------------------------------------------------------------
bool=`echo "$lkf > 0" | bc -l`
if [ "$bool" = "1" ]; then
#Making sure Lambda k is strictly positive
bool=`echo "$lxf >= 0" | bc -l`
if [ "$bool" = "1" ]; then
#Making sure Lambda x is positive
bool=`echo "$lxf <= 5" | bc -l`
if [ "$bool" = "1" ]; then
     acceptableconvergence=1
fi
fi
fi
#Check if RAPID optimization converged to acceptable values

if [ "$acceptableconvergence" = "1" ]; then
     echo $lkf
     echo $lxf
     echo $phif
     echo "(Final results - RAPID optimization converged to acceptable values" \
          "after $nn function evaluations)"
else
     echo $lko
     echo $lxo
     echo $phio
     echo "(Best results - RAPID optimization converged to meaningless values" \
          "after $nn function evaluations, last valid set was evaluation $jj)"
fi
#Output acceptable values


#*******************************************************************************
#Done
#*******************************************************************************
