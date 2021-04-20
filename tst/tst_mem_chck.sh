#!/bin/bash
#*******************************************************************************
#tst_mem_chck.sh
#*******************************************************************************

#Purpose:
#This script checks that the matrix memory allocation was optimal after having
#run RAPID with the -info option and the saved its standard output in a text
#file which is used here as the unique input. 
#A total of 1 argument must be provided:
# - Argument 1: Name of the text file
#The script returns the following exit codes
# - 0  if the script finds that the matrix memory allocation was optimal
# - 22 if arguments are faulty 
# - 44 if the script finds that the matrix memory allocation was NOT optimal
#Author:
#Cedric H. David, 2018-2021.


#*******************************************************************************
#Notes on tricks used here
#*******************************************************************************
#grep -q "str" file    --> checks if "str" exists in file.
#grep -e "str" file    --> finds a string expression "str" in file.
#wc -l                 --> counts the number of lines
#echo "eq" | bc -l     --> computes the results of equation "eq"


#*******************************************************************************
#Notes on memory allocation in RAPID
#*******************************************************************************
#Proper memory allocation in PETSc is checked by information provided during the
#MatAssembly process. This process primarily takes place when matrices are
#created, preallocated, populated, and - more importantly - assembled. However,
#it also occurs as part of some built-in PETSc functions that manipulate
#matrices. In RAPID, these built-in functions include MatCopy and MatShift.
#Following is a summary of matrix that are assembled in RAPID:
# - ZM_hsh_tot        - MatAssemblyEnd    - rapid_hsh_mat.F90
# - ZM_hsh_bas        - MatAssemblyEnd    - rapid_hsh_mat.F90
# - ZM_Net            - MatAssemblyEnd    - rapid_net_mat.F90
# - ZM_A              - MatAssemblyEnd    - rapid_net_mat.F90
# - ZM_T              - MatAssemblyEnd    - rapid_net_mat.F90
# - ZM_TC1            - MatAssemblyEnd    - rapid_net_mat.F90
# - ZM_Net            - MatAssemblyEnd    - rapid_net_mat_brk.F90 (forcing)
# - ZM_T              - MatAssemblyEnd    - rapid_net_mat_brk.F90 (forcing)
# - ZM_Net            - MatAssemblyEnd    - rapid_net_mat_brk.F90 (dam)
# - ZM_T              - MatAssemblyEnd    - rapid_net_mat_brk.F90 (dam)
# - ZM_MC             - MatAssemblyEnd    - rapid_mus_mat.F90
# - ZM_M              - MatAssemblyEnd    - rapid_mus_mat.F90
# - ZM_Obs            - MatAssemblyEnd    - rapid_obs_mat.F90
# - ZM_A              - MatCopy           - rapid_routing_param.F90
# - ZM_TC1            - MatCopy           - rapid_routing_param.F90
# - ZM_A              - MatCopy           - rapid_uq.F90 (before UQ)
# - ZM_A              - MatCopy           - rapid_uq.F90 (after UQ)
# - ZM_A              - MatShift          - rapid_routing_param.F90
# - ZM_A              - MatShift          - rapid_uq.F90 (before UQ)
# - ZM_A              - MatShift          - rapid_uq.F90 (after UQ)
#(This list can be reproduced using grep)
#Note that MatShift does not trigger a MatAssemblyBegin and therefore such
#information cannot be used for inferring the number of matrices created.


#*******************************************************************************
#Check command line arguments
#*******************************************************************************
if [ "$#" != "1" ]; then
     echo "ERROR - One and only one argument must be given" 1>&2
     exit 22
fi
#Make sure a unique input file was given

if [ ! -e "$1" ]; then
     echo "ERROR - Input file doesn't exist" 1>&2
     exit 22
fi
#Make sure input file exists 

grep -q 'petscinitialize' $1
if [ "$?" != "0" ]; then
     echo "ERROR - Input file isn't from RAPID run with -info option" 1>&2
     exit 22
fi
#Make sure the input file looks like a RAPID optimization file


#*******************************************************************************
#Command line inputs
#*******************************************************************************
echo "Command line inputs"

file=$1
echo "- " $file


#*******************************************************************************
#Determine the number of cores used for this simulation
#*******************************************************************************
echo "Determining the number of cores used for this simulation"

core=0
pass=0
until [ $pass != 0 ]; do
    grep -q "\[$core" $file
    pass=$?
    if [ $pass == 0 ]; then let core=core+1; fi
done
echo "- $core core(s)" 


#*******************************************************************************
#Checking memory allocation information from .txt file storing RAPID stdout
#*******************************************************************************

#-------------------------------------------------------------------------------
#Checking that allocated storage was not insufficient at assembly begin (// only
#-------------------------------------------------------------------------------
echo "Checking that allocated storage was not insufficient at assembly begin"  \
     "(// only)"

IS_beg_prf=`grep -e 'MatAssemblyBegin' $file | wc -l`
#Number of occurences of 'Number of mallocs'
IS_beg_fil=`grep -e 'MatAssemblyBegin' $file | grep '0 mallocs' | wc -l`
#Number of occurences of 'Number of mallocs' that have 0 new memory added

echo "- $IS_beg_prf occurences of 'MatAssemblyBegin'"
echo "- $IS_beg_fil occurences of 'MatAssemblyBegin ... 0 mallocs'"

if [ $IS_beg_prf == $IS_beg_fil ]; then 
     echo "- OK"
else
     echo "ERROR - Allocated storage was insufficient" 1>&2
     exit 44
fi

#-------------------------------------------------------------------------------
#Checking that allocated storage was not excessive at assembly end
#-------------------------------------------------------------------------------
echo "Checking that allocated storage was not excessive at assembly end"

IS_exc_prf=`grep 'storage space' $file | wc -l`
#Number of occurences of 'storage space'
IS_exc_fil=`grep 'storage space: 0 unneeded' $file | wc -l`
#Number of occurences of 'storage space' that have 0 unneeded storage

echo "- $IS_exc_prf occurences of 'MatAssemblyEnd ... storage space:"
echo "- $IS_exc_fil occurences of 'MatAssemblyEnd ... storage space: 0 unneeded"

if [ $IS_sto_prf == $IS_sto_fil ]; then
     echo "- OK"
else
     echo "ERROR - Allocated storage was excessive" 1>&2
     exit 44
fi

#-------------------------------------------------------------------------------
#Checking that allocated storage was not insufficient at assembly end
#-------------------------------------------------------------------------------
echo "Checking that allocated storage was not insufficient at assembly end"

IS_end_prf=`grep 'Number of mallocs' $file | wc -l`
#Number of occurences of 'Number of mallocs'
IS_end_fil=`grep 'Number of mallocs during MatSetValues() is 0' $file | wc -l`
#Number of occurences of 'Number of mallocs' that have 0 new memory added

echo "- $IS_end_prf occurences of 'MatAssemblyEnd_SeqAIJ(): Number of"         \
     "mallocs during MatSetValues()'"
echo "- $IS_end_fil occurences of 'MatAssemblyEnd_SeqAIJ(): Number of"         \
     "mallocs during MatSetValues() is 0'"

if [ $IS_end_prf == $IS_end_fil ]; then 
     echo "- OK"
else
     echo "ERROR - Allocated storage was insufficient" 1>&2
     exit 44
fi

#-------------------------------------------------------------------------------
#Inferring the number of matrices that were assembled
#-------------------------------------------------------------------------------
echo "Inferring the number of matrices that were assembled"

if [ $core == 1 ]; then
     IS_exc_mat=`echo $IS_exc_prf | bc -l`
     IS_end_mat=`echo $IS_end_prf | bc -l`
     #A total of 1 PETSc matrix per core and per mathematical matrix is created
     #in serial mode
else
     IS_exc_mat=`echo $IS_exc_prf/$core/2 | bc -l`
     IS_end_mat=`echo $IS_end_prf/$core/2 | bc -l`
     #A total of 2 PETSc matrices (diag and off-diag) per core and per
     #mathematical matrix is created in parallel
fi

if [ $IS_exc_mat == $IS_end_mat ]; then
     echo "- $IS_exc_mat matrices assembled"
else
     echo "ERROR - Inconsistent number of matrices assembled:"                 \
          "$IS_exc_mat, $IS_end_mat" 1>&2
fi
     

#*******************************************************************************
#Done
#*******************************************************************************
