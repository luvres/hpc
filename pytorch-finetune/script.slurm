#!/bin/bash
#SBATCH --partition=gpu-rtx3090       # -p
#SBATCH --constraint=GPU              # -C feature
#SBATCH --gres=gpu:rtx3090:1          # 1 GPU per node
#SBATCH --nodes=1                     # -N | node count, 1 nodes reserved
#SBATCH --time=12:00:00               # -t | total run time limit (HH:MM:SS)
#SBATCH --output=./logs/slurm.log  # Standard output and error log
#SBATCH --error=./logs/slurm.log

apptainer run --nv $HOME/huggingsound.sif python -u finetune_cv.py
