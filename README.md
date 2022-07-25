Warewulf provider HPC with Rocky linux base OS
Slurm, NVIDIA Driver, Apptainer
=====

curl -Lo variables.txt https://raw.githubusercontent.com/luvres/hpc/master/variables.txt

curl -Lo wwhpc.sh  https://raw.githubusercontent.com/luvres/hpc/master/wwhpc.sh

sudo bash wwhpc.sh warewulf $(<variables.txt)






