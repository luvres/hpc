### Build on docker
```
docker build -t izone/pytorch:deque -f Dockerfile .
```

### Build on Apptainer
```
apptainer build ./pytorch-deque.sif ./pytorch-deque.def
```
### From docker
```
apptainer pull pytorch-deque.sif docker://izone/pytorch:deque
```

### Run
```
mkdir cache output logs

sbatch script.slurm
```
