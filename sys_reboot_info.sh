#!/usr/bin/env bash
#
#########################################################################################
### "sys_reboot_info.sh is there to send info to an end user in event of a reboot."   ###
### "for example after a powercut reboot etc where IP might have changed"             ###
### "Best placed in or symlinked to /usr/local/bin"                                   ###
### "Requres helper_script.sh & config.sh, both also in /usr/local/bin"               ###
###                                                                                   ###
### If you want to run as a system service, create a systemd file with the following: ###
###                                                                                   ###
### sudo nano /etc/systemd/systemd/sys_reboot_info.service                            ###
###                                                                                   ###
### [Unit]                                                                            ###
### Description=System Reboot Pushover Info                                           ###
### After=network.target                                                              ###
### [Service]                                                                         ###
### User=$USER                                                                        ###
### Group=$GROUP                                                                      ###
### Type=simple                                                                       ###
### ExecStart=/usr/local/bin/sys_reboot_info.sh -G                                    ###
### [Install]                                                                         ###
### WantedBy=multi-user.target"                                                       ###
###                                                                                   ###
### then run:                                                                         ###
###                                                                                   ###
### sudo systemctl daemon-reload && sudo systemctl enable sys_reboot_info.service     ###
#########################################################################################
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
#if [[ $EUID -ne 0 ]]; then
#    echo "Please run this script with sudo:"
#    echo "sudo $0 $*"
#    exit 66
#fi
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
verbosity=3
#
version="0.1" #
script_pid=$(echo $$)
sys_hostname=$(hostname)
pushover_title="$sys_hostname Reboot Info" #Uncomment if using pushover
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
#edebug "GETOPTS options set"
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
#get internal machine info
machine_ip=$(hostname -I | cut -d ' ' -f 1)
edebug "Machine IP: $machine_ip"
wanip_display=$(wan_ip)
edebug "WAN IP: $wanip_display"
gateway=$(ip r | grep default | cut -d ' ' -f -3 | cut -d ' ' -f 3-)
edebug "Gateway: $gateway"
sys_desc=$(lsb_release -d)
edebug "$sys_desc"
#set out message order
message_form="Hostname: $sys_hostname
Gateway: $gateway
WAN: $wanip_display
Machine IP: $machine_ip
$sys_desc" \
pushover
edebug "Message form would be: $message_form"
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
