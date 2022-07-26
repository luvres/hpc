Hello world MPI
===============

Reference: <https://www.youtube.com/watch?v=EpVDeesAq4c&t=3456s>

#### Create base container with docker
``curl -LO https://raw.githubusercontent.com/luvres/hpc/master/mpich-hello-world/Containerfile``

``curl -LO https://raw.githubusercontent.com/luvres/hpc/master/mpich-hello-world/mpi_hello_world.c``

``docker build -t mpich-hello-world -f Containerfile .``

#### Build container with apptainer from docker container
``apptainer build mpich-hello-world.sif docker-daemon://mpich-hello-world:latest``

#### Shoot slurm and follow the queue
``srun --mpi=pmi2 --nodes=1 --ntasks-per-node=4 ./mpich-hello-world.sif; watch squeue``

#### Runs with sbatch job
``curl -LO https://raw.githubusercontent.com/luvres/hpc/master/mpich-hello-world/mpi_hello_world.slurm``

``sbatch mpi_hello_world.slurm ; watch squeue``


