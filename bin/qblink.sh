#!/bin/bash 
#--------------------------------------------------------
#  Script: qblink.sh
#  Author: Mike Benjamin
#  Date:   December 3rd, 2019
#  About:  A script for quick simple blinkstick commands
#--------------------------------------------------------
#  Part 1: Initialize global variables
#-------------------------------------------------------
VERBOSE="no"
BLINK="no"
COLOR="blue"
DELAY=""
TIME=""
BRIGHT="90"
SIDE0="yes"
SIDE1="no"

#-------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "qblink.sh  [OPTIONS]                          "
        echo "  --help, -h      Display this help message   " 
        echo "  --verbose, -v   Increase verbosity          " 
        echo "  --help, -h      Display this help message   " 
        echo "  --blink=<amt>   Blink AMT times, then stop  "
        echo "  --color=<amt>   Light color                 "
        echo "  --time=<secs>   Duration if steady light    "
        echo "  --delay=<secs>  Delay before executing      "
        echo "  --dim,-d        Set brightness to 40        "
        echo "  --led_zero,-0   Light index=0 side (default)"
        echo "  --led_one,-1    Light index=1 side          "
        echo "  --both_leds,-2  Light both sides            "
        echo "  blue            Same as --color=blue        "
        echo "  green           Same as --color=green       "
        echo "  red             Same as --color=red         "
        echo "  yellow          Same as --color=yellow      "
        echo "  white           Same as --color=white       "
        echo "  purple          Same as --color=purple      "
        echo "  brown           Same as --color=brown       "
        echo "  pink            Same as --color=pink        "
        echo "  orange          Same as --color=orange      "
        echo "  cyan            Same as --color=cyan        "
        echo "  random          Same as --color=random      "
        echo "  off             Same as --color=off         "
        exit 0;
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    elif [ "${ARGI:0:8}" = "--blink=" ]; then
        BLINK="${ARGI#--blink=*}"
    elif [ "${ARGI:0:8}" = "--color=" ]; then
        COLOR="${ARGI#--color=*}"
    elif [ "${ARGI:0:7}" = "--time=" ]; then
        TIME="${ARGI#--time=*}"
    elif [ "${ARGI:0:8}" = "--delay=" ]; then
        DELAY="${ARGI#--delay=*}"
    elif [ "${ARGI}" = "blue"  -o "${ARGI}" = "green"  ]; then
	COLOR=$ARGI
    elif [ "${ARGI}" = "red"   -o "${ARGI}" = "yellow" ]; then
	COLOR=$ARGI
    elif [ "${ARGI}" = "white" -o "${ARGI}" = "purple" ]; then
	COLOR=$ARGI
    elif [ "${ARGI}" = "brown" -o "${ARGI}" = "orange" ]; then
	COLOR=$ARGI
    elif [ "${ARGI}" = "pink"  -o "${ARGI}" = "random" ]; then
	COLOR=$ARGI
    elif [ "${ARGI}" = "off"   -o "${ARGI}" = "cyan"   ]; then
	COLOR=$ARGI
    elif [ "${ARGI:0:6}" = "--dim=" ]; then
        BRIGHT="${ARGI#--dim=*}"
    elif [ "${ARGI}" = "--dim" -o "${ARGI}" = "-d"   ]; then
        BRIGHT="40"
    elif [ "${ARGI}" = "--b1" ]; then
        BRIGHT="1"
    elif [ "${ARGI}" = "--b2" ]; then
        BRIGHT="2"
    elif [ "${ARGI}" = "--b3" ]; then
        BRIGHT="3"
    elif [ "${ARGI}" = "--b5" ]; then
        BRIGHT="5"
    elif [ "${ARGI}" = "--b10" ]; then
        BRIGHT="10"
    elif [ "${ARGI}" = "--b20" ]; then
        BRIGHT="20"
    elif [ "${ARGI}" = "--b30" ]; then
        BRIGHT="30"
    elif [ "${ARGI}" = "--b40" ]; then
        BRIGHT="40"
    elif [ "${ARGI}" = "--b50" ]; then
        BRIGHT="50"
    elif [ "${ARGI}" = "--b60" ]; then
        BRIGHT="60"
    elif [ "${ARGI}" = "--b70" ]; then
        BRIGHT="70"
    elif [ "${ARGI}" = "--b80" ]; then
        BRIGHT="80"
    elif [ "${ARGI}" = "--b90" ]; then
        BRIGHT="90"
    elif [ "${ARGI}" = "--b100" ]; then
        BRIGHT="100"
    elif [ "${ARGI}" = "--led_zero" -o "${ARGI}" = "-0" ]; then
	SIDE0="yes"
	SIDE1="no"
    elif [ "${ARGI}" = "--led_one" -o "${ARGI}" = "-1" ]; then
	SIDE0="no"
	SIDE1="yes"
    elif [ "${ARGI}" = "--both_leds" -o "${ARGI}" = "-2" ]; then
	SIDE0="yes"
	SIDE1="yes"
    else
	echo "qblink.sh: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

if [ "$DELAY" != "" ]; then
    sleep $DELAY
fi

# If there is a blinkstick already running (pulsing, blinking)
# then kill it first. 
killall blinkstick >& /dev/null
#killall qblink.sh >& /dev/null       # new mar1024
pkill -9 -f blinkstick >& /dev/null  # new mar1024

#-------------------------------------------------------
#  Part 2: Handle the blinking case
#-------------------------------------------------------
if [ "$BLINK" != "no" ]; then
    ARGS+=" --blink --repeats $BLINK --brightness=$BRIGHT "
    if [ "$SIDE0" = "yes" ]; then
	blinkstick --index=0 $ARGS --brightness=$BRIGHT --set-color=$COLOR  >& /dev/null &
    fi
    if [ "$SIDE1" = "yes" ]; then
	blinkstick --index=1 $ARGS --brightness=$BRIGHT --set-color=$COLOR  >& /dev/null &
    fi
    exit 0
fi

#-------------------------------------------------------
#  Part 3: Handle simply setting it on to a color
#-------------------------------------------------------
if [ "$TIME" = "" ]; then
    if [ "$COLOR" = "off" ]; then
	blinkstick --set-color=off --index=0 >& /dev/null
	blinkstick --set-color=off --index=1 >& /dev/null
	exit 0
    fi

    if [ "$SIDE0" = "yes" ]; then
	blinkstick --brightness=$BRIGHT --set-color=$COLOR --index=0 >& /dev/null &
    else
	blinkstick --set-color=off --index=0 >& /dev/null &
    fi
    if [ "$SIDE1" = "yes" ]; then
	blinkstick --brightness=$BRIGHT --set-color=$COLOR --index=1 >& /dev/null &
    else
	blinkstick --set-color=off --index=1 >& /dev/null &
    fi
    exit 0
fi
    
#-------------------------------------------------------
#  Part 4: Handle setting it on to a color or a duration
#-------------------------------------------------------
if [ "$SIDE0" = "yes" ]; then
    blinkstick --brightness=$BRIGHT --set-color=$COLOR --index=0 >& /dev/null &
else
    blinkstick --set-color=off --index=0 >& /dev/null &
fi


if [ "$SIDE1" = "yes" ]; then
    blinkstick --brightness=$BRIGHT --set-color=$COLOR --index=1 >& /dev/null &
else
    blinkstick --set-color=off --index=1 >& /dev/null &
fi
    
sleep $TIME
blinkstick --set-color=off --index=0 >& /dev/null &
blinkstick --set-color=off --index=1 >& /dev/null &

exit 0
