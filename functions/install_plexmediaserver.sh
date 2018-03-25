#!/bin/sh
# ===================================================================
# Title			: install_plexmediaserver.sh
# Description	: Helper function to install Plex
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

install_plexmediaserver () {
	step=$((step+1)); substep=a
	service_name="plexmediaserver"

	echo "${BU}"$step". Installing Plex Media Server...${NC}"

    # Add the Plex repository for yum updates
	echo "${LB}        "$substep")${NC} Adding Plex repository for yum" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    tee /etc/yum.repos.d/plex.repo >/dev/null 2>&1 << EOF
[PlexRepo]
name=PlexRepo
baseurl=https://downloads.plex.tv/repo/rpm/\$basearch/
enabled=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
gpgcheck=1
EOF

    # Install Plex Media Server
	echo "${LB}        "$substep")${NC} Installing Plex" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
    yum install -y plexmediaserver >/dev/null 2>&1 &  
    spinner

# Create firewalld service
	echo "${LB}        "$substep")${NC} Adding firewalld rules" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
tee /etc/firewalld/services/$service_name.xml >/dev/null 2>&1 << EOF
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
    systemctl is-active firewalld >/dev/null 2>&1 || systemctl start firewalld >/dev/null 2>&1
    firewall-cmd --permanent --add-service $service_name >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
    
	echo "${LB}        "$substep")${NC} Starting the service" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	# Enable and start the Service
    systemctl is-active $service_name || systemctl start $service_name
    systemctl is-active $service_name && { systemctl is-enabled $service_name || systemctl enable $service_name || { echo "Failed to start and enable the $service_name service. Exiting...";  exit 1; } }

	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}