#!/bin/bash
#--------------------------------------------------------
# Script: pablo_git_hash.sh
#   Date: Aug 28th, 2024
#     By: Mike Benjamin
#  About: Execute a remote git rev-parse for latest hash
#--------------------------------------------------------
# Part 1: Initialize script variables
#--------------------------------------------------------
ME=`basename "$0"`
REPO=""
TERSE=""

#--------------------------------------------------------
# Part 2: Handle Command Line Args
#--------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "$ME [OPTIONS]                                     "
        echo "                                                  " 
        echo "Synopsis:                                         " 
        echo "  The $ME script will return the git hash of the  "
        echo "  specified repo                                  "
        echo "                                                  " 
        echo "Options:                                          " 
        echo "  --help, -h                                      "
	echo "  --terse, -t           No newline char in output "
        echo "                                                  " 
        echo "  --repo=<repo>         Name of repo to query     " 
        exit 0;
    elif [ "${ARGI:0:7}" = "--repo=" ]; then
        REPO="${ARGI#--repo=*}"
    elif [ "${ARGI}" = "--terse" -o "${ARGI}" = "-t" ]; then
        TERSE="-n"
    else
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
        exit 1
    fi
done

#--------------------------------------------------------
# Part 3: Verify that a tree has been specified
#--------------------------------------------------------
if [ "${REPO}" = "" ]; then
    echo "Repo must be specified with --repo arg. Exit 2."
    exit 2;
fi


#--------------------------------------------------------
# Part 4: Verify existence and location of repo.
#--------------------------------------------------------
FULL_REPO="$HOME/$REPO"
if [ ! -d "${FULL_REPO}" ]; then
    echo "Could not find [${REPO}]. Exit 3."
    exit 3;
fi

#--------------------------------------------------------
# Part 5: Execute the git command
#--------------------------------------------------------
cd $FULL_REPO

a=`git rev-parse --short HEAD`

echo $TERSE "$a"
