#!/bin/bash

start() {
  pid=$(pidof openconnect)
  if [[ -z $pid ]]; then
    (sudo sh -c '(echo "$0" | sudo openconnect --user=$1 --protocol=$2 --passwd-on-stdin $3 --authgroup=$4) &\
      pid=$!; sleep 0.5; if test "$(ps | grep -w $pid)" = ""; then wait $pid; STATUS=$? > .tmp; else echo; STATUS=$?; fi;\
      echo $STATUS > /tmp/.myvpn_status' $1 $2 $3 $4 $5) &> .log
    STATUS=$(cat /tmp/.myvpn_status)
    if test $STATUS = "0"; then
      echo "${green}$4 Connection established successfully."
      return
    else
      echo -e "${red}Connection could not be established. Error:\n$(cat .log)"
      exit 1
    fi
  fi

  echo "${yellow}$4 connection is already established."
}


stop() {
  pid=$(pidof openconnect)
  if [[ -z $pid ]]; then
    echo "${yellow}VPN is already disconnected"
    return
  fi

  sudo kill -2 $(pidof openconnect)
  echo  "VPN connection is stopped successfully"
}


status() {
  pid=$(pidof openconnect)
  if [[ -z $pid ]]; then
    echo "Status: VPN is not connected. ${yellow}Do you want to start it? [y/N]${reset}"
    read answer
    echo "Do you want to start with default configuration? [Y/n]"
    read DEFAULT
    DEFAULT="${DEFAULT,,}"
    if [[ $DEFAULT = "n" ]] && ([[ $answer = "y" ]] || [[ $answer = "Y" ]]); then
      echo "please enter your password"
      read -s PASSWORD
      echo "please enter your user protocol and domain [and group] respectively seperated by space."
      read USER PROTOCOL DOMAIN GROUP
    else
      CONFIG_FILE="$(grep -v '^#' $CONFIG_FILE)"
      PASSWORD=$(echo "$CONFIG_FILE" | grep 'password' | cut -f 2 -d '=')
      USER=$(echo "$CONFIG_FILE"     | grep  'user'    | cut -f 2 -d '=')
      PROTOCOL=$(echo "$CONFIG_FILE" | grep 'protocol' | cut -f 2 -d '=')
      DOMAIN=$(echo "$CONFIG_FILE"   | grep 'domain'   | cut -f 2 -d '=')
      GROUP=$(echo "$CONFIG_FILE"    | grep 'group'    | cut -f 2 -d '=')
    fi
    start $PASSWORD $USER $PROTOCOL $DOMAIN $GROUP
    return
  fi

  echo "Status: ${green}VPN is connected"
}


CONFIG_FILE="/etc/myvpn/myvpn.config"
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`

case "$1" in
  start)
    ACTION=start
    shift
    ;;
  stop)
    ACTION=stop
    shift
    ;;
  status)
    ACTION=status
    shift
    ;;
  restart)
    ACTION=restart
    shift
    ;;
  *)
    echo "${yellow}Usage: ./vpn_ulb.sh start|stop|status [-u|--user USER -p|--protocol PROTOCOL -d|--domain DOMAIN -g|--group GROUP] [--default]"
    exit 1
esac


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
    --default)
      DEFAULT=YES
      if [[ ! -f $CONFIG_FILE ]]; then
        echo "${red}confige file doesn't exist in /etc/myvpn directory"
        exit 1
      fi
      shift
      ;;
    *)
      # unknown option
      ;;
  esac
done

if [[ ! $DEFAULT = "YES" ]] && [[ $ACTION = "start" ]]; then
  echo "Please enter your password for your VPN connection."
  read -s PASSWORD
fi

if [[ $DEFAULT = "YES" ]]; then
  CONFIG_FILE="$(grep -v '^#' $CONFIG_FILE)"
  PASSWORD=$(echo "$CONFIG_FILE" | grep 'password' | cut -f 2 -d '=')
  USER=$(echo "$CONFIG_FILE"     | grep  'user'    | cut -f 2 -d '=')
  PROTOCOL=$(echo "$CONFIG_FILE" | grep 'protocol' | cut -f 2 -d '=')
  DOMAIN=$(echo "$CONFIG_FILE"   | grep 'domain'   | cut -f 2 -d '=')
  GROUP=$(echo "$CONFIG_FILE"    | grep 'group'    | cut -f 2 -d '=')
else
  if [[ $ACTION = "start" ]] && ([[ -z $USER ]] || [[ -z $PROTOCOL ]] || [[ -z $DOMAIN ]]); then
    echo "$PASSWORD $USER $PROTOCOL $DOMAIN"
    echo "${yellow}Usage: ./vpn_ulb.sh start|stop|status [-u|--user USER -p|--protocol PROTOCOL -d|--domain DOMAIN -g|--group GROUP] [--default]"
    exit 1
  fi
fi

case "$ACTION" in
  start)
    start $PASSWORD $USER $PROTOCOL $DOMAIN $GROUP
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
esac

exit 0

