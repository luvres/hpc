#!/bin/bash
#SBATCH --partition=gpu-titan-v    # -p
#SBATCH --nodes=1                  # -N | node count, 1 nodes reserved
#SBATCH --time=24:00:00            # -t | total run time limit (D-HH:MM:SS)
#SBATCH --output=./logs/slurm.log  # Standard output and error log
#SBATCH --error=./logs/slurm.log
###########
#export APPTAINER_BIND="/scratch/$USER"
export CONTAINER_FILE="/opt/images/squad3py39.sif"
###########
#
# Start job
#
apptainer run ${CONTAINER_FILE} python -u script.py
