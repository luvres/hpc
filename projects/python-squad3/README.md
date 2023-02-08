## Build
```docker build -t izone/hpc:python-squad3 -f Dockerfile.py39 .```

## Push
```docker push izone/hpc:squad3-py39```

## Apptainer
```apptainer build ./squad3py39.sif ./squad3py39.def```

```sudo mv ./squad3py39.sif /opt/images/```

### build apptainer from docker
```apptainer pull squad3py39.sif docker://izone/hpc:squad3-py39```

## Run
```mkdir cache output logs```

```sbatch script.slurm```
