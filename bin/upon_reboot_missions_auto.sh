#!/bin/bash
#--------------------------------------------------------------
#    Script: upon_reboot_missions_auto.sh
#    Author: Michael Benjamin
#      Date: May 2025
#  Synopsis: This may be invoked directly, but is intended to be
#            invoked from the upon_reboot.sh script.
#--------------------------------------------------------------
#  Part 1: Initialize global variables
#--------------------------------------------------------------
ME=`basename "$0"`
CODEBASE_DIR="$HOME/missions-auto"
GETREPO="no"

#--------------------------------------------------------------
#  Part 2: Handle Command Line args
#--------------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME [OPTIONS]                                   "
	echo "                                                "
	echo "Synopsis:                                       "
	echo "  Update the autotest repo while logging        "
	echo "  the results to the home folder.               "
	echo "                                                "
	echo "  To ~/.rebootlog         --> high level events "
	echo "                                                "
	echo "  Typically called from within upon_reboot.sh   "
	echo "                                                "
	echo "Options:                                        "
	echo "  --help, -h   Show this help message.          "
	echo "  --get, -g    Get repo if not present          "
	exit 0
    elif [ "${ARGI}" = "--get" -o "${ARGI}" = "-g" ]; then
        GETREPO="yes"
    else
	echo "ME: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

#--------------------------------------------------------------
#  Part 4: Update/Pull and note if successful
#--------------------------------------------------------------
qblink.sh cyan --b30 -2

if [ ! -d "${CODEBASE_DIR}" ]; then
    if [ "${GETREPO}" != "yes" ]; then
	echo "     Skipping update of missions-auto. OK Not in use." >> ~/.rebootlog
	exit 0
    else
	echo "      Cloning the repo from GitHub    " >> ~/.rebootlog
	cd; git clone https://github.com/moos-ivp/missions-auto.git
	echo "      Result of git clone: $?    " >> ~/.rebootlog	
    fi
fi

cd $CODEBASE_DIR
echo "  (1) $ME, updating git  " >> ~/.rebootlog

GIT_RESULT="FAIL"
git pull
if [ $? = 0 ]; then
    GIT_RESULT="pass"
fi
echo "      Result of git pull: $GIT_RESULT    " >> ~/.rebootlog
if [ "${GIT_RESULT}" = "FAIL" ]; then
    exit 2
fi
    
echo "  Update complete  "

qblink.sh off

exit 0
