#!/bin/sh
# ===================================================================
# Title			: install_radarr.sh
# Description	: Helper function to install Radarr
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

install_radarr () {
	step=$((step+1)); substep=a
	service_name=radarr

	echo "${BU}"$step". Installing Radarr...${NC}"
	
	# Install radarr
	echo "${LB}        "$substep")${NC} Installing Radarr" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	cd /tmp
    curl -L -O $( curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 ) 2>&1
    tar -xf Radarr.develop.*.linux.tar.gz & 
    spinner
	mkdir /opt/$service_name
	mv Radarr/* /opt/$service_name
	rm -rf Radarr*
	
    # Add a user for radarr to use
	echo "${LB}        "$substep")${NC} Adding $service_name user" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    useradd $service_name -s /sbin/nologin

    # Change ownership of the install directory
    chown -R $service_name: /opt/$service_name
    
    # Create firewalld service
	echo "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/firewalld/services/$service_name.xml 2>&1 >/dev/null << EOF
<service>
  <short>$service_name</short>
  <description>Radarr Download Service</description>
  <port protocol="tcp" port="7878"/>
</service>
EOF
    
    # Update the firewall
    systemctl is-active firewalld || systemctl start firewalld
    firewall-cmd --permanent --add-service $service_name 2>&1 >/dev/null
    firewall-cmd --reload 2>&1
    
    # Create systemd unit file
	echo "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    tee /usr/lib/systemd/system/$service_name.service 2>&1 >/dev/null << EOF
[Unit]
Description=Radarr Daemon
After=syslog.target network.target

[Service]
User=$service_name
Group=$service_name

Type=simple
ExecStart=/usr/bin/mono /opt/$service_name/Radarr.exe -nobrowser -data /opt/$service_name
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