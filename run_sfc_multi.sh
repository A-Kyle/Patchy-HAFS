#!/bin/bash

#----------------------------------------------------------------
# Make surface static fields - vegetation type, soil type, etc.
#
# For global grids with a nest, the program is run twice.  First
# to create the fields for the six global tiles.  Then to create
# the fields on the high-res nest.  This is done because the
# ESMF libraries can not interpolate to seven tiles at once.
# Note:
# Stand-alone regional grids may be run with any number of
# tasks.  All other configurations must be run with a
# MULTIPLE OF SIX MPI TASKS.

set -ax

if [ ${gtype} != uniform ] && [ ${gtype} != stretch ] && \
   [ ${gtype} != nest ] && [ ${gtype} != regional ] ; then
  echo "Error (run_sfc): Bad grid type specified."
  exit 1
fi

exe_sfc=${EXEChafs}/hafs_sfc_climo_gen.x
if [ ! -e $exe_sfc ] ; then
  echo "Error (run_sfc): Could not find executable."
  exit 1
fi

input_sfc_dir=${FIXhafs}/fix_sfc_climo
workdir=${sfc_dir}/work
mkdir -p $workdir
cd $workdir

if [ ${gtype} != regional ]; then
  halo=0
  orog_files=""
  i=1
  num_coarse=6
  while [ $i -le $num_coarse ] ; do
    if [ $i -ne $num_coarse ] ; then
      orog_files=${orog_files}'"'${oro_name}'.tile0'${i}'.nc",'
    else
      orog_files=${orog_files}'"'${oro_name}'.tile0'${i}'.nc"'
    fi
    i=`expr $i + 1`
  done
else
  halo=${halochg}
  i=7 # just using tile #7, the regional domain.
  orog_files='"'${oro_name}'.tile'${i}'.nc"'
  ln -sf ${grid_out_dir}/${grid_name}.tile${i}.halo${halochg}.nc ${grid_out_dir}/${grid_name}.tile${i}.nc
  ln -sf ${grid_out_dir}/${oro_name}.tile0${i}.halo${halochg}.nc ${grid_out_dir}/${oro_name}.tile0${i}.nc
fi

if [ ${gtype} != nest ]; then
  mosaic_file=${grid_dir}/${mosaic_name}.nc
else
  mosaic_file=${grid_dir}/${mosaic_name}_coarse.nc
fi

# Write namelist for the executable
cat > ./fort.41 <<EOF
&config
  input_facsf_file="${input_sfc_dir}/facsf.1.0.nc"
  input_substrate_temperature_file="${input_sfc_dir}/substrate_temperature.2.6x1.5.nc"
  input_maximum_snow_albedo_file="${input_sfc_dir}/maximum_snow_albedo.0.05.nc"
  input_snowfree_albedo_file="${input_sfc_dir}/snowfree_albedo.4comp.0.05.nc"
  input_slope_type_file="${input_sfc_dir}/slope_type.1.0.nc"
  input_soil_type_file="${input_sfc_dir}/soil_type.statsgo.0.05.nc"
  input_vegetation_type_file="${input_sfc_dir}/vegetation_type.igbp.0.05.nc"
  input_vegetation_greenness_file="${input_sfc_dir}/vegetation_greenness.0.144.nc"
  mosaic_file_mdl="${mosaic_file}"
  orog_dir_mdl="${grid_out_dir}"
  orog_files_mdl=${orog_files}
  halo=${halo}
  maximum_snow_albedo_method="bilinear"
  snowfree_albedo_method="bilinear"
  vegetation_greenness_method="bilinear"
  /
EOF

# remember: tasks must be a multiple of 6.
#srun --ntasks=6 --ntasks-per-node=6 --cpus-per-task=1 $exe_sfc
${MPIRUN} $exe_sfc

rc=$?
if [ $rc == 0 ]; then
  if [ ${gtype} != regional ]; then
    for files in *.nc ; do
      if [ -f $files ]; then
        mv $files ${sfc_dir}/C${res}.${files}
      fi
    done
  else
    for files in *.halo.nc ; do
      if [ -f $files ]; then
        file2=${files%.halo.nc}
        mv $files ${sfc_dir}/C${res}.${file2}.halo${HALO}.nc
      fi
    done
    for files in *.nc ; do
      if [ -f $files ]; then
        file2=${files%.nc}
        mv $files ${sfc_dir}/C${res}.${file2}.halo0.nc
      fi
    done
  fi  # is regional?
else
  echo "Error (run_sfc): hafs_sfc_climo_gen returned non-zero status."
  exit $rc
fi

if [ ${gtype} = regional ]; then
  tile=7
  rm -f ${grid_out_dir}/${grid_name}.tile${tile}.nc
  rm -f ${grid_out_dir}/${oro_name}.tile0${tile}.nc
fi

#----------------------------------------------------------------
# Run for the nests - tile 7+.
#----------------------------------------------------------------

if [ $gtype = nest ]; then
  tmpdir="tmp"
  mkdir -p $tmpdir

  for i in `seq 7 ${ntiles}`; do

    mosaic_file=${grid_out_dir}/${mosaic_name}_nested0${i}.nc
    orog_files='"'${oro_name}'.tile0'${i}'.nc"'

cat>./fort.41<<EOF
&config
    input_facsf_file="${input_sfc_dir}/facsf.1.0.nc"
    input_substrate_temperature_file="${input_sfc_dir}/substrate_temperature.1.0.nc"
    input_maximum_snow_albedo_file="${input_sfc_dir}/maximum_snow_albedo.0.05.nc"
    input_snowfree_albedo_file="${input_sfc_dir}/snowfree_albedo.4comp.0.05.nc"
    input_slope_type_file="${input_sfc_dir}/slope_type.1.0.nc"
    input_soil_type_file="${input_sfc_dir}/soil_type.statsgo.0.05.nc"
    input_vegetation_type_file="${input_sfc_dir}/vegetation_type.igbp.0.05.nc"
    input_vegetation_greenness_file="${input_sfc_dir}/vegetation_greenness.0.144.nc"
    mosaic_file_mdl="${mosaic_file}"
    orog_dir_mdl="${grid_out_dir}"
    orog_files_mdl=${orog_files}
    halo=${halo}
    maximum_snow_albedo_method="bilinear"
    snowfree_albedo_method="bilinear"
    vegetation_greenness_method="bilinear"
    /
EOF

    ${MPIRUN} $exe_sfc

    rc=$?
    if [ $rc == 0 ]; then
      echo "Note (run_sfc): Success for tile ${i}"
    else
      echo "Error (run_sfc): hafs_sfc_climo_gen returned non-zero status."
      exit $rc
    fi

  done

fi

cd ${grid_out_dir}
ln -sf ${sfc_dir}/*.nc .

# End of run for the global nest - tile 7.
#----------------------------------------------------------------

exit 0
