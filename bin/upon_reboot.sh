#!/bin/bash 
#--------------------------------------------------------------
#  Script: upon_reboot.sh
#  Author: Michael Benjamin
#  Date:   Dec 2nd, 2019
#  About:  This script will be invoked upon a reboot of the
#          pablo, by an @reboot cronjob.
#          For MTASC cluster pablos, not Heron/2.680 pablos
#--------------------------------------------------------------
#  Part 1: Set the path for the script. When run as a cronjob
#  it will only have /bin and /usr/bin by default, so we add
#  others that the script may need.
#--------------------------------------------------------------
PATH=$PATH:/bin
PATH=$PATH:/usr/bin
PATH=$PATH:/usr/local/bin
PATH=$PATH:~/moos-ivp-heron/bin
PATH=$PATH:~/moos-ivp-blueboat/bin
PATH=$PATH:~/moos-ivp-swarm/bin
PATH=$PATH:~/moos-ivp-2680/bin
PATH=$PATH:~/pablo-common/bin
PATH=$PATH:~/pablo-common-aro/bin
vecho() { if [ "$VERBOSE" != "" ]; then echo "$ME: $1"; fi }

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
        echo "  Note the upon_rebootx.sh script which typically wraps"
	echo "  this script, will first do an svn update of the tree "
	echo "  in which this script resides. So it can be expected  "
	echo "  that changes to this script will be executed the     "
	echo "  very next time the pablo reboots.                    "
	echo "                                                       "
	echo "Options:                                               "
        echo "  --help,     -h      Display this help message        " 
	echo "  --verbose,  -v      Increase verbosity               " 
        echo "  --info,     -i      Display short synopsis           " 
	echo "                                                       "
	echo "State:                                                 "
	echo " Yellow Solid:  svn update of moos-ivp                 "
	echo " Yellow Blink:  Building moos-ivp                      "
	echo " Purple Solid:  svn update of moos-ivp-swarm (if present)"
	echo " Purple Blink:  Building moos-ivp-swarm (if present)   "
	echo " Cyan Solid:    svn update of moos-ivp-pavlab (if present)"
	echo " Cyan Blink:    Building moos-ivp-pavlab (if present)   "
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
#  Part 2B: If a wait was requested, do it here. May help when
#           large N machines booting and hitting repos for updates
#--------------------------------------------------------------
if [ "${WAIT}" != "" ]; then
    RWAIT=$((1 + $RANDOM % $WAIT))
    vecho "sleeping for "$RWAIT
    sleep $RWAIT
fi

#--------------------------------------------------------------
#  Part 3: Prune the .rebootlog file to be no more than 500 lines
#          and then add a new entries to the .rebootlog file.
#--------------------------------------------------------------
tail -n 500 ~/.rebootlog > ~/.tmp && mv -f ~/.tmp ~/.rebootlog
echo "-------------------------------------------" >> ~/.rebootlog
echo "  (START) $ME .... (script updated March 29, 2026) " >> ~/.rebootlog

#-------------------------------------------------------
#  Part 4: Updating the moos-ivp tree
#-------------------------------------------------------
TS=`uptime | awk '{print $1}'`
echo "  (A) $ME: updating the moos-ivp tree $TS" >> ~/.rebootlog
#upon_reboot_moosivp.sh -u (changed by mikerb Jul0923)
upon_reboot_moosivp.sh
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp"
fi

#-------------------------------------------------------
#  Part 5: Updating the moos-ivp-swarm tree
#-------------------------------------------------------
TS=`uptime | awk '{print $1}'`
echo "  (B) $ME: updating the moos-ivp-swarm tree $TS" >> ~/.rebootlog
upon_reboot_swarm.sh
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp-swarm"
fi

#-------------------------------------------------------
#  Part 6: Updating the moos-ivp-2680 tree
#-------------------------------------------------------
TS=`uptime | awk '{print $1}'`
echo "  (C) $ME: updating the moos-ivp-2680 tree $TS" >> ~/.rebootlog
upon_reboot_2680.sh --get
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp-2680"
fi

#-------------------------------------------------------
#  Part 7: Updating the moos-ivp-pavlab tree
#-------------------------------------------------------
PABLO_NAME=`get_vname.sh`
#if [ "${PABLO_NAME:0:5}" != "pabaj" ]; then
TS=`uptime | awk '{print $1}'`
echo "  (D) $ME: updating moos-ivp-pavlab tree $TS" >> ~/.rebootlog
upon_reboot_pavlab.sh
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp-pavlab"
fi
#fi
    
#-------------------------------------------------------
#  Part 8: Updating the moos-ivp-heron tree
#-------------------------------------------------------
TS=`uptime | awk '{print $1}'`
echo "  (E) $ME: updating moos-ivp-heron tree $TS" >> ~/.rebootlog
# upon_reboot_heron.sh --get
upon_reboot_heron.sh 
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp-heron"
fi

#-------------------------------------------------------
#  Part 9: Updating the moos-ivp-blueboat tree
#-------------------------------------------------------
TS=`uptime | awk '{print $1}'`
echo "  (F) $ME: updating moos-ivp-blueboat tree $TS" >> ~/.rebootlog
# upon_reboot_blueboat.sh --get -f
upon_reboot_blueboat.sh 
if [ "$?" != "0" ]; then
    ALL_OK+=" moos-ivp-blueboat"
fi

    
#-------------------------------------------------------
#  Part 10: Updating the missions-auto tree
#-------------------------------------------------------
TS=`uptime | awk '{print $1}'`
echo "  (G) $ME: updating the missions-auto tree $TS" >> ~/.rebootlog
# upon_reboot_missions_auto.sh --get
upon_reboot_missions_auto.sh 
if [ "$?" != "0" ]; then
    ALL_OK+=" missions-auto"
fi

#-------------------------------------------------------
#  Part 9: Updating the missions-swarm tree
#-------------------------------------------------------
TS=`uptime | awk '{print $1}'`
echo "  (H) $ME: updating the missions-swarm tree $TS" >> ~/.rebootlog
#upon_reboot_missions_swarm.sh --get
upon_reboot_missions_swarm.sh 
if [ "$?" != "0" ]; then
    ALL_OK+=" missions-swarm"
fi

PABLO_TYPE=`get_vname.sh --wait --ptype`
if [ "${PABLO_TYPE}" = "monte" ]; then
    #-------------------------------------------------------
    #  Part 9: Updating the monte-moos tree
    #-------------------------------------------------------
    TS=`uptime | awk '{print $1}'`
    echo "  (Z) $ME: updating monte-moos tree $TS" >> ~/.rebootlog
    upon_reboot_monte.sh
    if [ "$?" != "0" ]; then
        ALL_OK+=" monte-moos"
    fi
fi


#-------------------------------------------------------
#  Part 12: Updating the autotest tree
#-------------------------------------------------------
#TS=`uptime | awk '{print $1}'`
#echo "  (Y) $ME: updating the autotest tree $TS" >> ~/.rebootlog
#upon_reboot_autotest.sh 
#if [ "$?" != "0" ]; then
#    ALL_OK+=" autotest"
#fi



#-------------------------------------------------------
#  Part N: Finish up! 
#-------------------------------------------------------
if [ "$ALL_OK" = "" ]; then 
    qblink.sh green --time=900 --b30 -2 &
else
    qblink.sh red --blink=1000 -2 &
fi

~/moos-ivp/scripts/ipaddrs.sh

TS=`date +%H:%I:%S`
if [ "${ALL_OK}" = "" ]; then
    echo "  (END) $ME: ALL_OK: YES $TS" >> ~/.rebootlog
else
    echo "  (END) $ME: ALL_OK: NO:$ALL_OK $TS" >> ~/.rebootlog
fi
    
#================================================================
# ONLY start monte-moos if configured to do so
# AND monte-moos is downloaded
if [ "${PABLO_TYPE}" = "monte" ]; then
  echo "   $ME: Designated monte-moos pablo. Attempting to run..." >> ~/.rebootlog
  
  MONTE_MOOS_BASE_DIR="$HOME/monte-moos"
  CARLO_DIR_LOCATION="$HOME/carlo_dir"

  if [[ -d "${MONTE_MOOS_BASE_DIR}" && -d "${CARLO_DIR_LOCATION}" ]]; then
    # Included this here as well as in the bashrc so it works on the 
    # first boot after a fresh install
    export MONTE_MOOS_BASE_DIR="${MONTE_MOOS_BASE_DIR}"
    export PATH="${PATH}:${MONTE_MOOS_BASE_DIR}/global_scripts"
    export CARLO_DIR_LOCATION="${CARLO_DIR_LOCATION}"
    rm -f ${CARLO_DIR_LOCATION}/monte_info ${CARLO_DIR_LOCATION}/.password
    cp ~/pablo-common/monte_info ${CARLO_DIR_LOCATION}/monte_info
    cp ~/.monte_password ${CARLO_DIR_LOCATION}/.password
    source ${CARLO_DIR_LOCATION}/monte_info 
    # Start monte-moos
    cd "$CARLO_DIR_LOCATION"
    echo $($HOME/pablo-common/bin/get_vname.sh) > myname.txt
    echo "Starting monte-moos client"
    if [ -f ~/monte_client_loop.log ]; then
      rm -f ~/monte_client_loop.log.old
      mv ~/monte_client_loop.log ~/monte_client_loop.log.old
    fi
    monte_client_loop.sh -p -y 2>&1 >> monte_client_loop.log & 
    echo "Scheduling a reboot in 12 hours"
    shutdown -r +720 &
  else
    echo "        $ME: Could not find monte-moos tree. Not running." >> ~/.rebootlog
  fi
else
    #echo "        $ME: not a monte-moos pablo. Not running." >> ~/.rebootlog
    echo "        $ME: not a monte-moos pablo. Not running."
fi


#-------------------------------------------------------
#  Handle return value. 0 only if ALL_K
#-------------------------------------------------------
if [ "$ALL_OK" != "" ]; then 
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
