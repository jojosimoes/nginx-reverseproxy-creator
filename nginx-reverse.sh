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
NGINXCONFDIR='/etc/nginx/conf.d/'
LEDIR='/opt/letsencrypt'
TEMPLATE='https://raw.githubusercontent.com/jojosimoes/nginx-reverseproxy-creator/master/includes/proxy.template.conf'
TEMPLATESSL='https://raw.githubusercontent.com/jojosimoes/nginx-reverseproxy-creator/master/includes/proxyssl.template.conf'
DATE=`date +%d/%m/%Y-%H:%M:%S`
BACKUPDATE=`date +%d-%m-%Y-%H-%M-%S`

### MAIN
clear
echo -e "${BLUE}##############################################${NC}"
echo -e "${BLUE}###       Nginx ReverseProxy Creator       ###${NC}"
echo -e "${BLUE}##############################################${NC}"

## Checking parameters
case $1 in
	"-h" )
		how_to_use
		;;
	"ssl" )
		DOMAIN=$2
		DESTINATION=$3
		EMAIL=$4
		RSAKEYSIZE=$5
		USESSL="yes"
		;;
	"classic" )
		USESSL="no"
		DOMAIN=$2
		DESTINATION=$3
		;;
	"" )
		MODE="manual"
		DOMAIN=$(whiptail --title "Domain" --inputbox "Enter your domain or subdomain for this app" 7 65 3>&1 1>&2 2>&3)
		DESTINATION=$(whiptail --title "Destination" --inputbox "Enter your app's destination (ex: 127.0.0.1:80)" 7 65 3>&1 1>&2 2>&3)
		if (whiptail --title "SSL" --yesno "Do you wan't to use SSL with Let's Encrypt ?" 7 90) then
			EMAIL=$(whiptail --title "Email" --inputbox "Enter your email" 7 65 3>&1 1>&2 2>&3)
			RSAKEYSIZE=$(whiptail --title "RSA Key Size" --inputbox "Enter RSA key size for Let'sEncrypt" 7 65 "2048" 3>&1 1>&2 2>&3)
			USESSL="yes"
		else
			USESSL="no"
		fi
		;;
esac

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
	if [[ ! -d '/opt/letsencrypt' ]]; then
		echo -e "	${GREEN}--> Let's Encrypt not found, installing !${NC}"
		install_letsencrypt
	else
		echo -e "	${YELLOW}--> Let's Encrypt detected${NC}"
	fi
	echo ""
	echo -e "${BLUE}### Define base parameters ###${NC}"
	if [[ "$#" -gt "1" ]]; then
		echo -e "${BWHITE}* You just passed parameters, we'll use them !${NC}"
	else
		echo -e "${BWHITE}* You've not passed parameters, let's started !${NC}"
		echo -e "${BWHITE}* Here is your informations :${NC}"
		echo -e "	-> Your domain : $DOMAIN"
		echo -e "	-> Your app destination : $DESTINATION"
		if [[ "$USESSL" == "yes" ]]; then
			echo -e "	-> Your email : $EMAIL"
			echo -e "	-> RSA Key Size : $RSAKEYSIZE"
		fi
		echo ""
	fi
	echo -e "${BWHITE}* Stopping Nginx service${NC}"
	service nginx stop > /dev/null 2>&1
	check_errors $?
	echo ""
	if [[ "$USESSL" == "yes" ]]; then
		echo -e "${BLUE}### Generating certificate ###${NC}"
		echo -e "${BWHITE}* Generating certificate files${NC}"
		generate_ssl_cert $EMAIL $DOMAIN $RSAKEYSIZE
		check_errors $?
		echo ""
	fi
	echo -e "${BLUE}### Creating reverse proxy ###${NC}"
	NGXPROXYFILE="$NGINXCONFDIR$DOMAIN.conf"
	echo -e "${BWHITE}* Downloading template...${NC}"
	if [[ "$USESSL" == "yes" ]]; then
		wget -q "$TEMPLATESSL" -O "$NGXPROXYFILE"
		check_errors $?
	else
		wget -q "$TEMPLATE" -O "$NGXPROXYFILE"
		check_errors $?
	fi
	echo -e "${BWHITE}* Modifying files...${NC}"
	sed -i "s|%DOMAIN%|$DOMAIN|g" $NGXPROXYFILE
	sed -i "s|%DESTINATION%|$DESTINATION|g" $NGXPROXYFILE
	nginx -t > /dev/null 2>&1
	if [[ "$?" == "0" ]]; then
		echo -e "	${GREEN}--> Nginx file configuration test sucessful !${NC}"
		echo -e "${BWHITE}* Restarting Nginx...${NC}"
		service nginx start > /dev/null 2>&1
		check_errors $?
	else
		echo -e "	${GREEN}--> Nginx file configuration test failed !${NC}"
	fi
	echo ""
fi
