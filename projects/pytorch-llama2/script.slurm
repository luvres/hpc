#!/bin/bash
#SBATCH --partition=gpu-rtx3090       # -p
#SBATCH --constraint=GPU              # -C feature
#SBATCH --gres=gpu:rtx3090:2          # 1 GPU per node
#SBATCH --nodes=1                     # -N | node count, 1 nodes reserved
#SBATCH --time=2-00:00:00             # -t | total run time limit (d-HH:MM:SS)
#SBATCH --output=./logs/slurm.log     # Standard output and error log
#SBATCH --error=./logs/slurm.log
###########
export APPTAINER_BIND="/scratch/$USER"
export CONTAINER_FILE="/opt/images/llama2.sif"
###########
apptainer run --nv ${CONTAINER_FILE} python -u script.py
