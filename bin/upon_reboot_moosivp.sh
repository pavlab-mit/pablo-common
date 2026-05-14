#!/bin/bash
#--------------------------------------------------------------
#    Script: upon_reboot_moosivp.sh
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
IVP_BLD_ARGS="--minrobot --nogui "
REPO="moos-ivp"
CODEBASE_DIR="$HOME/$REPO"
JPROCS="-j$(getconf _NPROCESSORS_ONLN)"
GETREPO="no"
FORCE_BLD="no"

#--------------------------------------------------------------
#  Part 2: Handle Command Line args
#--------------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
	echo "$ME [OPTIONS]                                   "
	echo "                                                "
	echo "Synopsis:                                       "
	echo "  Build the moos-ivp code while logging the     "
	echo "  results to the home folder.                   "
	echo "                                                "
	echo "  To ~/.rebootlog     --> high level events     "
	echo "  To ~/.superbld_moos --> compiler output       "
	echo "  To ~/.superbld_ivp  --> compiler output       "
	echo "                                                "
	echo "  Typically called from within upon_reboot.sh   "
	echo "                                                "
	echo "Options:                                        "
	echo "  --help, -h   Show this help message.          "
	echo "  --get, -g    Get repo if not present          "
	echo "  --fbld, -f   Force build clean                "
	echo "  -j1          Pass -j1 arg to build-*.sh       "
	exit 0
    elif [ "${ARGI}" = "--utm_off" -o "${ARGI}" = "-u" ]; then
        IVP_BLD_ARGS+=" --utm_off"
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
#  Part 3: Trim the home folder build logs from previous build
#--------------------------------------------------------------
tail -n 2500 ~/.superbld_moos > ~/.tmp && mv -f ~/.tmp ~/.superbld_moos
tail -n 2500 ~/.superbld_ivp  > ~/.tmp && mv -f ~/.tmp ~/.superbld_ivp

#--------------------------------------------------------------
#  Part 3B: Skip if there is no moos-ivp on this machine
#--------------------------------------------------------------
if [ ! -d "${CODEBASE_DIR}" -a "${GETREPO}" != "yes" ]; then
    echo "      Skipping $REPO. OK Not in use." >> ~/.rebootlog
    echo "      Skipping $REPO. OK Not in use." >> ~/.superbld_moos
    echo "      Skipping $REPO. OK Not in use." >> ~/.superbld_ivp
    exit 0
fi

#--------------------------------------------------------------
#  Part 4: Perform the GIT pull and note if success/change
#--------------------------------------------------------------
qblink.sh yellow --b30 -2

GIT_RESULT="FAIL"
REPO_CHANGE="yes"
if [ ! -d "${CODEBASE_DIR}" ]; then 
     echo "  (1) $ME: Cloning $REPO from GitHub    " >> ~/.rebootlog
     cd; git clone https://github.com/moos-ivp/moos-ivp.git
     if [ $? = 0 ]; then
	 GIT_RESULT="pass"
     fi
 else
     cd $CODEBASE_DIR
     echo "  (1) $ME: Updating $REPO from GitHub  " >> ~/.rebootlog
     PRE_PULL=$(git rev-parse HEAD)
     git pull --depth 1
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
    echo "  (2) $ME: Build MOOS Not Needed     " >> ~/.rebootlog
    echo "  (3) $ME: Build IvP Not Needed      " >> ~/.rebootlog
    echo -n "*********** No Git mod, No Build: " >> ~/.superbld_moos
    date >>  ~/.superbld_moos
    echo -n "*********** No Git mod, No Build: " >> ~/.superbld_ivp
    date >>  ~/.superbld_ivp
    exit 0
fi

#--------------------------------------------------------------
#  Part 5: Build MOOS
#          The ~/.superbld_moos file will hold a copy of all the 
#          build results.
#--------------------------------------------------------------
qblink.sh yellow --blink=1000 --b30 -2 &
echo "  (2) $ME: Building MOOS " >> ~/.rebootlog

echo "**************************************" >> ~/.superbld_moos
echo -n "START BUILD MOOS" > ~/.superbld_moos
date >>  ~/.superbld_moos
echo "**************************************" >> ~/.superbld_moos

MOOS_RESULT="FAIL"
cd $CODEBASE_DIR

if [ "${FORCE_BLD}" = "yes" ]; then
    ./build.sh --minrobot clean 2>&1 | tee -a ~/.superbld_moos
fi

./build-moos.sh --minrobot 2>&1 | tee -a ~/.superbld_moos
if [ ${PIPESTATUS[0]} = 0 ]; then
    MOOS_RESULT="pass"
fi
echo "**************************************" >> ~/.superbld_moos
echo -n "FINISHED BUILD MOOS: $MOOS_RESULT  " >> ~/.superbld_moos
date >>  ~/.superbld_moos
echo "**************************************" >> ~/.superbld_moos
echo "      Build MOOS: [${MOOS_RESULT}]    " >> ~/.rebootlog

if [ "${MOOS_RESULT}" = "FAIL" ]; then
    exit 3
fi


#--------------------------------------------------------------
#  Part 6: Build IvP (only if MOOS Core succeeded)
#--------------------------------------------------------------
echo "  (3) $ME: Building IvP  " >> ~/.rebootlog

echo "********************************" >> ~/.superbld_ivp
echo -n "START BUILD IVP:             " >> ~/.superbld_ivp
date >>  ~/.superbld_ivp
echo "********************************" >> ~/.superbld_ivp

IVP_RESULT="FAIL"
cd $CODEBASE_DIR
./build-ivp.sh $IVP_BLD_ARGS 2>&1 | tee -a ~/.superbld_ivp
if [ ${PIPESTATUS[0]} = 0 ]; then
    IVP_RESULT="pass"
fi

echo "********************************" >> ~/.superbld_ivp
echo -n "DONE BUILD IVP: $IVP_RESULT  " >> ~/.superbld_ivp
date >>  ~/.superbld_ivp
echo "********************************" >> ~/.superbld_ivp
echo "      Build IvP: [{$IVP_RESULT}]" >> ~/.rebootlog

date >>  ~/.superbld_moos 
date >>  ~/.superbld_ivp

if [ "${IVP_RESULT}" = "FAIL" ]; then
    exit 3
fi

qblink.sh off
exit 0
