#!/bin/bash 
#--------------------------------------------------------------
#  Script: pablo_ktm.sh
#  Author: Michael Benjamin
#  Date:   May 21st 2023
#  About:  This script is likely invoked remotely
#          Execute ktm and other MOOS shutdown methods.

qblink.sh -2 purple >& /dev/null &
ktm >& /dev/null
mykill >& /dev/null
qblink.sh off >& /dev/null &

