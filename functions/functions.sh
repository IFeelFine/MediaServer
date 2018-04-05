#!/bin/sh
# ===================================================================
# Title			: update_system.sh
# Description	: Helper function to load other functions
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================

. /tmp/MediaServer/functions/update_system.sh
. /tmp/MediaServer/functions/install_plexmediaserver.sh
. /tmp/MediaServer/functions/install_sonarr.sh
. /tmp/MediaServer/functions/install_radarr.sh
. /tmp/MediaServer/functions/install_jackett.sh
. /tmp/MediaServer/functions/install_rtorrent.sh
. /tmp/MediaServer/functions/install_tautulli.sh

check_continue () {
install_continue="N"
echo -e ""
read -p "Step $step is finished. Continue to the next step? [y/N] " install_continue
echo -e ""

if [ $install_continue == "y" ] ; then
	echo -e "Continuing to next step..."
	install_continue="N"
else
	exit
fi
}

update_firewall () {    
    systemctl restart firewalld
    #firewall-cmd --permanent --get-services
    firewall-cmd --permanent --add-service $service_name 
    firewall-cmd --reload
}

update_service () {
    systemctl is-active $service_name || systemctl start $service_name
    systemctl is-active $service_name && { systemctl is-enabled $service_name || systemctl enable $service_name || { echo -e "${RED}ERROR: ${NC}Failed to start and enable the $service_name service. Exiting...";  exit 1; } }
}
