#!/bin/sh
# ===================================================================
# Title			: install_plexmediaserver.sh
# Description	: Helper function to install Plex
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================

install_plexmediaserver () {
	step=$((step+1)); substep=a
	service_name="plexmediaserver"

	echo -e "${BU}"$step". Installing Plex Media Server...${NC}"

    # Add the Plex repository for yum updates
	echo -e "${LB}        "$substep")${NC} Adding Plex repository for yum" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/yum.repos.d/plex.repo << EOF
[PlexRepo]
name=PlexRepo
baseurl=https://downloads.plex.tv/repo/rpm/\$basearch/
enabled=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
gpgcheck=1
EOF

    # Install Plex Media Server
	echo -e "${LB}        "$substep")${NC} Installing Plex" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
    yum install -y plexmediaserver  
    spinner

# Create firewalld service
	echo -e "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
tee /etc/firewalld/services/$service_name.xml << EOF
<service>
  <short>plex</short>
  <description>Plex Media Server</description>
  <port protocol="tcp" port="32400"/>
  <port protocol="udp" port="1900"/>
  <port protocol="tcp" port="3005"/>
  <port protocol="udp" port="5353"/>
  <port protocol="tcp" port="8324"/>
  <port protocol="udp" port="32410"/>
  <port protocol="udp" port="32412"/>
  <port protocol="udp" port="32413"/>
  <port protocol="udp" port="32414"/>
  <port protocol="tcp" port="32469"/>
</service>
EOF
    
    # Update the firewall
	update_firewall
    
	echo -e "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
	# Enable and start the Service
	update_service

	echo -e "${BU}Step "$step" complete.${NC}"
	echo -e ""
}