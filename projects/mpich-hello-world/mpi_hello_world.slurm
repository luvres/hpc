#!/bin/bash
#SBATCH --job-name=mpich_hello_world
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem=1024
#SBATCH --time=0-00:01:00
#SBATCH --output=./output.txt

srun --mpi=pmi2 ./mpich-hello-world.sif

