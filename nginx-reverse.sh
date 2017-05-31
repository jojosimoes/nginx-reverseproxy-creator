#!/bin/bash
### SYNTAX COLORATION
RED='\e[0;31m'
GREEN='\033[0;32m'
BLUEDARK='\033[0;34m'
BLUE='\e[0;36m'
YELLOW='\e[0;33m'
BWHITE='\e[1;37m'
NC='\033[0m'
NGINXCONFDIR='/etc/nginx/'
LEDIR='/opt/letsencrypt'
DATE=`date +%d/%m/%Y-%H:%M:%S`
BACKUPDATE=`date +%d-%m-%Y-%H-%M-%S`

### MAIN
echo -e "${BLUE}### NGINX REVERSEPROXY CREATOR ###${NC}"
echo -e "${BWHITE}* Preparing system...${NC}"
apt-get update  > /dev/null 2>&1
apt-get install -y git locate curl > /dev/null 2>&1
check_errors $?
if [[ ! -d '$NGINXCONFDIR' ]]; then
	apt-get install -y nginx > /dev/null 2>&1
else
	if [[ '$#' -gt '0' ]]; then
		DOMAIN=$1
		PORT=$2
		EMAIL=$3
		RSAKEYSIZE=$4
	else
		if (whiptail --title "SSL" --yesno "Do you wan't to use SSL with Let's Encrypt ?" 7 90) then
			if [[ ! -f '$LEDIR' ]]; then

			fi
		fi
	fi
fi