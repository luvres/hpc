### Build
```
docker build -t izone/hpc:huggingsound -f Dockerfile .
```

### Push
```
docker push izone/hpc:huggingsound
```

### Apptainer
```
apptainer pull huggingsound.sif docker://izone/hpc:huggingsound
```

### Run
```
mkdir cache output logs

sbatch script.slurm
```
