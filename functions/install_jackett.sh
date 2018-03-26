#!/bin/sh
# ===================================================================
# Title			: install_jackett.sh
# Description	: Helper function to install Jackett
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================

install_jackett () {
	step=$((step+1)); substep=a
	service_name=jackett
	
	echo -e "${BU}"$step". Installing Jackett...${NC}"
	
	echo -e "${LB}        "$substep")${NC} Installing dependencies" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
	yum install -y mono-locale-extras ca-certificates-mono libcurl-devel bzip2 mono-devel ${tolog} &
	spinner
	
	echo -e "${LB}        "$substep")${NC} Installing Jackett" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
	cd /tmp/
    curl -L -O $( curl -s https://api.github.com/repos/Jackett/Jackett/releases | grep Mono.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 ) ${tolog} &
    tar -xf Jackett* 
	mkdir -p /opt/$service_name
	mv Jackett/* /opt/$service_name
	rm -rf Jackett*

    # Add a user for the app to use
	echo -e "${LB}        "$substep")${NC} Adding $service_name user" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    useradd $service_name -s /sbin/nologin ${tolog}
	
    # Change ownership of the install directory
    chown -R $service_name: /opt/$service_name ${tolog}
    
    # Create firewalld service
	echo -e "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/firewalld/services/$service_name.xml ${tolog} << EOF
<service>
  <short>$service_name</short>
  <description>Jackett Indexing Service</description>
  <port protocol="tcp" port="9117"/>
</service>
EOF
    
    # Update the firewall
	update_firewall
    
    # Create systemd unit file
	echo -e "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    tee /lib/systemd/system/$service_name.service ${tolog} << EOF
[Unit]
Description=Jackett Daemon
After=syslog.target network.target

[Service]
User=$service_name
Group=$service_name

Type=simple
ExecStart=/usr/bin/mono /opt/$service_name/JackettConsole.exe -nobrowser -data /opt/$service_name
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