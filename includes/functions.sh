#!/bin/bash

function check_errors() {
	if [[ "$1" == "0" ]]; then
		echo -e "	${GREEN}--> Operation success !${NC}"
	else
		echo -e "	${RED}--> Operation failed !${NC}"
	fi
}

function install_letsencrypt() {
	echo -e "${BLUE}### Let's Encrypt installation ###${NC}"
	LEDIR="/opt/letsencrypt"
	if [[ ! -d "$LEDIR" ]]; then
		echo " * Installing Lets'Encrypt"
		git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt > /dev/null 2>&1
		checking_errors $?
		echo ""
		cd /opt/letsencrypt && ./letsencrypt-auto --help > /dev/null 2>&1
	else
		echo -e " ${YELLOW}* Let's Encrypt is already installed !${NC}"
		echo ""
	fi
}

function generate_ssl_cert() {
	EMAILADDRESS=$1
	DOMAIN=$2
	echo -e "  ${BWHITE}* Generating LE certificate for $DOMAIN, please wait...${NC}"
	bash /opt/letsencrypt/letsencrypt-auto certonly --standalone --preferred-challenges http-01 --agree-tos --rsa-key-size 4096 --non-interactive --quiet --email $EMAILADDRESS -d $DOMAINSSL
}

