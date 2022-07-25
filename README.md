Warewulf provider HPC with Rocky linux base OS
Slurm, NVIDIA Driver, Apptainer
=====

curl -Lo variables.txt https://raw.githubusercontent.com/luvres/hpc/master/variables.txt

curl -Lo wwhpc.sh  https://raw.githubusercontent.com/luvres/hpc/master/wwhpc.sh

sudo bash wwhpc.sh install $(<variables.txt)


sudo bash wwhpc.sh warewulf $(<variables.txt)
sudo bash wwhpc.sh slurm $(<variables.txt)
sudo bash wwhpc.sh overlays $(<variables.txt)
sudo bash wwhpc.sh addnodes $(<variables.txt)


sudo wwctl node set cn81 -n default -N eth0 -M 255.255.255.240 -I 40.6.18.81 -H fa:ce:40:06:18:81 -R generic,chrony,slurm -C r8-nv-slurm --yes


Start nodes

sudo wwctl configure --all

# Slurm info
sinfo -lNe

# GPU
srun --gres=gpu:gtx1050:1 --mem=4G --cpus-per-gpu=1 --nodes=1 nvidia-smi ; watch squeue





