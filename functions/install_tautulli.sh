#!/bin/sh
# ===================================================================
# Title			: install_tautulli.sh
# Description	: Helper function to install Tautulli
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

install_tautulli () {
	step=$((step+1)); substep=a
	service_name=tautulli

	echo "${BU}"$step". Installing Jackett...${NC}"
	
	echo "${LB}        "$substep")${NC} Installing dependencies" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	yum install -y python & >/dev/null 2>&1
	spinner
	
	echo "${LB}        "$substep")${NC} Installing Radarr" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	cd /opt/ && git clone https://github.com/Tautulli/Tautulli.git
	
    # Add a user for the app to use
	echo "${LB}        "$substep")${NC} Adding $service_name user" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    adduser -s /sbin/nologin $service_name

	chown -R tautulli: Tautulli
	
    # Create firewalld service
	echo "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/firewalld/services/$service_name.xml 2>&1 >/dev/null << EOF
<service>
  <short>https://github.com/Tautulli/Tautulli/archive/master.zip</short>
  <description>Monitoring tool for Plex Media Servere</description>
  <port protocol="tcp" port="8181"/>
</service>
EOF
    
    # Update the firewall
    systemctl is-active firewalld || systemctl start firewalld
    firewall-cmd --permanent --add-service $service_name 2>&1 >/dev/null
    firewall-cmd --reload 2>&1
    
	# Enable and start the Service
	echo "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	tee /lib/systemd/system/$service_name.service 2>&1 >/dev/null << EOF
[Unit]
Description=Tautulli - Stats for Plex Media Server usage

[Service]
ExecStart=/opt/Tautulli/Tautulli.py --quiet --daemon --nolaunch --config /opt/Tautulli/config.ini --datadir /opt/Tautulli
GuessMainPID=no
Type=forking
User=$service_name
Group=$service_name

[Install]
WantedBy=multi-user.target
EOF

    systemctl is-active $service_name || systemctl start $service_name
    systemctl is-active $service_name && { systemctl is-enabled $service_name || systemctl enable $service_name || { echo "Failed to start and enable the $service_name service. Exiting...";  exit 1; } }

	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}