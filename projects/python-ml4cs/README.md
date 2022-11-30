## Build
```docker build -t izone/hpc:ml4cs-py311 -f Dockerfile.py311 .```

```docker build -t izone/hpc:ml4cs-py310 -f Dockerfile.py310 .```

## Push
```docker push izone/hpc:ml4cs-py311```

## Apptainer
```apptainer pull ml4cs311.sif docker://izone/hpc:ml4cs-py311```

```apptainer pull ml4cs310.sif docker://izone/hpc:ml4cs-py310```



## Run
```mkdir cache output logs```

```sbatch script.slurm```

