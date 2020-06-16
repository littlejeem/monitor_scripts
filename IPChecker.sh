#!/bin/bash
#
############################################################################
### This script should be installed on the relevant download machine.    ###
### Primarily this is used as a VPN checker                              ###
### It should by called via a sudo cron job to enable systemctl commands ###
############################################################################
#
#
#+---------------------+
#+---"Set Functions"---+
#+---------------------+
function pushover () {
  curl -s \
    --form-string token="$app_token" \
    --form-string user="$user_token" \
    --form-string title="VPN Checker" \
    --form-string message="$message_form" \
    https://api.pushover.net/1/messages.json
}
#
#
#+------------------------------+
#+---"Set & Import Variables"---+
#+------------------------------+
PATH=/sbin:/bin:/usr/bin:/home/jlivin25
log=/home/pi/bin/script_logs/services_checker.log
stamp=$(echo "`date +%H.%M`-`date +%d_%m_%Y`")
#
tested_ip=$(curl ipinfo.io/ip)
#
file_temp=/tmp/IPChecker.lock
#
#
#+---------------------+
#+---"Start Logging"---+
#+---------------------+
echo "#" >> $log
echo "-----------------------------------------------------------------------------" >> $log
echo "script STARTED - $stamp" >> $log
#
#
#+------------------------+
#+---"Import user info"---+
#+------------------------+
dir_name="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $dir_name >> $log
source $dir_name/config.sh
echo "I would source $dir_name/config.sh in real world" >> $log
#
#
#+--------------------+
#+---"Main Script"---+
#+--------------------+
if [ "$tested_ip" =! "$expected_ip" ]
 then
   echo "VPN is DOWN"
 else
   echo "VPN is UP"
 #
 #
#  if test -f "$FILE"
#  then echo "VPN Down but $FILE exists, a reset has not been completed"
#     exit 0
#  else
#  echo "VPN Down, stopping transmission-daemon"
#  systemctl stop transmission-daemon
#  fi
fi
#
#
#--------------------+
#+---"Stop Logging---+
#+-------------------+
echo "script ENDED - $stamp" >> $log
echo "-----------------------------------------------------------------------------" >> $log
echo "#" >> $log
