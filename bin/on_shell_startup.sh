#!/bin/bash
#---------------------------------------------------------
# Script: on_shell_startup.sh
#   Date: April 21st, 2017
#     By: Michael Benjamin
#  About: This file is designed to be executed whenever a new 
#         shell is started. Invoked from within .bashrc. 
#         It is designed to be a catch-all hook to add environment
#         configuration without the need to modify pablo-master
#         and re-clone.
#---------------------------------------------------------
#  Part 1: Define a convenience function for producing terminal 
#          debugging/status output depending on the verbosity.
#---------------------------------------------------------
vecho() { if [ "$VERBOSE" != "" ]; then echo $1; fi }

#---------------------------------------------------------
# Part 2: Initialize variables
#---------------------------------------------------------
VERBOSE=""

#---------------------------------------------------------
# Part 3: Handle Command Line Arguments
#---------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "Usage:                                             "
        echo "  on_shell_startup.sh [OPTIONS]                    "
        echo "                                                   "
        echo "Synopsis:                                          "
        echo "  This script is designed to be run whenever a new "
        echo "  shell is started. Invoked from with .bashrc, it  "
        echo "  is designed to be a catch-all hook to add        "
        echo "  environmental configurations without the need to "
        echo "  modify and re-clone pablos images.               "
        echo "                                                   "
        echo "Options:                                           "
        echo "  --help, -h                                       "
        echo "      Display this help message                    "
        echo "  --verbose, -v                                    "
        echo "      Increase verbosity                           "
	exit 0
    elif [ "${ARGI}" == "--verbose" -o "${ARGI}" == "-v" ]; then
    	VERBOSE="yes";
    else
        echo "on_shell_startup.sh: Bad Arg: $ARGI. Exit Code 1."
        exit 1
    fi
done

vecho "Executing on_shell_startup.sh..."

#================================================================
# Patch applied by mikerb 4/25/17
# If the machine doesn't have a .bash_profile file, create one
if [ ! -f ~/.bash_profile ]; then
  vecho "Adding a .bash_profile file"
  echo ". \"$HOME/.bashrc\"" >> ~/.bash_profile
fi
#================================================================

source "$HOME/pablo-common/dot_bashrc"

vecho "Done Executing on_shell_startup.sh."
