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
BU='\033[34;4m'		# Purple underline
NC='\033[0m'		# No Color
substep=a

echo -e "${BU}Installing I Feel Fine Media Server...${NC}"

# Check if we're root
[ "$EUID" -ne 0 ] && { echo -e "${RED}ERROR:${NC} This script must be run as root!\n       Change users and try again."; exit 1; } 
# Check Internet
[ `ping -q -c 1 -W 1 github.com >/dev/null; echo -e $?` -ne 0 ] && { echo -e "${RED}ERROR:${NC} You must be connected to the Internet to execute this script!\n       Connect to the Internet and try again."; exit 1; }

echo -e "${LB}        "$substep")${NC} Installing dependencies" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
yum install -y git-core 
cd /tmp/
echo -e "${LB}        "$substep")${NC} Copying Files" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
git clone https://github.com/IFeelFine/MediaServer.git --quiet
echo -e "${LB}        "$substep")${NC} Ready to install" ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
echo -e ""
read -t 5 -p "Do you wish to begin the installation? [Y/n]" begin
[[ -z $begin || ${begin,,} == "y" ]] || exit && sh /tmp/MediaServer/media_server.sh
