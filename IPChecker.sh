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
    --form-string title="VPN & Internet Check" \
    --form-string message="$message_form" \
    https://api.pushover.net/1/messages.json
}
#
#
#+------------------------------+
#+---"Set & Import Variables"---+
#+------------------------------+
PATH=/sbin:/bin:/usr/bin:/home/pi
log=/home/pi/bin/script_logs/ip_checker.log
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
if [ "$tested_ip" != "$expected_ip" ]
 then
   message_form=$(echo "VPN is DOWN")
   echo $message_form >> $log
   pushover
   if test -f "$file_temp"
   then
     message_form=$(echo "Lock file $file_temp exists, a reset has either not been completed or script exited dirty, attention needed")
     echo $message_form >> $log
     pushover
     exit 1
   else
     message_form=$(echo "Attempting to stop transmission-daemon")
     echo $message_form >> $log
     check=$(systemctl show -p SubState --value transmission-daemon.service)
     if [ $check != "running" ]
     then
       message_form=$(echo "transmission-daemon is already 'stopped'")
       echo $message_form >> $log
     else
       systemctl stop transmission-daemon
       sleep 1m
       if [ $check != "running" ]
       then
         message_form=$(echo "transmission-daemon successfully 'stopped'")
         echo $message_form >> $log
         pushover
         exit 0
       else
         message_form=$(echo "failed to successfully 'stop' transmission-daemon, urgent attention required")
         pushover
         exit 1
       fi
     fi
   fi
 else
   echo "VPN is UP" >> $log
fi
#
#
#--------------------+
#+---"Stop Logging---+
#+-------------------+
echo "script ENDED - $stamp" >> $log
echo "-----------------------------------------------------------------------------" >> $log
echo "#" >> $log
