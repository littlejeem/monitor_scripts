#!/usr/bin/env bash
#
#
#+--------------------------------------+
#+---"Exit Codes & Logging Verbosity"---+
#+--------------------------------------+
# pick from 64 - 113 (https://tldp.org/LDP/abs/html/exitcodes.html#FTN.AEN23647)
# exit 0 = Success
# exit 64 = Variable Error
# exit 65 = Sourcing file/folder error
# exit 66 = Processing Error
# exit 67 = Required Program Missing
#
#verbosity levels
#silent_lvl=0
#crt_lvl=1
#err_lvl=2
#wrn_lvl=3
#ntf_lvl=4
#inf_lvl=5
#dbg_lvl=6
#
#
#+----------------------+
#+---"Check for Root"---+
#+----------------------+
#only needed if root privaleges necessary, enable
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script with sudo:"
  echo "sudo $0 $*"
  exit 66
fi
#
#
#+-----------------------+
#+---"Set script name"---+
#+-----------------------+
# imports the name of this script
# failure to to set this as lockname will result in check_running failing and 'hung' script
# manually set this if being run as child from another script otherwise will inherit name of calling/parent script
scriptlong=`basename "$0"`
lockname=${scriptlong::-3} # reduces the name to remove .sh
#
#
#+--------------------------+
#+---Source helper script---+
#+--------------------------+
source /usr/local/bin/helper_script.sh
#
#
#+---------------------+
#+---"Set Variables"---+
#+---------------------+
#set default logging level, failure to set this will cause a 'unary operator expected' error
#remember at level 3 and lower, only esilent messages show, best to include an override in getopts
verbosity=6
#
version="1.2" #
script_pid=$(echo $$)
stamp=$(echo "`date +%H.%M`-`date +%d_%m_%Y`")
notify_lock=/tmp/IPChecker_notify
pushover_title="Services Checker"
#
#
#+---------------------------------------+
#+---"check if script already running"---+
#+---------------------------------------+
check_running
#
#
#+-------------------+
#+---Set functions---+
#+-------------------+
helpFunction () {
   echo ""
   echo "Usage: $0 $scriptlong"
   echo "Usage: $0 $scriptlong -G"
   echo -e "\t Running the script with no flags causes default behaviour with logging level set via 'verbosity' variable"
   echo -e "\t-S Override set verbosity to specify silent log level"
   echo -e "\t-V Override set verbosity to specify Verbose log level"
   echo -e "\t-G Override set verbosity to specify Debug log level"
   echo -e "\t-h Use this flag for help"
   if [ -d "/tmp/$lockname" ]; then
     edebug "removing lock directory"
     rm -r "/tmp/$lockname"
   else
     edebug "problem removing lock directory"
   fi
   exit 65 # Exit script after printing help
}
#
function check_service () {
  check=$(systemctl show -p SubState --value $service_name.service)
  edebug "service status: $check"
}
#
function check_selection () {
  if [ "$service_selection" == "1" ]
  then
    message_form=$(echo "$service_name IS selected for checking")
    edebug "$message_form"
    check_service
    if [ $check != "running" ]
    then
      message_form=$(echo "$service_name not running, attempting restart of $service_name service...")
      edebug $message_form
      pushover
      systemctl restart $service_name
      sleep 1m
      check_service
      if [ $check != "running" ]
      then
        message_form=$(echo "... $service_name STILL not running, critical failure. contact your administrator")
        edebug $message_form
        pushover
      else
        message_form=$(echo "...$service_name successfully restarted")
        edebug $message_form
        pushover
      fi
    fi
  else
    edebug "Service name: $service_name, is NOT selected for checking"
  fi
}
#
#
#+------------------------+
#+---"Get User Options"---+
#+------------------------+
OPTIND=1
while getopts ":SVGHh:" opt
do
    case "${opt}" in
        S) verbosity=$silent_lvl
        edebug "-S specified: Silent mode";;
        V) verbosity=$inf_lvl
        edebug "-V specified: Verbose mode";;
        G) verbosity=$dbg_lvl
        edebug "-G specified: Debug mode";;
#Example for extra options
#        d) drive_install=${OPTARG}
#        edebug "-d specified: alternative drive being used";;
        H) helpFunction;;
        h) helpFunction;;
        ?) helpFunction;;
    esac
done
shift $((OPTIND -1))
#
#
#+----------------------+
#+---"Script Started"---+
#+----------------------+
# At this point the script is set up and all necessary conditions met so lets log this
esilent "$lockname started"
#
#
#+-------------------------------+
#+---Configure GETOPTS options---+
#+-------------------------------+
#e.g for a drive option
#if [[ $drive_install = "" ]]; then
#  drive_number="sr0"
#  edebug "no alternative drive specified, using default: $drive_number as drive install"
#else
#  drive_number=$(echo $drive_install)
#  edebug "alternative drive specified, using: $drive_number as drive install"
#fi
#
edebug "GETOPTS options set"
#
#
#+--------------------------+
#+---"Source config file"---+
#+--------------------------+
source /usr/local/bin/config.sh
#
#
#+--------------------------------------+
#+---"Display some info about script"---+
#+--------------------------------------+
edebug "Version of $scriptlong is: $version"
edebug "PID is $script_pid"
#
#
#+-------------------+
#+---Set up script---+
#+-------------------+
#Get environmental info
edebug "INVOCATION_ID is set as: $INVOCATION_ID"
edebug "EUID is set as: $EUID"
edebug "PATH is: $PATH"
#
#
#+----------------------------+
#+---"Main Script Contents"---+
#+----------------------------+
service_name="transmission-daemon"
service_selection=${transmission}
check_selection
#
service_name="prowlarr"
service_selection=${prowlarr}
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
#+-------------------+
#+---"Script Exit"---+
#+-------------------+
rm -r /tmp/"$lockname"
if [[ $? -ne 0 ]]; then
    eerror "error removing lockdirectory"
    exit 65
else
    enotify "successfully removed lockdirectory"
fi
esilent "$lockname completed"
exit 0
