#!/bin/bash
#SBATCH --partition=gpu-rtx3090       # -p
#SBATCH --constraint=GPU              # -C feature
#SBATCH --gres=gpu:rtx3090:2          # GPU's per node
#SBATCH --nodes=1                     # -N | node count, 1 nodes reserved
#SBATCH --time=1-00:00:00             # -t | total run time limit (HH:MM:SS)
#SBATCH --output=./logs/slurm.log     # Standard output and error log
#SBATCH --error=./logs/slurm.log
###########
export APPTAINER_BIND="/scratch/$USER"
export CONTAINER_FILE="/opt/images/ultralytics.sif"
###########
apptainer run --nv ${CONTAINER_FILE} python -u script.py
