## Build
```docker build -t izone/dtaidistance -f Dockerfile .```

## Push
```docker push izone/dtaidistance```

## Apptainer
```apptainer build ./dtaidistance.sif ./dtaidistance.def```


## Run
```mkdir cache output logs```

```sbatch script.slurm```

