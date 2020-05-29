#!/bin/bash

set -ax

if [ ${gtype} != uniform ] && [ ${gtype} != stretch ] && \
   [ ${gtype} != nest ] && [ ${gtype} != regional ] ; then
  echo "Error (run_shave): Bad grid type specified."
  exit 1
elif [ ${gtype} != regional ] ; then
  echo "Note (run_shave): ${gtype} grid specified."
  echo "                  No shaving necessary. Exiting."
  exit 0
fi

exe_shave=${EXEChafs}/hafs_shave.x
if [ ! -e $exe_shave ] ; then
  echo "Error (run_shave): Could not find executable."
  exit 1
fi

# number of points in parent domain
nx=`expr ${iend_nest} - ${istart_nest} + 1`
ny=`expr ${jend_nest} - ${jstart_nest} + 1`
# number of compute grid points
nx_com=`expr $nx \* ${refine_ratio} / 2`
ny_com=`expr $ny \* ${refine_ratio} / 2`

cd ${filter_dir}

i=7 # Working with tile #7 on the regional domain.
    # Future updates to domains or nesting will likely benefit with
    # a non-hardcoded value here (unless that value is 0 or 1).

# Shave grid and orog files with halo=${halochg}.
# This is so that chgres will create BC's
# with ${halochg} rows/columns.
echo $nx_com $ny_com ${halochg} \
    \'${grid_dir}/${grid_name}.tile${i}.nc\' \
    \'${grid_dir}/${grid_name}.tile${i}.shave.nc\' >input.shave.grid.halo${halochg}
echo $nx_com $ny_com ${halochg} \
    \'${orog_dir}/${oro_name}.tile${i}.nc\' \
    \'${orog_dir}/${oro_name}.tile${i}.shave.nc\' >input.shave.orog.halo${halochg}

${MPIRUN} $exe_shave < input.shave.orog.halo${halochg}
if [ $? -ne 0 ]; then
  echo "Error (run_shave): hafs_shave returned non-zero status."
  exit 1
fi
${MPIRUN} $exe_shave < input.shave.grid.halo${halochg}
if [ $? -ne 0 ]; then
  echo "Error (run_shave): hafs_shave returned non-zero status."
  exit 1
fi

# Link the shaved files with the halo of ${halochg}.
ln -sf ${grid_name}.tile${i}.shave.nc ${grid_out_dir}/${grid_name}.tile${i}.halo${halochg}.nc
ln -sf ${oro_name}.tile${i}.shave.nc ${grid_out_dir}/${oro_name}.tile${i}.halo${halochg}.nc

# Now shave the orography file with halo of ${halo}.
# This is necessary for running the model.
echo $nx_com $ny_com ${halo} \
    \'${grid_dir}/${grid_name}.tile${i}.nc\' \
    \'${grid_dir}/${grid_name}.tile${i}.shave.nc\' >input.shave.grid.halo${halo}
echo $nx_com $ny_com ${halo} \
    \'${orog_dir}/${oro_name}.tile${i}.nc\' \
    \'${orog_dir}/${oro_name}.tile${i}.shave.nc\' >input.shave.orog.halo${halo}

${MPIRUN} $exe_shave < input.shave.orog.halo${halo}
if [ $? -ne 0 ]; then
  echo "Error (run_shave): hafs_shave returned non-zero status."
  exit 1
fi
${MPIRUN} $exe_shave < input.shave.grid.halo${halo}
if [ $? -ne 0 ]; then
  echo "Error (run_shave): hafs_shave returned non-zero status."
  exit 1
fi

# Link the shaved files with the halo of ${halo}.
ln -sf ${grid_name}.tile${i}.shave.nc ${grid_out_dir}/${grid_name}.tile${i}.halo${halo}.nc
ln -sf ${oro_name}.tile${i}.shave.nc ${grid_out_dir}/${oro_name}.tile${i}.halo${halo}.nc

# Now shave the orography file with halo of 0.
echo $nx_com $ny_com 0 \
    \'${grid_dir}/${grid_name}.tile${i}.nc\' \
    \'${grid_dir}/${grid_name}.tile${i}.shave.nc\' >input.shave.grid.halo0
echo $nx_com $ny_com 0 \
    \'${orog_dir}/${oro_name}.tile${i}.nc\' \
    \'${orog_dir}/${oro_name}.tile${i}.shave.nc\' >input.shave.orog.halo0

${MPIRUN} $exe_shave < input.shave.orog.halo0
if [ $? -ne 0 ]; then
  echo "Error (run_shave): hafs_shave returned non-zero status."
  exit 1
fi
${MPIRUN} $exe_shave < input.shave.grid.halo0
if [ $? -ne 0 ]; then
  echo "Error (run_shave): hafs_shave returned non-zero status."
  exit 1
fi

# Link the shaved files with the halo of 0.
ln -sf ${grid_name}.tile${i}.shave.nc ${grid_out_dir}/${grid_name}.tile${i}.halo0.nc
ln -sf ${oro_name}.tile${i}.shave.nc ${grid_out_dir}/${oro_name}.tile${i}.halo0.nc

exit 0
