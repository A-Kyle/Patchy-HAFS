#!/bin/bash

## sbatch directives for Slurm scheduler

#SBATCH --account=hur-aoml
#SBATCH --job-name="testchgres"
#SBATCH -n 6
#SBATCH --tasks-per-node=6
#SBATCH --cpus-per-task=6
#SBATCH -o testchgres.%j.log
#SBATCH -e testchgres.%j.err
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

# include settings for chgres program
. settings_sys.sh
. settings_grid.sh
. settings_chgres.sh

# run shell script containing calls to grid-based executables
./run_chgres_ic.sh

