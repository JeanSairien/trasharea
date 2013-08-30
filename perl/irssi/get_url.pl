#! /usr/bin/env perl
######################################################################
# Copyright 2013 (c) - Niamkik <niamkik@gmail.com>
#
# Howto use it:
#    /script load /path/to/this/script.pl
# Now, you can view all link in your windows status.
#
# Documentation/refernce:
#    http://www.irssi.org/documentation/perl
#    https://github.com/shabble/irssi-docs/wiki
######################################################################

use strict;
use warnings;
use POSIX qw(strftime);

use Irssi;
use Irssi::Irc;

use DBI;

# Original version by shabble:
# https://github.com/shabble/irssi-scripts/blob/master/url_hilight/url_hilight.pl

our $VERSION = '1.01';
our %IRSSI = (
      authors     => 'Niamkik',
      contact     => 'niamkik@gmail.com',
      name        => 'link filter',
      description => 'link filter',
      license     => 'FreeBSD',
    );

my $log_file = "~/.irssi/link.log";

my %global_variables = (
    mode => 'sqlite',
    log => 'link.log',
    report => 'html',
    schema => '~/.irssi/schema.sql'
);

# regex taken from http://daringfireball.net/2010/07/improved_regex_for_matching_urls
my $url_regex = qr((?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])));

sub get_url {
    # split message output
    my ($server, $msg, $nick, $nick_addr, $target) = @_;

    # check if message contain URL
    if ( $msg =~ $url_regex ) {

        # split message with null characters
        my @buf = split(/\s/, $msg);

        # second check. If one word == URL, print it
        foreach my $parse (@buf) {
            if ( $parse =~ $url_regex ) {
		store_url_sqlite($server->{'address'}, $target, $nick, $parse);
            }
        }
    }
}

sub init_database () {
    if ( -f $global_variables{'schema'}) {
	system("\$(which sqlite3) link.log < ".$global_variables{'schema'});
    }
    else {
	print "Where is ".$global_variables{'schema'}
	." file?\n"
    }
}

sub generate_date () {}

sub store_url_log ($$$$) {
    my ($server, $chan, $nick, $url) = @_;
}

sub store_url_sqlite ($$$$) {
    my ($server, $chan, $nick, $url) = @_;

    # delete not secure characters
    $server =~ s/(\'|\"|\`|\)|\(|\[|\]|--)//g;
    $chan =~ s/(\'|\"|\`|\)|\(|\[|\]|--)//g;
    $nick =~ s/(\'|\"|\`|\)|\(|\[|\]|--)//g;
    $url =~ s/(\'|\"|\`|\)|\(|\[|\]|--)//g;

    # set date
    my $current_time =  strftime("%Y-%m-%d %H:%M:%S",localtime);

    # default recursive request
    my %request = ( 'chanid'   => "(SELECT id FROM chan WHERE chan='".$chan."')",
		    'serverid' => "(SELECT id FROM server WHERE server='".$server."')"
	);
    
    # 0: open sqlite database with foreign_keys=ON ! It's very
    #    important!
    my $dbh = DBI->connect("DBI:SQLite:dbname=link.log","","");
    my $dbi = $dbh->do('PRAGMA foreign_keys = ON');
    my $res;

    # 1: check if server exist with: 
    #       SELECT COUNT(*) FROM (SELECT server FROM server WHERE
    #       server='$server_name');
    #    if not exist (result != 1):
    #       INSERT INTO server VALUES (NULL, '$server_name');
    $dbi = $dbh->prepare("SELECT COUNT(*) FROM ".$request{'serverid'});
    $res = $dbi->execute();
    if ( $dbi->fetchrow_array < 1 ) {
	$dbi = $dbh->prepare("INSERT INTO server VALUES (NULL, '".$server."')");
	$dbi->execute();
    }
    
    # 2: check if chan exist with:
    #       SELECT COUNT(*) FROM (SELECT chan FROM chan WHERE 
    #       chan='$chan_name');
    #    if not exist (result != 1):
    #       INSERT INTO chan VALUES (NULL, '$chan_name', 
    #          (SELECT id FROM server WHERE server='$server_name'));
    $dbi = $dbh->prepare("SELECT COUNT(*) FROM ".$request{'chanid'});
    $res = $dbi->execute();
    if ( $dbi->fetchrow_array < 1 ) {
	$dbi = $dbh->prepare("INSERT INTO chan VALUES (NULL, '".$chan."',".$request{'serverid'}.")");
	$dbi->execute();
    }

    # 3: finaly insert link
    #       INSERT INTO link VALUES (NULL, '$current_date', '$nick', 
    #          '$url', (SELECT id FROM chan WHERE chan='$chan_name'),
    #           (SELECT id FROM server WHERE server='$server_name'));
    $dbi = $dbh->prepare("INSERT INTO link VALUES (NULL, '".$current_time."', '".
			                                    $nick."','".$url."',".
			                                    $request{'chanid'}.",".
			                                    $request{'serverid'}.")");
    $res = $dbi->execute();
}

sub generate_report () {}

Irssi::signal_add_first('message public', \&get_url);

