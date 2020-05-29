#!/bin/bash

## sbatch directives for Slurm scheduler

#SBATCH --account=hur-aoml
#SBATCH --job-name="testgrid"
#SBATCH -n 1
#SBATCH --tasks-per-node=6
#SBATCH --cpus-per-task=6
#SBATCH -o testgrid.%j.log
#SBATCH -e testgrid.%j.err
#SBATCH -t 00:59:00
#SBATCH --exclusive

set -ax
ulimit -s unlimited
ulimit -a

module purge
module load intel
module load szip
module load hdf5
module load netcdf
module list

# include settings for grid generation
. settings_sys.sh
. settings_grid.sh

# run shell script containing calls to grid-based executables
./run_grid_multi.sh
./run_mosaic.sh
./run_orog_list.sh
wait

# temporary: For nested configs, these aren't necessary.
#./run_filtertopo.sh
#./run_shave.sh

