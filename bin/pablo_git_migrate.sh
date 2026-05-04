#!/bin/bash
#--------------------------------------------------------
# Script: pablo_git_migrate.sh
#   Date: Aug 28th, 2024
#     By: Mike Benjamin
#  About: Execute a remote mv from svn to git moos-ivp
#--------------------------------------------------------
# Part 1: Initialize script variables
#--------------------------------------------------------
ME=`basename "$0"`
BUILD="no"

#--------------------------------------------------------
# Part 2: Handle Command Line Args
#--------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
        echo "$ME [OPTIONS]                                    "
        echo "                                                 " 
        echo "Synopsis:                                        " 
        echo "  The $ME script will remove the ~/moos-ivp dir  "
        echo "  and replace it with a fresh pull from git      "
        echo "                                                 " 
        echo "  --help, -h                                     "
        echo "  --build, -b          Build following update    "
        echo "                                                 " 
        exit 0;
    elif [ "${ARGI}" = "--build" -o "${ARGI}" = "-b" ]; then
	BUILD="yes"
    else
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
        exit 1
    fi
done

if [ -d ~/moos-ivp/.git ]; then
    echo "It appears ~/moos-ivp is already git. Exit Code 2."
    exit 2;
fi


#=========================================================
# Part 3: Verify existence ~/moos-ivp
#=========================================================
if [ ! -d ~/moos-ivp ]; then
    echo "Could not find ~/moos-ivp. Exit Code 3."
    exit 3;
fi

#=========================================================
# Part 4: Make a temporary copy of ~/moos-ivp
#=========================================================
mv ~/moos-ivp ~/moos-ivp-aside

#=========================================================
# Part 5: Pull the moos-ivp tree from git
#=========================================================
qblink.sh --b30 yellow --both_leds --dim

cd
git clone https://github.com/moos-ivp/moos-ivp.git

if [ $? != 0 ]; then
    echo "Unsuccessful clone of moos-ivp"
    qblink.sh --b30 red --both_leds --dim
    rm -rf ~/moos-ivp
    mv ~/moos-ivp-aside moos-ivp
    exit 3;
fi

#=========================================================
# Part 4: Remove the temporary copy ~/moos-ivp-aside
#=========================================================
rm -rf ~/moos-ivp-aside

#=========================================================
# Part 5: If building, then build
#=========================================================
if [ "${BUILD}" = "yes" ]; then
    rm -rf ~/.cmake/packages/MOOS
    qblink.sh yellow --blink=1000 --b30 -2 &
    cd ~/moos-ivp
    ./build.sh -m
fi

qblink.sh --b30 green --both_leds --dim


