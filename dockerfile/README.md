#### Build base
``docker build -t izone/hpc:r8ww -f ./Dockerfile.r8ww .``

#### Build Slurm
``docker build -t izone/hpc:r8ww-slurm -f ./Dockerfile.r8ww-slurm .``

#### Build NVIDIA Driver with Slurm
``docker build -t izone/hpc:r8ww-nv-slurm -f ./Dockerfile.r8ww-nv-slurm .``

#### Build Open OnDemand
``docker build -t izone/hpc:ood -f ./Dockerfile.ood .``

-----
``docker build -t izone/hpc:ood-base -f ./Dockerfile.ood-base .``

``docker build -t izone/hpc:ood-pam -f ./Dockerfile.ood-pam .``

``docker build -t izone/hpc:ood-auth -f ./Dockerfile.ood-auth .``

