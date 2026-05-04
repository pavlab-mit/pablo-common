#!/bin/bash
#--------------------------------------------------------
# Script: pablo_svn_rev.sh
#   Date: Aug 24th, 2018
#     By: Mike Benjamin
#  About: Execute a remote svn info for Revision number
#--------------------------------------------------------
# Part 1: Initialize script variables
#--------------------------------------------------------
ME=`basename "$0"`
CHECK_DIR=""
TREE=""
TERSE=""

#--------------------------------------------------------
# Part 2: Handle Command Line Args
#--------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "$ME [OPTIONS]                                     "
        echo "                                                  " 
        echo "Synopsis:                                         " 
        echo "  The $ME script will return the SVN revision     "
        echo "  number of the specified tree.                   "
        echo "                                                  " 
        echo "Options  :                                        " 
        echo "  --help, -h                                      "
	echo "  --terse, -t           No newline char in output "
        echo "                                                  " 
        echo "  --pablo-common, -pac  Check pablo-common tree   "
        echo "  --moos, -m            Check moos-ivp tree       "
        echo "  --swarm, -s           Check moos-ivp-swarm tree "
        echo "  --2680, -2            Check moos-ivp-2680       "
        exit 0;
    elif [ "${ARGI}" = "--terse" -o "${ARGI}" = "-t" ]; then
        TERSE="-n"
    elif [ "${ARGI}" = "--moos" -o "${ARGI}" = "-m" ]; then
        TREE="moos-ivp"
    elif [ "${ARGI}" = "--pablo-common" -o "${ARGI}" = "-pac" ]; then
        TREE="pablo-common"
    elif [ "${ARGI}" = "--moos-ivp-swarm" -o "${ARGI}" = "-s" ]; then
        TREE="moos-ivp-swarm"
    elif [ "${ARGI}" = "--moos-ivp-pavlab" -o "${ARGI}" = "-pav" ]; then
        TREE="moos-ivp-pavlab"
    elif [ "${ARGI}" = "--2680" -o "${ARGI}" = "-2" ]; then
        TREE="moos-ivp-2680"
    else
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
        exit 1
    fi
done

#--------------------------------------------------------
# Part 3: Verify that a tree has been specified
#--------------------------------------------------------
if [ "${TREE}" = "" ]; then
    echo "A tree must be specified, -m, -s, -p or -2. Exit Code 2."
    exit 2;
fi


#--------------------------------------------------------
# Part 4: Verify existence and location of tree to update
#--------------------------------------------------------
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

#--------------------------------------------------------
# Part 5: Execute SVN info and grep for revision number
#--------------------------------------------------------
cd $CHECK_DIR

a=`svn info | fgrep Revision`
b=`echo $a | awk -F '[ ]' '{print $2}'`

echo $TERSE "$b"
