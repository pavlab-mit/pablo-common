#!/bin/bash 
#------------------------------------------------------------
#  Script: pablo_branch.sh
#  Author: Michael Benjamin
#  Date:   Sep 25th 2025
#  About:  This script is likely invoked remotely
#          Request git branch switch or status for given repo
#------------------------------------------------------------
#  Part 1: A convenience function for producing terminal
#          debugging/status output depending on verbosity.
#------------------------------------------------------------
vecho() { if [ "$VERBOSE" != "" ]; then echo "$1"; fi }
vechon() { if [ "$VERBOSE" != "" ]; then echo -n "$1"; fi }

#------------------------------------------------------------
#  Part 2: Set global variable default values    
#------------------------------------------------------------
ME=`basename "$0"`
VERBOSE=""
BRANCH=""
TREE=""
COLOR=""
BUILD=""
QUERY=""

#------------------------------------------------------------
# Part 3: Handle Command Line Args
#------------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "$ME [OPTIONS] branch                             "
        echo "                                                 " 
        echo "Synopsis:                                        " 
        echo "  The $ME switch to the specified git branch for "
        echo "  a given repo. A re-build is optional.          "
        echo "                                                 " 
        echo "Options:                                         "
        echo "  --help, -h                                     "
        echo "  --verbose, -v        Verbose output            "
        echo "                                                 " 
        echo "  --branch=<name>      Name the branch           "
        echo "                                                 "
        echo "  --moos, -m           Update moos-ivp tree      "
        echo "  --pablo-common, -pac Update pablo-common tree  "
        echo "  --swarm, -s          Update project-swarm tree "
        echo "  --pavlab, -pav       Update moos-ivp-pavlab    "
        echo "  --2680, -2           Update moos-ivp-2680      "
        echo "                                                 "
        echo "  --build, -b          Build following update    "
        echo "  --query, -q          Just query the curr branch"
        echo "  --rand, -r           Random delay up to 60 sec "
        echo "  --color              Show green if success     "
        echo "                                                 " 
        echo "Examples:                                        "
        echo "  $ pablo_branch.sh --moos --build test-feature  "
        echo "  $ pablo_branch.sh -2 -b widget-fix             "
        echo "  $ pablo_branch.sh --swarm --query              "
        exit 0;
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
        VERBOSE="yes"
    elif [ "${ARGI:0:9}" = "--branch=" ]; then
        BRANCH="${ARGI#--branch=*}"

    elif [ "${ARGI}" = "--moos" -o "${ARGI}" = "-m" ]; then
        TREE="moos-ivp"
    elif [ "${ARGI}" = "--pablo-common" -o "${ARGI}" = "-pac" ]; then
        TREE="pablo-common"
    elif [ "${ARGI}" = "--swarm" -o "${ARGI}" = "-s" ]; then
        TREE="moos-ivp-swarm"
    elif [ "${ARGI}" = "--pavlab" -o "${ARGI}" = "-pav" ]; then
        TREE="moos-ivp-pavlab"
    elif [ "${ARGI}" = "--2680" -o "${ARGI}" = "-2" ]; then
        TREE="moos-ivp-2680"

    elif [ "${ARGI}" = "--build" -o "${ARGI}" = "-b" ]; then
	BUILD="yes"
    elif [ "${ARGI}" = "--query" -o "${ARGI}" = "-q" ]; then
	QUERY="yes"
    elif [ "${ARGI}" = "--rand" -o "${ARGI}" = "-r" ]; then
	DELAY=$(( $RANDOM % 10 ))
	sleep $DELAY
    elif [ "${ARGI}" = "--color" ]; then
	COLOR="yes"
    else
	vecho "$ME: Bad Arg: $ARGI. Exit Code 1."
        exit 1
    fi

done

#=========================================================
# Part 3: Verify that a tree has been specified
#=========================================================
if [ "${TREE}" = "" ]; then
    vecho "A tree must be specified, -m, -s, -p or -2. Exit Code 2."
    exit 2;
fi

#=========================================================
# Part 4: Verify that a branch has been specified
#=========================================================
if [ "${BRANCH}" = "" -a "${QUERY}" = "" ]; then
    vecho "A branch must be specified, use --branch=<name>. Exit Code 3."
    exit 3;
fi

#=========================================================
# Part 5: Verify existence and location of tree to update
#=========================================================
cd  
if [ ! -d "${TREE}" ]; then
    vecho "Could not find $TREE. Exit Code 4."
    exit 4;
fi

#=========================================================
# Part 6: If just a query, execute the query
#=========================================================
if [ "${QUERY}" != "" ]; then
    cd; cd $TREE
    git branch --show-current
    exit 0
fi

#=========================================================
# Part 7: Execute the git branch switch
#=========================================================
cd; cd $TREE

CBRANCH=`git branch --show-current`

vechon "[$TREE]: switch branch [$CBRANCH] to [$BRANCH]: " 

git checkout $BRANCH >& /dev/null
if [ $? = 0 ]; then
    RESULT="SUCCESS"
else
    RESULT="FAIL"
fi

vecho "${RESULT}"

if [ "${RESULT}" != "SUCCESS" ]; then
    exit 5
fi


#=========================================================
# Part 8: Build the tree if requested
#=========================================================
cd; cd $TREE
if [ "${BUILD}" != "" ]; then
    qblink.sh yellow --blink=1000 --b30 -2 &
    ./build.sh -m >& /dev/null
    qblink.sh --b40 cyan --time=20 -2 &
fi

#=========================================================
# Part 9: If a color indicator enabled
#=========================================================
if [ "${COLOR}" != "" ]; then
    qblink.sh --b40 cyan --time=20 -2 &
fi

exit 0




