#!/bin/bash

## sbatch directives for Slurm scheduler

#SBATCH --account=hur-aoml
#SBATCH --job-name="testforecast"
#SBATCH -n 108
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=2
#SBATCH -o testforecast.%j.log
#SBATCH -e testforecast.%j.err
#SBATCH -t 00:59:00
#SBATCH --exclusive

set -ax
ulimit -s unlimited
ulimit -a

module purge
module load intel
module load szip
module load hdf5
module load netcdf/4.6.1
module list

# include settings for forecase program
. settings_sys.sh
. settings_grid.sh
. settings_chgres.sh
. settings_forecast.sh

# run shell script to set-up and run the forecast executable
./run_forecast_2nest.sh

