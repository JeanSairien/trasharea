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
#
# -> define protocol:
#    ^[a-zA-Z]{2,32}://$
# 
# -> define hostname:
#    ^(([[:print:]]{1,256}\.[a-zA-Z]{2,16})     # hostname
#    |[[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}    # ip4 address
#    |[[:xdigit:]]{0,4}\:){1,8}[[:xdigit:]]{0,4}$ # ip6 address
#
# -> define url:
#    ^.*{1,1024}$
######################################################################

use strict;
use warnings;
use POSIX qw(strftime);

use Irssi;
use Irssi::Irc;

use DBI;

# Original version by shabble:
# https://github.com/shabble/irssi-scripts
#         /blob/master/url_hilight/url_hilight.pl

our $VERSION = '1.01';
our %IRSSI = (
      authors     => 'Niamkik',
      contact     => 'niamkik@gmail.com',
      name        => 'link filter',
      description => 'link filter',
      license     => 'FreeBSD',
    );

my %global_variables = (
    mode      => 'sqlite',
    scheme    => 'v2',
    log       => $ENV{'HOME'}.'/.irssi/link.log',
    report    => 'html',
    schema    => $ENV{'HOME'}.'/.irssi/scripts/schema.sql',
    time_ret  => 90, # value in day
    debug     => 1
);

# regex taken from http://daringfireball.net/2010/07/improved_regex_for_matching_urls
# rewriting this regex (one-line is bad)
my $url_regex = qr{(?i)\b
                   (
                    (?:[a-z][\w-]+:
                     (?:/{1,3}|[a-z0-9%])
                     |www\d{0,3}[.]
                     |[a-z0-9.\-]+[.][a-z]{2,4}/
                    )
                    (?:[^\s()<>]+|\(
                     ([^\s()<>]+|
                     (\([^\s()<>]+\)))*\)
                    )+
                    (?:\(
                     ([^\s()<>]+|
                      (\([^\s()<>]+\))
                     )*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]
                    )
                   )}x;

######################################################################
# functions scripts                                                  #
######################################################################
sub get_url {
    # split message output
    my ($server, $msg, $nick, $nick_addr, $target) = chomp(@_);

    # check if message match valid URL (via $url_regex)
    # parse it:
    if ( $msg =~ $url_regex ) {
        # split message with null characters
        my @buf = split(/\s/, $msg);

        # second check. If one 'word' ~= URL, just add it
        # into sqlite database via store_url_sqlite_v2.
        foreach my $parse (@buf) {
            if ( $parse =~ $url_regex ) {
		if (($global_variables{"mode"}=~/sqlite/) &&
		    ($global_variables{"scheme"}=~/v2/)) {
		    store_url_sqlite_v2($server->{'address'}, 
					$target,
					$nick,
					$parse);
		}
		if ($global_variables{"debug"}>0) {
		    my $mes = $server->{'address'}." ".
			      $target." ".
			      $nick." ".
			      $parse;
		    print $mes;
		}
            }
        }
    }
}

sub init_database () {
    if ( -f $global_variables{'schema'}) {
	system("\$(which sqlite3)".$global_variables{'log'}.
	       " < ".$global_variables{'schema'});
    }
    else {
	print "Where is ".$global_variables{'schema'}
	." file?\n"
    }
}

sub store_url_sqlite_v2 ($$$$) {
    my ($server, $chan, $nick, $url) = chomp(@_);

    # delete not secure characters
    $server =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g;
    $chan   =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g; 
    $nick   =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g;
    $url    =~ s/(\'|\"|\`|\)|\(|\[|\]|--|\<|\>)//g;
    my ($proto, $hostname, $path) = cut_url($url);

    # v0.2 - new function: parse link for path, hostname, and proto
    my @link = cut_url($url);

    # 0: open sqlite database with foreign_keys=ON ! It's very
    #    important!
    my $db_str = "DBI:SQLite:dbname=".$global_variables{'log'};
    my $dbh = DBI->connect($db_str,"","");
    my $dbi = $dbh->do('PRAGMA foreign_keys = ON');

    # 1: check if server exist
    if (sqlite_check_server($db_str, $server)<1) {
	sqlite_add_server($db_str, $server);
    }

    # 2: check if chan exist on the server with:
    if (sqlite_check_chan($db_str, $chan)<1) {
	sqlite_add_chan($db_str, $chan);
    }

    # 3: check if nick exist on the server and the chan with:
    if (sqlite_check_nick($db_str, $nick)<1) {
	sqlite_add_nick($db_str, $nick);
    }

    # 4: check if proto exist in proto table
    if (sqlite_check_proto($db_str, $proto)<1) {
	sqlite_add_proto($db_str, $proto);
    }

    # 5: check if hostname exist in hostname table
    if (sqlite_check_hostname($db_str, $hostname)<1) {
	sqlite_add_hostname($db_str, $hostname);
    }
    
    # 6: check if path exist in url table
    if (sqlite_check_path($db_str, $path)<1) {
	sqlite_add_path($db_str, $proto, $hostname, $path);
    }

    # 7: finally add date into the link table! :)
    sqlite_add_link($db_str, $server, $chan, $nick,
		    $proto, $hostname, $path);

    #8: adding purge function ;)
    if ($global_variables{"time_ret"}>1) {
	purge_link_sqlite_v2($db_str);
    }
}

sub purge_link_sqlite_v2 ($) {
    my $a_dbi = shift;
    
    my $purge_time=strftime("%Y-%m-%d", 
			    localtime(time-($global_variables{"time_ret"}*86400)));
    
    # small check with pseudo-random value
    if ((int(rand(102))%101)==0) {

	if ($global_variables{"debug"}>0) {	
	    print "purge link before $purge_time";
	}

	my $a_request = "DELETE FROM link
                             WHERE date<date('".$purge_time."')";
	
	my $db = DBI->connect($a_dbi,"","");
	
	my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	    or die "purge link pragma error.\n";
	
	$db_conn = $db->prepare($a_request)
	    or die "purge link prepare request error.\n";
	
	$db_conn->execute()
	    or die "purge link execute error.\n";
    }
}

sub cut_url ($) {
    my @url;
    my $proto = my $hostname = my $path = chomp($_[0]);

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

    # 4: return @url array with $proto, $hostname, and $path.
    @url = ($proto, $hostname, $path);
    return @url;
}

######################################################################
# sqlite_add functions                                               #
######################################################################
sub sqlite_add_server ($$) {
    my ($a_dbi, $a_server) = chomp(@_);

    # delete dangerous characters
    $a_server =~ s/(\'|\"|\`|\)|\()//g;

    my $a_request = "INSERT INTO server
                     VALUES (NULL,'".$a_server."')";

    my $db = DBI->connect($a_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	or die "add server pragma error.\n";

    $db_conn = $db->prepare($a_request)
	or die "add server prepare request error.\n";

    $db_conn->execute()
	or die "add server execute error.\n";
}

sub sqlite_add_chan ($$) {
    my ($a_dbi, $a_chan) = chomp(@_);

    $a_chan   =~ s/(\'|\"|\`|\)|\()//g;

    my $a_request = "INSERT INTO chan 
                     VALUES (NULL, 
                             '".$a_chan."')";

    my $db = DBI->connect($a_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	or die "add chan pragma error.\n";

    $db_conn = $db->prepare($a_request)
	or die "add chan prepare request error.\n";

    $db_conn->execute()
	or die "add chan execute error.\n";

}

sub sqlite_add_nick ($$) {
    my ($a_dbi, $a_nick) = chomp(@_);

    $a_nick   =~ s/(\'|\"|\`|\)|\()//g;

    my $a_request = "INSERT INTO nick 
                     VALUES (NULL,'".$a_nick."')";

    my $db = DBI->connect($a_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	or die "add nick pragma error.\n";

    $db_conn = $db->prepare($a_request)
	or die "add nick prepare request error.\n";

    $db_conn->execute()
	or die "add nick execute error.\n";
}

sub sqlite_add_proto ($$) {
    my ($a_dbi, $a_proto) = chomp(@_);
    $a_proto =~ s/(\'|\"|\`|\)|\()//g;

    my $a_request = "INSERT INTO proto
                     VALUES (NULL, '".$a_proto."')";

    my $db = DBI->connect($a_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	or die "add proto pragma error.\n";

    $db_conn = $db->prepare($a_request)
	or die "add proto prepare request error.\n";

    $db_conn->execute()
	or die "add proto execute error.\n";
}

sub sqlite_add_hostname ($$) {
    my ($a_dbi, $a_hostname) = chomp(@_);

    $a_hostname =~ s/(\'|\"|\`|\)|\()//g;

    my $a_request = "INSERT INTO hostname 
                     VALUES (NULL, '".$a_hostname."')";

    my $db = DBI->connect($a_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	or die "add hostname pragma error.\n";

    $db_conn = $db->prepare($a_request)
	or die "add hostname prepare request error.\n";

    $db_conn->execute()
	or die "add hostname execute error.\n";
}

sub sqlite_add_url ($$$$) {
    my ($a_dbi, $a_proto, $a_hostname, $a_path) = chomp(@_);

    $a_proto    =~ s/(\'|\"|\`|\)|\()//g;
    $a_hostname =~ s/(\'|\"|\`|\)|\()//g;
    $a_path     =~ s/(\'|\"|\`|\)|\()//g;

    my $a_request = "INSERT INTO url 
                     VALUES (NULL,
                             (SELECT id 
                              FROM proto 
                              WHERE proto='".$a_proto."'),
                             (SELECT id 
                              FROM hostname 
                              WHERE hostname='".$a_hostname."'),
                             '".$a_path."')";

    my $db = DBI->connect($a_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	or die "add url pragma error.\n";

    $db_conn = $db->prepare($a_request)
	or die "add url prepare request error.\n";

    $db_conn->execute()
	or die "add url execute error.\n";
}

sub sqlite_add_path ($$$$) {
    my ($a_dbi, $a_proto, $a_hostname, $a_path) = chomp(@_);

    $a_proto    =~ s/(\'|\"|\`|\)|\()//g;
    $a_hostname =~ s/(\'|\"|\`|\)|\()//g;
    $a_path     =~ s/(\'|\"|\`|\)|\()//g;

    my $a_request = "INSERT INTO url
                     VALUES (NULL, 
       	    	     	     (SELECT id 
                              FROM proto
                              WHERE proto='".$a_proto."'),
			     (SELECT id 
                              FROM hostname 
                              WHERE hostname='".$a_hostname."'),
			     '".$a_path."')";

    my $db = DBI->connect($a_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	or die "add path pragma error.\n";

    $db_conn = $db->prepare($a_request)
	or die "add path prepare request error.\n";

    $db_conn->execute()
	or die "add path execute error.\n";
}

sub sqlite_add_link ($$$$$$$) {
    my ($a_dbi, $a_server, $a_chan, $a_nick, 
	$a_proto, $a_hostname, $a_path) = chomp(@_);

    # set date
    my $current_time = strftime("%Y-%m-%d %H:%M:%S",localtime);

    $a_server   =~ s/(\'|\"|\`|\)|\()//g;
    $a_chan     =~ s/(\'|\"|\`|\)|\()//g;
    $a_nick     =~ s/(\'|\"|\`|\)|\()//g;
    $a_proto    =~ s/(\'|\"|\`|\)|\()//g;
    $a_hostname =~ s/(\'|\"|\`|\)|\()//g;
    $a_path     =~ s/(\'|\"|\`|\)|\()//g;

    my $a_request = "INSERT INTO link 
                     VALUES (NULL,
                             '".$current_time."',
                             (SELECT id 
                              FROM server
                              WHERE server='".$a_server."'),
                             (SELECT id 
                              FROM chan
                              WHERE chan='".$a_chan."'),
                             (SELECT id 
                              FROM nick 
                              WHERE nick='".$a_nick."'),
                             (SELECT id 
                              FROM proto 
                              WHERE proto='".$a_proto."'),
                             (SELECT id 
                              FROM hostname 
                              WHERE hostname='".$a_hostname."'),
                             (SELECT id 
                              FROM url 
                              WHERE path='".$a_path."'))";

    my $db = DBI->connect($a_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	or die "add link pragma error.\n";

    $db_conn = $db->prepare($a_request)
	or die "add link prepare request error.\n";

    $db_conn->execute()
	or die "add link execute error.\n";
}

######################################################################
# sqlite_check functions                                             #
######################################################################
sub sqlite_check_server ($$) {
    my ($c_dbi, $c_server) = chomp(@_);
    $c_server =~ s/(\'|\"|\`|\)|\()//g;

    my $c_request = "SELECT COUNT(*) 
                     FROM server 
                     WHERE server='".$c_server."'";
    my $db = DBI->connect($c_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON') 
	or die "check server pragma error.\n";

    $db_conn = $db->prepare($c_request)
	or die "check server prepare request error.\n";

    $db_conn->execute()
	or die "check server execute error.\n";

    return $db_conn->fetchrow_array;
}

sub sqlite_check_chan ($$) {
    my ($c_dbi, $c_chan) = chomp(@_);

    $c_chan   =~ s/(\'|\"|\`|\)|\()//g;

    my $c_request = "SELECT COUNT(*) 
                     FROM chan 
       		     WHERE chan='".$c_chan."'";

    my $db = DBI->connect($c_dbi,"","");
    my $db_conn = $db->do('PRAGMA foreign_keys = ON')
	or die "check chan pragma error.\n";

    $db_conn = $db->prepare($c_request)
	or die "check chan prepare request error.\n";

    $db_conn->execute()
	or die "check chan execute error.\n";

    return $db_conn->fetchrow_array;
}

sub sqlite_check_nick ($$) {
    my ($c_dbi, $c_nick) = chomp(@_);

    $c_nick   =~ s/(\'|\"|\`|\)|\()//g;

    my $c_request = "SELECT COUNT(*) 
                     FROM nick 
                     WHERE nick='".$c_nick."'";

    my $db = DBI->connect($c_dbi,"","");
    my $db_conn = $db->do('PRAGMA foreign_keys = ON')
	or die "check nick pragma error.\n";

    $db_conn = $db->prepare($c_request)
	or die "check nick prepare request error.\n";

    $db_conn->execute()
	or die "check nick execute error.\n";

    return $db_conn->fetchrow_array;
}

sub sqlite_check_proto ($$) {
    my ($c_dbi, $c_proto) = chomp(@_);

    $c_proto =~ s/(\'|\"|\`|\)|\()//g;

    my $c_request = "SELECT COUNT(*) 
                     FROM proto
                     WHERE proto='".$c_proto."'";

    my $db = DBI->connect($c_dbi,"","");
    my $db_conn = $db->do('PRAGMA foreign_keys = ON')
	or die "check proto pragma error.\n";

    $db_conn = $db->prepare($c_request)
	or die "check proto prepare request error.\n";

    $db_conn->execute()
	or die "check proto execute error.\n";

    return $db_conn->fetchrow_array;
}

sub sqlite_check_hostname ($$) {
    my ($c_dbi, $c_hostname) = chomp(@_);

    $c_hostname =~ s/(\'|\"|\`|\)|\()//g;

    my $c_request = "SELECT COUNT(*) 
                      FROM hostname
                      WHERE hostname='".$c_hostname."'";
    my $db = DBI->connect($c_dbi,"","");
    my $db_conn = $db->do('PRAGMA foreign_keys = ON')
	or die "check hostname pragma error.\n";

    $db_conn = $db->prepare($c_request)
	or die "check hostname prepare request error.\n";

    $db_conn->execute()
	or die "check hostname execute error.\n";

    return $db_conn->fetchrow_array;
}

sub sqlite_check_path ($$) {
    my ($c_dbi, $c_path) = chomp(@_);

    $c_path =~ s/(\'|\"|\`)//g;

    my $c_request = "SELECT COUNT(*) 
                      FROM url
                      WHERE path='".$c_path."'";
    my $db = DBI->connect($c_dbi,"","");
    my $db_conn = $db->do('PRAGMA foreign_keys = ON')
	or die "check path pragma error.\n";

    $db_conn = $db->prepare($c_request)
	or die "check path prepare request error.\n";

    $db_conn->execute()
	or die "check path execute error.\n";

    return $db_conn->fetchrow_array;
}

######################################################################
# sqlite_get functions                                               #
######################################################################
sub sqlite_get_server () {
    my $g_dbi = @_;
    my $g_request = "SELECT server FROM server";

    my $db = DBI->connect($g_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON')
	or die "get server pragma error.\n";

    $db_conn = $db->prepare($g_request)
	or die "get server prepare request error.\n";

    $db_conn->execute()
	or die "get server execute error.\n";

    return 1;
}

sub sqlite_get_chan () {}
sub sqlite_get_nick () {}
sub sqlite_get_proto () {}
sub sqlite_get_hostname () {}
sub sqlite_get_path () {}

sub sqlite_get_url ($) {
    my $g_dbi = chomp(@_);
    my $g_request  = "SELECT date,server,chan,nick,proto,hostname,path
                      FROM server,chan,nick,proto,hostname,url,link
                      WHERE server.id=link.id_server     AND
                            chan.id=link.id_chan         AND
                            nick.id=link.id_nick         AND
                            proto.id=link.id_proto       AND
                            hostname.id=link.id_hostname AND
                            url.id=link.id_url";

    my $db = DBI->connect($g_dbi,"","");

    my $db_conn = $db->do('PRAGMA foreign_keys = ON')
	or die "get url pragma error.\n";

    $db_conn = $db->prepare($g_request)
	or die "get url prepare request error.\n";

    $db_conn->execute()
	or die "get url execute error.\n";

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
