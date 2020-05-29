#!/bin/bash

##===============================================================##
#  Chgres settings                                                #
##===============================================================##

set -ax

export ictype=gfsnemsio   # input data type (gfsnemsio, gfsgrib2_master,
export bctype=gfsnemsio   # gfsgrib2_0p25, gfsgrib2ab_0p25, gfsgrib2_0p50,
                          # or gfsgrib2_1p00)

export gfspre=gfs         # gfs or gdas
export   levs=65          # vertical levels in data

export  year=2020
export month=05
export   day=10
export  hour=00

# I/O settings
export ic_dir=${WORKhafs}/chgres_ic     # directory for initial conditions
export bc_dir=${WORKhafs}/chgres_bc     # directory for boundary conditions
export data_dir=${WORKhafs}/data        # directory for input data
