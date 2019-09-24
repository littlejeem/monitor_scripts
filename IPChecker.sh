#!/bin/bash
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
