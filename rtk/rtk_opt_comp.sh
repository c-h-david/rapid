#!/bin/bash
#*******************************************************************************
#rtk_opt_comp.sh
#*******************************************************************************

#Purpose:
#This script compares previous RAPID optimization results to the values given in
#a text file (from rtk_opt_find.sh or rtk_opt_pick.sh).  
#A total of 4 arguments must be provided:
# - Argument 1: Name of the text file
# - Argument 2: Value for Lambda k (to be compared with line 2 of text file) 
# - Argument 3: Value for Lambda x (to be compared with line 3 of text file) 
# - Argument 4: Value for Phi (to be compared with line 4 of text file)
#The script returns the following exit codes
# - 0  if the values are the same 
# - 22 if arguments are faulty 
# - 99 if the comparison failed
#Author:
#Cedric H. David, 2015-2017.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#$#              --> the number of arguments given
#$@              --> list all arguments given
#$1              --> the first argument given
#sed -n '2p' $1  --> extracts the string in line 2 of argument 1


#*******************************************************************************
#Perform comparison
#*******************************************************************************
#-------------------------------------------------------------------------------
#Check that 4 arguments are given and that the input text file exists
#-------------------------------------------------------------------------------
if [ "$#" -ne "4" ]; then
     echo "A total of 4 arguments must be provided" 1>&2
     exit 22
fi 
#Check that 4 arguments were provided 

if [ ! -e "$1" ]; then
     echo "Input file $file doesn't exist" 1>&2
     exit 22
fi
#Check that the input file exists 

#-------------------------------------------------------------------------------
#Compare the values in file with values given as arguments
#-------------------------------------------------------------------------------
lkf=`sed -n '2p' $1`
lxf=`sed -n '3p' $1`
phif=`sed -n '4p' $1`

lkc=$2
lxc=$3
phic=$4


bool=`echo "$lkf == $lkc" | bc -l`   
if [ "$bool" = "0" ]; then
     echo "The values for Lambda k don't match: $lkf /= $lkc" 1>&2
     exit 99
fi

bool=`echo "$lxf == $lxc" | bc -l`   
if [ "$bool" = "0" ]; then
     echo "The values for Lambda x don't match: $lxf /= $lxc" 1>&2
     exit 99
fi

bool=`echo "$phif == $phic" | bc -l`   
if [ "$bool" = "0" ]; then
     echo "The values for Phi don't match: $phif /= $phic" 1>&2
     exit 99
fi


#*******************************************************************************
#Done
#*******************************************************************************
