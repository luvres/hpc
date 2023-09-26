#!/bin/bash
#SBATCH --partition=cpu-128g          # -p
#SBATCH --nodes=1                     # -N | node count, 1 nodes reserved
#SBATCH --time=12:00:00               # -t | total run time limit (HH:MM:SS)
#SBATCH --output=./logs/slurm.log     # Standard output and error log
#SBATCH --error=./logs/slurm.log
###########
export APPTAINER_BIND="/scratch/$USER"
export CONTAINER_FILE="/opt/images/dtaidistance.sif"
###########
apptainer run ${CONTAINER_FILE} python -u script.py
