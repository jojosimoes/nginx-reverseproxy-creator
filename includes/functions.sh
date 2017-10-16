#!/bin/bash

function check_errors() {
	if [[ "$1" == "0" ]]; then
		echo -e "	${GREEN}--> Operation success !${NC}"
	else
		echo -e "	${RED}--> Operation failed !${NC}"
	fi
}

function how_to_use() {
	echo -e " ${YELLOW}/!\ Wrong usage of the script. Please use the following parameters :${NC}"
	echo -e "${BWHITE}Usage for classic reverse :${NC} ./nginx-reverse.sh [OPTIONS] [PARAMETERS]"
	echo ""
	echo -e "${BWHITE}Options 	Meaning${NC}"
	echo "classic 	Create classic reverse proxy on HTTP (80)"
	echo "ssl 		Create SSL reverse proxy on HTTPS (443)"
	echo -e "${BWHITE}Parameter 	Meaning${NC}"
	echo "DOMAIN 		Your domain or Subdomain you want to use with app"
	echo "DESTINATION 	Destination you wan't to use behind your reverse"
	echo "EMAIL 		Your email, to use with Let's Encrypt (Just for SSL)"
	echo "RSAKEYSIZE 	Define an RSA Key Size for Let's Encrypt generation (Just for SSL)"
	echo ""
	echo -e "${BWHITE}Examples :${NC}"
	echo "    -> ./nginx-reverse.sh"
	echo "    -> ./nginx-reverse.sh classic domain.tld localhost:8080"
	echo "    -> ./nginx-reverse.sh ssl domain.tld localhost:8080 contact@domain.tld 2048"
	exit 1
}

function install_letsencrypt() {
	LEDIR="/opt/letsencrypt"
	if [[ ! -d "$LEDIR" ]]; then
		echo -e "${BWHITE}* Installing Lets'Encrypt${NC}"
		git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt > /dev/null 2>&1
		cd /opt/letsencrypt && ./letsencrypt-auto --help > /dev/null 2>&1
		check_errors $?
	else
		echo -e "	${YELLOW}* [INFO] Let's Encrypt already installed !${NC}"
	fi
}

function generate_ssl_cert() {
	EMAILADDRESS=$1
	DOMAIN=$2
	RSAKEYSIZE=$3
	echo -e "  ${BWHITE}* Generating LE certificate for $DOMAIN, please wait...${NC}"
	bash /opt/letsencrypt/letsencrypt-auto certonly --standalone --preferred-challenges http-01 --agree-tos --rsa-key-size $RSAKEYSIZE --non-interactive --quiet --email $EMAILADDRESS -d $DOMAIN
}
