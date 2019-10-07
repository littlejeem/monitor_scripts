#!/bin/bash
#
#
##############################
### SET & IMPORT VARIABLES ###
##############################
source "$DIR2"/config.sh
croncmd="$DIR2"/IPChecker.sh
cronjob="* * * * * $croncmd"
#
#
##################
### RUN SCRIPT ###
##################
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
