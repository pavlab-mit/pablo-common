#!/usr/bin/perl -w

$prefix = "";
$help   = "";

foreach $arg (@ARGV) {
    if((index($arg, "-help") ==0) or
       (index($arg, "--help")==0) or
       (index($arg, "-h")==0)){
        $help = "yes";
    }
    if(index($arg, "prefix=")==0) {
        $prefix = $arg;
        $prefix =~ s/prefix=(.*)/$1/i;
    }
}

if($help eq "yes") {
    print "Usage: \n";
    print "  $0 prefix=string  <file1> [file2]...[fileN] \n";
    print "Example: \n";
    print "  $0 prefix=th_   *.jpg \n";
    exit;
} 

if($prefix eq "") {
    exit;
}

# First make sure that none of the targets is pre-existing
# We do this up front, in whole, rather than on the fly since
# we want to be sure we can go all the way through the process
# w/out needing to abort (with a incomplete/confusing state).
foreach $file (@ARGV) {
    if((-d $file)    and       # Make sure $file is a filename
       (!(-l $file)) and       # Make sure $file is not a link
       (index($file, $prefix)==0)) {   
	$new  = $file;
        $new =~ s/$prefix(.*)/$1/i;
	if(-e $new) {
	    die "Pre-existing target: $new\n";
	}
    }
}


foreach $file (@ARGV) {
    if((-d $file)    and       # Make sure $file is a filename
       (!(-l $file)) and       # Make sure $file is not a link
       (index($file, $prefix)==0)) {   
	$new  = $file;
        $new =~ s/$prefix(.*)/$1/i;
	
	print "Renaming $file to $new\n";
	rename $file, $new or die "couldn't rename $file to $new: $!";
    }
}
