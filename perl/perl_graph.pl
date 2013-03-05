#! /usr/bin/perl

use strict;
use warnings;
use Curses;

my @array;
my $counter=0;

sub printbuf {
    for my $i (0..32) {
	for my $j (0..32) {
	    print $array[$i][$j];
	}
	print "\n";
    }
}

while ( $counter <=3 ) {

    for my $i (0..32) {
	for my $j (0..32) {
	    if ( (sin($i)%32) == $j ) {
		$array[$i][$j]=1;
	    }
	    else {
		$array[$i][$j]=0;
	    }
	}
    }

    printbuf;
    $counter += 1;
}


