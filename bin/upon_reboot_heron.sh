#!/bin/bash
#--------------------------------------------------------------
#    Script: upon_reboot_heron.sh
#    Author: Michael Benjamin
#      Date: March 2026
#  Synopsis: This script may be invoked directly, but is 
#            intended to be invoked from upon_reboot.sh script.
#--------------------------------------------------------------
#  Part 1: Initialize global variables
#--------------------------------------------------------------
ME=`basename "$0"`
REPO="moos-ivp-heron"
CODEBASE_DIR="$HOME/$REPO"
JPROCS="-j$(getconf _NPROCESSORS_ONLN)"
GETREPO="no"

#--------------------------------------------------------------
#  Part 2: Handle Command Line args
#--------------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME [OPTIONS]                                   "
	echo "                                                "
	echo "Synopsis:                                       "
	echo "  Build the moos-ivp-heron code while logging   "
	echo "  the results to the home folder.               "
	echo "                                                "
	echo "  To ~/.rebootlog       --> high level events   "
	echo "  To ~/.superbld_heron  --> compiler output     "
	echo "                                                "
	echo "  Typically called from within upon_reboot.sh   "
	echo "                                                "
	echo "Options:                                        "
	echo "  --help, -h   Show this help message.          "
	echo "  --get, -g    Get repo if not present          "
	echo "  -j1          Pass -j1 arg to build.sh         "
	exit 0
    elif [ "${ARGI}" = "-j1" ]; then
        JPROCS="-j1"
    elif [ "${ARGI}" = "--get" -o "${ARGI}" = "-g" ]; then
        GETREPO="yes"
    else
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

#--------------------------------------------------------------
#  Part 3: Trim the buildlog from the previous build. 
#--------------------------------------------------------------
tail -n 750 ~/.superbld_heron > ~/.tmp && mv -f ~/.tmp ~/.superbld_heron

#--------------------------------------------------------------
#  Part 3B: Skip if there is no moos-ivp-heron on this machine
#--------------------------------------------------------------
if [ ! -d "${CODEBASE_DIR}" -a "${GETREPO}" != "yes" ]; then
    echo "      Skipping $REPO. OK Not in use." >> ~/.rebootlog
    echo "      Skipping $REPO. OK Not in use." >> ~/.superbld_heron
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
     cd; git clone https://github.com/pavlab-mit/moos-ivp-heron.git
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

if [ "${REPO_CHANGE}" = "no" ]; then
    echo "  (2) $ME: Build $REPO Not Needed    " >> ~/.rebootlog
    echo -n "*********** No Git mod, No Build: " >> ~/.superbld_heron
    date >>  ~/.superbld_heron
    exit 0
fi

#--------------------------------------------------------------
#  Part 5: Build moos-ivp-heron
#          The ~/.superbld_heron file will hold a copy of all the 
#          build results.
#--------------------------------------------------------------
qblink.sh purple --blink=1000 --b20 -2 &
echo "  (2) $ME: Building $REPO " >> ~/.rebootlog

echo "*********************************" >> ~/.superbld_heron
echo -n "START BUILD $REPO             " >> ~/.superbld_heron
date >>  ~/.superbld_heron
echo "*********************************" >> ~/.superbld_heron

BLD_RESULT="FAIL"
cd $CODEBASE_DIR

./build.sh --minrobot $JPROCS 2>&1 | tee -a ~/.superbld_heron
if [ ${PIPESTATUS[0]} = 0 ]; then
    BLD_RESULT="pass"
fi

# Try to build again if it fails (after a clean)
if [ "$BLD_RESULT" != "pass" ]; then
    ./clean.sh
    ./build.sh --minrobot $JPROCS 2>&1 | tee -a ~/.superbld_heron
	if [ ${PIPESTATUS[0]} = 0 ]; then
    	    BLD_RESULT="pass"
	fi
fi
echo "***********************************" >> ~/.superbld_heron
echo -n "DONE BUILD $REPO: $BLD_RESULT   " >> ~/.superbld_heron
date >>  ~/.superbld_heron
echo "***********************************" >> ~/.superbld_heron
echo "      Build $REPO: [{$BLD_RESULT}] " >> ~/.rebootlog

if [ "${BLD_RESULT}" = "FAIL" ]; then
    exit 3
fi

qblink.sh off
exit 0
