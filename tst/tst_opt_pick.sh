#!/bin/bash
#*******************************************************************************
#tst_opt_pick.sh
#*******************************************************************************

#Purpose:
#This script picks the best values of Lamba k, Lambda x and Phi in a series of
#text files (from tst_opt_find.sh) provided as input   
#A total of at least one argument must be provided:
# - Argument 1: Name of the text file 1
# - Argument 2: Name of the text file 2 (optional)
# - ...
# - Argument n: Name of the text file n (optional)
#The script returns the following exit codes
# - 0  if the script found the desired answer
# - 22 if arguments are faulty 
# - 33 if the search failed 
#Author:
#Cedric H. David, 2015-2023.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#$#              --> the number of arguments given
#$@              --> list all arguments given


#*******************************************************************************
#Find best RAPID optimization values
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
#Determine which input file leads to best values
#-------------------------------------------------------------------------------
phio=1000000

for file in "$@"
do
     lkc=`sed -n '2p' $file`
     lxc=`sed -n '3p' $file`
     phic=`sed -n '4p' $file`
     bool=`echo "$phic < $phio" | bc -l`   
     if [ "$bool" = "1" ]; then
          lko=$lkc
          lxo=$lxc
          phio=$phic
fi
done

#-------------------------------------------------------------------------------
#Check that best value is not default
#-------------------------------------------------------------------------------
if [ "$phio" = "1000000" ]; then
     echo "The search best values was not successful" 1>&2
     exit 33
fi

#-------------------------------------------------------------------------------
#Output results
#-------------------------------------------------------------------------------
echo "Using: $@"
echo $lko
echo $lxo
echo $phio


#*******************************************************************************
#Done
#*******************************************************************************
