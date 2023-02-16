#!/bin/bash
#SBATCH --partition=gpu-titan-rtx     # -p
#SBATCH --constraint=GPU              # -C feature
#SBATCH --gres=gpu:titanrtx:1         # 1 GPU per node
#SBATCH --nodes=1                     # -N | node count, 1 nodes reserved
#SBATCH --time=12:00:00               # -t | total run time limit (HH:MM:SS)
#SBATCH --output=./logs/slurm.log     # Standard output and error log
#SBATCH --error=./logs/slurm.log
###########
export APPTAINER_BIND="/scratch/$USER"
export CONTAINER_FILE="/opt/images/pytorch-soccernet.sif"
###########
apptainer run --nv ${CONTAINER_FILE} python -u src/main.py
