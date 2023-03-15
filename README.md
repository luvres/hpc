Warewulf provider HPC with Rocky linux base OS
Slurm, NVIDIA Driver, Apptainer, Open OnDemand, Keycloak
=====
** Open OnDemand
- Keycloak

``curl -LO https://raw.githubusercontent.com/luvres/hpc/master/variables.txt``

``curl -LO https://raw.githubusercontent.com/luvres/hpc/master/wwhpc.sh``

### Install all
``sudo bash wwhpc.sh install $(<variables.txt)``: install and config

``sudo bash wwhpc.sh config $(<variables.txt)``: only configure if it was installed

### Configure nodes
```sudo wwctl node set cn81.hpcc.eu.org n default -N eth0 -M 255.255.255.224 -I 40.6.18.81 -H fa:ce:40:06:18:81 -R generic,chrony,slurm -C r8-nv-slurm --yes```

``sudo wwctl configure --all``

* Start nodes and have fun! 

### Slurm info
``sinfo -lNe``

### GPU
``srun --gres=gpu:gtx1050:1 --mem=4G --cpus-per-gpu=1 --nodes=1 nvidia-smi ; watch squeue``

``srun --gres=gpu:1 --mem=4G --cpus-per-gpu=1 --nodes=2 nvidia-smi``

### Configure Open OnDemand node
``sudo wwctl node set ood33 n default -N eth0 -M 255.255.255.224 -I 10.6.8.33 -H fa:ce:10:06:08:33 -R generic,chrony,slurm,oondemand -O wwinit.ood -C r8-ood --yes``

``sudo wwctl configure --all``

* Start the Open OnDemand node
* Access node Open On Demand via ssh and set user password
* Access the address and enter the password in the pop-up form

