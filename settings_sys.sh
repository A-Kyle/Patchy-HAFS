#!/bin/bash

##===============================================================##
#  System settings                                                #
#                                                                 #
#   This shell script is meant to establish the environmental     #
#   variables associated with the runtime environment.            #
#   It sets paths to important directories (e.g., those           #
#   containing executable files and paths to output) and defines  #
#   commands specific to the way the executable files are run.    #
#                                                                 #
#   This file should contain declarations that remain             #
#   unchanged across the execution of the various programs        #
#   that comprise HAFS.                                           #
#                                                                 #
#   This script should be invoked prior to all executions of      #
#   HAFS components.                                              #
##===============================================================##

set -ax

# set environment vars for HAFS directories
export HOMEhafs=/mnt/lfs4/HFIP/hur-aoml/Kyle.Ahern/HAFS_MSN/ver.0b/HAFS
export WORKhafs=${HOMEhafs}/run/test_2_nests   # working directory
#export WORKhafs=${HOMEhafs}/run
export  USHhafs=${HOMEhafs}/ush
export PARMhafs=${HOMEhafs}/parm
export EXEChafs=${HOMEhafs}/exec  # executables directory
export  FIXhafs=${HOMEhafs}/fix   # fix directory
#export COMhafs=${COMhafs:-${COMOUT}}

# set environment vars for parallelization
export MPIRUN=srun # default is "srun" from Slurm
