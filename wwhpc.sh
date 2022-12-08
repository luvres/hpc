#!/bin/bash

# Variables
nfs_server="ip_nfs_server"
ipaddr=$2
netmask=$3
network=$4
range_start=$5
range_end=$6
netmask_bit=$7
ood=$8

count=1
for arg in "$@"
do
	if [ $count -ge 9 ]; then
		nodes_list+="$arg "
	fi
	count=$(($count + 1))
done

read -ra no_l <<< "$nodes_list"


# Functions
function install_warewulf() {
	echo "Install warewulf"
	dnf install -y https://github.com/hpcng/warewulf/releases/download/v4.3.0/warewulf-4.3.0-1.git_235c23c.el8.x86_64.rpm

	test -f /etc/cloud/templates/hosts.redhat.tmpl.ORIG \
	|| mv /etc/cloud/templates/hosts.redhat.tmpl{,.ORIG}

	echo "Start warewulf"
	systemctl enable --now warewulfd
	chmod 644 /etc/warewulf/nodes.conf
}

function config_warewulf() {
	echo "Config warewulf"
	test -f /etc/warewulf/warewulf.conf.ORIG || cp /etc/warewulf/warewulf.conf{,.ORIG}

	curl -Lo /etc/warewulf/warewulf.conf https://raw.githubusercontent.com/luvres/hpc/master/config/warewulf.conf
	sed -i "s/192.168.200.1/$ipaddr/" /etc/warewulf/warewulf.conf
	sed -i "s/255.255.255.0/$netmask/" /etc/warewulf/warewulf.conf
	sed -i "s/192.168.200.0/$network/" /etc/warewulf/warewulf.conf
	sed -i "s/192.168.200.50/$range_start/" /etc/warewulf/warewulf.conf
	sed -i "s/192.168.200.99/$range_end/" /etc/warewulf/warewulf.conf

	bash -c 'echo >/etc/hosts'
	
	echo "external nfs server in computenodes fstab to mount /home"
	curl -Lo /var/lib/warewulf/overlays/wwinit/etc/fstab.ww \
		https://raw.githubusercontent.com/luvres/hpc/master/config/fstab.ww
	sed -i "s/nfs_server/$nfs_server/g" /var/lib/warewulf/overlays/wwinit/etc/fstab.ww
	echo "${HOSTNAME}:/opt /opt xfs defaults 0 0" >>/var/lib/warewulf/overlays/wwinit/etc/fstab.ww

	wwctl configure --all

	echo "Add Chrony config file on headnode"
	test -f /etc/chrony.conf.ORIG || cp /etc/chrony.conf{,.ORIG}
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
	
	echo "Restrict su Access"
	bash -c "sed -i '/pam_wheel.so use_uid/s/#//' /etc/pam.d/su"
	mkdir -p /var/lib/warewulf/overlays/generic/etc/pam.d/
	bash -c "echo '{{Include \"/etc/pam.d/su\"}}' >/var/lib/warewulf/overlays/generic/etc/pam.d/su.ww"
}

function install_slurm() {
	echo "Install Slurm"
	dnf -y install http://repos.openhpc.community/OpenHPC/2/EL_8/$(uname -m)/ohpc-release-2-1.el8.$(uname -m).rpm
	dnf install -y dnf-plugins-core 
	dnf config-manager --set-enabled powertools 

	dnf install -y ohpc-base ohpc-slurm-server nhc-ohpc

	echo "Download slurmctld.service"
	test -f /usr/lib/systemd/system/slurmctld.service.ORIG \
	|| cp /usr/lib/systemd/system/slurmctld.service{,.ORIG}

	curl -Lo /usr/lib/systemd/system/slurmctld.service \
		https://raw.githubusercontent.com/luvres/hpc/master/config/slurmctld.service

	systemctl enable --now slurmctld

	echo "New Munge key"
	test -f /etc/munge/munge.key.ORIG || mv /etc/munge/munge.key{,.ORIG}
	bash -c "dd if=/dev/urandom | base64| head -c 1024 > /etc/munge/munge.key"
	bash -c "echo  >> /etc/munge/munge.key"
	chown munge. /etc/munge/munge.key
	chmod 0400 /etc/munge/munge.key

	systemctl enable --now munge
}

function config_slurm() {
	echo "Download slurm.conf"
	curl -Lo /etc/slurm/slurm.conf \
		https://raw.githubusercontent.com/luvres/hpc/master/config/slurm.conf
	curl -Lo /etc/slurm/cgroup.conf \
		https://raw.githubusercontent.com/luvres/hpc/master/config/cgroup.conf
	echo "Download slurmdbd.conf"
	curl -Lo /etc/slurm/slurmdbd.conf \
		https://raw.githubusercontent.com/luvres/hpc/master/config/slurmdbd.conf
	chown slurm:slurm /etc/slurm/slurmdbd.conf
	chmod 600 /etc/slurm/slurmdbd.conf
	
	systemctl enable --now slurmdbd

	perl -pi -e "s/SlurmctldHost=\S+/SlurmctldHost=${HOSTNAME}/" /etc/slurm/slurm.conf

	echo "Download gres.conf"
	curl -Lo /etc/slurm/gres.conf \
		https://raw.githubusercontent.com/luvres/hpc/master/config/gres.conf
}

function overlays_slurm() {
	echo "Slurmd overlay"
	mkdir -p /var/lib/warewulf/overlays/slurm/etc/sysconfig/
	bash -c 'echo "SLURMD_OPTIONS=\"-M --conf-server $(hostname):6817\""' \
                                 >/var/lib/warewulf/overlays/slurm/etc/sysconfig/slurmd
	echo "Munge overlay"
	mkdir -p /var/lib/warewulf/overlays/slurm/etc/munge/
	bash -c "echo '{{Include \"/etc/munge/munge.key\"}}' >/var/lib/warewulf/overlays/slurm/etc/munge/munge.key.ww"
#	chown 998:995 /var/lib/warewulf/overlays/slurm/etc/munge/munge.key.ww
	chown 997:994 /var/lib/warewulf/overlays/slurm/etc/munge/munge.key.ww
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
}

function overlays_oondemand() {
	echo "Open OnDemand TLS overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/etc/pki/tls
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/pki/tls/cert.crt \
  						https://raw.githubusercontent.com/luvres/hpc/master/config/tls/certs/cert.pem
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/pki/tls/cert.key \
  						https://raw.githubusercontent.com/luvres/hpc/master/config/tls/certs/cert-key.pem
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/pki/tls/cert.csr \
  						https://raw.githubusercontent.com/luvres/hpc/master/config/tls/certs/cert.csr
	echo "Open OnDemand Cluster HPCC overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/etc/ood/config/clusters.d
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/ood/config/clusters.d/hpcc.yml \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/cluster-hpcc.yml
	sed -i "s/headnode/$HOSTNAME/" /var/lib/warewulf/overlays/oondemand/etc/ood/config/clusters.d/hpcc.yml
#	echo "Open OnDemand Cluster Kubernetes overlay"
#	mkdir -p /var/lib/warewulf/overlays/oondemand/etc/ood/config/clusters.d
#	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/ood/config/clusters.d/kubernetes.yml \
#		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/cluster-kubernetes.yml
  # ----------------------
	echo "Open OnDemand Pinned apps overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/etc/ood/config/ondemand.d
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/ood/config/ondemand.d/ondemand.yml \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/ondemand.yml
		    
	echo "Open OnDemand Jupyter overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys
	curl -L https://github.com/luvres/hpc/raw/master/config/ood/bc_jupyter.tar.gz \
		    | tar -xf - -C /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/
#	echo "Open OnDemand Jupyter k8s overlay"
#	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys
#	curl -L https://github.com/luvres/hpc/raw/master/config/ood/bc_k8s_jupyter.tar.gz \
#		    | tar -xf - -C /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/
		    
	echo "Open OnDemand Tensorboard overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys
	curl -L https://github.com/luvres/hpc/raw/master/config/ood/bc_tensorboard.tar.gz \
			  | tar -xf - -C /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/

	echo "Open OnDemand IJulia overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys
	curl -L https://github.com/luvres/hpc/raw/master/config/ood/bc_ijulia.tar.gz \
			  | tar -xf - -C /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/
		    	    
	echo "Open OnDemand RStudio overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys
	curl -L https://github.com/luvres/hpc/raw/master/config/ood/bc_rstudio.tar.gz \
		    | tar -xf - -C /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/
		    
	echo "Open OnDemand CodeServer overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys
	curl -L https://github.com/luvres/hpc/raw/master/config/ood/bc_codeserver.tar.gz \
		    | tar -xf - -C /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/
	# ----------------------
	echo "Open OnDemand Dashboard Navbar"
	mkdir -p /var/lib/warewulf/overlays/oondemand/etc/ood/config/apps/dashboard/initializers/
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/ood/config/apps/dashboard/initializers/ood.rb \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/dashboard_navbar.rb
	echo "Open OnDemand Dashboard 'System Installed App'"
	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/dashboard/app/apps
	curl -Lo /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/dashboard/app/apps/sys_router.rb \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/dashboard_sys_router.rb
	echo "Open OnDemand LOGO"
	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/public
	curl -Lo /var/lib/warewulf/overlays/oondemand/var/www/ood/public/logo_header.png \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/logo_PUC/PUC_logo1.png
	curl -Lo /var/lib/warewulf/overlays/oondemand/var/www/ood/public/logo_dashboard.png \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/logo_PUC/logo_FULL-roboto.png
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/ood/config/nginx_stage.yml \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/nginx_stage.yml
	echo "Open OnDemand Favicon"
	curl -Lo /var/lib/warewulf/overlays/oondemand/var/www/ood/public/favicon.ico \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/logo_PUC/favicon-puc.ico
	echo "Open OnDemand Backgrount Image"
	curl -Lo /var/lib/warewulf/overlays/oondemand/var/www/ood/public/background.png \
	      https://raw.githubusercontent.com/luvres/hpc/master/config/logo_PUC/bg_ood.png
	echo "Open OnDemand locales"
	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/dashboard/config/locales
	curl -Lo /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/dashboard/config/locales/en.yml \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/en.yml
	echo "Open OnDemand appication HTML"
	mkdir -p /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/dashboard/public/assets
	curl -Lo /var/lib/warewulf/overlays/oondemand/var/www/ood/apps/sys/dashboard/public/assets/application-2fde447313952cf2d4f0c8cf0b2f0549ed7eac0e3aaf162a376b4fbe0589ac7e.css \
	      https://raw.githubusercontent.com/luvres/hpc/master/config/ood/application-2fde447313952cf2d4f0c8cf0b2f0549ed7eac0e3aaf162a376b4fbe0589ac7e.css
	echo "Open OnDemand widgets"
	mkdir -p /var/lib/warewulf/overlays/oondemand/etc/ood/config/apps/dashboard/views/widgets
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/ood/config/apps/dashboard/views/widgets/_wellcome.html \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/_wellcome.html
	echo "Open OnDemand motd"
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/motd \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/motd
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/ood/config/apps/dashboard/env \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/ood/motd_env
}

function overlays_xdmod() {
  echo "Open XDMoD Apache"
  mkdir -p /var/lib/warewulf/overlays/oxdmod/etc/httpd/conf.d
  curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/httpd/conf.d/xdmod.conf \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/xdmod/xdmod.conf
	echo "Open XDMoD Portal Settings"
	mkdir -p /var/lib/warewulf/overlays/oxdmod/etc/xdmod
	curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/xdmod/portal_settings.ini \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/xdmod/portal_settings.ini
	echo "Open XDMoD Portal Organization"
	curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/xdmod/organization.json \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/xdmod/organization.json
	echo "Open XDMoD Portal Resources"
	curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/xdmod/resources.json \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/xdmod/resources.json
	echo "Open XDMoD Portal Resources Specs"
	curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/xdmod/resource_specs.json \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/xdmod/resource_specs.json
	echo "Open XDMoD SimpleSAMLphp"
	mkdir -p /var/lib/warewulf/overlays/oxdmod/etc/xdmod/simplesamlphp/config
	mkdir -p /var/lib/warewulf/overlays/oxdmod/etc/xdmod/simplesamlphp/metadata
	mkdir -p /var/lib/warewulf/overlays/oxdmod/etc/xdmod/simplesamlphp/cert
	curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/xdmod/simplesamlphp/config/config.php \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/xdmod/config.php
	curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/xdmod/simplesamlphp/config/authsources.php \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/xdmod/authsources.php
	curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/xdmod/simplesamlphp/metadata/saml20-idp-remote.php \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/xdmod/saml20-idp-remote.php
	curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/xdmod/simplesamlphp/cert/xdmod.crt \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/tls/certs/cert.pem
	curl -Lo /var/lib/warewulf/overlays/oxdmod/etc/xdmod/simplesamlphp/cert/xdmod.key \
		    https://raw.githubusercontent.com/luvres/hpc/master/config/tls/certs/cert-key.pem
}

function overlay_httpd_auth_pam() {
  echo "Open OnDemand Apache PAM overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/etc/httpd/conf.d
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/httpd/conf.d/ood-portal.conf \
  						https://raw.githubusercontent.com/luvres/hpc/master/config/ood/ood-portal-pam.conf
}

function overlay_httpd_auth_keycloak() {
  echo "Open OnDemand Apache OIDC Keycloak overlay"
	mkdir -p /var/lib/warewulf/overlays/oondemand/etc/httpd/conf.d
	curl -Lo /var/lib/warewulf/overlays/oondemand/etc/httpd/conf.d/ood-portal.conf \
  						https://raw.githubusercontent.com/luvres/hpc/master/config/ood/ood-portal-keycloak.conf
}

function overlays_build() {
	echo "Build overlay"
	wwctl overlay build
}

function addnodes() {
	echo "Import container with Slurm and NVIDIA Driver"
	wwctl container import docker://izone/hpc:r8ww-nv-slurm r8-nv-slurm
	
	echo "Import container with Slurm"
	wwctl container import docker://izone/hpc:r8ww-slurm r8-slurm

	echo "Import container from Open OnDemand"
	wwctl container import docker://izone/hpc:r8ww-ood r8-ood
	
	echo "Import container from Open XDMoD"
	wwctl container import docker://izone/hpc:r8ww-xdmod r8-xdmod

	echo "Add nodes"
	for arg in "${no_l[@]}"
	do
		wwctl node delete $arg --yes &>/dev/null
		wwctl node add $arg
	done

	wwctl node delete $ood --yes &>/dev/null
	wwctl node add $ood

	# Config nodes
	#wwctl node set cn81 -n default -N eth0 -M 255.255.255.240 -I 40.6.18.81 -H fa:ce:40:06:18:81 -R generic,chrony,slurm -C r8-nv-slurm --yes
}

function restart() {
  echo "Restart Slurmctld"  
  systemctl restart slurmctld
	echo "Reboot"
	/usr/bin/sleep 3 && /usr/sbin/shutdown -r now
}


install() {
	install_warewulf
	install_slurm
	config_warewulf
	config_slurm
	overlays_slurm
	overlays_oondemand
	overlays_xdmod
	overlay_httpd_auth_keycloak
	overlays_build
	addnodes
	restart
}

install_auth_pam() {
	install_warewulf
	install_slurm
	config_warewulf
	config_slurm
	overlays_slurm
	overlays_oondemand
	overlay_httpd_auth_pam
	overlays_build
	addnodes
	restart
}

config() {
	config_warewulf
	config_slurm
	overlays_slurm
	overlays_oondemand
	overlay_httpd_auth_keycloak
	overlays_build
}

config_auth_pam() {
	config_warewulf
	config_slurm
	overlays_slurm
	overlays_oondemand
	overlay_httpd_auth_pam
	overlays_build
}


# Start
if   [ $1 == 'install' ];  then install;
elif   [ $1 == 'install_auth_pam' ];  then install_auth_pam;
elif [ $1 == 'config' ];   then config;
elif [ $1 == 'config_auth_pam' ];   then config_auth_pam;
elif [ $1 == 'warewulf' ]; then warewulf;
elif [ $1 == 'slurm' ];    then config_slurm;
elif [ $1 == 'overlays_slurm' ]; then overlays_slurm;
elif [ $1 == 'overlays_oondemand' ]; then overlays_oondemand;
elif [ $1 == 'overlay_httpd_auth_pam' ]; then overlay_httpd_auth_pam;
elif [ $1 == 'overlay_httpd_auth_keycloak' ]; then overlay_httpd_auth_keycloak;
elif [ $1 == 'overlays_build' ]; then overlays_build;
elif [ $1 == 'addnodes' ]; then addnodes;
elif [ $1 == 'restart' ];  then restart;
fi

