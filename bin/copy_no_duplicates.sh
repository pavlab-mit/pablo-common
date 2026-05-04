#!/bin/bash
#=========================================================
# Script: copy_no_duplicates.sh
#   Date: Aug 26th, 2018
#     By: Mike Benjamin
#  About: A script copying the lines of first file into 
#         the second file, only for lines that don't 
#         already exist in the second file.
#=========================================================

#---------------------------------------------------------
#  Part 1: Initialize global variables
#---------------------------------------------------------
VERBOSE="no"
if [ $# -lt 2 ] ; then
    echo "Usage: copy_no_duplicates.sh INFILE OUTFILE"
    exit 1
fi
IFILE=$1
OFILE=$2

#---------------------------------------------------------
#  Part 2: Handle Command Line arguments
#---------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" == "--help" -o "${ARGI}" == "-h" ]; then
    	printf "%s INFILE OUTFILE"
    	echo "SYNOPSIS:"
    	echo "  Copies lines of one file to another if line is"
    	echo "  not found in the target."
    	echo "OPTIONS:"
    	echo "  -h, --help    : Print this help message and quits"
    	echo "  -v, --verbose : Script progress is printed."
    	exit 0
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="yes"
    fi
done

#---------------------------------------------------------
#  Part 3: Sanity check input and output files.
#---------------------------------------------------------
if [ ! -r $IFILE ]; then
    if [ "${VERBOSE}" = "yes" ] ; then
	echo "Input file ["$IFILE"] is not readable. Exiting."
    fi
    exit 2
fi	

if [ ! -e $OFILE ]; then
    touch $OFILE
fi

if [ ! -w $OFILE ]; then
    if [ "${VERBOSE}" = "yes" ]; then
	echo "Output file ["$OFILE"] is not writeable. Exiting."
    fi
    exit 3
fi


#---------------------------------------------------------
#  Part 4: Do the line by line conditional add of lines
#---------------------------------------------------------
while read ILINE; do
    FOUND_IN_TARGET=false
    while read OLINE; do
	if [ "$ILINE" == "$OLINE" ]; then
	    FOUND_IN_TARGET=true
	    break
	fi
    done <$OFILE
        
    if [ "$FOUND_IN_TARGET" = false ]; then
	echo $ILINE >> $OFILE
    fi
done <$IFILE

