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
    systemctl is-active firewalld ${tolog} || systemctl start firewalld ${tolog}
    firewall-cmd --permanent --add-service $service_name ${tolog} 
    firewall-cmd --reload ${tolog}
}

update_service () {
    systemctl is-active $service_name ${tolog} || systemctl start $service_name ${tolog}
    systemctl is-active $service_name ${tolog} && { systemctl is-enabled $service_name ${tolog} || systemctl enable $service_name ${tolog} || { echo -e "${RED}ERROR: ${NC}Failed to start and enable the $service_name service. Exiting...";  exit 1; } }
}

spinner () {
    local colour=('\033[0m' '\033[1;31m' '\033[1;36m' '\033[1;33m' '\033[34;4m')
    local pid=$!
    local delay=0.15
    local spinstr="|/-\\"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        for i in {1..8}; do
	        for j in {1..4}; do
	        	local temp=${spinstr#?}
    	    	printf colour[i] " [%c]  " "$spinstr"
        		local spinstr=$temp${spinstr%"$temp"}
        		sleep $delay
        		for k in {1..80}; do printf "\b"; done
	        	local temp=${spinstr#?}
        		sleep $delay
        		for k in {1..80}; do printf "\b"; done
    done
    printf "    \b\b\b\b\b\b"
}