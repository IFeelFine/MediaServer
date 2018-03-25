#!/bin/sh
# ===================================================================
# Title			: install_sonarr.sh
# Description	: Helper function to install Sonarr
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================
# Set colours & other vars
RED='\033[1;31m'	# Bold red
LB='\033[1;36m'		# Bold blue
DB='\033[36m'		# Dark blue
YB='\033[1;33m'		# Bold yellow
BU='\033[34;4m'		# Purple underline
LG='\033[37m'		# Light gray
LU='\033[37;1;4m'	# Light gray underlined
NC='\033[0m'		# No Color

install_sonarr () {
	step=$((step+1)); substep=a
	service_name="sonarr"

	echo "${BU}"$step". Installing Sonarr...${NC}"
		
	# Install required repos and packages
	echo "${LB}        "$substep")${NC} Installing dependencies" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    yum install epel-release yum-utils -y & >/dev/null 2>&1 
    spinner
    rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" 2>&1
    yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ & >/dev/null 2>&1
    spinner
    yum -y install wget mediainfo libzen libmediainfo curl gettext mono-core mono-devel mono-locale-extras sqlite.x86_64 git par2cmdline p7zip unzip tar gcc python-feedparser python-configobj python-cheetah python-dbus python-devel libxslt-devel & >/dev/null 2>&1
    spinner
 
    # Add a user for sonarr to use
	echo "${LB}        "$substep")${NC} Adding $service_name user" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    useradd $service_name -s /sbin/nologin
    
    # Download, extract, & move sonarr
	echo "${LB}        "$substep")${NC} Installing Sonarr" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    cd /tmp
    wget http://download.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz --quiet
    tar -xzf NzbDrone* -C .
    mkdir -p /opt/$service_name/bin
    mv NzbDrone/* /opt/$service_name/bin
    rm -rf NzbDrone*
    
    # Change ownership of the install directory
    chown -R $service_name: /opt/$service_name
    
    # Create firewalld service
	echo "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/firewalld/services/$service_name.xml 2>&1 >/dev/null << EOF
<service>
  <short>$service_name</short>
  <description>Sonarr Download Service</description>
  <port protocol="tcp" port="8989"/>
</service>
EOF
    
    # Update the firewall
    systemctl is-active firewalld || systemctl start firewalld
    firewall-cmd --permanent --add-service $service_name 2>&1 >/dev/null
    firewall-cmd --reload 2>&1
    
	# Enable and start the Service
	echo "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    # Create systemd unit file
    tee /usr/lib/systemd/system/$service_name.service 2>&1 >/dev/null << EOF
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
    systemctl is-active $service_name || systemctl start $service_name
    systemctl is-active $service_name && { systemctl is-enabled $service_name || systemctl enable $service_name || { echo "Failed to start and enable the $service_name service. Exiting...";  exit 1; } }

	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}
