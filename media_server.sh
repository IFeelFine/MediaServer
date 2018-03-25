#!/bin/sh
# ===================================================================
# Title			: media_server.sh
# Description	: Main script to install the media server
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================

# Set colours
RED='\033[1;31m'	# Bold red
NC='\033[0m'		# No Color

step=0 				# Set the step number
do_continue=1		# Continue after each step (0 = prompt, !0 = automatic)

# Check if we're root
[ "$EUID" -ne 0 ] && { echo -e "${RED}ERROR:${NC} This script must be run as root!\n       Change users and try again."; exit 1; }
# Check Internet
[ `ping -q -c 1 -W 1 github.com >/dev/null; echo $?` -ne 0 ] && { echo -e "${RED}ERROR:${NC} You must be connected to the Internet to execute this script!\n       Connect to the Internet and try again."; exit 1; }

. /tmp/MediaServer/functions/functions.sh
[ $do_continue -ne 0 ] || check_continue

update_system
[ $do_continue -ne 0 ] || check_continue

install_plexmediaserver
[ $do_continue -ne 0 ] || check_continue

install_sonarr
[ $do_continue -ne 0 ] || check_continue
	
install_radarr
[ $do_continue -ne 0 ] || check_continue

install_rtorrent_rutorrent
[ $do_continue -ne 0 ] || check_continue
		
configure_nginx_rutorrent
[ $do_continue -ne 0 ] || check_continue
	
configure_user_rtorrent_rutorrent
[ $do_continue -ne 0 ] || check_continue
	
configure_rtorrent_service
[ $do_continue -ne 0 ] || check_continue

install_jackett
[ $do_continue -ne 0 ] || check_continue
		
install_tautulli
echo ""
echo "Installation is now complete!"
echo ""
