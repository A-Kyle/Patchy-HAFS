#!/bin/bash

##===============================================================##
#  Topography settings                                            #
#                                                                 #
#   This script is essentially a look-up table for topographical  #
#   parameters associated with valid grid resolutions.            #
#   I don't know where these values come from.                    #
#   Alter this information at your own risk.                      #
#                                                                 #
#   This script is invoked within the grid settings script        #
#   settings_grid.sh.                                             #
##===============================================================##

set -ax

# valid options:  48 (200km), 96 (100km), 192 (50km),
#                 384 (25km), 768 (13km), 1152 (8.5km),
#                 1536 (6.5km), 2304 (4.3km), 3072 (3.2km),
#                 4608 (2.1km), 6144 (1.6km)

if [ $res -eq 48 ]; then
 export cd4=0.12;  export max_slope=0.12; export n_del2_weak=4;   export peak_fac=1.1
elif [ $res -eq 96 ]; then
 export cd4=0.12;  export max_slope=0.12; export n_del2_weak=8;   export peak_fac=1.1
elif [ $res -eq 128 ]; then
 export cd4=0.13;  export max_slope=0.12; export n_del2_weak=8;   export peak_fac=1.1
elif [ $res -eq 192 ]; then
 export cd4=0.15;  export max_slope=0.12; export n_del2_weak=12;  export peak_fac=1.05
elif [ $res -eq 384 ]; then
 export cd4=0.15;  export max_slope=0.12; export n_del2_weak=12;  export peak_fac=1.0
elif [ $res -eq 768 ]; then
 export cd4=0.15;  export max_slope=0.12; export n_del2_weak=16;   export peak_fac=1.0
elif [ $res -eq 1152 ]; then
 export cd4=0.15;  export max_slope=0.16; export n_del2_weak=20;   export peak_fac=1.0
elif [ $res -eq 1536 ]; then
 export cd4=0.15;  export max_slope=0.24; export n_del2_weak=20;   export peak_fac=1.0
elif [ $res -eq 2304 ]; then
 export cd4=0.15;  export max_slope=0.27; export n_del2_weak=22;   export peak_fac=1.0
elif [ $res -eq 3072 ]; then
 export cd4=0.15;  export max_slope=0.30; export n_del2_weak=24;   export peak_fac=1.0
elif [ $res -eq 4608 ]; then
 export cd4=0.15;  export max_slope=0.33; export n_del2_weak=26;   export peak_fac=1.0
elif [ $res -eq 6144 ]; then
 export cd4=0.15;  export max_slope=0.36; export n_del2_weak=28;   export peak_fac=1.0
else
 echo "grid C$res not supported, exit"
 exit 1
fi
