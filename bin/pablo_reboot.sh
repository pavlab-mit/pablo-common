#!/bin/bash 
#--------------------------------------------------------------
#  Script: pablo_reboot.sh
#  Author: Michael Benjamin
#  Date:   March 10th 2023
#  About:  This script is likely invoked remotely
#          If pablo has blinkstick, should set it to steady cyan
#          before reboot. 
#--------------------------------------------------------------
#  Part 1: Set the path for the script. When run as a cronjob
#  it will only have /bin and /usr/bin by default, so we add
#  others that the script may need.
#--------------------------------------------------------------
DATE=`date`

PATH=$PATH:/sbin
PATH=$PATH:/usr/bin
PATH=$PATH:/usr/local/bin
PATH=$PATH:~/pablo-common/bin
PATH=$PATH:~/pablo-common-aro/bin

echo "Rebooting: $DATE     " >> ~/.rebootlog

qblink.sh orange --dim -2
sleep 1
qblink.sh orange -2
sleep 3
sudo reboot --no-wall  

# If shutdown wasn't successful, indicate with blinking
qblink.sh cyan --blink=100 --dim -2
