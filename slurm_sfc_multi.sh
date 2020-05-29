#!/bin/bash

## sbatch directives for Slurm scheduler

#SBATCH --account=hur-aoml
#SBATCH --job-name="testsfc"
#SBATCH -n 24
#SBATCH --tasks-per-node=6
#SBATCH --cpus-per-task=6
#SBATCH -o testsfc.%j.log
#SBATCH -e testsfc.%j.err
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

# include grid settings
. settings_sys.sh
. settings_grid.sh

# run shell script containing necessary executables
./run_sfc_multi.sh

