#!/bin/bash
#--------------------------------------------------------------
#    Script: upon_reboot_autotest.sh
#    Author: Michael Benjamin
#      Date: April 2025
#  Synopsis: This may be invoked directly, but is intended to be
#            invoked from the upon_reboot.sh script.
#--------------------------------------------------------------
#  Part 1: Initialize global variables
#--------------------------------------------------------------
ME=`basename "$0"`
REPO="autotest"
CODEBASE_DIR="$HOME/$REPO"
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
#  Part 3: Skip if there no autotest on this machine
#--------------------------------------------------------------
if [ ! -d "${CODEBASE_DIR}" -a "${GETREPO}" != "yes" ]; then
    echo "  (0) $ME: $Skipping $REPO. OK Not in use." >> ~/.rebootlog
    exit 0
fi

#--------------------------------------------------------------
#  Part 4: Perform the GIT pull and note if success
#--------------------------------------------------------------
qblink.sh cyan --b30 -2

eval $(ssh-agent -s)
trap "ssh-agent -k" EXIT
ssh-add -t 120 ~/.ssh/id_ed25519_pablo_autotest
 
GIT_RESULT="FAIL"
if [ ! -d "${CODEBASE_DIR}" ]; then 
     echo "  (1) $ME: Cloning $REPO from GitHub    " >> ~/.rebootlog
     cd; git clone git@github.com:mikerb/autotest.git
     if [ $? = 0 ]; then
	 GIT_RESULT="pass"
     fi
 else
     cd $CODEBASE_DIR
     echo "  (1) $ME: Updating $REPO from GitHub  " >> ~/.rebootlog
     git pull
     if [ $? = 0 ]; then
	 GIT_RESULT="pass"
     fi
fi

qblink.sh off

exit 0
