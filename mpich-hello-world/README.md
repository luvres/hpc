Hello world MPI
===============

Reference: <https://www.youtube.com/watch?v=EpVDeesAq4c&t=3456s>

```
docker build -t mpich-hello-world -f Containerfile .
sudo apptainer build mpich-hello-world.sif docker-daemon://mpich-hello-world:latest
```
```
srun --mpi=pmi2 --nodes=2 --ntasks-per-node=4 ./mpich-hello-world.sif; watch squeue
```
