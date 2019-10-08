#!/bin/bash
#
#
##############################
### SET & IMPORT VARIABLES ###
##############################
DIR1=${PWD}
source "$DIR1"/config.sh
croncmd="$DIR1"/IPChecker.sh
cronjob="* * * * * $croncmd >> $log_location"
#
#
##################
### RUN SCRIPT ###
##################
mkdir -p $log_location
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
#
#
#################################
### MODIFY SCRIPT PERMISSIONS ###
#################################
chmod +x IPChecker.sh
#
#
