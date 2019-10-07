#!/bin/bash
#
############################################################################
### This script should be installed on the relevant download machine.    ###
### Primarily this is used as a VPN checker                              ###
### It should by called via a sudo cron job to enable systemctl commands ###
############################################################################
#
#
##############################
### SET & IMPORT VARIABLES ###
##############################
TESTED_IP=$(curl ipinfo.io/ip)
FILE=/tmp/IPChecker.lock
source "$DIR1"/config.sh
#
#
###############
### TEST IP ###
###############
if [ "$EXPECTED_IP" == "$TESTED_IP" ]
 then echo "UP"
 else
 echo "DOWN"
 #
 #
  if test -f "$FILE"
  then echo "$FILE exists, a reset has not been completed"
     exit 0
  else
  systemctl stop transmission-daemon
  curl -s \
    --form-string "token=$APP_TOKEN" \
    --form-string "user=$USER_KEY" \
    --form-string "message=VPN Down, transmission-daemon stopped" \
    https://api.pushover.net/1/messages.json
  fi
fi
