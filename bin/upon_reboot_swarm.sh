#!/bin/bash
#--------------------------------------------------------------
#    Script: upon_reboot_swarm.sh
#    Author: Michael Benjamin
#      Date: January 2021
#  Synopsis: This "supervised build" script does the primary
#            work of implementing automated building.
#            It may be invoked directly, but is intended to be
#            invoked from the upon_reboot.sh script.
#--------------------------------------------------------------
#  Part 1: Initialize global variables
#--------------------------------------------------------------
ME=`basename "$0"`
REPO="moos-ivp-swarm"
CODEBASE_DIR="$HOME/$REPO"
JPROCS="-j$(getconf _NPROCESSORS_ONLN)"
GETREPO="no"
FORCE_BLD="no"

#--------------------------------------------------------------
#  Part 2: Handle Command Line args
#--------------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME [OPTIONS]                                   "
	echo "                                                "
	echo "Synopsis:                                       "
	echo "  Build the moos-ivp-swarm code while logging   "
	echo "  the results to the home folder.               "
	echo "                                                "
	echo "  To ~/.rebootlog       --> high level events   "
	echo "  To ~/.superbld_swarm  --> compiler output     "
	echo "                                                "
	echo "  Typically called from within upon_reboot.sh   "
	echo "                                                "
	echo "Options:                                        "
	echo "  --help, -h   Show this help message.          "
	echo "  --get, -g    Get repo if not present          "
	echo "  --fbld, -f   Force build clean                "
	echo "  -j1          Pass -j1 arg to build.sh         "
	exit 0
    elif [ "${ARGI}" = "-j1" ]; then
        JPROCS="-j1"
    elif [ "${ARGI}" = "--get" -o "${ARGI}" = "-g" ]; then
        GETREPO="yes"
    elif [ "${ARGI}" = "--fbld" -o "${ARGI}" = "-f" ]; then
        FORCE_BLD="yes"
    else
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

#--------------------------------------------------------------
#  Part 3: Clear the buildlog from the previous build. 
#--------------------------------------------------------------
tail -n 1500 ~/.superbld_swarm > ~/.tmp && mv -f ~/.tmp ~/.superbld_swarm

#--------------------------------------------------------------
#  Part 3B: Skip if there is no moos-ivp-swarm on this machine
#--------------------------------------------------------------
if [ ! -d "${CODEBASE_DIR}" -a "${GETREPO}" != "yes" ]; then
    echo "      Skipping moos-ivp-swarm. OK Not in use." >> ~/.rebootlog
    echo "      Skipping moos-ivp-swarm. OK Not in use." >> ~/.superbld_swarm
    exit 0
fi

#--------------------------------------------------------------
#  Part 4: Perform the GIT pull and note if success/change
#--------------------------------------------------------------
qblink.sh purple --b30 -2

GIT_RESULT="FAIL"
REPO_CHANGE="yes"

if [ ! -d "${CODEBASE_DIR}" ]; then 
     echo "  (1) $ME: Cloning $REPO from GitHub    " >> ~/.rebootlog
     cd; git clone https://github.com/pavlab-mit/moos-ivp-swarm.git
     if [ $? = 0 ]; then
	 GIT_RESULT="pass"
     fi
 else
     cd $CODEBASE_DIR
     echo "  (1) $ME: Updating $REPO from GitHub  " >> ~/.rebootlog
     PRE_PULL=$(git rev-parse HEAD)
     git pull
     if [ $? = 0 ]; then
	 GIT_RESULT="pass"
     fi
     POST_PULL=$(git rev-parse HEAD)
     if [ "$PRE_PULL" = "$POST_PULL" ]; then
	 REPO_CHANGE="no"
     fi
fi
qblink.sh off

echo "      Result of git pull: $GIT_RESULT    " >> ~/.rebootlog
if [ "${GIT_RESULT}" = "FAIL" ]; then
    exit 2
fi

if [ "${REPO_CHANGE}" = "no" -a "${FORCE_BLD}" = "no" ]; then
    echo "  (2) $ME: Build $REPO Not Needed    " >> ~/.rebootlog
    echo -n "*********** No Git mod, No Build: " >> ~/.superbld_swarm
    date >>  ~/.superbld_swarm
    exit 0
fi

#--------------------------------------------------------------
#  Part 5: Build moos-ivp-swarm
#          The ~/.superbld_swarm file will hold a copy of all the 
#          build results.
#--------------------------------------------------------------
qblink.sh purple --blink=1000 --b20 -2 &
echo "  (2) $ME: Building $REPO " >> ~/.rebootlog

echo "*********************************" >> ~/.superbld_swarm
echo -n "START BUILD $REPO             " > ~/.superbld_swarm
date >>  ~/.superbld_swarm
echo "*********************************" >> ~/.superbld_swarm

BLD_RESULT="FAIL"
cd $CODEBASE_DIR

if [ "${FORCE_BLD}" = "yes" ]; then
    ./build.sh --minrobot clean 2>&1 | tee -a ~/.superbld_swarm
fi

./build.sh --minrobot $JPROCS 2>&1 | tee -a ~/.superbld_swarm
if [ ${PIPESTATUS[0]} = 0 ]; then
    BLD_RESULT="pass"
fi
# Try to build again if it fails
if [ "$BLD_RESULT" != "pass" ]; then
    ./clean.sh
    ./build.sh --minrobot $JPROCS 2>&1 | tee -a ~/.superbld_swarm
    if [ ${PIPESTATUS[0]} = 0 ]; then
    	BLD_RESULT="pass"
    fi
fi
echo "***********************************" >> ~/.superbld_swarm
echo -n "DONE BUILD $REPO: $BLD_RESULT   " >> ~/.superbld_swarm
date >>  ~/.superbld_swarm
echo "***********************************" >> ~/.superbld_swarm
echo "      Build $REPO: [${BLD_RESULT}] " >> ~/.rebootlog

if [ "${BLD_RESULT}" = "FAIL" ]; then
    exit 3
fi

qblink.sh off
exit 0

