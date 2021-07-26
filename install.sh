#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`

for arg in "$@"; do
  case $arg in
    -p=*|--protocol=*)
      PROTOCOL="${arg#*=}"
      shift
      ;;
    -u=*|--user=*)
      USER="${arg#*=}"
      shift
      ;;
    -d=*|--domain=*)
      DOMAIN="${arg#*=}"
      shift
      ;;
    -g=*|--group=*)
      GROUP="${arg#*=}"
      shift
      ;;
    *)
      # unknown option
      ;;
  esac
done

echo "Please enter your password for your VPN connection."
read -s PASSWORD

cp myvpn.config /tmp/myvpn.config
sed -i "s/PASSWORD/$PASSWORD/g" /tmp/myvpn.config
sed -i "s/USER/$USER/g" /tmp/myvpn.config
sed -i "s/PROTOCOL/$PROTOCOL/g" /tmp/myvpn.config
sed -i "s/DOMAIN/$DOMAIN/g" /tmp/myvpn.config
sed -i "s/GROUP/$GROUP/g" /tmp/myvpn.config

sudo mkdir -p /etc/myvpn
sudo cp /tmp/myvpn.config /etc/myvpn/
sudo cp ./myvpn.sh /usr/bin/
sudo chmod +x /usr/bin/myvpn.sh

echo "${green}myvpn is installed successfully."
echo "${yellow}Usage: ./vpn_ulb.sh start|stop|status [-u|--user USER -p|--protocol PROTOCOL -d|--domain DOMAIN -g|--group GROUP] [--default]"
