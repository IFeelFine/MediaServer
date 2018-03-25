#!/bin/sh
# ===================================================================
# Title			: update_system.sh
# Description	: Helper function to load other functions
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================

. functions/update_system.sh
. functions/install_plexmediaserver.sh
. functions/install_sonarr.sh
. functions/install_radarr.sh
. functions/install_jackett.sh
. functions/install_rtorrent.sh
. functions/install_tautulli.sh

check_continue() {
install_continue="N"
echo ""
read -p "Step $step is finished. Continue to the next step? [y/N] " install_continue
echo ""

if [ $install_continue == "y" ] ; then
	echo "Continuing to next step..."
	install_continue="N"
else
	exit
fi
}

spinner()
{
    local pid=$!
    local delay=0.75
    local spinstr="|/-\\"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}