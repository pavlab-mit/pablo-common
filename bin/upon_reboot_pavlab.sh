#!/bin/bash
#--------------------------------------------------------------
#    Script: upon_reboot_pavlab.sh
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
CODEBASE_DIR="$HOME/moos-ivp-pavlab"
JPROCS="-j2"

#--------------------------------------------------------------
#  Part 2: Handle Command Line args
#--------------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "upon_reboot_pavlab.sh [OPTIONS]                 "
	echo "                                                "
	echo "Synopsis:                                       "
	echo "  Build the moos-ivp-pavlab code while logging  "
	echo "  the results to the home folder.               "
	echo "                                                "
	echo "  To ~/.rebootlog       --> high level events   "
	echo "  To ~/.superbld_pavlab --> compiler output     "
	echo "                                                "
	echo "  Typically called from within upon_reboot.sh   "
	echo "                                                "
	echo "Options:                                        "
	echo "  --help, -h                                    "
	echo "     Show this help message.                    "
	echo "  -j1                                           "
	echo "     Pass -j1 arg to build.sh                   "
	exit 0
    elif [ "${ARGI}" = "-j1" ]; then
        JPROCS="-j1"
    else
	echo "ME: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

#--------------------------------------------------------------
#  Part 3: Clear the buildlog from the previous build. 
#--------------------------------------------------------------
rm -f ~/.superbld_pavlab

#--------------------------------------------------------------
#  Part 3B: Skip if there is no moos-ivp-pavlab on this machine
#--------------------------------------------------------------
if [ ! -d $CODEBASE_DIR ]; then
    echo "      Skipping update of moos-ivp-pavlab. OK Not in use." >> ~/.rebootlog
    echo "      Skipping update of moos-ivp-pavlab. OK Not in use." >> ~/.superbld_pavlab
    exit 0
fi

#--------------------------------------------------------------
#  Part 4: Perform an SVN update and note if it was successful
#--------------------------------------------------------------
qblink.sh cyan --b30 -2
cd $CODEBASE_DIR
echo "  (1) $ME, updating svn  " >> ~/.rebootlog

SVN_RESULT="FAIL"
svn update && svn cleanup; svn update
if [ $? = 0 ]; then
    SVN_RESULT="pass"
fi

echo "      Result of SVN update: $SVN_RESULT    " >> ~/.rebootlog

if [ "${SVN_RESULT}" = "FAIL" ]; then
    exit 2
fi
qblink.sh off 


#--------------------------------------------------------------
#  Part 5: Build moos-ivp-pavlab
#          The ~/.superbld_pavlab file will hold a copy of all the 
#          build results.
#--------------------------------------------------------------
qblink.sh cyan --blink=1000 --b20 -2 &
echo "  (2) $ME: Building moos-ivp-pavlab " >> ~/.rebootlog

echo "**************************************" >> ~/.superbld_pavlab
echo -n "START BUILD MOOS-IVP-PAVLAB" > ~/.superbld_pavlab
date >>  ~/.superbld_pavlab
echo "**************************************" >> ~/.superbld_pavlab

PAVLAB_RESULT="FAIL"
./build.sh --minrobot $JPROCS 2>&1 | tee -a ~/.superbld_pavlab
if [ ${PIPESTATUS[0]} = 0 ]; then
    PAVLAB_RESULT="pass"
fi
# Try to build again if it fails
if [ "$PAVLAB_RESULT" -ne "pass" ]; then
	./clean.sh
    ./build.sh --minrobot $JPROCS 2>&1 | tee -a ~/.superbld_pavlab
	if [ ${PAVLAB_RESULT[0]} = 0 ]; then
    	PAVLAB_RESULT="pass"
	fi
fi
echo "**************************************" >> ~/.superbld_pavlab
echo -n "FINISHED BUILD MOOS-IVP-PAVLAB: $PAVLAB_RESULT " >> ~/.superbld_pavlab
date >>  ~/.superbld_pavlab
echo "**************************************" >> ~/.superbld_pavlab

echo "      Result of Pavlab Build: $PAVLAB_RESULT " >> ~/.rebootlog

if [ "${PAVLAB_RESULT}" = "FAIL" ]; then
    exit 3
fi

echo "  Build complete  "
date >>  ~/.superbld_pavlab

qblink.sh off

exit 0
