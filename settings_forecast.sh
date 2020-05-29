#!/bin/bash

##===============================================================##
#  Forecast settings                                              #
#                                                                 #
#   glob_layoutx : N of processors on a tile along the x-dir.     #
#   glob_layouty : Same as layoutx but in the y-dir. Note that    #
#             layoutx * layouty * tiles must be equal             #
#             to the N of PEs assigned to the (global) domain.    #
#   layoutx : Similar to glob_layoutx but for the nested domain.  #
#   glob_npx : Number of grid corners in the x-dir on a tile of   #
#         the domain. The N of grid cells across a tile plus one. #
#   glob_npy : Same as npx but in the y-dir.                      #
#   npz : Number of vertical levels. Choice must come with a      #
#         fixed set of hybrid sigma-p levels and model top---     #
#         see "fv_eta.F90" for details.                           #
##===============================================================##

set -ax

export num_hours=6
export dt=90    # integration timestep in seconds (for atmosphere)
export restart_interval=0
export quilting=.true.
export write_groups=1
export write_tasks_per_group=4
export cores_per_node=2
export num_threads=2

export glob_layoutx=4
export glob_layouty=4
export glob_npx=`expr ${res} + 1 `
export glob_npy=`expr ${res} + 1 `

export layoutx=2
export layouty=2

# NOTE: npx and npy are equal if nest sizes are the same.
# variable refinement ratio may also have to alter these...
export npx=$(( (${iend_nest} - ${istart_nest}) * 2 + 3 ))
export npy=$(( (${jend_nest} - ${jstart_nest}) * 2 + 3 ))
export npz=`expr ${levs} - 1 `

# These are for the model_configure namelist.
# I'm not sure exactly what they do, but they're
# probably related to how output works.
export output_grid=rotated_latlon
export output_grid_cen_lon=${target_lon}
export output_grid_cen_lat=${target_lat}
export output_grid_lon1=-35.0
export output_grid_lat1=-30.0
export output_grid_lon2=35.0
export output_grid_lat2=30.0
export output_grid_dlon=0.025
export output_grid_dlat=0.025

export ccpp_suite_regional=HAFS_v0_gfdlmp_nocp
export ccpp_suite_glob=HAFS_v0_gfdlmp
export ccpp_suite_nest=HAFS_v0_gfdlmp_nocp

export forecast_dir=${WORKhafs}/forecast     # top directory for forecast
export forecast_work=${forecast_dir}/work    # directory for runtime
export forecast_in=${forecast_work}/INPUT     # directory for forecast input
export forecast_re=${forecast_work}/RESTART   # directory for restart files
export forecast_out=${forecast_dir}/output   # directory for forecast output
