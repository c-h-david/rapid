#!/bin/bash
#*******************************************************************************
#rapid_script.sh
#*******************************************************************************

#Purpose:
#This script allows running RAPID and save the outputs generated for both stdout 
#stderr in a text file of which the name is automatically created here based on 
#the current date.  
#Author:
#Cedric H. David, 2010-2016


#*******************************************************************************
#Instructions
#*******************************************************************************
cd $(dirname ${BASH_SOURCE[0]})

FILE=$(date +"%Y-%m-%d_%H-%M-%S_rapid_stdout.txt")

/usr/bin/time mpiexec                  \
              -n 1                     \
              ./rapid                  \
              -ksp_type richardson     \
              1>$FILE 2>>$FILE

#FILE is a name created based on the time when the model started running. FILE 
#contains stdout from running the model (through 1), but also stderr (through 
#2). The output of the time function is also included because it is located in 
#stderr.
#The statement including BASH_SOURCE[0] allows running this script from other 
#directories.
