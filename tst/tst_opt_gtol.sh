#!/bin/bash
#*******************************************************************************
#tst_opt_gtol.sh
#*******************************************************************************

#Purpose:
#This script helps with the transition between PETSc 3.6 and PETSc 3.7 in which 
#the convergence tolerances on the function (absolute: fatol, relative: frtol) 
#were deprecated. The only tolerances available now are on the function gradient
#(absolute: gatol, relative: grtol, and relative to initial gradient: gttol). 
#Using the previous default value in RAPID (fatol=0.0001 and frtol=0.0001), and 
#results from previous RAPID optimization experiments, this script computes 
#suggested values of gatol and grtol that can be used in order to reproduce the 
#same results. 
#A total of n (n>=1) arguments can be provided:
# - Argument 1: Name of the 1st text file output from tst_opt_find.sh
# - Argument 2: Name of the 2nd text file output from tst_opt_find.sh (optional)
# - ... 
# - Argument n: Name of the nth text file output from tst_opt_find.sh (optional)
#The script returns the following exit codes
# - 0  if the script found the desired answer
# - 22 if arguments are faulty 
#Author:
#Cedric H. David, 2016-2020.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#$#              --> the number of arguments given
#$@              --> list all arguments given
#$1              --> the first argument given
#sed -n '2p' $1  --> extracts the string in line 2 of argument 1


#*******************************************************************************
#Compute recommended gradient tolerances
#*******************************************************************************

#-------------------------------------------------------------------------------
#Check that input files are given and that they all exist
#-------------------------------------------------------------------------------
if [ "$#" = "0" ]; then
     echo "No file names were provided" 1>&2
     exit 22
fi 
#Check that at least 1 input file is given

for file in "$@"
do 
if [ ! -e "$file" ]; then
     echo "Input file $file doesn't exist" 1>&2
     exit 22
fi
done
#Check that all files exist

#-------------------------------------------------------------------------------
#Find the average value of the final objective function
#-------------------------------------------------------------------------------
phi_avg=0

for file in "$@"
do
     phi_end=`sed -n '4p' $file`
     phi_avg=$(echo $phi_avg + $phi_end | bc -l)
done
phi_avg=$(echo $phi_avg / $# | bc -l)

#-------------------------------------------------------------------------------
#Output recommended gradient tolerances
#-------------------------------------------------------------------------------
gatol=$(echo "sqrt(0.0001)" | bc -l)
grtol=$(echo "sqrt(0.0001 / $phi_avg)" | bc -l)

printf "%3.1e \n" $gatol
printf "%3.1e \n" $grtol


#*******************************************************************************
#End
#*******************************************************************************
