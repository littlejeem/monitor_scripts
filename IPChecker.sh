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
function remove_lock () {
  if [ -d "$script_lock" ]
  then
    echo "$script_lock folder exists, deleting" >> $log
    rm -r $script_lock
  else
    echo "ERROR $script_lock folder not present" >> $log
  fi
}
#
function end_log () {
  #--------------------+
  #+---"Stop Logging---+
  #+-------------------+
  echo "script ENDED - $stamp" >> $log
  echo "-----------------------------------------------------------------------------" >> $log
  echo "#" >> $log
}
#
#+---------------------+
#+---"Set Variables"---+
#+---------------------+
PATH=/sbin:/bin:/usr/bin:/home/pi
log=/home/pi/bin/script_logs/ip_checker.log
stamp=$(echo "`date +%H.%M`-`date +%d_%m_%Y`")
tested_ip=$(curl ipinfo.io/ip)
script_lock=/tmp/IPChecker
notify_lock=/tmp/IPChecker_notify
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
if test -d "$script_lock"
 then
   message_form=$(echo "Lock file $script_lock exists, script is already running, or script exited dirty")
   echo $message_form >> $log
   end_log
   exit 1
elif [ "$tested_ip" != "$expected_ip" ]
 then
   if test -d "$notify_lock"
   then
     echo "Script previously run, VPN down, notifications sent but no reset action yet taken" >> $log
     end_log
     exit 0
   fi
   message_form=$(echo "VPN is DOWN")
   echo $message_form >> $log
   pushover
   mkdir $script_lock
   echo "$script_lock created" >> $log
   message_form=$(echo "Attempting to stop transmission-daemon")
   echo $message_form >> $log
   pushover
   check=$(systemctl show -p SubState --value transmission-daemon.service)
   echo $check >> $log
   if [ $check != "running" ]
    then
      message_form=$(echo "transmission-daemon is already 'stopped'")
      echo $message_form >> $log
      pushover
      remove_lock
      end_log
      exit 0
    else
      systemctl stop transmission-daemon
      sleep 1m
      check=$(systemctl show -p SubState --value transmission-daemon.service)
      echo $check >> $log
      if [ $check != "running" ]
      then
        message_form=$(echo "transmission-daemon successfully 'stopped'")
        echo $message_form >> $log
        pushover
        remove_lock
        end_log
        exit 0
      else
        message_form=$(echo "failed to successfully 'stop' transmission-daemon, urgent attention required")
        pushover
        end_log
        exit 1
      fi
    fi
 else
   echo "VPN is UP" >> $log
   end_log
   exit 0
 fi
#
#
