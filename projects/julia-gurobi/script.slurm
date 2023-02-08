#!/bin/bash

#SBATCH --partition=gpu-titan-v     # -p
#SBATCH --constraint=GPU            # -C feature
#SBATCH --nodes=1                   # -N | node count, 1 nodes reserved
#SBATCH --time=12:00:00             # -t | total run time limit (HH:MM:SS)
#SBATCH --output=./logs/slurm.log   # Standard output and error log
#SBATCH --error=./logs/slurm.log
######################
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
# Adds files from the "Formatting" package not installed by "Pkg.add"
#curl -Lo $HOME/.julia/packages/Formatting/BwWBf/src/fmtspec.jl https://raw.githubusercontent.com/JuliaIO/Formatting.jl/master/src/fmtspec.jl
#curl -Lo $HOME/.julia/packages/Formatting/BwWBf/src/fmtcore.jl https://raw.githubusercontent.com/JuliaIO/Formatting.jl/master/src/fmtcore.jl
#curl -Lo $HOME/.julia/packages/Formatting/BwWBf/src/formatexpr.jl https://raw.githubusercontent.com/JuliaIO/Formatting.jl/master/src/formatexpr.jl
######################
#
# Start job
#
apptainer run ${CONTAINER_FILE} julia alis_csv.jl
