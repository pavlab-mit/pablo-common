#!/bin/bash
#--------------------------------------------------------------
#    Script: upon_reboot_monte.sh
#    Author: Kevin Becker, Adapted from Michael Benjamin
#      Date: January 2023
#  Synopsis: This "supervised build" script does the primary
#            work of implementing automated building.
#            It may be invoked directly, but is intended to be
#            invoked from the upon_reboot.sh script.
#--------------------------------------------------------------
#  Part 1: Initialize global variables
#--------------------------------------------------------------
ME=`basename "$0"`
CODEBASE_DIR="$HOME/monte-moos"
CARLO_DIR="$HOME/carlo_dir"

#--------------------------------------------------------------
#  Part 2: Handle Command Line args
#--------------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME.sh [OPTIONS]                 "
	echo "                                                "
	echo "Synopsis:                                       "
	echo "  Update the monte-moos directory.              "
	echo "                                                "
	echo "  Typically called from within upon_reboot.sh   "
	echo "                                                "
	echo "Options:                                        "
	echo "  --help, -h                                    "
	echo "     Show this help message.                    "
	exit 0
    else
	echo "ME: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

#--------------------------------------------------------------
#  Part 3: Clear the buildlog from the previous build. 
#--------------------------------------------------------------
rm -f ~/.superbld_monte

#--------------------------------------------------------------
#  Part 4: Perform a GIT pull and note if it was successful
#--------------------------------------------------------------
qblink.sh pink --b30 -2
if [ -d $CODEBASE_DIR ]; then
    cd $CODEBASE_DIR
    echo "  (1) $ME, updating ${CODEBASE_DIR}  " >> ~/.rebootlog
    git config pull.rebase false >> ~/.superbld_monte 2>&1
    git pull >> ~/.superbld_monte 2>&1
    EXIT_CODE=$?

    if [ $EXIT_CODE != 0 ]; then
        rm -rf ${CODEBASE_DIR} 
        echo "      $ME, git pull failed. Deleting and re-cloning ${CODEBASE_DIR}  " >> ~/.rebootlog
        git clone https://github.com/kjbecker00/monte-moos-public.git $CODEBASE_DIR >> ~/.superbld_monte 2>&1
        EXIT_CODE=$?
    fi
else
    echo "  (1) $ME, cloning ${CODEBASE_DIR}  " >> ~/.rebootlog
    git clone https://github.com/kjbecker00/monte-moos-public.git $CODEBASE_DIR >> ~/.superbld_monte 2>&1
    EXIT_CODE=$?
fi

RESULT="pass"
if [ $EXIT_CODE != 0 ]; then
	RESULT="FAIL"
fi
echo "      Result of GIT update/clone: $RESULT    " >> ~/.rebootlog
if [ "${RESULT}" = "FAIL" ]; then
    exit 2
fi

#--------------------------------------------------------------
#  Part 4.1: Make carlo_dir if it doesn't exist
#--------------------------------------------------------------
qblink.sh pink --b30 -2
if [ -d $CARLO_DIR ]; then
    : # Do nothing
else
    echo "  (1) $ME, cloning ${CARLO_DIR}  " >> ~/.rebootlog
    git clone https://github.com/kjbecker00/carlo_dir_template.git $CARLO_DIR >> ~/.superbld_monte 2>&1
    EXIT_CODE=$?
    RESULT="pass"
    if [ $EXIT_CODE != 0 ]; then
        RESULT="FAIL"
    fi
    echo "      Result of GIT clone carlo_dir_template: $RESULT    " >> ~/.rebootlog
fi
if [ "${RESULT}" = "FAIL" ]; then
    exit 2
fi




#--------------------------------------------------------------
#  Part 5: Ensure yco is a valid ssh key
#--------------------------------------------------------------
if [ -f ~/.ssh/id_rsa_yco ]; then
	chmod -R go-rwx ~/.ssh/id_rsa_yco &> /dev/null
else
	echo "      Result of finding ~/.ssh/id_rsa_yco: FAIL " >> ~/.rebootlog
	exit 2
fi



#--------------------------------------------------------------
#  Part 6: Install matplotlib
#--------------------------------------------------------------
echo "  (2) $ME, installing matplotlib  " >> ~/.rebootlog
pip3 install matplotlib
if [ $EXIT_CODE != 0 ]; then
	RESULT="FAIL"
fi
echo "      Result of pip install matplotlib: $RESULT    " >> ~/.rebootlog
if [ "${RESULT}" = "FAIL" ]; then
    exit 2
fi

#--------------------------------------------------------------
#  Part 7: Install numpy
#--------------------------------------------------------------
echo "  (3) $ME, installing numpy  " >> ~/.rebootlog
pip3 install numpy
if [ $EXIT_CODE != 0 ]; then
	RESULT="FAIL"
fi
echo "      Result of pip3 install numpy: $RESULT    " >> ~/.rebootlog
if [ "${RESULT}" = "FAIL" ]; then
    exit 2
fi

#--------------------------------------------------------------
#  Part 8: Install libatlas-base-dev
#--------------------------------------------------------------
echo "  (4) $ME, installing libatlas for numpy on PIs  " >> ~/.rebootlog
sudo apt-get install -y libatlas-base-dev
if [ $EXIT_CODE != 0 ]; then
	RESULT="FAIL"
fi
echo "      Result of apt install libatlas: $RESULT    " >> ~/.rebootlog
if [ "${RESULT}" = "FAIL" ]; then
    exit 2
fi


qblink.sh off 

date >>  ~/.superbld_monte


exit 0

