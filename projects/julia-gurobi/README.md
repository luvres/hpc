# Apptainer
apptainer pull ./julia.sif docker://julia:1.8.5

# Run
cd testeMaior2
julia alis_csv.jl

sbatch script.slurm

