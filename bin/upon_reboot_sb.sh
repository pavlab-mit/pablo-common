#!/bin/bash 
#--------------------------------------------------------------
#  Script: upon_reboot_sb.sh 
#  Author: Michael Benjamin
#  Date:   Apr 2nd, 2024
#  About:  This script will be invoked upon a reboot of the
#          Pi, by an @reboot cronjob. It will:
#--------------------------------------------------------------
#  Part 1: Set the path for the script. When run as a cronjob
#  it will only have /bin and /usr/bin by default, so we add
#  others that the script may need.
#--------------------------------------------------------------
exit 0
DATE=`date`

PATH=$PATH:/bin
PATH=$PATH:/usr/bin
PATH=$PATH:/usr/local/bin
PATH=$PATH:~/pablo-common/bin
PATH=$PATH:~/pablo-common-aro/bin

#-------------------------------------------------------
#  Part 2: Initialize global variables
#-------------------------------------------------------
VERBOSE="no"
ALL_ARGS=""

#-------------------------------------------------------
#  Part 3: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    ALL_ARGS+=" $ARGI"
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "Usage:                                                  "
        echo "  upon_rebootx.sh [OPTIONS]                             "
        echo "                                                        "
	echo "Synopsis:                                               "
	echo "  This script will be invoked upon a reboot of the      "
	echo "  pablo, by an @reboot cronjob. It (a) verify a network "
	echo "  connection and light RED if no network, and (b) upon  "
	echo "  a network connection will svn update pablo-common,    "
	echo "  and then (c) invoke the upon_reboot.sh script.        "
	echo "                                                        "
	echo "Options:                                                "
        echo "  --help,     -h      Display this help message         " 
	echo "  --verbose,  -v      Increase verbosity                " 
        echo "  --info,     -i      Display short synopsis            " 
	echo "                                                        "
	echo "Returns:                                                "
	echo "  0 if ok                                               "
	echo "  2 if unable to establish internet connection.         "

    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    elif [ "${ARGI}" = "--info" -o "${ARGI}" = "-i" ]; then
	echo "Pablo reboot script. Network, svn update, run upon_reboot.sh"
        exit 0;
    fi
done

#-------------------------------------------------------
#  Part 4: Ensure the reboot log doesnt get too long
#-------------------------------------------------------
tail -n 500 ~/.rebootlog > ~/.tmp && mv -f ~/.tmp ~/.rebootlog

#-------------------------------------------------------
#  Part 5: Write header and optional verbose info
#-------------------------------------------------------
echo "                                     " >> ~/.rebootlog
echo "//===================================" >> ~/.rebootlog
echo "// upon_reboot_sb.sh (1.1)           " >> ~/.rebootlog
echo "// $DATE                             " >> ~/.rebootlog
echo "//===================================" >> ~/.rebootlog

if [ "$VERBOSE" = "yes" ]; then    
    echo "PATH:$PATH" >> ~/.rebootlog
    echo "ALL_ARGS: [$ALL_ARGS]" >> ~/.rebootlog
fi

echo "$DATE [OK]" >> ~/.rebootlog
exit 0
