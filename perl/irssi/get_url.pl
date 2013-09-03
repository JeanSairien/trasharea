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
		store_url_sqlite_v2($server->{'address'}, $target, $nick, $parse);
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

sub store_url_log ($$$$) {
    my ($server, $chan, $nick, $url) = @_;
}

sub store_url_sqlite ($$$$) {
    my ($server, $chan, $nick, $url) = @_;

    # delete not secure characters
    $server =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g;
    $chan =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g; 
    $nick =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g;
    $url =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g;

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

sub store_url_sqlite_v2 ($$$$) {
    my ($server, $chan, $nick, $url) = @_;

    # delete not secure characters
    $server =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g;
    $chan =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g; 
    $nick =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g;
    $url =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g;
    my ($proto, $hostname, $path) = cut_url($url);

    # v0.2 - new function: parse link for path, hostname, and proto
    my @link = cut_url($url);
	
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
    #    if not exist (result<1):
    #       INSERT INTO server VALUES (NULL, '$server_name');
    $dbi = $dbh->prepare("SELECT COUNT(*) FROM server WHERE server='".$server."'");
    $dbi->execute();
    if ( $dbi->fetchrow_array < 1 ) {
	$dbi = $dbh->prepare("INSERT INTO server VALUES (NULL, '".$server."')");
	$dbi->execute();
    }

    # 2: check if chan exist on the server with:
    #       ...
    #    if not exist (result<1):
    #       ...
    $dbi = $dbh->prepare("SELECT COUNT(*) FROM chan 
                                          WHERE chan='".$chan."' 
                                          AND id_server=(SELECT id FROM server WHERE server='".$server."')");
    $dbi->execute();
    if ( $dbi->fetchrow_array < 1) {
	$dbi =$dbh->prepare("INSERT INTO chan VALUES (NULL, '".$chan."',
                          (SELECT id FROM server WHERE server='".$server."'))");
	$dbi->execute();
    }

    # 3: check if nick exist on the server and the chan with:
    #       ...
    #    if not exist (result<1):
    #      ...
    $dbi = $dbh->prepare("SELECT COUNT(*) FROM  nick
                                          WHERE nick='".$nick."' AND
                                                id_chan=(SELECT id   FROM chan   WHERE chan='".$chan."') AND
                                                id_server=(SELECT id FROM server WHERE server='".$server."')");
    $dbi->execute();
    if ($dbi->fetchrow_array < 1) {
	$dbi = $dbh->prepare("INSERT INTO nick VALUES (NULL,'".$nick."',
                                                (SELECT id FROM chan   WHERE chan='".$chan."'),
                                                (SELECT id FROM server WHERE server='".$server."'))");
	$dbi->execute();
    }

    # 4: check if proto exist in proto table
    $dbi = $dbh->prepare("SELECT COUNT(*) FROM proto
                                          WHERE proto='".$proto."'");
    $dbi->execute();
    if ($dbi->fetchrow_array<1) {
	$dbi=$dbh->prepare("INSERT INTO proto VALUES (NULL, '".$proto."')");
	$dbi->execute();
    }

    # 5: check if hostname exist in hostname table
    $dbi = $dbh->prepare("SELECT COUNT(*) FROM hostname WHERE hostname='".$hostname."'");
    $dbi->execute();
    if ($dbi->fetchrow_array<1) {
	$dbi=$dbh->prepare("INSERT INTO hostname VALUES (NULL, '".$hostname."')");
	$dbi->execute();
    }
    
    # 6: check if path exist in url table
    $dbi = $dbh->prepare("SELECT COUNT(*) FROM url WHERE path='$path';");
    $dbi->execute();
    if ($dbi->fetchrow_array<1) {
	$dbi=$dbh->prepare("INSERT INTO url VALUES (NULL,
                        (SELECT id FROM proto    WHERE proto='".$proto."'),
                        (SELECT id FROM hostname WHERE hostname='".$hostname."'),
                        '".$path."')");
	$dbi->execute();
    }

    # 7: finally add date into the link table! :)
    $dbi = $dbh->prepare("INSERT INTO link VALUES (NULL,
                         '".$current_time."',
                         (SELECT id FROM server   WHERE server='".$server."'),
                         (SELECT id FROM chan     WHERE chan='".$chan."'),
                         (SELECT id FROM nick     WHERE nick='".$nick."'),
                         (SELECT id FROM proto    WHERE proto='".$proto."'),
                         (SELECT id FROM hostname WHERE hostname='".$hostname."'),
                         (SELECT id FROM url      WHERE path='".$path."'))"); 
    $dbi->execute();
}

sub cut_url ($) {
    my @url;
    my $proto = my $hostname = my $path = $_[0];

    # 1: parsing proto by default http://.
    if ( $proto =~ /:\/{1,}.*/) {
        $proto =~ s/:\/{1,}.*/:\/\//;
    }
    else {
        $proto="http://";
    }

    # 2: parsing hostname.
    if ( $hostname =~ /(.*:\/\/|)/) {
	$hostname =~ s/$proto//;
	$hostname =~ s/\/.*$//;
    }

    # 3: parsing path.
    if (!($path =~ s/$proto// && 
	  $path =~ s/$hostname// && 
	  $path =~ /\S/)) {
	$path='NULL';
    }

    # 4: return @url array with $proto, 
    #    $hostname, and $path.
    @url = ($proto, $hostname, $path);
    return @url;
}

######################################################################
# sqlite_add functions                                               #
######################################################################
sub sqlite_add_server ($$) {
    my ($a_dbi, $a_server) = @_;
    my $a_request;
    my $db = DBI->connect($a_dbi,"","");
    my $db_conn = $db->do('PRAGMA foreign_keys = ON');
#    $db_conn = $db->prepare("SELECT COUNT(*) FROM  server
#                             WHERE server='".$a_server."'");
    return $db_conn;
}

sub sqlite_add_chan ($$$) {
    my ($a_dbi, $a_server, $a_chan) = @_;
    my $a_request;
    my $db = DBI->connect($a_dbi,"","");
    my $db_conn = $db->do('PRAGMA foreign_keys = ON');
#    $db_conn = $db->prepare("SELECT COUNT(*) FROM chan
#           WHERE chan='".$a_chan."' AND
#           id_server=(SELECT id FROM server WHERE server='".$a_server."')");
    return $db_conn;
}

sub sqlite_add_nick ($$$$) {
    my ($a_dbi, $a_server, $a_chan, $a_nick) = @_;
    my $a_request;
    my $db = DBI->connect($a_dbi,"","");
    my $db_conn = $db->do('PRAGMA foreign_keys = ON');
    return 1;
}
sub sqlite_add_proto ($$) {
    my ($a_dbi, $a_proto) = @_;
    my $a_request;
    my $db = DBI->connect($a_dbi,"","");
    my $db_conn = $db->do('PRAGMA foreign_keys = ON');
    return 1;
}
sub sqlite_add_hostname ($$) {
    my ($a_dbi, $a_hostname) = @_;
    my $a_request;
    return 1;
}
sub sqlite_add_url ($$$$) {
    my ($a_dbi, $a_proto, $a_hostname, $a_path) = @_;
    my $a_request;
    return 1;
}
sub sqlite_add_link ($$$$$$$) {
    my ($a_dbi, $a_server, $a_chan, $a_nick, 
	$a_proto, $a_hostname, $a_path) = @_;
    my $a_request;
    return 1;
}

######################################################################
# sqlite_check functions                                             #
######################################################################
sub sqlite_check_server ($$) {
    my ($c_dbi, $c_server) = @_;
    my $c_request;
    return 1;
}
sub sqlite_check_chan ($$) {
    my ($c_server, $c_chan) = @_;
    my $c_request;
    return 1;
}
sub sqlite_check_nick ($$$) {
    my ($c_server, $c_chan, $c_nick) = @_;
    my $c_request;
    return 1;
}
sub sqlite_check_proto ($) {
    my $c_proto = @_;
    my $c_request;
    return 1;
}
sub sqlite_check_hostname ($) {
    my $c_hostname = @_;
    my $c_request;
    return 1;
}

######################################################################
# report functions                                                   #
######################################################################
sub html_html ($) {}
sub html_header ($) {}
sub html_body ($) {}
sub html_table ($) {}
sub html_tr ($) {}
sub html_td ($) {}
sub html_a ($) {}

sub generate_report_html () {
    # 1: configure report date
    print "Work in progress... \n";
}

sub generate_report_text () {
    print "Work in progress...\n";
}

Irssi::signal_add_first('message public', \&get_url);

