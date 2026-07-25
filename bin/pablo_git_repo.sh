#!/bin/bash
#--------------------------------------------------------
# Script: pablo_git_repo.sh
#   Date: Apr 28th, 2026
#     By: Mike Benjamin
#  About: Execute an action upon a given pablo git repo
#--------------------------------------------------------
# Part 1: Useful Utilities
#--------------------------------------------------------
vecho() { if [ "$VERBOSE" != "" ]; then echo "$ME: $1"; fi }

#--------------------------------------------------------
# Part 1: Initialize script variables
#--------------------------------------------------------
ME=`basename "$0"`
REPO=""
ACTION=""
BUILD=""
VERBOSE=""
COLOR=""
NOROK=1
DKEY=""

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
	echo "  --norepo_ok, -norok  No err if repo not present "
        echo "                                                  " 
        echo "Options (naming the repo):                        " 
        echo "  --repo=<repo-name>   Existing pablo repo name   " 
        echo "  --repo=<repo-url>    URL of repo to clone       " 
        echo "                                                  " 
        echo "Options (Actions):                                " 
        echo "  --clone              Clone given by --repo url  " 
        echo "  --dkey=<dkey>        Deploy key for cloning     " 
        echo "  --pull               Pull given by --repo name  " 
        echo "  --rm, -rm            Remove repo by --repo name " 
        echo "  --clean              Clean repo by --repo name  " 
        echo "  --build, -bld        Build repo by --repo name  " 
        echo "  --switch=<branch>    Switch repo by --repo name " 
        echo "                       to given branch            " 
        echo "                                                  " 
        echo "Options (Query):                                  " 
        echo "  --hash               Git hash for given repo    " 
        echo "  --branch             Git branch for given repo  " 
        echo "  --du                 Disk usage for given repo  " 
        echo "                                                  " 
        echo "Options: (colors)                                 "
        echo "  --cyan               Blink cyan before action   "
        echo "  --blue               Blink blue before action   "
        echo "  --yellow             Blink yellow before action "
        echo "  --white              Blink white before action  "
        echo "  --pink               Blink pink before action   "
        echo "                                                  "
        echo "Note: A --build option can be provide in addition " 
        echo "      to --clone, --pull, --clean, --switch>.     " 
        echo "      The build will be done after first action.  " 
        echo "                                                  " 
        echo "Note: For Info options, this script will return a "
        echo "      single line with no CRLF. For the --switch  " 
        echo "      action, the new branch name is returned.    " 
	echo "                                                  "
	echo "Return Value:                                     "
	echo "      0        Success                            "
	echo "      1        Unsupported arg                    "
	echo "      2        Unsupported action                 "
	echo "      3        Specified repo is not present      "
	echo "      4        Failed repo remove                 "
	echo "      5        Failed repo pull                   "
	echo "      6        Failed repo clone                  "
	echo "      7        Failed repo branch switch          "
	echo "      8        Failed repo build                  "
	echo "                                                  "
	echo "Examples:                                         "
	echo "  $ pablo_git_repo.sh --repo=moos-ivp --pull --cyan "
	echo "  $ pablo_git_repo.sh --clone --yellow        \\    "
	echo "    --repo=https://github.com/moos-ivp/missions-auto.git "
	echo "                                                  "
	echo "  $ pablo_git_repo.sh --repo=moos-ivp --switch=main "
	echo "  $ pablo_git_repo.sh --repo=mission-auto --du    "
	echo "  $ pablo_git_repo.sh --repo=mission-auto --hash  "
	echo "                                                  "
        exit 0;
    elif [ "${ARGI:0:7}" = "--repo=" ]; then
        REPO="${ARGI#--repo=*}"
    elif [ "${ARGI}" = "--clone" ]; then
        ACTION="clone"
    elif [ "${ARGI:0:7}" = "--dkey=" ]; then
	DKEY="${ARGI#--dkey=*}"
    elif [ "${ARGI}" = "--pull" ]; then
        ACTION="pull"
    elif [ "${ARGI}" = "--rm" -o "${ARGI}" = "-rm" ]; then
        ACTION="rm"
    elif [ "${ARGI}" = "--clean" ]; then
        ACTION="rm"
    elif [ "${ARGI}" = "--build" -o "${ARGI}" = "-bld" ]; then
        BUILD="yes"
    elif [ "${ARGI:0:9}" = "--switch=" ]; then
        ACTION="switch"
        BRANCH="${ARGI#--switch=*}"

    elif [ "${ARGI}" = "--hash" ]; then
        ACTION="hash"
    elif [ "${ARGI}" = "--branch" ]; then
        ACTION="branch"
    elif [ "${ARGI}" = "--du" ]; then
        ACTION="du"
    elif [ "${ARGI}" = "--norepo_ok" -o "${ARGI}" = "-norok" ]; then
        NOROK=0

    elif [ "${ARGI}" = "--cyan" ]; then
        COLOR="cyan"
    elif [ "${ARGI}" = "--blue" ]; then
        COLOR="blue"
    elif [ "${ARGI}" = "--yellow" ]; then
        COLOR="yellow"
    elif [ "${ARGI}" = "--white" ]; then
        COLOR="white"
    elif [ "${ARGI}" = "--pink" ]; then
        COLOR="pink"
    elif [ "${ARGI}" = "--brown" ]; then
        COLOR="brown"

    else
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
        exit 1
    fi
done

#--------------------------------------------------------
# Part 3: Verify valid action 
#--------------------------------------------------------
SUPPORTED_ACTIONS="clone,pull,rm,clean,build,hash,branch,du"
if [[ $SUPPORTED_ACTIONS != *"$ACTION"* ]]; then
    echo "$ACTION is not supported. Exit 2."
    exit 2
fi

#--------------------------------------------------------
# Part 3: Acknowledge receipt of action with blink
#--------------------------------------------------------
if [ "$COLOR" != "" ]; then
    qblink.sh $COLOR --b30 -2;
    sleep 3
    qblink.sh off;
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
    vecho "Handling $ACTION for $REPO"
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
    if [ $RES != 0 ]; then
	exit 4
    fi
    exit 0
fi

#--------------------------------------------------------
# Part 6: Handle the clean action
#--------------------------------------------------------
if [ $ACTION = "clean" ]; then
    cd "$FULL_REPO"
    vecho "Handling $ACTION for $REPO"
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
	exit 5
    fi
fi

#--------------------------------------------------------
# Part 7: Handle updating the repo (git pull)
#--------------------------------------------------------
if [ $ACTION == "pull" ]; then
    cd "$FULL_REPO"
    vecho "Handling $ACTION for $REPO"
    REPO_LOG="${HOME}/.repo_${REPO}"
    tail -n 500 $REPO_LOG > file.tmp && mv -f file.tmp $REPO_LOG

    echo -e "\n**************** Pull:$REPO ****************\n" >> $REPO_LOG
    git pull 2>&1 | tee -a $REPO_LOG
    RES=$?
    END_UTC=$(date +%s)
    DATE=`date +%Y%m%dT%H%M%S`
    echo "$RES $DATE" >> $REPO_LOG    
    if [ $RES != 0 ]; then
	exit 6
    fi
fi

#--------------------------------------------------------
# Part 8: Handle cloning the repo
#--------------------------------------------------------
if [ $ACTION == "clone" ]; then
    if [ "$DKEY" != "" ]; then
	if [ ! -f "$HOME/.ssh/$DKEY" ]; then
	    exit 6
	fi
	eval $(ssh-agent -s)
	ssh-add "$HOME/.ssh/$DKEY" 
    fi
    cd $HOME
    vecho "Handling $ACTION for $REPO"
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
	exit 6
    fi
fi

#--------------------------------------------------------
# Part 9: Handle switching the repo branch
#--------------------------------------------------------
if [ $ACTION == "switch" ]; then
    cd $HOME
    vecho "Handling $ACTION for $REPO"
    git switch $BRANCH
    if [ $? != 0 ]; then
	exit 7
    fi
    BRANCH=`git branch --show-current`
    # echo confirming the current branch, but if -bld selected
    # there may be more output during the build procees
    echo -n $BRANCH
fi


#--------------------------------------------------------
# Part 10: Handle the build action
#--------------------------------------------------------
if [ "${BUILD}" = "yes" ]; then
    cd "$FULL_REPO"
    vecho "Handling $ACTION for $REPO"
    BLD_LOG="${HOME}/.bld_${REPO}"
    tail -n 800 $BLD_LOG > file.tmp && mv -f file.tmp $BLD_LOG

    # Flashing Blink during build if color provided
    if [ "$COLOR" != "" ]; then
	qblink.sh $COLOR --blink=1000 --b30 -2 &
    fi
    
    START_UTC=$(date +%s)
    echo -e "\n**************** BUILD:$REPO ****************\n" >> $BLD_LOG
    ./build.sh --minrobot 2>&1 | tee -a $BLD_LOG
    BLD_RES=$?
    END_UTC=$(date +%s)
    ELAPSED=$((END_UTC - START_UTC))
    DATE=`date +%Y%m%dT%H%M%S`
    echo "$BLD_RES $ELAPSED $END_UTC $DATE" >> $BLD_LOG

    if [ "$COLOR" != "" ]; then
	qblink.sh off
    fi

    if [ $BLD_RES != 0 ]; then
	exit 8
    fi
    
fi

#--------------------------------------------------------
# Part 11: Handle getting repo current hash
#--------------------------------------------------------
if [ "${ACTION}" = "hash" ]; then
    cd "$FULL_REPO"
    HASH=`git rev-parse --short HEAD`
    echo -n $HASH
fi

#--------------------------------------------------------
# Part 12: Handle getting repo current branch
#--------------------------------------------------------
if [ "${ACTION}" = "branch" ]; then
    cd "$FULL_REPO"
    BRANCH=`git branch --show-current`
    echo -n $BRANCH
fi

#--------------------------------------------------------
# Part 13: Handle getting disk usage current branch
#--------------------------------------------------------
if [ "${ACTION}" = "du" ]; then
    cd "$FULL_REPO"
    DINFO=`du --max-depth=0 -h | awk '{print $1}'`
    echo -n $DINFO
fi

exit 0

