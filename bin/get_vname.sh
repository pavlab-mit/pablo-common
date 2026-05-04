#!/bin/bash
#--------------------------------------------------------
# Script: get_vname.sh
#   Date: Aug 10th, 2018
#   Date: Mar 3rd, 2023 substantial mods by mikerb
#     By: Mike Benjamin
#  About: A script for use on the pablos for guessing the
#         Heron or MTASC name for this pablo.
#         Based on IP address for Heron pablos.
#         Based on MAC address for MTASC pablos.
#-------------------------------------------------------
#  Part 1: Initialize global variables
#-------------------------------------------------------
ME=`basename "$0"`
VERBOSE="no"
GET_PTYPE="no"
PABLO_TYPE="pablo"
IP_WAIT="no"
SHORT_NAME="no"
VNAME="pablo"
REPORT_UTC=""

# Get MAC address
# RasPi 4s have the ethernet port, but this may change
# for future RasPis. 
if [ -f /sys/class/net/eth0/address ]; then
    MAC_ADDR=`cat /sys/class/net/eth0/address` 
# The Pocket Beagles use a USB port
elif [ -f /sys/class/net/usb0/address ]; then
    MAC_ADDR=`cat /sys/class/net/usb0/address`
else
    echo "$ME: Not able to find MAC address. Exit Code 1."
    exit 1
fi


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
        echo "  Get a Pablo name based on (a) IP Addr, for Herons, "
	echo "  or (b) MAC Address, for MTASC pablos.              "
        echo "  Optionally just get the pablo type: pablo/mtast    " 
        echo "                                                     " 
        echo "  --help, -h            Display this help message    " 
        echo "  --verbose, -v         Increase verbosity           " 
        echo "  --ptype, -p           Get the pablo type           " 
        echo "  --wait, -w            Wait for IP Addr before name " 
        echo "  --short, -s           Return short version of name " 
        exit 0;
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    elif [ "${ARGI}" = "--ptype" -o "${ARGI}" = "-p" ]; then
	GET_PTYPE="yes"
    elif [ "${ARGI}" = "--wait" -o "${ARGI}" = "-w" ]; then
	IP_WAIT="yes"
    elif [ "${ARGI}" = "--short" -o "${ARGI}" = "-s" ]; then
	SHORT_NAME="yes"
    elif [ "${ARGI}" = "--utc" -o "${ARGI}" = "-u" ]; then
	REPORT_UTC="yes"
    else
	echo "$ME: Bad Arg:[$ARGI]. Exit Code 1."
	exit 1
    fi
done

#--------------------------------------------------------
# Part: Get assigned IPAddr, wait if requested and needed
#--------------------------------------------------------
if [ "${IP_WAIT}" = "yes" ]; then
    IP_COUNTER=0
    while [ "${IP_ADDR}" = "" ]; do
	IP_ADDR=`hostname -I`
	if [ "${IP_ADDR}" = "" ]; then
	    IP_COUNTER=$((IP_COUNTER+1))
	    if [[ "$IP_COUNTER" -gt 60 ]]; then
		IP_ADDR="127.0.0.1"
	    fi
	    sleep 1
	fi
    done
fi

# Note: hostname function likely to return nothing for a while upon
# initial reboot. For ssh-ing into a booted pablo, it seems to always
# work, but cannot be counted on during @reboot cronjob entry.
IPA=`echo $IP_ADDR | cut -d . -f 1`
IPB=`echo $IP_ADDR | cut -d . -f 2`
IPC=`echo $IP_ADDR | cut -d . -f 3`
IPD=`echo $IP_ADDR | cut -d . -f 4 | cut -d ' ' -f 1`

#--------------------------------------------------------
# Part: Check MAC address of known MTASC machines
#--------------------------------------------------------
if [ "${MAC_ADDR}" = "2c:cf:67:ac:1b:8e" ]; then VNAME="npt01"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1b:ff" ]; then VNAME="npt02"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1d:55" ]; then VNAME="npt03"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1e:06" ]; then VNAME="npt04"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1b:1b" ]; then VNAME="npt05"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1a:84" ]; then VNAME="npt06"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1d:69" ]; then VNAME="npt07"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:19:3b" ]; then VNAME="npt08"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1e:4e" ]; then VNAME="npt09"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1c:35" ]; then VNAME="npt10"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1c:95" ]; then VNAME="npt11"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1f:50" ]; then VNAME="npt12"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1c:83" ]; then VNAME="npt13"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1b:4d" ]; then VNAME="npt14"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:2b:b4:88" ]; then VNAME="npt15"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1a:df" ]; then VNAME="npt16"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:ac:1d:22" ]; then VNAME="npt17"; 
fi

#--------------------------------------------------------
# Part: Check MAC address of known MTASC machines
#--------------------------------------------------------
if [ "${MAC_ADDR}" = "88:a2:9e:95:99:c4" ]; then VNAME="mtc01"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:58:d2" ]; then VNAME="mtc02"; 
elif [ "${MAC_ADDR}" = "88:a2:9e:95:99:c7" ]; then VNAME="mtc03"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:5a:cc" ]; then VNAME="mtc04"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:02:f1" ]; then VNAME="mtc05"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:70:35:0b" ]; then VNAME="mtc06"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:46" ]; then VNAME="mtc07"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:c4" ]; then VNAME="mtc08"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:0a" ]; then VNAME="mtc09"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:57:f3" ]; then VNAME="mtc10"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:64:ce:36" ]; then VNAME="mtc11"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:63:8e:05" ]; then VNAME="mtc12"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:64:ce:cf" ]; then VNAME="mtc13"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:63:83:43" ]; then VNAME="mtc14"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:64:cd:bb" ]; then VNAME="mtc15"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:64:ce:72" ]; then VNAME="mtc16"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bc:8f" ]; then VNAME="mtc17"; 
elif [ "${MAC_ADDR}" = "88:a2:9e:95:99:e2" ]; then VNAME="mtc18"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:63:83:94" ]; then VNAME="mtc19"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:b1:d1:5b" ]; then VNAME="mtc20"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:6d" ]; then VNAME="mtc21"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:24" ]; then VNAME="mtc22"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bc:fc" ]; then VNAME="mtc23"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:a4:22:f7" ]; then VNAME="mtc24"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:a1" ]; then VNAME="mtc25"; 
						   
elif [ "${MAC_ADDR}" = "dc:a6:32:32:67:4d" ]; then VNAME="paba01"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:02:8e:a8" ]; then VNAME="paba02"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:68:34" ]; then VNAME="paba03"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:66:ed" ]; then VNAME="paba04"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:66:9f" ]; then VNAME="paba05"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:67:86" ]; then VNAME="paba06"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:66:57" ]; then VNAME="paba07"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:68:2e" ]; then VNAME="paba08"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:68:85" ]; then VNAME="paba09"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:69:48" ]; then VNAME="paba10"; 
						   
elif [ "${MAC_ADDR}" = "dc:a6:32:32:67:8f" ]; then VNAME="paba11"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:2b:be:4e" ]; then VNAME="paba12"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:66:f9" ]; then VNAME="paba13"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:67:47" ]; then VNAME="paba14"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:68:58" ]; then VNAME="paba15"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:67:56" ]; then VNAME="paba16"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:66:99" ]; then VNAME="paba17"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:2d:75:bc" ]; then VNAME="paba18"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:68:df" ]; then VNAME="paba19"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:66:87" ]; then VNAME="paba20"; 
						   
elif [ "${MAC_ADDR}" = "d8:3a:dd:f2:f8:51" ]; then VNAME="paba21"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:66:cf" ]; then VNAME="paba22"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:67:68" ]; then VNAME="paba23"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:67:2f" ]; then VNAME="paba24"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:67:3e" ]; then VNAME="paba25"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:88:a5" ]; then VNAME="paba26"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:87:a6" ]; then VNAME="paba27"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:84:f7" ]; then VNAME="paba28"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:87:cd" ]; then VNAME="paba29"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:85:60" ]; then VNAME="paba30"; 
						   
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:87:f2" ]; then VNAME="paba31"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:84:bb" ]; then VNAME="paba32"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:85:c6" ]; then VNAME="paba33"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:84:ac" ]; then VNAME="paba34"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:87:b7" ]; then VNAME="paba35";     
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:88:c0" ]; then VNAME="paba36"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:81:7c" ]; then VNAME="paba37"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:87:c4" ]; then VNAME="paba38"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:81:6d" ]; then VNAME="paba39"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:88:1b" ]; then VNAME="paba40"; 

elif [ "${MAC_ADDR}" = "dc:a6:32:4b:7e:0a" ]; then VNAME="paba41"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:85:4f" ]; then VNAME="paba42"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:88:b7" ]; then VNAME="paba43"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:85:77" ]; then VNAME="paba44"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:85:7b" ]; then VNAME="paba45";     
elif [ "${MAC_ADDR}" = "dc:a6:32:4b:87:a9" ]; then VNAME="paba46"; 
#elif [ "${MAC_ADDR}" = "dc:a6:32:4b:85:b1" ]; then VNAME="paba47"; 
#elif [ "${MAC_ADDR}" = "dc:a6:32:4b:84:df" ]; then VNAME="paba48"; 
#elif [ "${MAC_ADDR}" = "dc:a6:32:4b:81:49" ]; then VNAME="paba49"; 
#elif [ "${MAC_ADDR}" = "dc:a6:32:4b:88:00" ]; then VNAME="paba50"; 
#elif [ "${MAC_ADDR}" = "dc:a6:32:53:4b:d8" ]; then VNAME="paba51"; 
						   
elif [ "${MAC_ADDR}" = "dc:a6:32:6f:cc:e3" ]; then VNAME="pab01"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:c4" ]; then VNAME="pab02"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:2e" ]; then VNAME="pab03"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:02:fd" ]; then VNAME="pab04"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:02:ee" ]; then VNAME="pab05"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:37" ]; then VNAME="pab06"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:5e" ]; then VNAME="pab07"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:70" ]; then VNAME="pab08"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:5a:33" ]; then VNAME="pab09"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:64" ]; then VNAME="pab10"; 
						   
elif [ "${MAC_ADDR}" = "dc:a6:32:71:05:ed" ]; then VNAME="pab11"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:70:34:e1" ]; then VNAME="pab12"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:58:a7" ]; then VNAME="pab13"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:58:aa" ]; then VNAME="pab14"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:f4" ]; then VNAME="pab15"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:5a:0c" ]; then VNAME="pab16"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:58:e6" ]; then VNAME="pab17"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:3d" ]; then VNAME="pab18"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:03:7e" ]; then VNAME="pab19"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:55:0b" ]; then VNAME="pab20"; 
						   
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:21" ]; then VNAME="pab21"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:43" ]; then VNAME="pab22"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:30" ]; then VNAME="pab23"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:02:e1" ]; then VNAME="pab24"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:79" ]; then VNAME="pab25"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bb:f0" ]; then VNAME="pab26"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:63:8e:ce" ]; then VNAME="pab27"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:5a:1d" ]; then VNAME="pab28"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bc:38" ]; then VNAME="pab29"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bc:3b" ]; then VNAME="pab30"; 
						   
elif [ "${MAC_ADDR}" = "dc:a6:32:71:03:d8" ]; then VNAME="pab31"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:67" ]; then VNAME="pab32"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:c5" ]; then VNAME="pab33"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:76" ]; then VNAME="pab34"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:58:f5" ]; then VNAME="pab35"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:58:c8" ]; then VNAME="pab36"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:51" ]; then VNAME="pab37"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:6f:cb:1f" ]; then VNAME="pab38"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:5a:66" ]; then VNAME="pab39"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:25" ]; then VNAME="pab40"; 
						   
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:79" ]; then VNAME="pab41"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:34" ]; then VNAME="pab42"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:6f:d8:e0" ]; then VNAME="pab43"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:6f:cb:4c" ]; then VNAME="pab44"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:7f" ]; then VNAME="pab45"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:70:30:2e" ]; then VNAME="pab46"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:c1" ]; then VNAME="pab47"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:71:59:40" ]; then VNAME="pab48"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:6f:c9:c2" ]; then VNAME="pab49"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:55:bd:2b" ]; then VNAME="pab50";
						   
elif [ "${MAC_ADDR}" = "b8:27:eb:f5:88:f8" ]; then VNAME="pablo01"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:f5:88:f8" ]; then VNAME="pablo02"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:0a:54:02" ]; then VNAME="pablo03"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:1d:d3:69" ]; then VNAME="pablo06"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:2f:52:06" ]; then VNAME="pablo08"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:8e:68:6e" ]; then VNAME="pablo09"; 
						   
elif [ "${MAC_ADDR}" = "b8:27:eb:ab:34:1e" ]; then VNAME="pablo11"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:ba:6f:9c" ]; then VNAME="pablo12"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:43:ce:3d" ]; then VNAME="pablo13"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:72:75:6f" ]; then VNAME="pablo14"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:86:c7:05" ]; then VNAME="pablo18"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:3a:97:f4" ]; then VNAME="pablo21"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:cc:76:94" ]; then VNAME="pablo23"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:be:87:32" ]; then VNAME="pablo25"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:eb:18:07" ]; then VNAME="pablo27"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:c5:52:91" ]; then VNAME="pablo29"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:de:cd:09" ]; then VNAME="pablo32"; 

#    elif [ "${MAC_ADDR}" = "b8:27:eb:dc:01:07" ]; then VNAME="pablo33"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:8b:8e:e9" ]; then VNAME="pablo34"; 
						   
elif [ "${MAC_ADDR}" = "b8:27:eb:51:a5:db" ]; then VNAME="pablo35"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:57:7f:69" ]; then VNAME="pablo36"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:68:6d:74" ]; then VNAME="pablo37"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:d0:86:68" ]; then VNAME="pablo39"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:8a:b7:0c" ]; then VNAME="pablo40"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:22:fe:fd" ]; then VNAME="pablo41"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:0f:76:ab" ]; then VNAME="pablo42"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:bf:54:cb" ]; then VNAME="pablo44"; 
elif [ "${MAC_ADDR}" = "b8:27:eb:d9:e0:75" ]; then VNAME="pablo47"; 
elif [ "${MAC_ADDR}" = "dc:a6:32:32:68:77" ]; then VNAME="pablo48";


elif [ "${MAC_ADDR}" = "d8:3a:dd:68:22:a0" ]; then VNAME="pabaj01"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:20:4f" ]; then VNAME="pabaj02"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f4:d2" ]; then VNAME="pabaj03"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f3:f3" ]; then VNAME="pabaj04"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:1b:95" ]; then VNAME="pabaj05"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:22:8e" ]; then VNAME="pabaj06"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:1b:a4" ]; then VNAME="pabaj07"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f6:d0" ]; then VNAME="pabaj08"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f4:ba" ]; then VNAME="pabaj09"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:59:28" ]; then VNAME="pabaj10"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5a:b5" ]; then VNAME="pabaj11"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f6:10" ]; then VNAME="pabaj12"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:20:c9" ]; then VNAME="pabaj13"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f6:a7" ]; then VNAME="pabaj14"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f3:55" ]; then VNAME="pabaj15"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:1b:b9" ]; then VNAME="pabaj16"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:22:e8" ]; then VNAME="pabaj17"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5b:0b" ]; then VNAME="pabaj18"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f4:8f" ]; then VNAME="pabaj19"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f5:bf" ]; then VNAME="pabaj20"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:68:20:81" ]; then VNAME="pabaj21"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f3:6f" ]; then VNAME="pabaj22"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f5:df" ]; then VNAME="pabaj23"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:1b:98" ]; then VNAME="pabaj24"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:20:1f" ]; then VNAME="pabaj25"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:67:77:08" ]; then VNAME="pabaj26"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f4:89" ]; then VNAME="pabaj27"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f5:47" ]; then VNAME="pabaj28"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:22:1e" ]; then VNAME="pabaj29"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:20:5d" ]; then VNAME="pabaj30"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f4:43" ]; then VNAME="pabaj31"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:20:06" ]; then VNAME="pabaj32"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5b:86" ]; then VNAME="pabaj33"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5a:60" ]; then VNAME="pabaj34"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5b:93" ]; then VNAME="pabaj35"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5a:54" ]; then VNAME="pabaj36"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5a:0d" ]; then VNAME="pabaj37"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5c:31" ]; then VNAME="pabaj38"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:68:22:79" ]; then VNAME="pabaj39"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:75:f6:c3" ]; then VNAME="pabaj40"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:4a:57:cd" ]; then VNAME="pabaj41"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9f:13:67" ]; then VNAME="pabaj42"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9f:15:59" ]; then VNAME="pabaj43"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9f:14:22" ]; then VNAME="pabaj44"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5b:99" ]; then VNAME="pabaj45"; 
elif [ "${MAC_ADDR}" = "2c:cf:67:36:12:5c" ]; then VNAME="pabaj46"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:f8:a2:1c" ]; then VNAME="pabaj47"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4c:5a:bd" ]; then VNAME="pabaj48"; 
elif [ "${MAC_ADDR}" = "e4:5f:01:57:70:5f" ]; then VNAME="pabaj49"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9d:a5:fb" ]; then VNAME="pabaj50"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:75:d4:cd" ]; then VNAME="pabaj51"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9f:00:46" ]; then VNAME="pabaj52"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9f:27:1b" ]; then VNAME="pabaj53"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9f:26:12" ]; then VNAME="pabaj54"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4a:57:5b" ]; then VNAME="pabaj55"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:4a:55:38" ]; then VNAME="pabaj56"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9f:13:c9" ]; then VNAME="pabaj57"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9f:17:64" ]; then VNAME="pabaj58"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9d:a8:d5" ]; then VNAME="pabaj59"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9d:a6:48" ]; then VNAME="pabaj60"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:8f:f5" ]; then VNAME="pabaj61"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:70" ]; then VNAME="pabaj62";
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:f1" ]; then VNAME="pabaj63"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:b7:a6:bb" ]; then VNAME="pabaj64"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:0a" ]; then VNAME="pabaj65"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:41" ]; then VNAME="pabaj66"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9d:83:c4" ]; then VNAME="pabaj67"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9d:84:1b" ]; then VNAME="pabaj68"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:74" ]; then VNAME="pabaj69"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:94:92" ]; then VNAME="pabaj70"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:80" ]; then VNAME="pabaj71"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a1:d2:25" ]; then VNAME="pabaj72"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9d:84:06" ]; then VNAME="pabaj73"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9d:83:df" ]; then VNAME="pabaj74"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:4b" ]; then VNAME="pabaj75"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:93:28" ]; then VNAME="pabaj76"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:fa" ]; then VNAME="pabaj77"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:94:dd" ]; then VNAME="pabaj78"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:b7:f6:e5" ]; then VNAME="pabaj79"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:9d:84:00" ]; then VNAME="pabaj80"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:9d:83:34" ]; then VNAME="pabaj81"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:93:f9" ]; then VNAME="pabaj82"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:93:9f" ]; then VNAME="pabaj83"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:13" ]; then VNAME="pabaj84"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:91:a0" ]; then VNAME="pabaj85"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:90:dd" ]; then VNAME="pabaj86"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:91:fd" ]; then VNAME="pabaj87"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:93:8c" ]; then VNAME="pabaj88"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:94:64" ]; then VNAME="pabaj89"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:93:25" ]; then VNAME="pabaj90"; 

elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:91:56" ]; then VNAME="pabaj91"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:94:ce" ]; then VNAME="pabaj92"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:8a:74" ]; then VNAME="pabaj93"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:91:ea" ]; then VNAME="pabaj94"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:47" ]; then VNAME="pabaj95"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:ee" ]; then VNAME="pabaj96"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:90:8d" ]; then VNAME="pabaj97"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:93:35" ]; then VNAME="pabaj98"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:a0:92:a1" ]; then VNAME="pabaj99"; 
elif [ "${MAC_ADDR}" = "d8:3a:dd:fb:47:b1" ]; then VNAME="pabaj100"; 
						   

fi

# if one of those MAC addresses matches, the we have an mtasc pablo
if [ "${VNAME}" != "pablo" ]; then
    PABLO_TYPE="mtasc"
fi


#--------------------------------------------------------
# Part: Manually designate motnte-moos pablos
#--------------------------------------------------------
#if [ "${VNAME}" = "pabaj41" ]; then PABLO_TYPE="monte";
if [ "${VNAME}" = "paba42" ]; then PABLO_TYPE="monte";
elif [ "${VNAME}" = "paba43" ]; then PABLO_TYPE="monte";
elif [ "${VNAME}" = "paba44" ]; then PABLO_TYPE="monte";
elif [ "${VNAME}" = "paba45" ]; then PABLO_TYPE="monte";
elif [ "${VNAME}" = "paba46" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj50" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj49" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj48" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj47" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj46" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj45" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj44" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj43" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj42" ]; then PABLO_TYPE="monte"; 
#elif [ "${VNAME}" = "pabaj41" ]; then PABLO_TYPE="monte"; 
fi

#--------------------------------------------------------
# Part: Check MAC address of known Sea Beaver II's
#       and the associated pocket beagle.  It was assumed
#       that the ip address would not be known when the
#       script could be run, but is listed for reference
#--------------------------------------------------------
# serial no : 
# ip address: 192.168.0.50
if [ "${MAC_ADDR}" = "d8:3a:dd:6f:99:3c" ]; then VNAME="avi";      PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f0:04:ac" ]; then VNAME="avi-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.51			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:98:8f" ]; then VNAME="bee";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f1:01:4e" ]; then VNAME="bee-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.52			   						   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:9a:6d" ]; then VNAME="cap";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:ee:98:d6" ]; then VNAME="cap-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.53			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:f2:b4:cb" ]; then VNAME="dan";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:ee:a1:94" ]; then VNAME="dan-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.54			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:98:3a" ]; then VNAME="ebb";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:ef:cf:6e" ]; then VNAME="ebb-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.55			   						   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:9c:6d" ]; then VNAME="fay";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f0:8b:c1" ]; then VNAME="fay-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.56			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:99:10" ]; then VNAME="geo";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:ee:98:cd" ]; then VNAME="geo-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.57			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:99:69" ]; then VNAME="ham";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f1:b6:f8" ]; then VNAME="ham-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.58			   						   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:98:ab" ]; then VNAME="ivy";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f0:b3:24" ]; then VNAME="ivy-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.59			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:9b:cc" ]; then VNAME="jan";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:ee:9d:8f" ]; then VNAME="jan-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.60			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:9c:09" ]; then VNAME="kay";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:ee:a1:fa" ]; then VNAME="kay-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.61			   						   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:98:fe" ]; then VNAME="lee";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f1:75:67" ]; then VNAME="lee-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.62			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:c3:9e:65" ]; then VNAME="mel";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:ee:9d:bf" ]; then VNAME="mel-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.63			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:98:c8" ]; then VNAME="nat";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f0:b7:1a" ]; then VNAME="nat-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.64			   						   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:9b:a9" ]; then VNAME="oak";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f1:ba:eb" ]; then VNAME="oak-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.65			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:99:2a" ]; then VNAME="pal";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f0:b8:67" ]; then VNAME="pal-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.66			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:9a:fc" ]; then VNAME="que";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f0:8b:dc" ]; then VNAME="que-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.67			   						   
elif [ "${MAC_ADDR}" = "TO CHANGE 0:04:ac" ]; then VNAME="ron";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "TO CHANGE 0:04:ac" ]; then VNAME="ron-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.68			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:99:84" ]; then VNAME="sid";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:ee:a1:f1" ]; then VNAME="sid-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.69			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:9c:3e" ]; then VNAME="tad";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:ee:a1:be" ]; then VNAME="tad-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.70			   						   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:99:13" ]; then VNAME="umm";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f1:b6:e3" ]; then VNAME="umm-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.71			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:f2:b7:8e" ]; then VNAME="val";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "30:e2:83:31:8f:fe" ]; then VNAME="val-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.72			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:98:97" ]; then VNAME="wes";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:e6:7d:3c" ]; then VNAME="wes-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.73			   						   
elif [ "${MAC_ADDR}" = "d8:3a:dd:f2:b8:17" ]; then VNAME="xiu";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f1:b6:f5" ]; then VNAME="xiu-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.74			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:99:a8" ]; then VNAME="yen";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "30:e2:83:33:75:44" ]; then VNAME="yen-PB"; PABLO_TYPE="SeaBeaverII-PB";
# ip address: 192.168.0.75			   
elif [ "${MAC_ADDR}" = "d8:3a:dd:6f:9c:13" ]; then VNAME="zan";    PABLO_TYPE="SeaBeaverII";
elif [ "${MAC_ADDR}" = "1c:63:49:f0:8d:92" ]; then VNAME="zan-PB"; PABLO_TYPE="SeaBeaverII-PB";   
fi

#---------------------------------------------------------------
# Part : SeaScout vehicles here:
#         
#---------------------------------------------------------------



#---------------------------------------------------------------
# Part 4: If 4th field of IP Addr is 100, likely a Heron, even if
#         the pablo might have once been an mtasc pablo.
#---------------------------------------------------------------
if [[ $IPD -eq 100 ]]; then
    # Note: 7.100 could be an MTASC pablo
    if [ "${IPC}" != "7" ]; then 
	VNAME="pablo"
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
	if [ $IPC -eq 14 ]; then VNAME="heron-abe"; fi
	if [ $IPC -eq 15 ]; then VNAME="heron-ben"; fi
	if [ $IPC -eq 16 ]; then VNAME="heron-cal"; fi
	if [ $IPC -eq 17 ]; then VNAME="heron-deb"; fi
	if [ $IPC -eq 18 ]; then VNAME="heron-eve"; fi
	if [ $IPC -eq 19 ]; then VNAME="heron-fin"; fi
	if [ $IPC -eq 20 ]; then VNAME="heron-max"; fi
	if [ $IPC -eq 21 ]; then VNAME="heron-ned"; fi
	if [ $IPC -eq 22 ]; then VNAME="heron-oak"; fi
	if [ $IPC -eq 23 ]; then VNAME="heron-pip"; fi
	if [ $IPB -eq 31 ]; then VNAME="blueboat-zoe"; fi
    if [ $IPB -eq 32 ]; then VNAME="blueboat-yip"; fi
    if [ $IPB -eq 33 ]; then VNAME="blueboat-xai"; fi
	
	# if heron name set, ensure type is not mtasc
	if [ "${VNAME}" != "pablo" ]; then
	    PABLO_TYPE="pablo"
	fi
    fi
fi


#--------------------------------------------------------
# Part: If querying pablo type, we know it now, return it now
#--------------------------------------------------------
if [ "${GET_PTYPE}" = "yes" ]; then
    echo -n $PABLO_TYPE
    exit 0
fi

#--------------------------------------------------------
# Part: If the pablo is one of our build-test machines
#       set the name accordingly.
#--------------------------------------------------------
#if [ "$VNAME" = "pablo34" -a "$PABLO_TYPE" = "bt" ]; then
#    VNAME="bt_jessie_34"
#elif [ "$VNAME" = "pablo32" -a "$PABLO_TYPE" = "bt" ]; then
#    VNAME="bt_stretch_32"
#elif [ "$VNAME" = "pablo09" -a "$PABLO_TYPE" = "bt" ]; then
#    VNAME="bt_buster_09"
#fi


#--------------------------------------------------------
# Part: Reduce heron-abe etc to just abe if requested
#--------------------------------------------------------
if [ "${VNAME:0:6}" = "heron-" -a "${SHORT_NAME}" = "yes" ]; then
    VNAME="${VNAME#heron-*}"
elif [ "${VNAME:0:9}" = "blueboat-" -a "${SHORT_NAME}" = "yes" ]; then
	VNAME="${VNAME#bleuboat-*}"
fi

if [ "${REPORT_UTC}" != "" ]; then
    UTC=`date -u +%s`
    echo -n $VNAME $UTC
else
    echo -n $VNAME
fi

exit 0
