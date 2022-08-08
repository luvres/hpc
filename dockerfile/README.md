#### Build base
``docker build -t izone/hpc:r8ww -f ./Dockerfile.r8ww .``

#### Build Slurm
``docker build -t izone/hpc:r8ww-slurm -f ./Dockerfile.r8ww-slurm .``

#### Build NVIDIA Driver with Slurm
``docker build -t izone/hpc:r8ww-nv-slurm -f ./Dockerfile.r8ww-nv-slurm .``

``docker build -t izone/hpc:r8ww-515.65.01-slurm -f ./Dockerfile.r8ww-nv-slurm .``

``docker build -t izone/hpc:r8ww-515.57-slurm -f ./Dockerfile.r8ww-nv-slurm .``

``docker build -t izone/hpc:r8ww-515.48.07-slurm -f ./Dockerfile.r8ww-nv-slurm .``

#### Build Open OnDemand
``docker build -t izone/hpc:ood -f ./Dockerfile.r8ww-ood .``

