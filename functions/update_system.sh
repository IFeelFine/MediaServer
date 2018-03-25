#!/bin/sh
# ===================================================================
# Title			: update_system.sh
# Description	: Helper function to update the system
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

update_system () {
	step=$((step+1)); substep=a
	echo "${BU}"$step". Updating system...${NC}"

	echo "${LB}        "$substep")${NC} Running yum update..." ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	yum update -y & >/dev/null 2>&1
	spinner

	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}
