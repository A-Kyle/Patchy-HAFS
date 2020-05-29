#!/bin/bash

set -ax

if [ ${gtype} != uniform ] && [ ${gtype} != stretch ] && \
   [ ${gtype} != nest ] && [ ${gtype} != regional ] ; then
  echo "Error (run_orog): Bad grid type specified."
  exit 1
fi

exe_orog=${EXEChafs}/hafs_orog.x
if [ ! -e $exe_orog ] ; then
  echo "Error (run_orog): Could not find executable."
  exit 1
fi

tile=$1

mkdir -p ${orog_dir}
cd ${orog_dir}

ln -sf ${FIXhafs}/fix_orog/thirty.second.antarctic.new.bin fort.15
ln -sf ${FIXhafs}/fix_orog/landcover30.fixed .
ln -sf ${FIXhafs}/fix_orog/gmted2010.30sec.int fort.235

mtnres=1
lonb=${res}
latb=${res}
jcap=0 #jcap is for Gaussian grid
NR=0
NF1=0
NF2=0
efac=0
blat=0
infile="orog_inputs.$tile.txt"
cust_orog="none"

tfile=${grid_name}.tile${tile}.nc
ln -sf ${grid_dir}/$tfile .
echo $mtnres $lonb $latb $jcap $NR $NF1 $NF2 $efac $blat $tile ${ntiles} > $infile
echo $tfile >> $infile
echo $cust_orog >> $infile
$exe_orog < $infile

if [ $? -ne 0 ] ; then
  echo "Error (run_orog): hafs_orog returned non-zero status for tile $tile."
  exit 1
else
  # The executable should have produced a file,
  # "out.oro.tile##.nc". We need to rename & move it.

  if [ $tile -lt 10 ] ; then
    outfile=${oro_name}.tile0${tile}.nc
    mv ./out.oro.tile0${tile}.nc ${orog_dir}/$outfile
  else
    outfile=${oro_name}.tile${tile}.nc
    mv ./out.oro.tile${tile}.nc ${orog_dir}/$outfile
  fi
  echo "File ${orog_dir}/$outfile created."

  # link orog files to output directory.
  ln -sf ${orog_dir}/${outfile} ${grid_out_dir}/${outfile}
fi

exit 0
