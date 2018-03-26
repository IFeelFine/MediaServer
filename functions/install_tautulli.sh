#!/bin/sh
# ===================================================================
# Title			: install_tautulli.sh
# Description	: Helper function to install Tautulli
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================
# Set colours & other vars

install_tautulli () {
	step=$((step+1)); substep=a
	service_name=tautulli

	echo -e "${BU}"$step". Installing Jackett...${NC}"
	
	echo -e "${LB}        "$substep")${NC} Installing dependencies" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
	yum install -y python ${tolog} & 
	spinner
	
	echo -e "${LB}        "$substep")${NC} Installing Radarr" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
	git clone https://github.com/Tautulli/Tautulli.git --quiet &
	spinner
	mv Tautulli/ opt/
	
    # Add a user for the app to use
	echo -e "${LB}        "$substep")${NC} Adding $service_name user" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    adduser -s /sbin/nologin $service_name ${tolog}

	chown -R tautulli: /opt/Tautulli ${tolog}
	
    # Create firewalld service
	echo -e "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/firewalld/services/$service_name.xml ${tolog} << EOF
<service>
  <short>https://github.com/Tautulli/Tautulli/archive/master.zip</short>
  <description>Monitoring tool for Plex Media Servere</description>
  <port protocol="tcp" port="8181"/>
</service>
EOF
    
    # Update the firewall
	update_firewall
    
	# Enable and start the Service
	echo -e "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
	tee /lib/systemd/system/$service_name.service ${tolog} << EOF
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

   	# Enable and start the Service
	update_service

	echo -e "${BU}Step "$step" complete.${NC}"
	echo -e ""
}