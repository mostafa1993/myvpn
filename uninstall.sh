#!/bin/bash

green=`tput setaf 2`
yellow=`tput setaf 3`

if test -f /usr/bin/myvpn || test -d /etc/myvpn; then
  sudo rm /usr/bin/myvpn
  sudo rm -rf /etc/myvpn
  echo -e "${green}myvpn is uninstalled successfully.\nThanks for your intrest in using myvpn app."
  exit 0
else
  echo "${yellow}myvpn is already uninstalled or not installed !!!"
  exit 1
fi


