Lammps MPI
==========

Reference: <https://www.youtube.com/watch?v=EpVDeesAq4c&t=3456s>

#### Create base container with docker
``curl -LO https://raw.githubusercontent.com/luvres/hpc/master/mpich-lammps/Containerfile``

``curl -LO https://raw.githubusercontent.com/luvres/hpc/master/mpich-lammps/lmp-wrapper.sh``

``DOCKER_BUILDKIT=1 docker build -t mpich-lammps -f Containerfile .``

#### Build container with apptainer from docker container
``apptainer build lammps.sif docker-daemon://mpich-lammps:latest``

#### Shoot slurm and follow the queue
``curl -L https://www.lammps.org/inputs/in.lj.txt | env OMP_NUM_THREADS=4 \
srun --mpi=pmi2 --ntasks=1 --ntasks-per-node=1 --cpus-per-task=4 ./lammps.sif``

