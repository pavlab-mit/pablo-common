#!/bin/bash
#--------------------------------------------------------
# Script: get_heron_name.sh
#   Date: Apr 16th, 2023
#     By: Mike Benjamin
#  About: A script for getting the pablo heron name based
#         on the IP address. When pablos are connected to 
#         Herons, they have one of a known set of IP addrs
#-------------------------------------------------------
#  Part 1: Initialize global variables
#-------------------------------------------------------
ME=`basename "$0"`
VNAME=""

# Linux specific
IP_ADDR=`hostname -I`

#-------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "$ME  [OPTIONS]                                       "
        echo "                                                     " 
        echo "Synopsis:                                            " 
        echo "  Get a Pablo name based on Heron IP Address         "
        echo "                                                     " 
        echo "  --help, -h            Display this help message    " 
        exit 0;
    else
	echo "$ME: Bad Arg:[$ARGI]. Exit Code 1."
	exit 1
    fi
done

IPA=`echo $IP_ADDR | cut -d . -f 1`
IPB=`echo $IP_ADDR | cut -d . -f 2`
IPC=`echo $IP_ADDR | cut -d . -f 3`
IPD=`echo $IP_ADDR | cut -d . -f 4 | cut -d ' ' -f 1`

#---------------------------------------------------------------
# Part 3: If 4th field of IP Addr is 100, likely a Heron
#---------------------------------------------------------------
if [[ $IPD -eq 100 ]]; then
    # Pablos on herons will likely be:
    # 192.168.14.100 abe
    # 192.168.15.100 ben
    # 192.168.16.100 cal
    # 192.168.17.100 deb
    # 192.168.18.100 eve
    # 192.168.19.100 fin
    # 192.168.20.100 max
    # 192.168.21.100 ned
    # 192.168.22.100 oak
    # 192.168.23.100 pip
    # 10.31.1.100 zoe
    # 10.32.1.100 yip
    # 10.33.1.100 xai

    if [ $IPC -eq 14 ]; then VNAME="abe"; fi
    if [ $IPC -eq 15 ]; then VNAME="ben"; fi
    if [ $IPC -eq 16 ]; then VNAME="cal"; fi
    if [ $IPC -eq 17 ]; then VNAME="deb"; fi
    if [ $IPC -eq 18 ]; then VNAME="eve"; fi
    if [ $IPC -eq 19 ]; then VNAME="fin"; fi
    if [ $IPC -eq 20 ]; then VNAME="max"; fi
    if [ $IPC -eq 21 ]; then VNAME="ned"; fi
    if [ $IPC -eq 22 ]; then VNAME="oak"; fi
    if [ $IPC -eq 23 ]; then VNAME="pip"; fi
    if [ $IPB -eq 31 ]; then VNAME="zoe"; fi
    if [ $IPB -eq 32 ]; then VNAME="yip"; fi
    if [ $IPB -eq 33 ]; then VNAME="xai"; fi

fi

echo -n $VNAME

exit 0
