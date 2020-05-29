#!/bin/bash

set -ax

if [ ${gtype} != uniform ] && [ ${gtype} != stretch ] && \
   [ ${gtype} != nest ] && [ ${gtype} != regional ] ; then
  echo "Error (run_filtertopo): Bad grid type specified."
  exit 1
elif [ ${gtype} = nest ] || [ ${gtype} = regional ] ; then
  echo "Note (run_filtertopo): ${gtype} grid specified."
  echo "                       Topo filtering will be done online. Exiting."
  exit 0
fi

exe_filter=${EXEChafs}/hafs_filter_topo.x
if [ ! -e $exe_filter ] ; then
  echo "Error (run_filtertopo): Could not find executable."
  exit 1
fi

if [ ${gtype} = stretch ] ; then
  stretch=${stretch_fac}
  refine=${refine_ratio}
else
  stretch=1.0
  refine=1
fi
(( regional = ${gtype}=regional?.true.:.false.))

# Create and move into working directory
mkdir -p ${filter_dir}
cd ${filter_dir}

# Link necessary data to working directory
ln -sf ${grid_dir}/${mosaic_name}.nc .
ln -sf ${grid_dir}/${grid_name}.tile?.nc .
ln -sf ${orog_dir}/${oro_name}.tile?.nc .

# Write namelist for the executable
cat > input.nml <<EOF
&filter_topo_nml
  grid_file = ${mosaic_name}.nc
  topo_file = ${oro_name}
  mask_field = "land_frac"     ! Defaults:
  cd4 = ${cd4}                 ! 0.15
  peak_fac =  ${peak_fac}      ! 1.0
  max_slope = ${max_slope}     ! 0.12
  n_del2_weak = ${n_del2_weak} ! 16
  regional = $regional
  stretch_fac = $stretch
  refine_ratio = $refine
  res = ${res}
  /
EOF

# Run the topography filtering exe
${MPIRUN} $exe_filter

if [ $? -ne 0 ]; then
  echo "Error (run_filtertopo): hafs_filter_topo returned non-zero status."
  exit 1
else
  echo "Successfully running filter topography."
fi

exit 0
