#/bin/bash
#
#
#A script to monitor activity of a number of services and if necessary notify the end user (me!)
#https://unix.stackexchange.com/questions/396630/the-proper-way-to-test-if-a-service-is-running-in-a-script
#
#+---------------------+
#+---"Set Variables"---+
#+---------------------+
#PATH=/sbin:/bin:/usr/bin:/home/jlivin25
#transmission-daemon=1
jackett="1"
lidarr="0"
sonarr="0"
radarr="0"
#
#
#+----------------------+
#+---Set up functions---+
#+----------------------+
function pushover () {
  curl -s --form-string token="$app_token" --form-string user="$user_token" --form-string message="$message_form" https://api.pushover.net/1/messages.json
}
#
function Check_Service () {
  check=$(systemctl show -p SubState --value $service_name.service)
}
#
function check_selection () {
#  if [ $service_name == "1" ]
  if [[ "$service_name" -eq 1 ]]
  then
    Check_Service
    if [ $check != "running" ]
    then
      message_form=$(echo "$service_name not running, sending error report and attempting restart of $service_name service")
      echo $message_form
#      pushover
#      systemctl restart $service_name
      wait 1m
      Check_Service
      if [ $check != "running" ]
      then
        message_form=$(echo "$service_name STILL not running, critical failure with $service_name.service, in-system investiation needed")
        echo $message_form
#        pushover
      else
        message_form=$(echo "$service_name successfully restarted")
        echo $message_form
#        pushover
      fi
    fi
  else
    echo "$service_name not selected for checking"
  fi
}
#
#
#+------------------------+
#+---"Import user info"---+
#+------------------------+
dir_name="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $dir_name/config.sh
#
#
#+-------------------+
#+---"Main Script"---+
#+-------------------+
service_name=${transmission-daemon}
check_selection
#
service_name=${jackett}
check_selection
#
service_name=${lidarr}
check_selection
#
service_name=${sonarr}
check_selection
#
service_name=${radarr}
check_selection
