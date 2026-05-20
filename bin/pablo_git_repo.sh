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
NOROK=1
AND_BUILD="no"

#--------------------------------------------------------
# Part 2: Handle Command Line Args
#--------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "$ME [OPTIONS]                                     "
        echo "                                                  " 
        echo "Synopsis:                                         " 
        echo "  The $ME script will perform one of several      "
        echo "  supported actions on the specified repo.        "
        echo "                                                  " 
        echo "Options:                                          " 
        echo "  --help, -h                                      "
	echo "  --verbose, -v        Verbose output             "
	echo "  --noblink, -nob      No Blinkstick calls        "
	echo "  --norepo_ok, -norok  No err if repo not present "
        echo "                                                  " 
        echo "  --repo=<repo-name>   Existing pablo repo name   " 
        echo "  --repo=<repo-url>    URL of repo to clone       " 
        echo "                                                  " 
        echo "  --action=clone                                  " 
        echo "  --action=pull                                   " 
        echo "  --action=rm                                     " 
        echo "  --action=clean                                  " 
        echo "  --action=build                                  " 
        echo "                                                  " 
        echo "  --and_bld, -bld      Build repo after actions:  " 
        echo "                       clean,clone,pull           " 
        exit 0;
    elif [ "${ARGI:0:7}" = "--repo=" ]; then
        REPO="${ARGI#--repo=*}"
    elif [ "${ARGI:0:9}" = "--action=" ]; then
        ACTION="${ARGI#--action=*}"
    elif [ "${ARGI}" = "--terse" -o "${ARGI}" = "-t" ]; then
        TERSE="-n"
    elif [ "${ARGI}" = "--norepo_ok" -o "${ARGI}" = "-norok" ]; then
        NOROK=0
    elif [ "${ARGI}" = "--and_bld" -o "${ARGI}" = "-bld" ]; then
        AND_BLD="yes"
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
    echo "$ACTION is not supported. Exit 2."
    exit 2
fi

#--------------------------------------------------------
# Part 4: Check if repo already exists on the pablo
#--------------------------------------------------------
# If the action is "clone" the repo should be the git URL.
# 
# Otherwise check if repo exists. Depending on NOROK setting
# the lack of a repo may or may not be regarded as an error.

FULL_REPO="$HOME/$REPO"
if [ "${ACTION}" != "clone" ]; then
    if [ ! -d "${FULL_REPO}" ]; then
	echo "$ME: Could not find repo: [${REPO}]. Exit $NOROK."
	exit $NOROK;
    fi
fi

#--------------------------------------------------------
# Part 5: Handle removing the repo
#--------------------------------------------------------
if [ $ACTION == "rm" ]; then
    cd "$FULL_REPO"
    echo "Handling $ACTION for $REPO"
    REPO_LOG="${HOME}/.repo_${REPO}"
    tail -n 500 $REPO_LOG > file.tmp && mv -f file.tmp $REPO_LOG

    echo -e "\n**************** Remove:$REPO ****************\n" >> $REPO_LOG
    if [ -d ".git" ]; then
	cd ..    
	rm -rf "$REPO" 2>&1 | tee -a $REPO_LOG
	RES=$?
    fi
    DATE=`date +%Y%m%dT%H%M%S`
    echo "$RES $DATE" >> $REPO_LOG    
    exit $RES
fi

#--------------------------------------------------------
# Part 6: Handle the clean action
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
    RES=$?
    DATE=`date +%Y%m%dT%H%M%S`
    echo "$RES $DATE" >> $REPO_LOG    
    if [ $RES != 0 ]; then
	exit $RES
    fi
fi

#--------------------------------------------------------
# Part 7: Handle updating the repo (git pull)
#--------------------------------------------------------
if [ $ACTION == "pull" ]; then
    cd "$FULL_REPO"
    echo "Handling $ACTION for $REPO"
    REPO_LOG="${HOME}/.repo_${REPO}"
    tail -n 500 $REPO_LOG > file.tmp && mv -f file.tmp $REPO_LOG

    echo -e "\n**************** Pull:$REPO ****************\n" >> $REPO_LOG
    git pull 2>&1 | tee -a $REPO_LOG
    RES=$?
    END_UTC=$(date +%s)
    DATE=`date +%Y%m%dT%H%M%S`
    echo "$RES $DATE" >> $REPO_LOG    
    if [ $RES != 0 ]; then
	exit $RES
    fi
fi

#--------------------------------------------------------
# Part 8: Handle cloning the repo
#--------------------------------------------------------
if [ $ACTION == "clone" ]; then
    cd $HOME
    echo "Handling $ACTION for $REPO"
    CLONE_LOG="${HOME}/.clone_log"
    tail -n 500 $CLONE_LOG > file.tmp && mv -f file.tmp $CLONE_LOG

    START_UTC=$(date +%s)
    echo -e "\n**************** Clone:$REPO ****************\n" >> $CLONE_LOG
    if [ ! -d "$REPO" ]; then
	git clone "$REPO" 2>&1 | tee -a $CLONE_LOG
	RES=$?
    fi
    END_UTC=$(date +%s)
    ELAPSED=$((END_UTC - START_UTC))
    DATE=`date +%Y%m%dT%H%M%S`
    echo "$RES $ELAPSED $END_UTC $DATE" >> $CLONE_LOG    
    if [ $RES != 0 ]; then
	exit $RES
    fi
fi



#--------------------------------------------------------
# Part 9: Handle the build action
#--------------------------------------------------------
if [ $ACTION == "build" -o "${AND_BLD}" = "yes" ]; then
    cd "$FULL_REPO"
    echo "Handling $ACTION for $REPO"
    BLD_LOG="${HOME}/.bld_${REPO}"
    tail -n 800 $BLD_LOG > file.tmp && mv -f file.tmp $BLD_LOG

    blink yellow
    START_UTC=$(date +%s)
    echo -e "\n**************** BUILD:$REPO ****************\n" >> $BLD_LOG
    ./build.sh --minrobot 2>&1 | tee -a $BLD_LOG
    BLD_RES=$?
    END_UTC=$(date +%s)
    ELAPSED=$((END_UTC - START_UTC))
    DATE=`date +%Y%m%dT%H%M%S`
    echo "$BLD_RES $ELAPSED $END_UTC $DATE" >> $BLD_LOG
    blink off
fi

exit 0


