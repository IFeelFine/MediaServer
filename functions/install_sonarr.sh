#!/bin/sh
# ===================================================================
# Title			: install_sonarr.sh
# Description	: Helper function to install Sonarr
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================
# Set colours & other vars

install_sonarr () {
	step=$((step+1)); substep=a
	service_name="sonarr"

	echo -e "${BU}"$step". Installing Sonarr...${NC}"
		
	# Install required repos and packages
	echo -e "${LB}        "$substep")${NC} Installing dependencies" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    yum install epel-release yum-utils -y ${tolog} &
    spinner
    rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" 2>&1
    yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ ${tolog} &
    spinner
    yum -y install wget mediainfo libzen libmediainfo curl gettext mono-core mono-devel mono-locale-extras sqlite.x86_64 git par2cmdline p7zip unzip tar gcc python-feedparser python-configobj python-cheetah python-dbus python-devel libxslt-devel ${tolog} &
    spinner
 
    # Download, extract, & move sonarr
	echo -e "${LB}        "$substep")${NC} Installing Sonarr" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    cd /tmp/
    wget http://download.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz --quiet &
    spinner
    tar -xzf NzbDrone* -C . &
    spinner
    mkdir -p /opt/$service_name/bin
    mv NzbDrone/* /opt/$service_name/bin
    rm -rf NzbDrone*
    
    # Add a user for sonarr to use
	echo -e "${LB}        "$substep")${NC} Adding $service_name user" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    useradd $service_name -s /sbin/nologin ${tolog}
    
    # Change ownership of the install directory
    chown -R $service_name: /opt/$service_name ${tolog}
    
    # Create firewalld service
	echo -e "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/firewalld/services/$service_name.xml ${tolog} << EOF
<service>
  <short>$service_name</short>
  <description>Sonarr Download Service</description>
  <port protocol="tcp" port="8989"/>
</service>
EOF
    
    # Update the firewall
	update_firewall
    
    # Create systemd unit file
	echo -e "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    tee /lib/systemd/system/$service_name.service ${tolog} << EOF
[Unit]
Description=Sonarr Daemon
After=syslog.target network.target

[Service]
User=$service_name
Group=$service_name

Type=simple
ExecStart=/usr/bin/mono /opt/sonarr/bin/NzbDrone.exe -nobrowser -data /opt/$service_name
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

	# Enable and start the Service
	update_service

	echo -e "${BU}Step "$step" complete.${NC}"
	echo -e ""
}