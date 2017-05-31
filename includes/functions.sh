#!/bin/bash

function check_errors() {
	if [[ "$1" == "0" ]]; then
		echo -e "	${GREEN}--> Operation success !${NC}"
	else
		echo -e "	${RED}--> Operation failed !${NC}"
	fi
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

