#!/bin/bash
source includes/functions.sh
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
clear
echo -e "${BLUE}##############################################${NC}"
echo -e "${BLUE}###       Nginx ReverseProxy Creator       ###${NC}"
echo -e "${BLUE}##############################################${NC}"
echo ""
echo -e "${BLUE}### Checking system ###${NC}"
echo -e "${BWHITE}* Preparing system...${NC}"
apt-get update  > /dev/null 2>&1
apt-get install -y git locate curl > /dev/null 2>&1
check_errors $?
echo -e "${BWHITE}* Checking Nginx...${NC}"
if [[ ! -d '/etc/nginx' ]]; then
	echo -e "${GREEN}--> Nginx isn't installed, let's go !${NC}"
	apt-get install -y nginx > /dev/null 2>&1
	check_errors $?
else
	echo -e "	${YELLOW}--> Nginx detected !${NC}"
	echo -e "${BWHITE}* Checking Let's Encrypt...${NC}"
	if (whiptail --title "SSL" --yesno "Do you wan't to use SSL with Let's Encrypt ?" 7 90) then
		USESSL="yes"
	else
		USESSL="no"
	fi
	if [[ ! -d '/opt/letsencrypt' ]]; then
		echo -e "	${GREEN}--> Let's Encrypt not found, installing !${NC}"
		install_letsencrypt
	else
		echo -e "	${YELLOW}--> Let's Encrypt detected${NC}"
	fi
	echo ""
	echo -e "${BLUE}### Define base parameters ###${NC}"
	if [[ "$#" -gt "0" ]]; then
		echo -e "${BWHITE}* You just passed parameters, we'll use them !${NC}"
		DOMAIN=$1 && PORT=$2 && EMAIL=$3 && RSAKEYSIZE=$4
		echo "$1 $2 $3 $4"
	else
		echo -e "${BWHITE}* You've not passed parameters, let's started !${NC}"
		DOMAIN=$(whiptail --title "Domain" --inputbox "Enter your domain or subdomain for this app" 7 50 3>&1 1>&2 2>&3)
		PORT=$(whiptail --title "Port" --inputbox "Enter your app's port" 7 50 3>&1 1>&2 2>&3)
		if [[ "$USESSL" == "yes" ]]; then
			EMAIL=$(whiptail --title "Email" --inputbox "Enter your email" 7 50 3>&1 1>&2 2>&3)
			RSAKEYSIZE=$(whiptail --title "RSA Key Size" --inputbox "Enter RSA key size for Let'sEncrypt" 7 50 "2048" 3>&1 1>&2 2>&3)
		fi
		echo -e "${BWHITE}* Here is your informations :${NC}"
		echo -e "	-> Your domain : $DOMAIN"
		echo -e "	-> Your app port : $PORT"
		if [[ "$USESSL" == "yes" ]]; then
			echo -e "	-> Your email : $EMAIL"
			echo -e "	-> RSA Key Size : $RSAKEYSIZE"
		fi
		echo ""
	fi
	if [[ "$USESSL" == "yes" ]]; then
		echo -e "${BLUE}### Generating certificate ###${NC}"
		echo -e "${BWHITE}* Stopping Nginx service${NC}"
		service nginx stop > /dev/null 2>&1
		check_errors $?
		echo -e "${BWHITE}* Generating certificate files${NC}"
		generate_ssl_cert $EMAIL $DOMAIN $RSAKEYSIZE
		check_errors $?
	fi
fi