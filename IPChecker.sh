#!/bin/bash
#
############################################################################
### This script should be installed on the relevant download machine.    ###
### Primarily this is used as a VPN checker                              ###
### It should by called via a sudo cron job to enable systemctl commands ###
############################################################################
#
#
#####################
### SET VARIABLES ###
#####################
DIR2=${PWD}
TESTED_IP=$(curl ipinfo.io/ip)
#
#
########################
### IMPORT VARIABLES ###
########################
source "$DIR2"/config.sh
#
#
###############
### TEST IP ###
###############
if [ "$EXPECTED_IP" == "$TESTED_IP" ]
 then echo "UP"
else
 echo "DOWN"
fi
