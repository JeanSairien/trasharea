#! /usr/bin/perl
#
# Default usage command (novice mode):
#
# whistle: pre-load server from hosts file, database or csv file
# teach:   pre-load a script
# show:    get configured values
# hunt:    check server
# fetch:   get remote server information
# quiet:   disable verbose
# noise:   enable verbose
# bite:    force script execution without alert
# walk:    execute script with configuration
# attack:  
# sleep:   reset all variables
# name:    show version
# 
#
# > need SIG handler
# > need database gest (sqlite)
# > need log
# > need Rex... :P

use warnings;
use strict;
use v5.10.1;

our $shucks;

my $prompt="perlsh: ";
my @server_list;
my %server_hash = ( init_server => [ "name", 
				     "ip_adress", 
				     "user", 
				     "password",
				     "private_key" ] );

print $server_hash{'init_server'}[1]."\n";

sub get_help {
    print "usage... \n"
}

sub get_server {

    if ( ! @server_list ) {
	print "No server set...\n"
    }

    else {
	my $counter=1;
	foreach my $i (@server_list) {
	    print "$i ";
	    if ( ($counter%5) == 0 ) {
		print "\n";
	    }
	    $counter+=1;
	}
	if ( (($counter-1)%5) != 0 ) {
	    print "\n";
	}
    }
}


sub set_server {
    my $server_count = @server_list;
    $server_list[$server_count]=$_[0];
}

sub execute {
    
    my $commandLine = $_[0];
    my @command = split(/\s/, $commandLine);
    
    if ( @command ) {
	for ($command[0]) {
	    when (/^load_server|ls$/) { print "load server from...\n" }
	    when (/^get_server|gs$/) { get_server }
	    when (/^set_server|ss$/) { set_server $command[1] }
	    when (/^set|s$/) { print "use global set function\n" }
	    when (/^get|g$/) { print "use global get function\n" }
	    when (/^(help|h|usage|us)$/) { get_help }
	    default { print "Command not found. Please use help.\n"}
	}
    }
}

while (1) {
    print "$prompt";
    my $buf = (<STDIN>);
    chomp($buf);
    execute($buf);
}
