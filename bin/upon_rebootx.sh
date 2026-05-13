#!/bin/bash 
#--------------------------------------------------------------
#  Script: upon_rebootx.sh (wrapper for upon_reboot.sh)
#  Author: Michael Benjamin
#  Date:   Dec 2nd 2019
#  About:  This script will be invoked upon a reboot of the
#          pablo, by an @reboot cronjob. It will:
#          (a) verify a network connection and light RED if no
#          network, and then
#          (b) upon a network connection will svn update
#          pablo-common, and then
#          (c) invoke the upon_reboot.sh script.
#--------------------------------------------------------------
#  Part 1: Set the path for the script. When run as a cronjob
#  it will only have /bin and /usr/bin by default, so we add
#  others that the script may need.
#--------------------------------------------------------------
DATE=`date`
PATH=$PATH:/bin
PATH=$PATH:/usr/bin
PATH=$PATH:/usr/local/bin
PATH=$PATH:~/pablo-common/bin

#-------------------------------------------------------
#  Part 2: Initialize global variables
#-------------------------------------------------------
ME=`basename "$0"`
VERBOSE="no"
ALL_ARGS=""

#-------------------------------------------------------
#  Part 3: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    ALL_ARGS+=" $ARGI"
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "Usage:                                                  "
        echo "  $ME: [OPTIONS]                                        "
        echo "                                                        "
	echo "Synopsis:                                               "
	echo "  This script will be invoked upon a reboot of the      "
	echo "  pablo, by an @reboot cronjob. It (a) verify a network "
	echo "  connection and light RED if no network, and (b) upon  "
	echo "  a network connection will svn update pablo-common,    "
	echo "  and then (c) invoke the upon_reboot.sh script.        "
	echo "                                                        "
	echo "Options:                                                "
        echo "  --help,     -h      Display this help message         " 
	echo "  --verbose,  -v      Increase verbosity                " 
        echo "  --info,     -i      Display short synopsis            " 
	echo "                                                        "
	echo "Returns:                                                "
	echo "  0 if ok                                               "
	echo "  2 if unable to establish internet connection.         "

    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    elif [ "${ARGI}" = "--info" -o "${ARGI}" = "-i" ]; then
	echo "Pablo reboot script. Network, svn update, run upon_reboot.sh"
        exit 0;
    fi
done

#-------------------------------------------------------
#  Part 4: Ensure the reboot log doesnt get too long
#-------------------------------------------------------
tail -n 500 ~/.rebootlog > ~/.tmp && mv -f ~/.tmp ~/.rebootlog

#-------------------------------------------------------
#  Part 5: Write header and optional verbose info
#-------------------------------------------------------
echo "                                     " >> ~/.rebootlog
echo "//===================================" >> ~/.rebootlog
echo "// $ME (1.2)                         " >> ~/.rebootlog
echo "// $DATE                             " >> ~/.rebootlog
echo "//===================================" >> ~/.rebootlog

if [ "$VERBOSE" = "yes" ]; then    
    echo "PATH:$PATH" >> ~/.rebootlog
    echo "ALL_ARGS: [$ALL_ARGS]" >> ~/.rebootlog
fi

#-------------------------------------------------------
#  Part 6: Establish Network Connection
#-------------------------------------------------------
echo "$ME: Establishing network." >> ~/.rebootlog
qblink.sh white --blink=1000 -2 --b40 &

# To avoid MTASC cluster all hitting the networks at once, add
# random sleep of up to 10 secs
sleep $(( $RANDOM % 10))

COUNTER=0
CONNECTED="false"
echo -n "ping result: " >> ~/.rebootlog
while [ "${CONNECTED}" = "false" ]; do
    ping -c 1 -w 10 oceanai.mit.edu
    PING_RES=$?
    echo -n "$PING_RES " >> ~/.rebootlog
    if [ $PING_RES = 0 ]; then
	echo " CONNECTED" >> ~/.rebootlog
	CONNECTED="true"
    else
	sleep 1
	COUNTER=$((COUNTER+1))
    fi

    mod=$(($COUNTER%20))
    if [ $mod = 0 ]; then
	echo -n "H " >> ~/.rebootlog
	sudo ifconfig eth0 down && sleep 10 && \
	    sudo ifconfig eth0 up && echo -n "J " >> ~/.rebootlog
	qblink.sh blue --blink=1000 -2 --b40 &
    fi
    
    # Try for 60 seconds
    if [[ "$COUNTER" -gt 90 ]]; then
	echo "                      No Network. Exiting." >> ~/.rebootlog
	qblink.sh red
	exit 2
    fi
done

# Run ipaddrs to detect and store IP address infon in ~/.ipaddrs
ipaddrs.sh

#-------------------------------------------------------
#  Part 7: Invoke svn upate on pablo-common, possibly
#  updating this very script, for the next reboot. But
#  certainly updating upon_reboot.sh script for this reboot.
#-------------------------------------------------------
cd $HOME/pablo-common
echo "$ME: In $PWD, performing git pull" >> ~/.rebootlog

GIT_RESULT="SUCCESS"
git pull
if [ "$?" != "0" ]; then
    SVN_RESULT="FAIL"
fi

echo "$ME: git pull: $GIT_RESULT" >> ~/.rebootlog

#-------------------------------------------------------
#  Part 8: Continue updating repos
#-------------------------------------------------------
upon_reboot.sh
REBOOT_RES=$?

#-------------------------------------------------------
#  Part 9: Finish up!
#-------------------------------------------------------

echo "//======= END upon_rebootx.sh =======" >> ~/.rebootlog

# Very Last line of the .reboot log should be date + summary
if [ ${REBOOT_RES} != 0 ]; then
    echo "$DATE [Not OK]" >> ~/.rebootlog
    exit 1
fi

echo "$DATE [OK]" >> ~/.rebootlog
exit 0
