#!/bin/sh
# ===================================================================
# Title			: update_system.sh
# Description	: Helper function to update the system
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================
# Set colours & other vars

update_system () {
	step=$((step+1)); substep=a
	echo -e "${BU}"$step". Updating system...${NC}"

	echo -e "${LB}        "$substep")${NC} Running yum update..." ; substep="$(echo -e $substep | tr '[a-y]z' '[b-z]a')"
	yum update -y & >/dev/null 2>&1
	spinner

	echo -e "${BU}Step "$step" complete.${NC}"
	echo -e ""
}
