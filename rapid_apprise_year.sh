#!/bin/bash
#*******************************************************************************
#rapid_apprise_year.sh
#*******************************************************************************

#Purpose:
#This script allows updating the authorship year for all RAPID files. 
#Author:
#Cedric H. David, 2019-2024.


#*******************************************************************************
#Check command line arguments
#*******************************************************************************
if [ "$#" -ne "2" ]; then
     echo "ERROR - A total of 2 arguments must be provided" 1>&2
     exit 22
fi 
#Check that 2 arguments were provided

if ! [[ $1 =~ ^[0-9]+$ ]] || [[ ${#1} != 4 ]]; then
     echo "ERROR - Argument 1 must be a year"
     exit 22
fi
#Check that argument 1 is a year

if ! [[ $2 =~ ^[0-9]+$ ]] || [[ ${#2} != 4 ]]; then
     echo "ERROR - Argument 2 must be a year"
     exit 22
fi
#Check that argument 2 is a year


#*******************************************************************************
#Assign command line arguments to local variables
#*******************************************************************************
old_year=$1
new_year=$2

echo "- Changing the authorship year in all files from $old_year to $new_year"


#*******************************************************************************
#Change year in ./ directory
#*******************************************************************************
for file in `find ./ -maxdepth 1 -type f`
do
     sed -i -e "s|\-$old_year|\-$new_year|" $file
done

echo " . Done for ./ directory"


#*******************************************************************************
#Change year in ./drv/ directory
#*******************************************************************************
for file in `find ./drv/ -maxdepth 1 -type f`
do
     sed -i -e "s|\-$old_year|\-$new_year|" $file
done

echo " . Done for ./drv/ directory"


#*******************************************************************************
#Change year in ./src/ directory
#*******************************************************************************
for file in `find ./src/ -maxdepth 1 -type f`
do
     sed -i -e "s|\-$old_year|\-$new_year|" $file
done

echo " . Done for ./src/ directory"


#*******************************************************************************
#Change year in ./tst/ directory
#*******************************************************************************
for file in `find ./tst/ -maxdepth 1 -type f`
do
     sed -i -e "s|\-$old_year|\-$new_year|" $file
done

echo " . Done for ./tst/ directory"


#*******************************************************************************
#Change year in ./.github/workflows/ directory
#*******************************************************************************
for file in `find ./.github/workflows/ -maxdepth 1 -type f`
do
     sed -i -e "s|\-$old_year|\-$new_year|" $file
done

echo " . Done for ./.github/workflows/ directory"


#*******************************************************************************
#end
#*******************************************************************************
