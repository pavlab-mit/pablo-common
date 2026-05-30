#!/bin/bash 
#--------------------------------------------------------------
#  Script: pablo_action.sh
#  Author: Michael Benjamin
#  Date:   April 10th 2026
#  About:  This script is likely invoked remotely
#--------------------------------------------------------------
#  Part 1: Initialize global variables
#--------------------------------------------------------------
ME=`basename "$0"`
ACTION=""
BLINK=""
DELAY="3"

#-------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    ALL_ARGS+=" $ARGI"
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "Usage:                                            "
        echo "  $ME: [OPTIONS]                                  "
        echo "                                                  "
	echo "Synopsis:                                         "
	echo "  A script for supported remote actions.          "
	echo "                                                  "
	echo "Options:                                          "
        echo "  --help,     -h      Display this help message   " 
	echo "  --verbose,  -v      Increase verbosity          " 
	echo "                                                  "
	echo "  --halt              Halt the pablo              "
	echo "  --shutdown          Shutdown the pablo          "
	echo "  --reboot            Reboot the pablo            "
	echo "  --ktm               Run ktm on the pablo        "
	echo "                                                  "
	echo "  --cyan              Blink cyan before action    "
	echo "  --blue              Blink blue before action    "
	echo "  --yellow            Blink yellow before action  "
	echo "  --white             Blink white before action   "
	echo "  --pink              Blink pink before action    "
	echo "  --brown             Blink brown before action   "
	echo "                                                  "
	echo "  --delay=N           Delay N secs after blink    "
	echo "                                                  "
	echo "Returns:                                          "
	echo "  9 if action not supported                       "
	echo "  Return value of action otherwise.               "
	
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    elif [ "${ARGI}" = "--halt" ]; then
	ACTION="halt"
    elif [ "${ARGI}" = "--shutdown" ]; then
	ACTION="shutdown"
    elif [ "${ARGI}" = "--reboot" ]; then
	ACTION="reboot"
    elif [ "${ARGI}" = "--ktm" ]; then
	ACTION="ktm"

    elif [ "${ARGI}" = "--cyan" ]; then
	BLINK="cyan"
    elif [ "${ARGI}" = "--blue" ]; then
	BLINK="blue"
    elif [ "${ARGI}" = "--yellow" ]; then
	BLINK="yellow"
    elif [ "${ARGI}" = "--white" ]; then
	BLINK="yellow"
    elif [ "${ARGI}" = "--pink" ]; then
	BLINK="pink"
    elif [ "${ARGI}" = "--brown" ]; then
	BLINK="brown"

    elif [ "${ARGI:0:8}" = "--delay=" ]; then
        DELAY="${ARGI#--delay=*}"
    else
	exit 1
    fi
done

#-------------------------------------------------------
#  Part 3: Blink if requested
#-------------------------------------------------------
if [ "${BLINK}" != "" ]; then
    qblink.sh $BLINK --dim -2
    sleep $DELAY
    qblink.sh off
fi

#-------------------------------------------------------
#  Part 4: Handle the action
#-------------------------------------------------------
if [ "${ACTION}" = "halt" ]; then 
    sudo shutdown -h now
elif [ "${ACTION}" = "shutdown" ]; then
    sudo shutdown -h now
elif [ "${ACTION}" = "reboot" ]; then
    sudo reboot --no-wall
elif [ "${ACTION}" = "ktm" ]; then
    ktm; killall -9 pLogger
fi

exit 0
