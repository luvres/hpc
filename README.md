## Warewulf provider HPC with Rocky linux base OS
### NVIDIA Driver
### Apptainer
### Slurm
-----

### Pull image
```
docker pull izone/hpc:r8ww
```

### Run
```
docker run --rm --name rocky -ti izone/hpc:r8ww bash
```

-----
### Build
```
docker build -t izone/hpc:r8ww -f ./Dockerfile.r8ww .
```
```
docker build -t izone/hpc:r8ww-nv -f ./Dockerfile.r8ww-nv .
```
```
docker build -t izone/hpc:r8ww-slurm -f ./Dockerfile.r8ww-slurm .
```
```
#docker build -t izone/hpc:r8ww-nv-slurm -f ./Dockerfile.r8ww-nv-slurm .
```



