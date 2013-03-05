#!/usr/bin/perl
######################################################################
# Generate small url with mathematical algorithm.
# o first, define base64 scheme (0->9, a->z and A->Z): 10^64 
#   possibilities.
# o next, define special char like ('&','*','#','$','@','.',':','|') 
#   which define a "generator".
# o URL seems like that (perfect form)
#   0000*0000 => 
#   aaaa$aaaa =>
#   zzzz@zzzz =>
# o Url seems like that (combined form)
#   0@a*z.A:ZZ
#
# Usefull function: 
#   inverseRange(int)
#   inverseRangePrime(int)
#   simpleAdd(start, count)   [+] 
#   simpleLoop(start, count)  [@]
#   simpleExp(start, count)   [&]
#   simpleFrac(start, count)  [:]
#   findBestMethod(int)
#   convertHex(string)
#
# Method:
#   DNS: oci.re 
#   hex: 0x6f63692e7265
#   dec: 122472757097061
#               19402089 /
#                6312349
#   ((/3/7/7)-1)/2
#
#   0x6475636b6475636b2e 
#   0x636f6d2f7175657279
#
#   0x746573742e746573742e636f6dc2a0
######################################################################

use MIME::Base64;
use Compress::Zlib;
use warnings;
use strict;

my $URL="https://duckduckgo.com/?q=base91/test/test/";
my $PROTO="";
my $HOST="";
my $REQUEST="";

# a -> z : 97 -> 122
# A -> Z : 65 -> 90
# 0 -> 9 : 48 -> 57

my %base62 = ( '00'=>'A', '01'=>'B', '02'=>'C', '03'=>'D',
               '04'=>'E', '05'=>'F', '06'=>'G', '07'=>'H',
               '08'=>'I', '09'=>'J', '10'=>'K', '11'=>'L', 
               '12'=>'M', '13'=>'N');

my @prime = ( );

sub simplify_url {
    my $buf = shift;
    my $i;

    foreach $i (split(//, $buf)) {
	print $i."\n";
    }
}

sub get_proto {
    my $buf = shift;
    $buf =~ s/:\/\/.*//;

    print $buf."\n";
    return $buf;
}

sub get_host {
    my $buf = shift;
    $buf =~ s/^.*:\/\///;
    $buf =~ s/\/.*$//;

    if ( $buf =~ /[a-z]{1,255}\.[a-z]{1,4}/ ) {
	print $buf."\n";
	return $buf;
    }
}

sub get_target {
    my $target_host = shift ;
    my $buf = shift ;

    $buf =~ s/^.*$target_host\///;

    return $buf;
}

sub gcd {
    my $a = shift;
    my $b = shift;
    
    if ( $a == 0 ) {
	return $b;
    }

    while ( $b != 0 ) {
	if ( $a > $b ) {
	    $a = $a - $b;
	}
	else {
	    $b = $b - $a;
	}
    }
    return $a;
}

sub gcd2 {
    my $a = shift;
    my $b = shift;
    if ( $b == 0 ) {
	return $a;
    }
    else { 
	gcd2($b, $a % $b); 
    }
}

sub checkNumb {
    my $a = shift;
    my $b = shift;
}

#simplify_url($URL);
#my $tp = get_proto($URL);
#my $th = get_host($URL);
#my $tt = get_target("duckduckgo.com", $URL);
#print gcd2(12, 3)."\n";
#print 12%3;
#print $tp.$th.$tt."\n";
#compress($tp.$th.$tt, 9));

printf "0b%b", 5
