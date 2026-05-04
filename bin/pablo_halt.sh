#!/bin/bash 
#--------------------------------------------------------------
#  Script: pablo_halt.sh
#  Author: Michael Benjamin
#  Date:   March 10th 2023
#  About:  This script is likely invoked remotely
#          If pablo has blinkstick, should set it to steady cyan
#          before shutdown. Pablo shutdown will not power down
#          the blinkstick. It only powers down the CPU, as safer
#          method than powering off. Otherwise the SD card is
#          more likely to be corrupted.
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

echo "Halting: $DATE     " >> ~/.rebootlog

qblink.sh cyan  --dim -2
sleep 1
qblink.sh cyan -2
sleep 2
sudo shutdown -h now

# If shutdown wasn't successful, indicate with blinking
qblink.sh cyan --blink=100 --dim -2
