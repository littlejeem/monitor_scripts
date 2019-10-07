#!/bin/bash
#
#
##############################
### SET & IMPORT VARIABLES ###
##############################
DIR1=${PWD}
source "$DIR1"/config.sh
croncmd="$DIR1"/IPChecker.sh
cronjob="* * * * * $croncmd"
#
#
##################
### RUN SCRIPT ###
##################
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
#
#
#################################
### MODIFY SCRIPT PERMISSIONS ###
#################################
chmod +x IPChecker.sh
#
#
