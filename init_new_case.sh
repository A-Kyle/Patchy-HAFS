#!/bin/bash

##===============================================================##
#  Initialize New Case Directory                                  #
#                                                                 #
#   This script should be run to create a new directory           #
#   that contains all necessary information pertaining to a       #
#   specific case for research or development/testing.            #
#                                                                 #
#   It will create a new directory named after the argument       #
#   to this script.                                               #
#   It then copies over the required "settings" files from the    #
#   ${HAFS}/run directory, and creates an empty "data"            #
#   subdirectory (used for input in chgres).                      #
##===============================================================##

if [ $# -eq 0 ]; then
  echo "No arguments supplied"
  exit 0
fi

casename=$1


if [ ! -d "$casename" ]; then
  mkdir -p ${casename}/data
  cp settings_grid.sh ${casename}/
  cp settings_topo.sh ${casename}/
  cp settings_chgres.sh ${casename}/
  cp settings_forecast.sh ${casename}/
else
  echo "That directory (case) already exists."
  exit 0
fi