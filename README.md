Warewulf provider HPC with Rocky linux base OS
# Slurm, NVIDIA Driver, Apptainer
=================================

Pull image
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
docker build -t izone/hpc:r8ww-slurm -f ./Dockerfile.r8ww-slurm .
```
```
docker build -t izone/hpc:r8ww-nv-slurm -f ./Dockerfile.r8ww-nv-slurm .
```

Hello world MPI
===============

Reference: `https://www.youtube.com/watch?v=EpVDeesAq4c&t=3456s`

```
docker build -t mpich-hello-world -f Containerfile .
sudo apptainer build mpich-hello-world.sif docker-daemon://mpich-hello-world:latest
```
```
srun --mpi=pmi2 --nodes=2 --ntasks-per-node=4 ./mpich-hello-world.sif; watch squeue
```
