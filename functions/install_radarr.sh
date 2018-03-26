#!/bin/sh
# ===================================================================
# Title			: install_radarr.sh
# Description	: Helper function to install Radarr
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================

install_radarr () {
	step=$((step+1)); substep=a
	service_name=radarr

	echo -e "${BU}"$step". Installing Radarr...${NC}"
	
	# Install radarr
	echo -e "${LB}        "$substep")${NC} Installing Radarr" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
	cd /tmp/
    curl -L -O $( curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 ) ${tolog}
    tar -xf Radarr.develop.*.linux.tar.gz 
	mkdir -p /opt/$service_name
	mv Radarr/* /opt/$service_name
	rm -rf Radarr*
	
    # Add a user for radarr to use
	echo -e "${LB}        "$substep")${NC} Adding $service_name user" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    useradd $service_name -s /sbin/nologin ${tolog}

    # Change ownership of the install directory
    chown -R $service_name: /opt/$service_name ${tolog}
    
    # Create firewalld service
	echo -e "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/firewalld/services/$service_name.xml ${tolog} << EOF
<service>
  <short>$service_name</short>
  <description>Radarr Download Service</description>
  <port protocol="tcp" port="7878"/>
</service>
EOF
    
    # Update the firewall
	update_firewall
    
    # Create systemd unit file
	echo -e "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    tee /lib/systemd/system/$service_name.service ${tolog} << EOF
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
	update_service

	echo -e "${BU}Step "$step" complete.${NC}"
	echo -e ""
}