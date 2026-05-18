#!/bin/bash
#--------------------------------------------------------
# Script: pablo_git_repo.sh
#   Date: Apr 28th, 2026
#     By: Mike Benjamin
#  About: Execute an action upon a given pablo git repo

vecho() { if [ "$VERBOSE" != "" ]; then echo "$ME: $1"; fi }
blink() { if [ "$BLINK" = "yes" ]; then qblink.sh $1 --b30 -2; fi }

#--------------------------------------------------------
# Part 1: Initialize script variables
#--------------------------------------------------------
ME=`basename "$0"`
REPO=""
ACTION=""
VERBOSE=""
BLINK="yes"

#--------------------------------------------------------
# Part 2: Handle Command Line Args
#--------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "$ME [OPTIONS]                                     "
        echo "                                                  " 
        echo "Synopsis:                                         " 
        echo "  The $ME script will perform one of several      "
        echo "  supported actions on the specified repo.         "
        echo "                                                  " 
        echo "Options:                                          " 
        echo "  --help, -h                                      "
	echo "  --verbose, -v        Verbose output             "
	echo "  --noblink, -nob      No Blinkstick calls        "
        echo "                                                  " 
        echo "  --repo=<repo-name>   Existing pablo repo name   " 
        echo "  --repo=<repo-url>    URL of repo to clone       " 
        echo "                                                  " 
        echo "  --action=clone                                  " 
        echo "  --action=pull                                   " 
        echo "  --action=rm                                     " 
        echo "  --action=clean                                  " 
        echo "  --action=build                                  " 
        exit 0;
    elif [ "${ARGI:0:7}" = "--repo=" ]; then
        REPO="${ARGI#--repo=*}"
    elif [ "${ARGI:0:9}" = "--action=" ]; then
        ACTION="${ARGI#--action=*}"
    elif [ "${ARGI}" = "--terse" -o "${ARGI}" = "-t" ]; then
        TERSE="-n"
    else
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
        exit 1
    fi
done

#--------------------------------------------------------
# Part 3: Verify valid action 
#--------------------------------------------------------
SUPPORTED_ACTIONS="clone,pull,rm,clean,build"
if [[ $SUPPORTED_ACTIONS != *"$ACTION"* ]]; then
    echo "$ACTION is supported. Exit 2."
    exit 2
fi

#--------------------------------------------------------
# Part 4: Verify existence of repo.
#--------------------------------------------------------

# If the action is "clone" the repo should be the git URL.
# Otherwise the repo should refer to an existing repo in
# the $HOME directory. And we check for the latter here.
FULL_REPO="$HOME/$REPO"
if [ "${ACTION}" != "clone" ]; then
    if [ ! -d "${FULL_REPO}" ]; then
	echo "Could not find repo: [${REPO}]. Exit 3."
	exit 3;
    fi
fi

#--------------------------------------------------------
# Part 5: Handle the clean action
#--------------------------------------------------------
if [ $ACTION = "clean" ]; then
    cd "$FULL_REPO"
    echo "Handling $ACTION for $REPO"
    BLD_LOG="${HOME}/.bld_${REPO}"
    tail -n 800 $BLD_LOG > file.tmp && mv -f file.tmp $BLD_LOG
    cd $FULL_REPO
    echo -e "\n**************** CLEAN *******************\n" >> $BLD_LOG
    if [ -f "./clean.sh" ]; then
	./clean.sh  2>&1 | tee -a $BLD_LOG
    else
	./build.sh -m clean 2>&1 | tee -a $BLD_LOG
    fi
    exit 0
fi

#--------------------------------------------------------
# Part 5: Handle the build and build clean actions
#--------------------------------------------------------
if [ $ACTION == "build" ]; then
    cd "$FULL_REPO"
    echo "Handling $ACTION for $REPO"
    BLD_LOG="${HOME}/.bld_${REPO}"
    tail -n 800 $BLD_LOG > file.tmp && mv -f file.tmp $BLD_LOG

    blink yellow
    START_UTC=$(date +%s)
    echo -e "\n**************** BUILD *******************\n" >> $BLD_LOG
    ./build.sh --minrobot clean 2>&1 | tee -a $BLD_LOG
    BLD_RES=$?
    END_UTC=$(date +%s)
    ELAPSED=$((END_UTC - START_UTC))
    DATE=`date +%Y%m%dT%H%M%S`
    echo "$BLD_RES $ELAPSED $END_UTC $DATE" >> $BLD_LOG
    blink off
    exit 0
fi

#--------------------------------------------------------
# Part 6: Handle updating the repo (git pull)
#--------------------------------------------------------
if [ $ACTION == "pull" ]; then
    cd "$FULL_REPO"
    echo "Handling $ACTION for $REPO"
    PULL_LOG="${HOME}/.bld_${REPO}"
    tail -n 800 $PULL_LOG > file.tmp && mv -f file.tmp $PULL_LOG

    START_UTC=$(date +%s)
    git pull >& $PULL_LOG
    PULL_RES=$?
    END_UTC=$(date +%s)
    ELAPSED=$((END_UTC - START_UTC))
    DATE=`date +%Y%m%dT%H%M%S`
    echo "$PULL_RES $ELAPSED $END_UTC $DATE" >> $PULL_LOG    
    exit 0
fi

echo "Unrecognized action"

