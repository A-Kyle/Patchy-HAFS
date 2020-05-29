#!/bin/bash

set -ax

if [ ${gtype} != uniform ] && [ ${gtype} != stretch ] && [ ${gtype} != nest ] && [ ${gtype} != regional ] ; then
  echo "Error (run_grid): Bad grid type specified."
  exit 1
fi

exe_grid=${EXEChafs}/hafs_make_hgrid.x

if [ ! -e $exe_grid ] ; then
  echo "Error (run_grid): Could not find executable."
  exit 1
fi

mkdir -p ${grid_dir} ${grid_out_dir}
cd ${grid_dir}

nx=`expr ${res} \* 2 `

if [ ${gtype} = uniform ] ; then
  $exe_grid --grid_type gnomonic_ed --nlon $nx --grid_name ${grid_name}
elif [ ${gtype} = stretch ] ; then
  $exe_grid --grid_type gnomonic_ed --nlon $nx --grid_name ${grid_name} \
                      --do_schmidt --stretch_factor ${stretch_fac} \
                      --target_lon ${target_lon} --target_lat ${target_lat}
elif [ ${gtype} = nest ] ; then
  # Try multi-nest execution
  $exe_grid --grid_type gnomonic_ed --nlon $nx --grid_name ${grid_name} \
                      --do_schmidt --stretch_factor ${stretch_fac} \
                      --target_lon ${target_lon} --target_lat ${target_lat} \
                      --nest_grids ${num_nests} --parent_tile 6,6 \
                      --refine_ratio ${refine_ratio},${refine_ratio} \
                      --istart_nest ${istart_nest},${istart_nest_2} \
                      --jstart_nest ${jstart_nest},${jstart_nest_2} \
                      --iend_nest ${iend_nest},${iend_nest_2} \
                      --jend_nest ${jend_nest},${jend_nest_2} \
                      --halo ${halo} \
                      --great_circle_algorithm

elif [ ${gtype} = regional ] ; then
  # delta_halo is the N of points added to each side of the domain
  # to have AT LEAST ${halogrid} halo points for grid generation.
  delta_halo=$(( ( ( ${halogrid} * 2 ) + ${refine_ratio} - 1 ) / ${refine_ratio} ))
  istart_nest_halo=`expr ${istart_nest} - $delta_halo `
  jstart_nest_halo=`expr ${jstart_nest} - $delta_halo `
  iend_nest_halo=`expr ${iend_nest} + $delta_halo `
  jend_nest_halo=`expr ${jend_nest} + $delta_halo `

  $exe_grid --grid_type gnomonic_ed --nlon $nx --grid_name ${grid_name} \
                      --do_schmidt --stretch_factor ${stretch_fac} \
                      --target_lon ${target_lon} --target_lat ${target_lat} \
                      --nest_grid --parent_tile 6 --refine_ratio ${refine_ratio} \
                      --istart_nest $istart_nest_halo --jstart_nest $jstart_nest_halo \
                      --iend_nest $iend_nest_halo --jend_nest $jend_nest_halo --halo ${halo} \
                      --great_circle_algorithm
fi

if [ $? -ne 0 ]; then
  echo "Error (run_grid): hafs_make_hgrid returned non-zero status."
  exit 1
fi

# link grid files to output directory.
cd ${grid_out_dir}
i=1
while [ $i -le ${ntiles} ]; do
  ln -sf ${grid_dir}/${grid_name}.tile${i}.nc .
  i=`expr $i + 1 `
done

exit 0
