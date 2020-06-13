#!/usr/bin/env bash
#
#
#A script to monitor activity of a number of services and if necessary notify the end user (me!)
#https://unix.stackexchange.com/questions/396630/the-proper-way-to-test-if-a-service-is-running-in-a-script
#
#+---------------------+
#+---"Set Variables"---+
#+---------------------+
PATH=/sbin:/bin:/usr/bin:/home/jlivin25
log=/home/pi/bin/script_logs/services_checker.log
#transmission-daemon="1"
jackett="0"
lidarr="0"
sonarr="0"
radarr="0"
#
#
#+------------------------+
#+---"Set up functions"---+
#+------------------------+
function pushover () {
  curl -s --form-string token="$app_token" --form-string user="$user_token" --form-string message="$message_form" https://api.pushover.net/1/messages.json
}
#
function Check_Service () {
  check=$(systemctl show -p SubState --value $service_name.service)
}
#
function check_selection () {
  if [ "$service_selection" == "1" ]
  then
    message_form=$(echo "$service_name IS selected for checking")
    echo $message_form >> $log
    Check_Service
    if [ $check != "running" ]
    then
      message_form=$(echo "$service_name not running, sending error report and attempting restart of $service_name service")
      echo $message_form >> $log
#      pushover
#      systemctl restart $service_name
      wait 1m
      Check_Service
      if [ $check != "running" ]
      then
        message_form=$(echo "$service_name STILL not running, critical failure with $service_name.service, in-system investiation needed")
        echo $message_form >> $log
#        pushover
      else
        message_form=$(echo "$service_name successfully restarted")
        echo $message_form >> $log
#        pushover
      fi
    fi
  else
    echo "$service_name is NOT selected for checking" >> $log
  fi
}
#
#
#+---------------------+
#+---"Start Logging"---+
#+---------------------+
echo "#" >> $log
echo "-----------------------------------------------------------------------------" >> $log
echo "script STARTED" >> $log
#
#
#+------------------------+
#+---"Import user info"---+
#+------------------------+
dir_name="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $dir_name >> $log
#source $dir_name/config.sh
echo "I would source $dir_name/config.sh in real world" >> $log
#
#
#+-------------------+
#+---"Main Script"---+
#+-------------------+
#service_name="transmisson-daemon"
#service_selection=${transmission-daemon}
#check_selection
#
service_name="jackett"
service_selection=${jackett}
check_selection
#
service_name="lidarr"
service_selection=${lidarr}
check_selection
#
service_name="sonarr"
service_selection=${sonarr}
check_selection
#
service_name="radarr"
service_selection=${radarr}
check_selection
#
#
#--------------------+
#+---"Stop Logging---+
#+-------------------+
echo "script ENDED" >> $log
echo "-----------------------------------------------------------------------------" >> $log
echo "#" >> $log
#
#
