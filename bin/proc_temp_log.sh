#!/bin/bash

# Raspberry Pi temperature logger
# Raphael Segal
# Jan 20, 2017
# outputs CSV of three variables, time, epoch time, and temperature in degrees C

RAWNAME="CPU_TEMPS_"`date`".log"
OF=${RAWNAME// /_}

while true
do
    tempstring=`sudo /opt/vc/bin/vcgencmd measure_temp`
    IFS='='"'" read -ra temparray <<< $tempstring
    temp=${temparray[1]}
    
    echo `date`", "`date +%s`", "$temp >> $OF

    trap "echo ""; echo Exited!; exit;" SIGINT SIGTERM

    sleep 1
done

