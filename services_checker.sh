#/bin/bash
#
#
#A script to monitor activity of a number of services and if necessary notify the end user (me!)
#https://unix.stackexchange.com/questions/396630/the-proper-way-to-test-if-a-service-is-running-in-a-script
#
#+---------------------+
#+---"Set Variables"---+
#+---------------------+
transmissiondaemon=1
jackett=1
lidarr=1
sonarr=1
radarr=1
#
#
#+----------------------+
#+---Set up functions---+
#+----------------------+
function Check_Services ()
{
  systemctl show -p SubState --value $service_name.service
}

function check_selection ()
{
  if [ $service_name == "1" ]
  then
    Check_Services
  else
    echo "$service_name not selected for checking"
  fi
}
#
#
#+-------------------+
#+---"Main Script"---+
#+-------------------+
service_name="transmission-daemon"
check_selection
#
service_name="jackett"
check_selection
#
service_name="lidarr"
check_selection
#
service_name="sonarr"
check_selection
#
service_name="radarr"
check_selection
