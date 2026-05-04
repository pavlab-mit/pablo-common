#!/bin/bash 
#--------------------------------------------------------
#  Script: pablo_restore_svn.sh
#  Author: Mike Benjamin
#  Date:   August 30th, 2021
#  About:  Delete and re-obtaining an code tree
#--------------------------------------------------------
#  Part 1: A convenience function for producing terminal 
#          debugging output depending on the verbosity.
#--------------------------------------------------------
vecho() { if [ "$VERBOSE" != "" ]; then echo $1; fi }

#--------------------------------------------------------
#  Part 1: Initialize script variables
#--------------------------------------------------------
ME=`basename "$0"`
VERBOSE=""
TREE=""
BUILD="no"

#--------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#--------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
        echo "$ME  [OPTIONS]                                       "
        echo "                                                     " 
        echo "Synopsis:                                            " 
        echo "  The $ME script is used when an SVN tree "
        echo "  is suspected to be corrupted and cannot be updated." 
        echo "  This script will change to the home directory,     " 
        echo "  delete the tree in question, and perform an fresh  " 
        echo "  svn checkout on the tree. The user may optionally  " 
        echo "  invoke the build command for the tree.             " 
        echo "                                                     " 
        echo "  This script is built with the idea in mind that a  " 
        echo "  shoreside user might want to run a sweep command   " 
        echo "  to do this on all machines.                        " 
        echo "                                                     " 
        echo "Options:                                             " 
        echo "  --help, -h            Display this help message    " 
        echo "  --verbose, -v         Increase verbosity           " 
        echo "  --build, -b           Build tree after restoring   " 
        echo "                                                     " 
	echo "  --moos, -m            Restore moos-ivp tree        "
        echo "  --pablo-common, -pac  Restore pablo-common tree    "
        echo "  --swarm, -s           Restore moos-ivp-swarm       "
        echo "  --pavlab, -pav        Restore moos-ivp-pavlab      "
        echo "  --2680, -2            Restore moos-ivp-2680        "
        echo "  --monte, -mm          Restore monte-moos           "
        echo "  --rand, -r            Random delay up to 60 sec     "
        exit 0;
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    elif [ "${ARGI}" = "--build" -o "${ARGI}" = "-b" ]; then
	BUILD="yes"

    elif [ "${ARGI}" = "--moos" -o "${ARGI}" = "-m" ]; then
        TREE="moos-ivp"
    elif [ "${ARGI}" = "--pablo-common" -o "${ARGI}" = "-p" ]; then
        TREE="pablo-common"
    elif [ "${ARGI}" = "--swarm" -o "${ARGI}" = "-s" ]; then
        TREE="moos-ivp-swarm"
    elif [ "${ARGI}" = "--pavlab" -o "${ARGI}" = "-pav" ]; then
        TREE="moos-ivp-pavlab"
    elif [ "${ARGI}" = "--2680" -o "${ARGI}" = "-2" ]; then
        TREE="moos-ivp-2680"
    elif [ "${ARGI}" = "--monte" -o "${ARGI}" = "-mm" ]; then
        TREE="monte-moos"
    elif [ "${ARGI}" = "--rand" -o "${ARGI}" = "-r" ]; then
	DELAY=$(( $RANDOM % 60 ))
	sleep $DELAY
    else
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
        exit 1
    fi
done


#-------------------------------------------------------
#  Part 4: Restore the tree
#-------------------------------------------------------
RESULT=8
vecho "Restoring [$TREE]"
if [ "$TREE" = "moos-ivp" ]; then
    cd; rm -rf moos-ivp
    svn co https://oceanai.mit.edu/svn/moos-ivp-aro/trunk moos-ivp
    RESULT=$?
elif [ "$TREE" = "moos-ivp-swarm" ]; then
    cd; rm -rf moos-ivp-swarm
    svn co https://oceanai.mit.edu/svn/moos-ivp-swarm-aro-K6z/trunk moos-ivp-swarm
    RESULT=$?
elif [ "$TREE" = "pablo-common" ]; then
    cd; rm -rf pablo-common
    svn co https://oceanai.mit.edu/svn/pablo-common-aro pablo-common
    RESULT=$?
elif [ "$TREE" = "moos-ivp-pavlab" ]; then
    cd; rm -rf moos-ivp-pavlab
    svn co https://oceanai.mit.edu/svn/moos-ivp-pavlab-aro moos-ivp-pavlab
    RESULT=$?
elif [ "$TREE" = "moos-ivp-2680" ]; then
    cd; rm -rf moos-ivp-2680
    svn co https://oceanai.mit.edu/svn/moos-ivp-2680-aro/trunk moos-ivp-2680
    RESULT=$?
elif [ "$TREE" = "monte-moos" ]; then
    cd; rm -rf monte-moos
    git clone https://github.com/kjbecker00/monte-moos-public.git monte-moos
    RESULT=$?
fi
vecho "Done Restoring. Result: $RESULT"

if [ ! "$BUILD" = "yes" ]; then
    vecho "Exiting w/out building. Use --build/-b option to also build."
    exit $RESULT
fi

#-------------------------------------------------------
#  Part 5: Build if it was requested
#-------------------------------------------------------

RESULT=9
vecho "Building [$TREE]"
if [ "$TREE" = "moos-ivp" ]; then
    cd ~/moos-ivp
    ./build.sh -m
    RESULT=$?
elif [ "$TREE" = "moos-ivp-swarm" ]; then
    cd ~/moos-ivp-swarm
    ./build.sh -m
    RESULT=$?
elif [ "$TREE" = "moos-ivp-pavlab" ]; then
    cd ~/moos-ivp-pavlab
    ./build.sh -m
    RESULT=$?
elif [ "$TREE" = "moos-ivp-2680" ]; then
    cd ~/moos-ivp-2680
    ./build.sh -m
    RESULT=$?
fi
vecho "Done Building. Result: $RESULT"
