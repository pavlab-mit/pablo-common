#!/bin/bash
#--------------------------------------------------------
# Script: pablo_svn_update.sh
#   Date: Sep 23rd, 2018
#     By: Mike Benjamin
#  About: Execute a remote svn update on specified tree
#--------------------------------------------------------
# Part 1: Initialize script variables
#--------------------------------------------------------
ME=`basename "$0"`
CHECK_DIR=""
TREE=""
COLOR=""
BUILD="no"

#--------------------------------------------------------
# Part 2: Handle Command Line Args
#--------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
        echo "$ME [OPTIONS]                                    "
        echo "                                                 " 
        echo "Synopsis:                                        " 
        echo "  The $ME script will update a specified         "
        echo "  SVN tree tree, and optionally rebuild.         "
        echo "                                                 " 
        echo "  --help, -h                                     "
        echo "  --build, -b          Build following update    "
        echo "                                                 " 
        echo "  --moos, -m           Update moos-ivp tree      "
        echo "  --pablo-common, -pac Update pablo-common tree  "
        echo "  --swarm, -s          Update project-swarm tree "
        echo "  --pavlab, -pav       Update moos-ivp-pavlab    "
        echo "  --2680, -2           Update moos-ivp-2680      "
        echo "  --rand, -r           Random delay up to 60 sec "
        exit 0;
    elif [ "${ARGI}" = "--build" -o "${ARGI}" = "-b" ]; then
	BUILD="yes"

    elif [ "${ARGI}" = "--moos" -o "${ARGI}" = "-m" ]; then
        TREE="moos-ivp"
        COLOR="green"
    elif [ "${ARGI}" = "--pablo-common" -o "${ARGI}" = "-pac" ]; then
        TREE="pablo-common"
        COLOR="blue"
    elif [ "${ARGI}" = "--swarm" -o "${ARGI}" = "-s" ]; then
        TREE="moos-ivp-swarm"
        COLOR="purple"
    elif [ "${ARGI}" = "--pavlab" -o "${ARGI}" = "-pav" ]; then
        TREE="moos-ivp-pavlab"
        COLOR="purple"
    elif [ "${ARGI}" = "--2680" -o "${ARGI}" = "-2" ]; then
        TREE="moos-ivp-2680"
        COLOR="purple"
    elif [ "${ARGI}" = "--rand" -o "${ARGI}" = "-r" ]; then
	DELAY=$(( $RANDOM % 60 ))
	sleep $DELAY
    else
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
        exit 1
    fi
done

#=========================================================
# Part 3: Verify that a tree has been specified
#=========================================================
if [ "${TREE}" = "" ]; then
    echo "A tree must be specified, -m, -s, -p or -2. Exit Code 2."
    exit 2;
fi

#=========================================================
# Part 4: Verify existence and location of tree to update
#=========================================================
TREE_ARO=${TREE}"-aro"

cd 
if [ -d ./$TREE ]; then
    CHECK_DIR="./$TREE"
elif [ -d ./$TREE_ARO ]; then
    CHECK_DIR="./$TREE_ARO"
elif [ -d ./Research/$TREE ]; then
    CHECK_DIR="./Research/$TREE"
elif [ -d ./Research/$TREE_ARO ]; then
    CHECK_DIR="./Research/$TREE_ARO"
fi

if [ "${CHECK_DIR}" = "" ]; then
    echo "Could not find $TREE or $TREE_ARO. Exit Code 3."
    exit 3;
fi

#=========================================================
# Part 5: Execute the SVN update
#=========================================================
cd $CHECK_DIR

qblink.sh --b30 white --both_leds --dim

svn update
if [ $? -eq 0 ]; then
    qblink.sh --b20 $COLOR --both_leds
    if [ "${BUILD}" = "yes" ]; then
	./build.sh -m
    fi
else
    qblink.sh --b20 red --both_leds
fi

qblink.sh --delay=10 off --both_leds &

