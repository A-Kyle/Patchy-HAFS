#!/bin/bash

set -ax

if [ ${gtype} != uniform ] && [ ${gtype} != stretch ] && \
   [ ${gtype} != nest ] && [ ${gtype} != regional ] ; then
  echo "Error (run_mosaic): Bad grid type specified."
  exit 1
fi

exe_mosaic=${EXEChafs}/hafs_make_solo_mosaic.x

if [ ! -e $exe_mosaic ] ; then
  echo "Error (run_mosaic): Could not find executable."
  exit 1
fi

cd ${grid_dir}

tfiles=""
tile=1
while [ $tile -le ${ntiles} ] ; do
  if [ $tile -ne ${ntiles} ] ; then
    tfiles=${tfiles}${grid_name}.tile${tile}.nc,
  else
    tfiles=${tfiles}${grid_name}.tile${tile}.nc
  fi
  tile=`expr $tile + 1`
done

if [ ${gtype} = uniform ] || [ ${gtype} = stretch ] ; then

  ${MPIRUN} $exe_mosaic --num_tiles ${ntiles} --dir ${grid_dir} \
                        --mosaic ${mosaic_name} --tile_file $tfiles


elif [ ${gtype} = nest ] ; then

  ${MPIRUN} $exe_mosaic --num_tiles ${ntiles} --dir ${grid_dir} \
                        --mosaic ${mosaic_name} --tile_file $tfiles

  coarsefiles=""
  tile=1
  num_coarse=6
  while [ $tile -le $num_coarse ] ; do
    if [ $tile -ne $num_coarse ] ; then
      coarsefiles=${coarsefiles}${grid_name}.tile${tile}.nc,
    else
      coarsefiles=${coarsefiles}${grid_name}.tile${tile}.nc
    fi
    tile=`expr $tile + 1`
  done

  ${MPIRUN} $exe_mosaic --num_tiles $num_coarse --dir ${grid_dir} \
                        --mosaic ${mosaic_name}_coarse --tile_file $coarsefiles

  # TODO: What should this look like with multiple nests?
  # ${MPIRUN} $exe_mosaic --num_tiles $num_nests --dir ${grid_dir} \
  #                      --mosaic ${mosaic_name}_nested --tile_file ${grid_name}.tile7.nc

  # IDEA: Maybe like this? OR all nests in one mosaic?
  while [ $tile -le ${ntiles} ] ; do
    ${MPIRUN} $exe_mosaic --num_tiles 1 --dir ${grid_dir} \
                          --mosaic ${mosaic_name}_nested0${tile} \
                          --tile_file ${grid_name}.tile${tile}.nc
    tile=`expr $tile + 1`
  done

elif [ ${gtype} = regional ] ; then
  ${MPIRUN} $exe_mosaic --num_tiles $ntiles --dir ${grid_dir} \
                        --mosaic ${mosaic_name} --tile_file ${grid_name}.tile7.nc
fi

# link mosaic files to output directory.
cd ${grid_out_dir}
ln -sf ${grid_dir}/${mosaic_name}.nc .
if [ ${gtype} = nest ] ; then
  ln -sf ${grid_dir}/${mosaic_name}_coarse.nc .
  i=7
  while [ $i -le ${ntiles} ]; do
    ln -sf ${grid_dir}/${mosaic_name}_nested0${i}.nc .
    i=`expr $i + 1`
  done
fi

exit 0
