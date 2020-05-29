#!/bin/bash

set -ax

if [ ${gtype} != regional ] ; then
  i=1
  while [ $i -le ${ntiles} ] ; do
    srun ./run_orog_single.sh $i &
    i=`expr $i + 1`
  done
else
  # for regional, only do the 7th tile.
  # will need to change this if domain
  # configurations for regional grids changes.
  srun ./run_orog_single.sh 7 &
fi

wait