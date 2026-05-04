#!/bin/bash
#--------------------------------------------------------------
#    Script: upon_reboot_2680.sh
#    Author: Michael Benjamin
#      Date: July 2022
#  Synopsis: This "supervised build" script does the primary
#            work of implementing automated building.
#            It may be invoked directly, but is intended to be
#            invoked from the upon_reboot.sh script.
#--------------------------------------------------------------
#  Part 1: Initialize global variables
#--------------------------------------------------------------
ME=`basename "$0"`
REPO="moos-ivp-2680"
CODEBASE_DIR="/$HOME/$REPO"
JPROCS="-j2"
GETREPO="no"

#--------------------------------------------------------------
#  Part 2: Handle Command Line args
#--------------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME [OPTIONS]                                   "
	echo "                                                "
	echo "Synopsis:                                       "
	echo "  Build the moos-ivp-2680 code while logging    "
	echo "  the results to the home folder.               "
	echo "                                                "
	echo "  To ~/.rebootlog       --> high level events   "
	echo "  To ~/.superbld_2680 --> compiler output       "
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
	echo "ME: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

#--------------------------------------------------------------
#  Part 3: Trim the buildlog from the previous build. 
#--------------------------------------------------------------
tail -n 500 ~/.superbld_2680 > ~/.tmp && mv -f ~/.tmp ~/.superbld_2680

#--------------------------------------------------------------
#  Part 3B: Skip if there is no moos-ivp-2680 on this machine
#--------------------------------------------------------------
if [ ! -d "${CODEBASE_DIR}" -a "${GETREPO}" != "yes" ]; then
    echo "      Skipping update of moos-ivp-2680. OK Not in use." >> ~/.rebootlog
    echo "      Skipping update of moos-ivp-2680. OK Not in use." >> ~/.superbld_2680
    exit 0
fi

#--------------------------------------------------------------
#  Part 4: Perform the GIT pull and note if success/change
#--------------------------------------------------------------
qblink.sh cyan --b30 -2

GIT_RESULT="FAIL"
REPO_CHANGE="yes"
if [ ! -d "${CODEBASE_DIR}" ]; then 
     echo "  (1) $ME: Cloning $REPO from GitHub    " >> ~/.rebootlog
     cd; git clone https://github.com/mit2680/moos-ivp-2680.git
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
    echo -n "*********** No Git mod, No Build: " >> ~/.superbld_2680
    date >>  ~/.superbld_bboat
    exit 0
fi


#--------------------------------------------------------------
#  Part 5: Build moos-ivp-2680
#          The ~/.superbld_2680 file will hold a copy of all the 
#          build results.
#--------------------------------------------------------------
qblink.sh cyan --blink=1000 --b20 -2 &
echo "  (2) $ME: Building $REPO " >> ~/.rebootlog

echo "*********************************" >> ~/.superbld_2680
echo -n "START BUILD $REPO             " >> ~/.superbld_2680
date >>  ~/.superbld_2680
echo "*********************************" >> ~/.superbld_2680

BLD_RESULT="FAIL"
cd $CODEBASE_DIR
./build.sh --minrobot $JPROCS 2>&1 | tee -a ~/.superbld_2680
if [ ${PIPESTATUS[0]} = 0 ]; then
    BLD_RESULT="pass"
fi
# Try to build again if it fails
if [  "$BLD_RESULT" != "pass" ]; then
    ./clean.sh
    ./build.sh --minrobot $JPROCS 2>&1 | tee -a ~/.superbld_2680
    if [ ${PIPESTATUS[0]} = 0 ]; then
    	BLD_RESULT="pass"
    fi
fi

echo "***********************************" >> ~/.superbld_2680
echo -n "DONE BUILD $REPO: $BLD_RESULT   " >> ~/.superbld_2680
date >>  ~/.superbld_2680
echo "***********************************" >> ~/.superbld_2680
echo "      Build $REPO: [${BLD_RESULT}] " >> ~/.rebootlog

if [ "${BLD_RESULT}" = "FAIL" ]; then
    exit 3
fi

qblink.sh off
exit 0
