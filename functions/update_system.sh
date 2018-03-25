#!/bin/sh
# ===================================================================
# Title			: update_system.sh
# Description	: Helper function to update the system
# Author		: David Bates
# Date			: 3/24/2018
# Notes			: 
#====================================================================

update_system () {
	step=$((step+1)); substep=a
	echo "${BU}"$step". Updating system...${NC}"

	echo "${LB}        "$substep")${NC} Running yum update..." ; substep="$(echo $substep | tr '[a-y]z' '[b-z]a')"
	yum update -y & >/dev/null 2>&1
	spinner

	echo "${BU}Step "$step" complete.${NC}"
	echo ""
}
