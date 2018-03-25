#!/bin/sh
# ===================================================================
# Title			: autoinstall.sh
# Description	: Downloadable init script
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
substep=a

echo "${BU}Installing I Feel Fine Media Server...${NC}"

# Check if we're root
[ "$EUID" -ne 0 ] && sudo -s ||	{ echo -e "${RED}ERROR:${NC}This script must be run as root!\nPlease run it again as root."; exit 1 }
# Check Internet
[ ping -q -c 1 -W 1 github.com >/dev/null ] { echo -e "${RED}ERROR:${NC}You must be connected to the Internet to execute this script\nConnect to the Internet and try again."}

echo "${LB}        "$substep")${NC} Installing dependencies" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
yum install -y git-core 
cd /tmp/
echo "${LB}        "$substep")${NC} Copying Files" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
git clone https://github.com/IFeelFine/MediaServer.git --quiet
echo "${LB}        "$substep")${NC} Ready to install" ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
echo ""
read -t 5 -p "Do you wish to begin the installation? [Y/n]" begin
[[ -z $begin || echo $begin | grep -qi 'y' ]] || exit && sh /tmp/MediaServer/media_server.sh
