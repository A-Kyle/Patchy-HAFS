#!/bin/bash

##===============================================================##
#  Grid settings                                                  #
#                                                                 #
#   This script contains definitions pertaining to the grid       #
#   used for HAFS.                                                #
#                                                                 #
#   This script should be invoked prior to executions of          #
#   HAFS components that require grid information                 #
#   (which should include most components of HAFS).               #
##===============================================================##

set -ax

# Critical grid settings
export      gtype=nest      # grid type (uniform, stretch, nest, or regional)
export        res=96        # C-resolution (see settings_topo.sh for valid options)

# Settings for non-uniform grids
export stretch_fac=1.5        # Grid stretching factor
export  target_lon=20.0        # center longitude of target or finest resolution domain
export  target_lat=10.0        # center latitude of target or finest resolution domain
                               # BUG: orog program will throw a fit with 0.0 for lon

# Settings for refined grids (nest, regional)
export   parent_dom=6         # Parent domain (tile) number
                              # Note: Tile 6 is hardcoded as the finest domain
                              #       on the non-uniform supergrid
export refine_ratio=4         # Specify the refinement ratio for a nested grid
export  istart_nest=11        # Minimum i-index of nested grid on parent domain
export  jstart_nest=11        # Minimum j-index of nested grid on parent domain
export    iend_nest=42        # Maximum i-index of nested grid on parent domain
export    jend_nest=42        # Maximum j-index of nested grid on parent domain
export  istart_nest_2=51        # Minimum i-index of nested grid on parent domain
export  jstart_nest_2=51        # Minimum j-index of nested grid on parent domain
export    iend_nest_2=82        # Maximum i-index of nested grid on parent domain
export    jend_nest_2=82        # Maximum j-index of nested grid on parent domain
export         halo=3         # halo size for nested grids
export     halogrid=5         # halo size for grid/orog generation
export      halochg=4         # halo size used in chgres

# Settings for nested grids
export num_nests=2      # number of nests

# I/O settings
export grid_dir=${WORKhafs}/grid    # directory for grid data
export orog_dir=${WORKhafs}/orog    # directory for topographical data
export filter_dir=${WORKhafs}/filter_topo    # directory for filtered topography
export sfc_dir=${WORKhafs}/sfc      # directory for static surface data
export grid_out_dir=${grid_dir}/out      # directory for storing output
export grid_name=C${res}_grid       # base name for grid tile files
export mosaic_name=C${res}_mosaic   # base name for mosaic files
export oro_name=C${res}_oro         # base name for orog files


# Declare the number of tiles/domains for the complete grid
if [ $gtype = uniform ] ; then
  export ntiles=6       # the uniform grid on the cubed sphere
                        # strictly has 6 domains/tiles.
elif [ $gtype = stretch ] ; then
  export ntiles=6       # the stretched grid on the cubed sphere
                        # strictly has 6 domains/tiles.
elif [ $gtype = nest ] ; then
  export ntiles=`expr $num_nests + 6 `  # the number of domains/tiles
                                          # is the number of nests plus 6 faces on
                                          # the cubed sphere.
elif [ $gtype = regional ] ; then
  export ntiles=1         # For a regional set-up, there's only 1 domain/tile.
                          # Adding telescoping regional nests would require work here.
fi

. settings_topo.sh
