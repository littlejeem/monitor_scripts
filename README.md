# monitor_scripts
A repository of scripts designed to monitor or oversea functions

This script should be installed on the relevant download machine. Primarily this is used as a VPN checker

Help to create necessary install file came from here:
https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor

It should by called via a sudo cron job to enable systemctl commands. Install by navigating to your preferred script location, eg. ```/home/USER/bin/```

```bash
sudo git clone https://github.com/littlejeem/monitor_scripts.git
cd monitor_scripts
sudo chmod +x install_monitor_scripts.sh
sudo ./install_monitor_scripts.sh
```
