#!/bin/bash 
#--------------------------------------------------------
#  Script: mlaunch.sh
#  Author: Mike Benjamin
#  Date:   April 15th, 2026
#  About:  A script for launching pablo missions
#--------------------------------------------------------
#  Part 1: Convenience function for producing terminal 
#          debugging output depending on verbosity.
#--------------------------------------------------------
vecho () {
    if [ "$VERBOSE" = "yes" ]; then
        echo $1
    fi
    echo $1 >> ~/.mlaunch_log
}

#-------------------------------------------------------
#  Part 2: Initialize global variables
#-------------------------------------------------------
ME=`basename "$0"`
MISSION=""
LAUNCH_ARGS=""
USER_MODE="no"
RUN_KTM="no"
VERBOSE=""

# LAUNCH_COLOR will blink when processing, go solid if all ok
# PFAIL_COLOR  will go solid if pre-launch fails
# VFAIL_COLOR  will go solid if the launch_vehicle script fails

LAUNCH_COLOR="white" 
PFAIL_COLOR="yellow"
VFAIL_COLOR="red"

#-------------------------------------------------------
#  Part 3: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
        echo "$ME  [OPTIONS]                                       "
        echo "                                                     " 
        echo "Synopsis:                                            " 
        echo "  The $ME script is the point-of-entry script  "  
        echo "  for remote auto launching of a vehicle mission on  " 
        echo "  a pablo from a shoreside or similar computer.      " 
        echo "  Other than choosing the mission type, most other   " 
        echo "  args are simply passed to the launch_vehicle.sh    " 
        echo "  script in that mission folder                      " 
        echo "                                                     " 
        echo "  In normal mode (not user mode), the script will re-" 
        echo "  turn immediately with an exit code indicating if a " 
        echo "  successful launch occured.                         " 
        echo "                                                     " 
        echo "  The user mode is available for a user to launch a  " 
        echo "  mission while remotely logged on to the pablo, for "
	echo "  debuging purposes.                                 "
	echo "  So in user mode, the launch will end with an       " 
	echo "  interactive uMAC session.                          " 
        echo "                                                     " 
        echo "Options:                                             " 
        echo "  --help, -h            Display this help message    " 
        echo "  --verbose, -v         Increase verbosity           " 
        echo "  --user, -u            User (testing) mode          " 
        echo "  --ktm, -k             Run ktm prior to launch      " 
        echo "  --mission=<mission>   Mission Name                 "
        echo "                                                     " 
        echo "  --lcolor=<color>      Launching color              "
        echo "  --pcolor=<color>      Pre-launch fail color        "
        echo "  --vcolor=<color>      Launch fail color            "
        exit 0;
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    elif [ "${ARGI}" = "--user" -o "${ARGI}" = "-u" ]; then
	USER_MODE="yes"
    elif [ "${ARGI}" = "--ktm" -o "${ARGI}" = "-k" ]; then
	RUN_KTM="yes"

    elif [ "${ARGI:0:9}" = "--lcolor=" ]; then
        LAUNCH_COLOR="${ARGI#--lcolor=*}"
    elif [ "${ARGI:0:9}" = "--pcolor=" ]; then
        PFAIL_COLOR="${ARGI#--pcolor=*}"
    elif [ "${ARGI:0:9}" = "--vcolor=" ]; then
        VFAIL_COLOR="${ARGI#--vcolor=*}"

    elif [ "${ARGI:0:10}" = "--mission=" ]; then
        MISSION="${ARGI#--mission=*}"
    elif [ "${ARGI:0:3}" = "-m=" ]; then
        MISSION="${ARGI#-m=*}"
    else
	LAUNCH_ARGS+=" $ARGI"
    fi
done


#--------------------------------------------------------------
#  Part 4: Prune .mlaunch_log file to be no more than 500 lines
#--------------------------------------------------------------
tail -n 500 ~/.mlaunch_log > ~/.tmpml && mv -f ~/.tmpml ~/.mlaunch_log

LOG_ENTRY=`date`" "$MISSION

vecho "================================================="
vecho "${LOG_ENTRY}"
vecho "================================================="
vecho "Output produced from pablo_common/bin/$ME        "
vecho "Command Line args:                               "
vecho "       VERBOSE=$VERBOSE                          "
vecho "     USER_MODE=$USER_MODE                        "
vecho "  LAUNCH_COLOR=$LAUNCH_COLOR                     "
vecho "   PFAIL_COLOR=$PFAIL_COLOR                      "    
vecho "   VFAIL_COLOR=$VFAIL_COLOR                      "    
vecho "   LAUNCH_ARGS=$LAUNCH_ARGS                      "    

qblink.sh --blink=100 $LAUNCH_COLOR

#-------------------------------------------------------
#  Part 5: Set, verify existence of the mission directory
#-------------------------------------------------------
MISSION_DIR="$HOME/$MISSION"
if [ ! -d $MISSION_DIR ]; then
    vecho "Mission dir [$MISSION_DIR] not found. Exit code 3."
    qblink.sh $PFAIL_COLOR -2 --b30
    exit 3
fi
vecho "Successfully entered MISSION_DIR:$MISSION_DIR "

#-------------------------------------------------------
#  Part 6: Verify launch_vehicle.sh exists
#-------------------------------------------------------
cd $MISSION_DIR
if [ ! -f "launch_vehicle.sh" ]; then
    vecho "[$MISSION_DIR] has no launch_vehicle.sh. Exit code 5."
    qblink.sh $PFAIL_COLOR  -2 --b30
    exit 5
fi

#-------------------------------------------------------
#  Part 7: Run ktm if configured to do so
#-------------------------------------------------------
if [ "${RUN_KTM}" = "yes" ]; then
    vecho "Running ktm prior to launch_vehicle"
    qblink.sh aqua  -2 --b50
    ktm
    qblink.sh off  -2 
fi

#-------------------------------------------------------
#  Part 8: Launch the vehicle mission 
#-------------------------------------------------------
vecho "Launching the vehicle mission..."
./launch_vehicle.sh --auto $LAUNCH_ARGS
RES=$?

if [ "$?" != "0" ]; then
    vecho "launch_vehicle.sh failed with exit code $RES"
    qblink.sh $VFAIL_COLOR  -2 --b40
    exit $RES
fi

if [ "$USER_MODE" = "yes" ]; then
    vecho "Launching uMAC in user mode."
    uMAC targ_vehicle.moos  -2 --b40
fi

qblink.sh $LAUNCH_COLOR  -2 --b40
vecho "Exiting the $ME script."
exit 0

