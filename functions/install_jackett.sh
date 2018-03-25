#!/bin/sh
# ===================================================================
# Title			: install_jackett.sh
# Description	: Helper function to install Jackett
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

install_jackett () {
	step=$((step+1)); substep=a
	service_name=jackett
	
	echo "${BU}"$step". Installing Jackett...${NC}"
	
	echo "${LB}        "$substep")${NC} Installing dependencies" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	yum install -y mono-locale-extras ca-certificates-mono libcurl-devel bzip2 mono-devel  >/dev/null 2>&1 &
	spinner
	
	echo "${LB}        "$substep")${NC} Installing Jackett" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	cd /tmp/
    curl -L -O $( curl -s https://api.github.com/repos/Jackett/Jackett/releases | grep Mono.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 ) 2>&1
    tar -xf Jackett* & 
    spinner
	mkdir -p /opt/$service_name
	mv Jackett/* /opt/$service_name
	rm -rf Jackett*

    # Add a user for the app to use
	echo "${LB}        "$substep")${NC} Adding $service_name user" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    useradd $service_name -s /sbin/nologin
	
    # Change ownership of the install directory
    chown -R $service_name: /opt/$service_name
    
    # Create firewalld service
	echo "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/firewalld/services/$service_name.xml >/dev/null 2>&1 << EOF
<service>
  <short>$service_name</short>
  <description>Jackett Indexing Service</description>
  <port protocol="tcp" port="9117"/>
</service>
EOF
    
    # Update the firewall
    systemctl is-active firewalld >/dev/null 2>&1 || systemctl start firewalld >/dev/null 2>&1 
    firewall-cmd --permanent --add-service $service_name >/dev/null 2>&1 
    firewall-cmd --reload  >/dev/null 2>&1 &
    
	# Enable and start the Service
	echo "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    tee /lib/systemd/system/$service_name.service >/dev/null 2>&1 << EOF
[Unit]
Description=Jackett Daemon
After=syslog.target network.target

[Service]
User=$service_name
Group=$service_name

Type=simple
ExecStart=/usr/bin/mono --debug /opt/$service_name/JackettConsole.exe -nobrowser -data /opt/$service_name
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

	# Enable and start the Service
    systemctl is-active $service_name >/dev/null 2>&1 || systemctl start $service_name >/dev/null 2>&1
    systemctl is-active $service_name >/dev/null 2>&1 && { systemctl is-enabled $service_name >/dev/null 2>&1 || systemctl enable $service_name >/dev/null 2>&1 || { echo "Failed to start and enable the $service_name service. Exiting...";  exit 1; } }

	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}