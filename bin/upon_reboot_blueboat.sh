#!/bin/bash
#--------------------------------------------------------------
#    Script: upon_reboot_blueboat.sh
#    Author: Michael Benjamin
#      Date: March 2026
#  Synopsis: This script may be invoked directly, but is 
#            intended to be invoked from upon_reboot.sh script.
#--------------------------------------------------------------
#  Part 1: Initialize global variables
#--------------------------------------------------------------
ME=`basename "$0"`
REPO="moos-ivp-blueboat"
CODEBASE_DIR="$HOME/$REPO"
JPROCS="-j2"
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
	echo "  Build the moos-ivp-blueboat code while        "
	echo "  logging the results to the home folder.       "
	echo "                                                "
	echo "  To ~/.rebootlog      --> high level events    "
	echo "  To ~/.superbld_bboat --> compiler output      "
	echo "                                                "
	echo "  Typically called from within upon_reboot.sh   "
	echo "                                                "
	echo "Options:                                        "
	echo "  --help, -h   Show this help message.          "
	echo "  --get, -g    Get repo if not present          "
	echo "  --fbld, -f   Force build clean                "
	echo "  -j1          Pass -j1 arg to build-*.sh       "
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
#  Part 3: Trim the buildlog from the previous build. 
#--------------------------------------------------------------
tail -n 750 ~/.superbld_bboat > ~/.tmp && mv -f ~/.tmp ~/.superbld_bboat

#--------------------------------------------------------------
#  Part 3B: Skip if there no moos-ivp-blueboat on this machine
#--------------------------------------------------------------
if [ ! -d "${CODEBASE_DIR}" -a "${GETREPO}" != "yes" ]; then
    echo "  (0) $ME: Skipping $REPO. OK Not in use." >> ~/.rebootlog
    echo "      $ME: Skipping $REPO. OK Not in use." >> ~/.superbld_bboat
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
     cd; git clone https://github.com/pavlab-mit/moos-ivp-blueboat.git
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

if [ "${REPO_CHANGE}" = "no" -a  "${FORCE_BLD}" = "no" ]; then
    echo "  (2) $ME: Build $REPO Not Needed    " >> ~/.rebootlog
    echo -n "*********** No Git mod, No Build: " >> ~/.superbld_bboat
    date >>  ~/.superbld_bboat
    exit 0
fi

#--------------------------------------------------------------
#  Part 5: Build moos-ivp-blueboat
#          The ~/.superbld_bboat file will hold a copy of 
#          all the build results.
#--------------------------------------------------------------
qblink.sh purple --blink=1000 --b20 -2 &
echo "  (2) $ME: Building $REPO " >> ~/.rebootlog

echo "********************************" >> ~/.superbld_bboat
echo -n "START BUILD $REPO            " >> ~/.superbld_bboat
date >>  ~/.superbld_bboat
echo "********************************" >> ~/.superbld_bboat

BLD_RESULT="FAIL"
cd $CODEBASE_DIR

if [ "${FORCE_BLD}" = "yes" ]; then
    ./clean.sh 2>&1 | tee -a ~/.superbld_bboat
fi

./build.sh $JPROCS 2>&1 | tee -a ~/.superbld_bboat
if [ ${PIPESTATUS[0]} = 0 ]; then
    BLD_RESULT="pass"
fi

# If first build attempt fails, try clean/build 
if [ "BLD_RESULT" != "pass" ]; then
    ./clean.sh
    ./build.sh --minrobot $JPROCS 2>&1 | tee -a ~/.superbld_bboat
	if [ ${PIPESTATUS[0]} = 0 ]; then
    	    BLD_RESULT="pass"
	fi
fi

echo "***********************************" >> ~/.superbld_bboat
echo -n "DONE BUILD $REPO: $BLD_RESULT   " >> ~/.superbld_bboat
date >>  ~/.superbld_bboat
echo "***********************************" >> ~/.superbld_bboat
echo "      Build $REPO: [{$BLD_RESULT}] " >> ~/.rebootlog

if [ "${BLD_RESULT}" = "FAIL" ]; then
    exit 3
fi

qblink.sh off
exit 0
