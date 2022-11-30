#!/bin/bash
#SBATCH --partition=gpu-rtx3090       # -p
#SBATCH --nodes=1                     # -N | node count, 1 nodes reserved
#SBATCH --time=12:00:00               # -t | total run time limit (HH:MM:SS)
#SBATCH --output=./logs/slurm.log  # Standard output and error log
#SBATCH --error=./logs/slurm.log

apptainer run --nv $HOME/ml4cs310.sif python -u finetune_cv.py
