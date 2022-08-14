#### Build base
``docker build -t izone/hpc:r8ww -f ./Dockerfile.r8ww .``

#### Build Slurm
``docker build -t izone/hpc:r8ww-slurm -f ./Dockerfile.r8ww-slurm .``

#### Build NVIDIA Driver with Slurm
References in [CUDA Installation Guide Linux](https://docs.nvidia.com/cuda/pdf/CUDA_Installation_Guide_Linux.pdf) for more information.

``docker build -t izone/hpc:r8ww-nv-slurm -f ./Dockerfile.r8ww-nv-slurm .``

``docker build -t izone/hpc:r8ww-515.65.01-slurm -f ./Dockerfile.r8ww-nv-slurm .``: CUDA Version: 11.7

``docker build -t izone/hpc:r8ww-510.85.02-slurm -f ./Dockerfile.r8ww-nv-slurm .``: CUDA Version: 11.6

``docker build -t izone/hpc:r8ww-470.141.03-slurm -f ./Dockerfile.r8ww-nv-slurm .``: CUDA Version: 11.4

``docker build -t izone/hpc:r8ww-390.154-slurm -f ./Dockerfile.r8ww-nv-slurm .``: 

#### Build Open OnDemand
``docker build -t izone/hpc:ood-2.0.28 -f ./Dockerfile.r8ww-ood-2.0.28 .``

``docker build -t izone/hpc:ood -f ./Dockerfile.r8ww-ood .``
