#!/bin/bash 
#--------------------------------------------------------------
#  Script: upon_reboot.sh
#  Author: Michael Benjamin
#  Date:   Dec 2nd, 2019
#  About:  This script will be invoked upon a reboot of the
#          pablo, by an @reboot cronjob.
#--------------------------------------------------------------
#  Part 1: Set the path for the script. When run as a cronjob
#  it will only have /bin and /usr/bin by default, so we add
#  others that the script may need.
#--------------------------------------------------------------
PATH=$PATH:/bin
PATH=$PATH:/usr/bin
PATH=$PATH:/usr/local/bin
vecho() { if [ "$VERBOSE" != "" ]; then echo "$ME: $1"; fi }
lognote() {
    TS=`uptime | awk '{print $1}'`
    echo "$1 $TS" >> ~/.rebootlog
}

#-------------------------------------------------------
#  Part 2: Initialize global variables
#-------------------------------------------------------
ME=`basename "$0"`
VERBOSE=""
ALL_OK=""
WAIT="7"

#-------------------------------------------------------
#  Part 3: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "Usage:                                                 "
        echo "  $ME [OPTIONS]                                        "
        echo "                                                       "
	echo "Synopsis:                                              "
	echo "  This script is typically invoked upon reboot, by the "
        echo "  upon_rebootx.sh script. This script performs a set   "
        echo "  of tasks such as svn updating key folders and        "
        echo "  (re)building code if needed.                         "
        echo "  Note the upon_rebootx.sh script which wraps this     "
	echo "  script, will first do an update/poll of the tree     "
	echo "  in which this script resides. So it can be expected  "
	echo "  that changes to this script will be executed the     "
	echo "  very next time the pablo reboots.                    "
	echo "                                                       "
	echo "Options:                                               "
        echo "  --help,     -h      Display this help message        " 
	echo "  --verbose,  -v      Increase verbosity               " 
        echo "  --info,     -i      Display short synopsis           " 
	echo "                                                       "
	echo "Final State Colors:                                    "
	echo " Green Solid:   Done - All OK                          "
	echo " Red Blink:     Done - All is NOT OK                   "
	echo "                                                       "
	echo "Returns:                                               "
	echo "  0 if ok                                              "
	echo "  1 if bad command line arg                            "
	echo "  2 if unable to establish internet connection.        "
	echo "  3 if one or more of the builds failed.               "
	exit 0;
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    elif [ "${ARGI}" = "--info" -o "${ARGI}" = "-i" ]; then
        echo " Script executed by upon_restartx.sh at pablo restart. " 
        exit 0;
    else
        echo "$ME: Bad Arg: [$ARGI]. Exit code 1."
        exit 1;
    fi
done

#--------------------------------------------------------------
#  If a wait was requested, do it here. May help when
#  large N machines booting and hitting repos for updates
#--------------------------------------------------------------
if [ "${WAIT}" != "" ]; then
    RWAIT=$((1 + $RANDOM % $WAIT))
    vecho "sleeping for "$RWAIT
    sleep $RWAIT
fi

#--------------------------------------------------------------
#  Prune the .rebootlog file to be no more than 500 lines
#--------------------------------------------------------------
tail -n 500 ~/.rebootlog > ~/.tmp && mv -f ~/.tmp ~/.rebootlog
echo "-------------------------------------------" >> ~/.rebootlog
echo "  (START) $ME .... (script updated March 29, 2026) " >> ~/.rebootlog

#-------------------------------------------------------
#  Update moos-ivp tree
#-------------------------------------------------------
lognote "  (A) $ME: updating the moos-ivp tree."
upon_reboot_moosivp.sh
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp"
fi

#-------------------------------------------------------
#  Update moos-ivp-swarm tree
#-------------------------------------------------------
lognote "  (B) $ME: updating the moos-ivp-swarm tree."
upon_reboot_swarm.sh
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp-swarm"
fi

#-------------------------------------------------------
#  Update moos-ivp-2680 tree
#-------------------------------------------------------
lognote "  (C) $ME: updating the moos-ivp-2680 tree."
pablo_git_repo.sh --repo=moos-ivp-2680 --action=pull -norok -bld
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp-2680"
fi

#-------------------------------------------------------
#  Update moos-ivp-heron tree
#-------------------------------------------------------
lognote "  (E) $ME: updating moos-ivp-heron tree."
pablo_git_repo.sh --repo=moos-ivp-heron --action=pull -norok -bld
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp-heron"
fi

#-------------------------------------------------------
#  Update moos-ivp-blueboat tree
#-------------------------------------------------------
lognote "  (F) $ME: updating moos-ivp-blueboat tree."
pablo_git_repo.sh --repo=moos-ivp-blueboat --action=pull -norok -bld
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp-blueboat"
fi

#-------------------------------------------------------
#  Update missions-auto tree
#-------------------------------------------------------
lognote "  (G) $ME: updating the missions-auto tree."
pablo_git_repo.sh --repo=missions-auto --action=pull -norok
if [ "$?" != "0" ]; then
    ALL_OK+=" missions-auto"
fi

#-------------------------------------------------------
#  Update missions-swarm tree
#-------------------------------------------------------
lognote "  (H) $ME: updating the missions-swarm tree."
pablo_git_repo.sh --repo=missions-swarm --action=pull -norok
if [ "$?" != "0" ]; then
    ALL_OK+=" missions-swarm"
fi

#-------------------------------------------------------
#  Update autotest tree
#-------------------------------------------------------
lognote "  (Y) $ME: updating the autotest tree."
pablo_git_repo.sh --repo=autotest --action=pull -norok
if [ "$?" != "0" ]; then
    ALL_OK+=" autotest"
fi

#-------------------------------------------------------
#  Finish up! 
#-------------------------------------------------------
TS=`date +%H:%I:%S`
if [ "${ALL_OK}" = "" ]; then
    echo "  (END) $ME: ALL_OK: YES $TS" >> ~/.rebootlog
    qblink.sh green --time=900 --b30 -2 &
else
    echo "  (END) $ME: ALL_OK: NO:$ALL_OK $TS" >> ~/.rebootlog
    qblink.sh red --blink=1000 -2 &
    exit 3
fi

#-------------------------------------------------------
#  Added mikerb Jul 18, 24
#-------------------------------------------------------
if ps -p $SSH_AGENT_PID > /dev/null
then
   echo "ssh-agent is already running"
   # Do something knowing the pid exists, i.e. the process with $PID is running
else
eval `ssh-agent -s`
fi

exit 0
