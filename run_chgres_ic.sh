#!/bin/bash

set -ax

if [ ${gtype} != uniform ] && [ ${gtype} != stretch ] && \
   [ ${gtype} != nest ] && [ ${gtype} != regional ] ; then
  echo "Error (run_chgres_ic): Bad grid type specified."
  exit 1
fi

exe_chgres=${EXEChafs}/hafs_chgres_cube.x
num_coarse=6

if [ ! -e $exe_chgres ] ; then
  echo "Error (run_chgres_ic): Could not find executable."
  exit 1
fi

mkdir -p ${ic_dir}
cd ${ic_dir}

# Use gfs nemsio files from 2019 GFS (fv3gfs)
# Note: currently, generating IC from grib2 file is not supported yet.
if [ $ictype = "gfsnemsio" ]; then
  atm_files_input_grid=${gfspre}.t${hour}z.atmanl.nemsio
  sfc_files_input_grid=${gfspre}.t${hour}z.sfcanl.nemsio
  grib2_file_input_grid=""
  input_type="gaussian"
  varmap_file=""
  fixed_files_dir_input_grid=""
  tracers='"sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"'
  tracers_input='"spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"'
# Use gfs master grib2 files
elif [ $ictype = "gfsgrib2_master" ]; then
  atm_files_input_grid=${gfspre}.t${hour}z.master.pgrb2f000
  sfc_files_input_grid=${gfspre}.t${hour}z.master.pgrb2f000
  grib2_file_input_grid=${gfspre}.t${hour}z.master.pgrb2f000
  input_type="grib2"
  varmap_file="${HOMEhafs}/sorc/hafs_utils.fd/parm/varmap_tables/FV3GFSphys_var_map.txt"
  fixed_files_dir_input_grid="${HOMEhafs}/sorc/hafs_utils.fd/fix/fix_chgres"
  tracers='"sphum","liq_wat","o3mr"'
  tracers_input='"spfh","clwmr","o3mr"'
# Use gfs 0.25 degree grib2 files
elif [ $ictype = "gfsgrib2_0p25" ]; then
  atm_files_input_grid=${gfspre}.t${hour}z.pgrb2.0p25.f000
  sfc_files_input_grid=${gfspre}.t${hour}z.pgrb2.0p25.f000
  grib2_file_input_grid=${gfspre}.t${hour}z.pgrb2.0p25.f000
  input_type="grib2"
  varmap_file="${HOMEhafs}/sorc/hafs_utils.fd/parm/varmap_tables/FV3GFSphys_var_map.txt"
  fixed_files_dir_input_grid="${HOMEhafs}/sorc/hafs_utils.fd/fix/fix_chgres"
  tracers='"sphum","liq_wat","o3mr"'
  tracers_input='"spfh","clwmr","o3mr"'
# Use gfs 0.25 degree grib2 a and b files
elif [ $ictype = "gfsgrib2ab_0p25" ]; then
  atm_files_input_grid=${gfspre}.t${hour}z.pgrb2.0p25.f000
  sfc_files_input_grid=${gfspre}.t${hour}z.pgrb2.0p25.f000
  grib2_file_input_grid=${gfspre}.t${hour}z.pgrb2ab.0p25.f000
  input_type="grib2"
  varmap_file="${HOMEhafs}/sorc/hafs_utils.fd/parm/varmap_tables/FV3GFSphys_var_map.txt"
  fixed_files_dir_input_grid="${HOMEhafs}/sorc/hafs_utils.fd/fix/fix_chgres"
  tracers='"sphum","liq_wat","o3mr"'
  tracers_input='"spfh","clwmr","o3mr"'
# Use gfs 0.50 degree grib2 files
elif [ $ictype = "gfsgrib2_0p50" ]; then
  atm_files_input_grid=${gfspre}.t${hour}z.pgrb2.0p50.f000
  sfc_files_input_grid=${gfspre}.t${hour}z.pgrb2.0p50.f000
  grib2_file_input_grid=${gfspre}.t${hour}z.pgrb2.0p50.f000
  input_type="grib2"
  varmap_file="${HOMEhafs}/sorc/hafs_utils.fd/parm/varmap_tables/FV3GFSphys_var_map.txt"
  fixed_files_dir_input_grid="${HOMEhafs}/sorc/hafs_utils.fd/fix/fix_chgres"
  tracers='"sphum","liq_wat","o3mr"'
  tracers_input='"spfh","clwmr","o3mr"'
# Use gfs 1.00 degree grib2 files
elif [ $ictype = "gfsgrib2_1p00" ]; then
  atm_files_input_grid=${gfspre}.t${hour}z.pgrb2.1p00.f000
  sfc_files_input_grid=${gfspre}.t${hour}z.pgrb2.1p00.f000
  grib2_file_input_grid=${gfspre}.t${cyc}z.pgrb2.1p00.f000
  input_type="grib2"
  varmap_file="${HOMEhafs}/sorc/hafs_utils.fd/parm/varmap_tables/FV3GFSphys_var_map.txt"
  fixed_files_dir_input_grid="${HOMEhafs}/sorc/hafs_utils.fd/fix/fix_chgres"
  tracers='"sphum","liq_wat","o3mr"'
  tracers_input='"spfh","clwmr","o3mr"'
else
  echo "Error (run_chgres_ic): Unsupported input data type."
  exit 1
fi

if [ ${gtype} = nest ] ; then
  mosaic_file="${mosaic_name}_coarse.nc"
  orog_files=""
  i=1
  while [ $i -le $num_coarse ] ; do
    if [ $i -ne $num_coarse ] ; then
      orog_files=${orog_files}'"'${oro_name}'.tile0'${i}'.nc",'
    else
      orog_files=${orog_files}'"'${oro_name}'.tile0'${i}'.nc"'
    fi
    i=`expr $i + 1`
  done
  convert_atm=.true.
  convert_sfc=.true.
  convert_nst=.true.
  input_type="gaussian"
  tracers='"sphum","liq_wat","o3mr","ice_wat","rainwat","snowwat","graupel"'
  tracers_input='"spfh","clwmr","o3mr","icmr","rwmr","snmr","grle"'
  regional=0
  halo_bndy=0
fi

# create namelist and run chgres_cube
#
cat>./fort.41<<EOF
&config
 mosaic_file_target_grid="${grid_out_dir}/${mosaic_file}"
 fix_dir_target_grid="${grid_out_dir}"
 orog_dir_target_grid="${grid_out_dir}"
 orog_files_target_grid=${orog_files}
 vcoord_file_target_grid="${FIXhafs}/fix_am/global_hyblev.l65.txt"
 mosaic_file_input_grid="NULL"
 orog_dir_input_grid="NULL"
 orog_files_input_grid="NULL"
 data_dir_input_grid="${data_dir}"
 atm_files_input_grid="${atm_files_input_grid}"
 sfc_files_input_grid="${sfc_files_input_grid}"
 varmap_file="${varmap_file}"
 cycle_mon=${month}
 cycle_day=${day}
 cycle_hour=${hour}
 convert_atm=${convert_atm}
 convert_sfc=${convert_sfc}
 convert_nst=${convert_nst}
 input_type="${input_type}"
 tracers=${tracers}
 tracers_input=${tracers_input}
 regional=${regional}
 halo_bndy=${halo_bndy}
/
EOF

echo "Note (run_chgres_ic): hafs_chgres_cube initialized."
${MPIRUN} $exe_chgres

if [ $? -ne 0 ]; then
  echo "Error (run_chgres_ic): hafs_chgres_cube returned non-zero status."
  exit 1
fi

if [ ${gtype} = nest ] ; then
  # if this is a nested run, we need to run
  # chgres_ic for the nests individually.
  # The program outputs files using a rigid
  # nomenclature that does not explicitly consider
  # the type of data ingested or the tile number.
  #
  # Hack:
  # If we re-run the program, it will overwrite
  # output for tile #1. We will use a temporary
  # directory to store our previously generated tiles
  # until mosaic/chgres is modified to allow
  # internal handling of multiple nests.
  tmpdir="tmp"
  mkdir -p $tmpdir
  mv gfs_ctrl.nc $tmpdir
  tile=1
  while [ $tile -le $num_coarse ]; do
    # move the output from the coarse tiles
    # to the temporary directory.
    mv out.atm.tile${tile}.nc $tmpdir/atm_data.tile${tile}.nc
    mv out.sfc.tile${tile}.nc $tmpdir/sfc_data.tile${tile}.nc
    tile=`expr $tile + 1 `
  done
  while [ $tile -le ${ntiles} ]; do
    mosaic_file="${mosaic_name}_nested0${tile}.nc"
    orog_files='"'${oro_name}'.tile0'${tile}'.nc"'
# create namelist and run chgres_cube
#
cat>./fort.41<<EOF
&config
 mosaic_file_target_grid="${grid_out_dir}/${mosaic_file}"
 fix_dir_target_grid="${grid_out_dir}"
 orog_dir_target_grid="${grid_out_dir}"
 orog_files_target_grid=${orog_files}
 vcoord_file_target_grid="${FIXhafs}/fix_am/global_hyblev.l65.txt"
 mosaic_file_input_grid="NULL"
 orog_dir_input_grid="NULL"
 orog_files_input_grid="NULL"
 data_dir_input_grid="${data_dir}"
 atm_files_input_grid="${atm_files_input_grid}"
 sfc_files_input_grid="${sfc_files_input_grid}"
 varmap_file="${varmap_file}"
 cycle_mon=${month}
 cycle_day=${day}
 cycle_hour=${hour}
 convert_atm=${convert_atm}
 convert_sfc=${convert_sfc}
 convert_nst=${convert_nst}
 input_type="${input_type}"
 tracers=${tracers}
 tracers_input=${tracers_input}
 regional=${regional}
 halo_bndy=${halo_bndy}
/
EOF

    # Also due to limitations in chgres and/or its
    # required input, fixed data is expected from tile #7
    # regardless of the actual tile passed.
    # It's possible that it uses information from the
    # mosaic file to determine what tile to refer to
    # when grabbing fixed data (note that nested mosaic files
    # always have a tile value of "tile7").
    #
    # Hack:
    # Here we link fix_sfc data from the working tile to
    # the grid output directory AS data in tile #7.
    # SOLN: Fixes to the grid-generation and mosaics
    # might have solved this issue.
#    cd ${sfc_dir}
#    for file in *${tile}.nc ; do
#      if [[ -f $file ]]; then
#        ln -sf ${sfc_dir}/$file ${grid_out_dir}/"${file/${tile}*}"7.nc
#      fi
#    done
#    cd ${ic_dir}

    echo "Note (run_chgres_ic): hafs_chgres_cube initialized for tile ${tile}."
    ${MPIRUN} $exe_chgres

    if [ $? -ne 0 ]; then
      echo "Error (run_chgres_ic): hafs_chgres_cube returned non-zero status."
      exit 1
    fi

    # move the newly generated output
    # to the temporary directory.
    mv out.atm.tile1.nc $tmpdir/atm_data.tile${tile}.nc
    mv out.sfc.tile1.nc $tmpdir/sfc_data.tile${tile}.nc

    # Fix links that we had to alter in our hack.
    cd ${sfc_dir}
    for file in *${tile}.nc ; do
      if [[ -f $file ]]; then
        ln -sf ${sfc_dir}/$file ${grid_out_dir}/$file
      fi
    done
    cd ${ic_dir}

    tile=`expr $tile + 1 `
  done

  # move output for all tiles from the temp
  # directory to the chgres_ic directory.
  mv $tmpdir/*.nc .
fi

exit 0
