#### Build base
``docker build -t izone/hpc:r8ww -f ./Dockerfile.r8ww .``

#### Build Slurm
``docker build -t izone/hpc:r8ww-slurm -f ./Dockerfile.r8ww-slurm .``

#### Build NVIDIA Driver with Slurm
``docker build -t izone/hpc:r8ww-nvrepo-slurm -f ./Dockerfile.r8ww-nvrepo-slurm .``: CUDA Version: 11.8

#### Build Open OnDemand
``docker build -t izone/hpc:r8ww-ood -f ./Dockerfile.r8ww-ood .``

#### Build Open XDMoD (in progress..)
``docker build -t izone/hpc:r8ww-xdmod -f ./Dockerfile.r8ww-xdmod .``

-----
#### Build NVIDIA proprietary driver
References in [CUDA Installation Guide Linux](https://docs.nvidia.com/cuda/pdf/CUDA_Installation_Guide_Linux.pdf) for more information.

``docker build -t izone/hpc:r8ww-520.56.06-slurm -f ./Dockerfile.r8ww-nvidia-slurm .``: CUDA Version: 11.8

``docker build -t izone/hpc:r8ww-515.76-slurm -f ./Dockerfile.r8ww-nv-slurm .``: CUDA Version: 11.7

``docker build -t izone/hpc:r8ww-510.85.02-slurm -f ./Dockerfile.r8ww-nv-slurm .``: CUDA Version: 11.6

``docker build -t izone/hpc:r8ww-470.141.03-slurm -f ./Dockerfile.r8ww-nv-slurm .``: CUDA Version: 11.4

``docker build -t izone/hpc:r8ww-390.154-slurm -f ./Dockerfile.r8ww-nv-slurm .``: 

