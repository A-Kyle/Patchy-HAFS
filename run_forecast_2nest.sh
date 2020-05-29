#!/bin/bash

set -ax

if [ ${gtype} != uniform ] && [ ${gtype} != stretch ] && \
   [ ${gtype} != nest ] && [ ${gtype} != regional ] ; then
  echo "Error (run_forecast): Bad grid type specified."
  exit 1
fi

exe_forecast=${EXEChafs}/hafs_forecast.x

if [ ! -e $exe_forecast ] ; then
  echo "Error (run_forecast): Could not find executable."
  exit 1
fi

mkdir -p ${forecast_dir} ${forecast_in} ${forecast_out} ${forecast_re} \
         ${forecast_work}

cd ${forecast_work}

# Link in the necessary inputs for the forecast.
ln -sf ${ic_dir}/*.nc ${forecast_in}/   # Link ICs from chgres
if [ ${gtype} = regional ]; then
  ln -sf ${bc_dir}/*.nc ${forecast_in}/   # Link BCs from chgres
fi

# Copy over fixed data to the runtime directory.
fix_am_dir=${FIXhafs}/fix_am
cp ${fix_am_dir}/global_solarconstant_noaa_an.txt  solarconstant_noaa_an.txt
cp ${fix_am_dir}/global_h2o_pltc.f77               global_h2oprdlos.f77
cp ${fix_am_dir}/global_sfc_emissivity_idx.txt     sfc_emissivity_idx.txt
cp ${fix_am_dir}/global_co2historicaldata_glob.txt co2historicaldata_glob.txt
cp ${fix_am_dir}/co2monthlycyc.txt                 co2monthlycyc.txt
cp ${fix_am_dir}/global_climaeropac_global.txt     aerosol.dat
cp ${fix_am_dir}/ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77 global_o3prdlos.f77
cp ${fix_am_dir}/global_glacier.2x2.grb .
cp ${fix_am_dir}/global_maxice.2x2.grb .
cp ${fix_am_dir}/RTGSST.1982.2012.monthly.clim.grb .
cp ${fix_am_dir}/global_snoclim.1.875.grb .
cp ${fix_am_dir}/global_snowfree_albedo.bosu.t1534.3072.1536.rg.grb .
cp ${fix_am_dir}/global_albedo4.1x1.grb .
cp ${fix_am_dir}/CFSR.SEAICE.1982.2012.monthly.clim.grb .
cp ${fix_am_dir}/global_tg3clim.2.6x1.5.grb .
cp ${fix_am_dir}/global_vegfrac.0.144.decpercent.grb .
cp ${fix_am_dir}/global_vegtype.igbp.t1534.3072.1536.rg.grb .
cp ${fix_am_dir}/global_soiltype.statsgo.t1534.3072.1536.rg.grb .
cp ${fix_am_dir}/global_soilmgldas.t1534.3072.1536.grb .
cp ${fix_am_dir}/seaice_newland.grb .
cp ${fix_am_dir}/global_shdmin.0.144x0.144.grb .
cp ${fix_am_dir}/global_shdmax.0.144x0.144.grb .
cp ${fix_am_dir}/global_slope.1x1.grb .
cp ${fix_am_dir}/global_mxsnoalb.uariz.t1534.3072.1536.rg.grb .

for file in `ls ${fix_am_dir}/fix_co2_proj/global_co2historicaldata* ` ; do
  # this sed expression truncates the "global_" prefix on the list of files.
  cp $file $(echo $(basename $file) |sed -e "s/global_//g")
done

if [ ${gtype} = nest ]; then
  # Link grid, orog, mosaic data to the input directory.
  tile=1
  while [ $tile -le ${ntiles} ]; do
    # ln -sf ${grid_out_dir}/${oro_name}.tile${tile}.nc INPUT/oro_data.tile${tile}.nc
    # ln -sf ${grid_out_dir}/${grid_name}.tile0${tile}.nc INPUT/${CASE}_grid.tile${tile}.nc
    ln -sf ${grid_out_dir}/${grid_name}.tile${tile}.nc \
            ${forecast_in}/${grid_name}.tile${tile}.nc
    ln -sf ${grid_out_dir}/${oro_name}.tile0${tile}.nc \
            ${forecast_in}/oro_data.tile${tile}.nc
    tile=`expr $tile + 1 `
  done
  ln -sf ${grid_out_dir}/${mosaic_name}.nc ${forecast_in}/grid_spec.nc

  # The next 4 links are a hack GFDL requires for running a nest
  # The two grid file links may be redundant.
  cd ${forecast_in}
  ln -sf ${grid_name}.tile7.nc grid.nest02.tile7.nc
  ln -sf ${grid_name}.tile7.nc ${grid_name}.nest02.tile7.nc
  ln -sf oro_data.tile7.nc oro_data.nest02.tile7.nc
  ln -sf atm_data.tile7.nc gfs_data.nest02.tile7.nc
  ln -sf sfc_data.tile7.nc sfc_data.nest02.tile7.nc
  # What about tile 8 (a second nest)?
  # Perhaps this?
  ln -sf ${grid_name}.tile8.nc grid.nest03.tile8.nc
  ln -sf ${grid_name}.tile8.nc ${grid_name}.nest03.tile8.nc
  ln -sf oro_data.tile8.nc oro_data.nest03.tile8.nc
  ln -sf atm_data.tile8.nc gfs_data.nest03.tile8.nc
  ln -sf sfc_data.tile8.nc sfc_data.nest03.tile8.nc

  # Rename atmos files to gfs. Has to be like this for model.
  i=1
  while [ $i -le 6 ]; do
    mv atm_data.tile${i}.nc gfs_data.tile${i}.nc
    i=`expr $i + 1 `
  done

  cd ${forecast_work}

  # Copy or set up files data_table, diag_table, field_table,
  #   input.nml, input_nest02.nml, model_configure, and nems.configure
  # TEST: going to try using atmos_sos in diag_table for multinest output
  parm_nest_dir="${PARMhafs}/forecast/multinest"
  cp ${parm_nest_dir}/data_table .
  cp ${parm_nest_dir}/diag_table.multi diag_table.tmp
#  cp ${parm_nest_dir}/diag_table.tmp .
  cp ${parm_nest_dir}/field_table .
  cp ${parm_nest_dir}/input.nml.tmp .
  cp ${parm_nest_dir}/input_nest02.nml.tmp .
  cp ${parm_nest_dir}/model_configure.tmp .
  cp ${parm_nest_dir}/nems.configure .

  # Copy xml file for the global nest ccpp physics suite
  ccpp_suite_dir="${HOMEhafs}/sorc/hafs_forecast.fd/FV3/ccpp/suites"
  ccpp_suite_glob_xml="${ccpp_suite_dir}/suite_${ccpp_suite_glob}.xml"
  cp ${ccpp_suite_glob_xml} .

  ndomain=$(( ${num_nests} + 1 )) # +1 for the global grid
  glob_pes=$(( ${glob_layoutx} * ${glob_layouty} * 6 ))

  # Calculate the number of PEs for the nests
  # NOTE: PEs for nest 1 and 2 are equal only
  #       in THIS TEST. For the workflow, we'll need
  #       to account for a variable number of PEs
  #       across grids.
  nest_pes=$(( ${layoutx} * ${layouty} ))
  nest_pes="${nest_pes},${nest_pes}"
  # nest_pes="${nest_pes_nest1},${nest_pes_nest2}, ..."

  # Replace placeholder values in the input namelist template
  # to create coarse-grid input namelist for the forecast
  sed -e "s/_fhmax_/${num_hours}/g" \
      -e "s/_ccpp_suite_/${ccpp_suite_glob}/g" \
      -e "s/_layoutx_/${glob_layoutx}/g" \
      -e "s/_layouty_/${glob_layouty}/g" \
      -e "s/_npx_/${glob_npx}/g" \
      -e "s/_npy_/${glob_npy}/g" \
      -e "s/_npz_/${npz}/g" \
      -e "s/_target_lat_/${target_lat}/g" \
      -e "s/_target_lon_/${target_lon}/g" \
      -e "s/_stretch_fac_/${stretch_fac}/g" \
      -e "s/_ngrids_/${ndomain}/g" \
      -e "s/_glob_pes_/${glob_pes}/g" \
      -e "s/_nest_pes_/${nest_pes}/g" \
      -e "s/_levp_/${levs}/g" \
    input.nml.tmp > input.nml

  # Do the same thing but for the first nested-grid.
  ccpp_suite_nest_xml="${ccpp_suite_dir}/suite_${ccpp_suite_nest}.xml"
  cp ${ccpp_suite_nest_xml} .

  ioffset=$(( (${istart_nest}-1)/2 + 1))
  joffset=$(( (${jstart_nest}-1)/2 + 1))

  sed -e "s/_fhmax_/${num_hours}/g" \
      -e "s/_ccpp_suite_/${ccpp_suite_nest}/g" \
      -e "s/_layoutx_/${layoutx}/g" \
      -e "s/_layouty_/${layouty}/g" \
      -e "s/_npx_/${npx}/g" \
      -e "s/_npy_/${npy}/g" \
      -e "s/_npz_/${npz}/g" \
      -e "s/_target_lat_/${target_lat}/g" \
      -e "s/_target_lon_/${target_lon}/g" \
      -e "s/_stretch_fac_/${stretch_fac}/g" \
      -e "s/_refinement_/${refine_ratio}/g" \
      -e "s/_ioffset_/${ioffset}/g" \
      -e "s/_joffset_/${joffset}/g" \
      -e "s/_ngrids_/${ndomain}/g" \
      -e "s/_glob_pes_/${glob_pes}/g" \
      -e "s/_nest_pes_/${nest_pes}/g" \
      -e "s/_levp_/${levs}/g" \
    input_nest02.nml.tmp > input_nest02.nml

  # Once more for the second nest.
  # In a workflow, this could probably be handled
  # cleanly in a for-loop that iterates through
  # for each nest.
  ioffset=$(( (${istart_nest_2}-1)/2 + 1))
  joffset=$(( (${jstart_nest_2}-1)/2 + 1))

  sed -e "s/_fhmax_/${num_hours}/g" \
      -e "s/_ccpp_suite_/${ccpp_suite_nest}/g" \
      -e "s/_layoutx_/${layoutx}/g" \
      -e "s/_layouty_/${layouty}/g" \
      -e "s/_npx_/${npx}/g" \
      -e "s/_npy_/${npy}/g" \
      -e "s/_npz_/${npz}/g" \
      -e "s/_target_lat_/${target_lat}/g" \
      -e "s/_target_lon_/${target_lon}/g" \
      -e "s/_stretch_fac_/${stretch_fac}/g" \
      -e "s/_refinement_/${refine_ratio}/g" \
      -e "s/_ioffset_/${ioffset}/g" \
      -e "s/_joffset_/${joffset}/g" \
      -e "s/_ngrids_/${ndomain}/g" \
      -e "s/_glob_pes_/${glob_pes}/g" \
      -e "s/_nest_pes_/${nest_pes}/g" \
      -e "s/_levp_/${levs}/g" \
    input_nest02.nml.tmp > input_nest03.nml

fi

# Generate diag_table, model_configure from their templates
# Note to self: What does this namelist do? What are these variables?
echo ${year}${month}${day}.${hour}Z.C${res}.32bit.non-hydro
echo ${year} ${month} ${day} ${hour} 0 0
cat > temp <<EOF
  ${year}${month}${day}.${hour}Z.C${res}.32bit.non-hydro
  ${year} ${month} ${day} ${hour} 0 0
EOF

cat temp diag_table.tmp > diag_table

# NOTE: The number of tasks should account for tasks in writing,
#       running the global domain, and all nested domains.
#       IN THIS TEST, the number of tasks for each nested domain
#       are CONSTANT, but should be allowed to be variable.
ntasks=$(( ${glob_pes} + (${write_groups} * ${write_tasks_per_group}) ))
ntasks=$(( ${ntasks} + (2 * ${layoutx} * ${layouty} ) )) # THIS IS JUST FOR TESTING MSN.
cat model_configure.tmp | sed s/NTASKS/${ntasks}/ | sed s/YR/${year}/ | \
    sed s/MN/${month}/ | sed s/DY/${day}/ | sed s/H_R/${hour}/ | \
    sed s/NHRS/${num_hours}/ | sed s/NTHRD/${num_threads}/ | \
    sed s/NCNODE/${cores_per_node}/ | \
    sed s/_dt_atmos_/${dt}/ | \
    sed s/_restart_interval_/${restart_interval}/ | \
    sed s/_quilting_/${quilting}/ | \
    sed s/_write_groups_/${write_groups}/ | \
    sed s/_write_tasks_per_group_/${write_tasks_per_group}/ | \
    sed s/_app_domain_/${gtype}/ | \
    sed s/_OUTPUT_GRID_/${output_grid}/ | \
    sed s/_CEN_LON_/${output_grid_cen_lon}/ | \
    sed s/_CEN_LAT_/${output_grid_cen_lat}/ | \
    sed s/_LON1_/${output_grid_lon1}/ | \
    sed s/_LAT1_/${output_grid_lat1}/ | \
    sed s/_LON2_/${output_grid_lon2}/ | \
    sed s/_LAT2_/${output_grid_lat2}/ | \
    sed s/_DLON_/${output_grid_dlon}/ | \
    sed s/_DLAT_/${output_grid_dlat}/ \
    >  model_configure

#-------------------------------------------------------------------
# Run the forecast
#-------------------------------------------------------------------

${MPIRUN} $exe_forecast 1>out.C${res} 2>err.C${res}
#${MPIRUN} $exe_forecast
if [ $? -ne 0 ]; then
  echo "Error (run_forecast): hafs_forecast returned non-zero status."
  exit 1
fi

exit 0
