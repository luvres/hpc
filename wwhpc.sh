#!/bin/bash
 
ipaddr=$2
netmask=$3
network=$4
range_start=$5
range_end=$6
netmask_bit=$7

function warewulf() {
	echo "Install warewulf"
	dnf install -y https://github.com/hpcng/warewulf/releases/download/v4.3.0/warewulf-4.3.0-1.git_235c23c.el8.x86_64.rpm

	echo "Config warewulf"
	cp /etc/warewulf/warewulf.conf /etc/warewulf/warewulf.conf.orig
	sed -i "s/192.168.200.1/$ipaddr/" /etc/warewulf/warewulf.conf
	sed -i "s/255.255.255.0/$netmask/" /etc/warewulf/warewulf.conf
	sed -i "s/192.168.200.0/$network/" /etc/warewulf/warewulf.conf
	sed -i "s/192.168.200.50/$range_start/" /etc/warewulf/warewulf.conf
	sed -i "s/192.168.200.99/$range_end/" /etc/warewulf/warewulf.conf

	mv /etc/cloud/templates/hosts.redhat.tmpl{,.ORIG}
	bash -c 'echo >/etc/hosts'
	wwctl configure --all

	echo "Start warewulf"
	systemctl enable --now warewulfd
	wwctl configure --all
	chmod 644 /etc/warewulf/nodes.conf

	echo "Add Chrony config file on headnode"
	cp /etc/chrony.conf /etc/chrony.conf.orig
	# -----------
	{
		echo "pool 2.pool.ntp.org iburst"
		echo "driftfile /var/lib/chrony/drift"
		echo "makestep 1.0 3"
		echo "rtcsync"
		echo "allow $network/$netmask_bit"
		echo "local stratum 8"
		echo "keyfile /etc/chrony.keys"
		echo "leapsectz right/UTC"
		echo "logdir /var/log/chrony"
		echo "log measurements statistics tracking"
		echo "initstepslew 10 $nodes_list"
	}> /etc/chrony.conf
}

function slurm() {
	echo "Install Slurm"
	dnf -y install http://repos.openhpc.community/OpenHPC/2/EL_8/$(uname -m)/ohpc-release-2-1.el8.$(uname -m).rpm
	dnf install -y dnf-plugins-core 
	dnf config-manager --set-enabled powertools 

	dnf install -y ohpc-base ohpc-slurm-server nhc-ohpc

	echo "Download slurm.conf"
	cp /etc/slurm/slurm.conf.ohpc /etc/slurm/slurm.conf
	curl -Lo /etc/slurm/slurm.conf https://raw.githubusercontent.com/luvres/hpc/master/config/slurm.conf

	perl -pi -e "s/ControlMachine=\S+/ControlMachine=${HOSTNAME}/" /etc/slurm/slurm.conf

	echo "Download slurmctld.service"
	curl -Lo /usr/lib/systemd/system/slurmctld.service https://raw.githubusercontent.com/luvres/hpc/master/config/slurmctld.service

	systemctl enable --now slurmctld
	systemctl status slurmctld

	echo "Download gres.conf"
	curl -Lo /etc/slurm/gres.conf https://raw.githubusercontent.com/luvres/hpc/master/config/gres.conf
}

function overlays() {
	echo "Slurm overlay"
	mkdir -p /var/lib/warewulf/overlays/slurm/etc/slurm/
	bash -c "echo '{{Include \"/etc/slurm/slurm.conf\"}}' >/var/lib/warewulf/overlays/slurm/etc/slurm/slurm.conf.ww"

	echo "Gres overlay"
	bash -c "echo '{{Include \"/etc/slurm/gres.conf\"}}' >/var/lib/warewulf/overlays/slurm/etc/slurm/gres.conf.ww"

	echo "New Munge key"
	mv /etc/munge/munge.key{,.orig}
	bash -c "dd if=/dev/urandom | base64| head -c 1024 > /etc/munge/munge.key"
	bash -c "echo  >> /etc/munge/munge.key"
	chown munge. /etc/munge/munge.key
	chmod 0400 /etc/munge/munge.key
	# -----------
	systemctl enable --now munge
	systemctl status munge
	# -----------
	echo "Munge overlay"
	mkdir -p /var/lib/warewulf/overlays/slurm/etc/munge/
	bash -c "echo '{{Include \"/etc/munge/munge.key\"}}' >/var/lib/warewulf/overlays/slurm/etc/munge/munge.key.ww"
	chown 998:995 /var/lib/warewulf/overlays/slurm/etc/munge/munge.key.ww
	chmod 0400 /var/lib/warewulf/overlays/slurm/etc/munge/munge.key.ww

	echo "Chrony overlay"
	mkdir -p /var/lib/warewulf/overlays/chrony/etc
	# -----------
	{
		echo "server $HOSTNAME"
		echo "driftfile /var/lib/chrony/drift"
		echo "makestep 1.0 3"
		echo "rtcsync"
		echo "allow $ipaddr"
		echo "local stratum 10"
		echo "keyfile /etc/chrony.keys"
		echo "leapsectz right/UTC"
		echo "logdir /var/log/chrony"
		echo "log measurements statistics tracking"
		echo "initstepslew 20 $HOSTNAME"
	}> /var/lib/warewulf/overlays/chrony/etc/chrony.conf

	echo "Localtime overlay"
	bash -c "echo '{{Include \"/etc/localtime\"}}' >/var/lib/warewulf/overlays/chrony/etc/localtime.ww"

	echo "Build overlay"
	wwctl overlay build
}

function addnodes() {
	echo "Inport container with Slurm and NVIDIA Driver"
	wwctl container import docker://izone/hpc:r8ww-nv-slurm r8-nv-slurm

	echo "Add nodes"
	wwctl node add cn81

	count=1
	for arg in "$@"
	do
		if [ $count -ge 8 ]; then
			wwctl node delete $arg --yes
			wwctl node add $arg
		fi
	count=$(($count + 1))
	done
  
	# Config nodes
	#wwctl node set cn81 -n default -N eth0 -M 255.255.255.240 -I 40.6.18.81 -H fa:ce:40:06:18:81 -R generic,chrony,slurm -C r8-nv-slurm --yes
}


install() {
  warewulf
  slurm
  overlays
  addnodes
}


if [ $1 == 'install' ]; then
	install;
elif [ $1 == 'warewulf' ]; then
	warewulf;
elif [ $1 == 'slurm' ]; then
	slurm;
elif [ $1 == 'overlays' ]; then
	overlays;
elif [ $1 == 'addnodes' ]; then
	addnodes;
fi

