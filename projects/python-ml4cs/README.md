## Build
```docker build -t izone/hpc:ml4cs-py311 -f Dockerfile.py310 .```

```docker build -t izone/hpc:ml4cs-py311 -f Dockerfile.py311 .```

## Push
```docker push izone/hpc:ml4cs-py311```

## Apptainer
```apptainer pull ml4cs.sif docker://izone/hpc:ml4cs-py311```



## Run
```mkdir cache output logs```

```sbatch script.slurm```

