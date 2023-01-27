#!/bin/bash

#SBATCH --partition=cpu-128g        # -p
#SBATCH --constraint=CPU            # -C feature
#SBATCH --nodes=1                   # -N | node count, 1 nodes reserved
#SBATCH --time=12:00:00             # -t | total run time limit (HH:MM:SS)
#SBATCH --output=./logs/slurm.log   # Standard output and error log
#SBATCH --error=./logs/slurm.log
###########
export APPTAINER_BIND="/scratch/$USER"
export APPTAINER_BIND="/opt/gurobi/gurobi.lic"
export CONTAINER_FILE="/opt/images/julia.sif"
###########
# Install IJulia in the user's home
apptainer exec ${CONTAINER_FILE} julia -e 'using Pkg;\
Pkg.add("DataFrames");\
Pkg.add("CSV");\
Pkg.add("LibPQ");\
Pkg.add("Decimals");\
Pkg.add("JuMP");\
Pkg.add("Gurobi")'
###########
apptainer run ${CONTAINER_FILE} julia alis_csv.jl
