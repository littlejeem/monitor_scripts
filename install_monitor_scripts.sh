#!/bin/bash
#
#
##############################
### SET & IMPORT VARIABLES ###
##############################
DIR2=${PWD}
source "$DIR2"/config.sh
croncmd="$DIR2"/IPChecker.sh
cronjob="* * * * * $croncmd"
#
#
##################
### RUN SCRIPT ###
##################
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
