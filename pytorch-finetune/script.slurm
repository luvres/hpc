#!/bin/bash
#SBATCH --partition=gpu-gtx3090     # -p 
#SBATCH --constraint=GPU            # -C feature
#SBATCH --gres=gpu:gtx3090:1        # 1 GPU per node
#SBATCH --nodes=1                   # -N | node count, 1 nodes reserved
#SBATCH --time=12:00:00             # -t | total run time limit (HH:MM:SS)
#SBATCH --output=out/slurm.%j.out   # Standard output and error log
#SBATCH --error=err/slurm.%j.err

apptainer run --nv $HOME/huggingsound.sif python -u finetune_cv.py
