-- schema.sql sqlite database structure for get_link.pl script
-- 
-- Copyright (c) 2013, Niamkik
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or
-- without modification, are permitted provided that the following
-- conditions are met: * Redistributions of source code must
-- retain the above copyright notice, this list of conditions and
-- the following disclaimer.  * Redistributions in binary form
-- must reproduce the above copyright notice, this list of
-- conditions and the following disclaimer in the documentation
-- and/or other materials provided with the distribution.  *
-- Neither the name of the <organization> nor the names of its
-- contributors may be used to endorse or promote products derived
-- from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
-- CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
-- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR
-- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
-- OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
-- THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
-- TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
-- OF SUCH DAMAGE.
--
-- You can use some INSERT and DELETE to test sqlite schema at the
-- end of this file.
--
-- If get_url.pl script doesn't work for initialize database, you
-- can use this command:
--
--    cat schema.sql | $(which sqlite || which sqlite3 2> /dev/null)\
--                     ~/.irssi/link.log

-- please set foreign_keys to ON!
PRAGMA foreign_keys = ON;

-- init table, drop all data
DROP TABLE IF EXISTS link;
DROP TABLE IF EXISTS url;
DROP TABLE IF EXISTS proto;
DROP TABLE IF EXISTS hostname;
DROP TABLE IF EXISTS nick;
DROP TABLE IF EXISTS chan;
DROP TABLE IF EXISTS server;

-- create table server (contain all server name)
-- info: need check string size (server<128char)
CREATE TABLE server ( id     INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                      server TEXT    UNIQUE NOT NULL
);

-- create table chan (contain chan and server)
-- info: need check string size (chan<64char)
CREATE TABLE chan   ( id          INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                      chan        TEXT NOT NULL,
                      id_server   INTEGER NOT NULL,
                      FOREIGN KEY (id_server) REFERENCES server(id)
);

-- create table link
-- info: no check needed
CREATE TABLE link   ( id          INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                      date        CURRENT_TIMESTAMP,     
                      id_server   INTEGER NOT NULL,
                      id_chan     INTEGER NOT NULL,
                      id_nick     INTEGER NOT NULL,
		      id_proto	  INTEGER NOT NULL,
		      id_hostname INTEGER NOT NULL,
		      id_url	  INTEGER NOT NULL,
		      FOREIGN KEY (id_url)      REFERENCES url(id),
		      FOREIGN KEY (id_hostname) REFERENCES hostname(id),
		      FOREIGN KEY (id_proto)    REFERENCES proto(id),  
		      FOREIGN KEY (id_nick)     REFERENCES nick(id),
		      FOREIGN KEY (id_chan)     REFERENCES chan(id),
		      FOREIGN KEY (id_server)   REFERENCES server(id)
);

-- v0.2 - new table nick
-- info: need check string size (nick<64char)
CREATE TABLE nick   ( id          INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                      nick        TEXT    NOT NULL,
		      id_chan     INTEGER NOT NULL,
		      id_server	  INTEGER NOT NULL,
		      FOREIGN KEY (id_chan)   REFERENCES chan(id),
		      FOREIGN KEY (id_server) REFERENCES server(id)
);

-- v0.2 - new table url
-- info: need check string size (path<1024char)
CREATE TABLE url   ( id          INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
       	             id_proto    INTEGER,
		     id_hostname INTEGER,
		     path        TEXT,
		     FOREIGN KEY (id_proto)    REFERENCES proto(id),
		     FOREIGN KEY (id_hostname) REFERENCES hostname(id)
);

-- 0.2 - new table hostname
-- info: need check string size (hostname<2048char)
CREATE TABLE hostname ( id       INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                        hostname TEXT    UNIQUE
);

-- v0.2 - new table proto
-- info: need check string size (proto<12char)
CREATE TABLE proto ( id    INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                     proto TEXT    UNIQUE
);

-- v0.2 - All first line in some table is for unknown value
INSERT INTO server   VALUES (NULL, 'unknown');
INSERT INTO chan     VALUES (NULL, 'unknown', 1);
INSERT INTO nick     VALUES (NULL, 'unknown', 1, 1);
INSERT INTO proto    VALUES (NULL, 'unknown');
INSERT INTO hostname VALUES (NULL, 'unknown');
INSERT INTO url      VALUES (NULL, 1, 1, 'unknown');

-- v0.2 - You can initialize some proto and don't add
--        proto dynamically.
INSERT INTO proto VALUES (NULL, 'http://');
INSERT INTO proto VALUES (NULL, 'https://');
INSERT INTO proto VALUES (NULL, 'ftp://');
INSERT INTO proto VALUES (NULL, 'ftps://');
INSERT INTO proto VALUES (NULL, 'ssh://');
INSERT INTO proto VALUES (NULL, 'sftp://');
INSERT INTO proto VALUES (NULL, 'gopher://');
INSERT INTO proto VALUES (NULL, 'ldap://');
INSERT INTO proto VALUES (NULL, 'xmpp://');
INSERT INTO proto VALUES (NULL, 'git://');

-- v0.2 - new test:
-- 
--    1. This is normal behavior of the script. In theory,
--       this schema is easy to understand, but, some comment
--       help you. ;)
--       $server=test.net, $chan=#test, $nick=testtest,
--       $url=https://new.thisisatest.net/path/to/page,
-- 	 $proto=https://, $hostname=new.thisisatest.net,
--	 $path=/path/to/page

-- #1 Check if $server exist (return >1), if not, add it.
--       $dbi->prepare($CHECK_SERVER)
--    Before insert $server, please saninitize string
--    and delete special char (<,>,',",(,),[,]).
SELECT 'Next values should be 0:';
SELECT COUNT(*) FROM  server 
       		WHERE server='$server';
INSERT INTO server VALUES (NULL, '$server');

-- #2 check if $chan exist (return >1), if not, add it.
--       $dbi->prepare($CHECK_CHAN)
--    Before insert $chan, please saninitize string
--    and delete special char (<,>,',",(,),[,]).
SELECT 'Next values should be 0:';
SELECT COUNT(*) FROM chan 
       		WHERE chan='$chan' AND 
       		      id_server=(SELECT id FROM server WHERE server='$server');
INSERT INTO chan VALUES (NULL, 
       	    	 	 '$chan', 
			  (SELECT id FROM server WHERE server='$server'));

-- #3 check if nick exist (return >1), if not, add it.
--       dbi->prepare($CHECK_NICK)
--    Before insert $nick, please saninitize string
--    and delete special char (<,>,',",(,),[,]).
SELECT 'Next values should be 0:';
SELECT COUNT(*) FROM  nick 
WHERE nick='$nick' AND
id_chan=(SELECT id   FROM chan   WHERE chan='$chan') AND
id_server=(SELECT id FROM server WHERE server='$server');
INSERT INTO nick VALUES (NULL, 
'$nick', 
(SELECT id FROM chan   WHERE chan='$chan'),
(SELECT id FROM server WHERE server='$server'));

-- #4 check if $proto exist (return >1), if not, add it.
--       dbi->prepare($CHECK_PROTO)
--    Before insert $proto, please saninitize string
--    and delete special char (<,>,',",(,),[,]).
SELECT 'Next values should be 0:';
SELECT COUNT(*) FROM proto 
WHERE proto='$proto';
INSERT INTO proto VALUES (NULL, '$proto');

-- #5 check if $hostname exist (return >1), if not add it.
--       dbi->prepare($CHECK_HOSTNAME)
--    Before insert $hostname, please saninitize string
--    and delete special char (<,>,',",(,),[,]).
SELECT 'Next values should be 0:';
SELECT COUNT(*) FROM hostname 
WHERE hostname='$hostname';
INSERT INTO hostname VALUES (NULL, '$hostname');

-- #6 check if $path exist ( return >1), if not, add it.
--       dbi->prepare($CHECK_PATH)
--    Before insert $path, please saninitize string
--    and delete special char (<,>,',",(,),[,]). If $path
--    contain special char... It's your problem! :P
SELECT 'Next values should be 0:';
SELECT COUNT(*) FROM url 
       		WHERE path='$path';
INSERT INTO url	VALUES (NULL, 
       	    	     	(SELECT id FROM proto    WHERE proto='$proto'),
			(SELECT id FROM hostname WHERE hostname='$hostname'),
			'$path');

-- #7 finaly, add $date into link with all info.
--       dbi->prepare($INSERT_LINK)
INSERT INTO link VALUES (NULL, 
       	    	  	 '$date',
			 (SELECT id FROM server   WHERE server='$server'),
			 (SELECT id FROM chan     WHERE chan='$chan'),
			 (SELECT id FROM nick     WHERE nick='$nick'),
			 (SELECT id FROM proto    WHERE proto='$proto'),
			 (SELECT id FROM hostname WHERE hostname='$hostname'),
			 (SELECT id FROM url      WHERE path='$path'));

-- #8 if you want all information you need use NATURAL JOIN:
.mode html
SELECT date,server,chan,nick,proto,hostname,path
       FROM server,chan,nick,proto,hostname,url,link 
       WHERE server.id=link.id_server     AND 
       	     chan.id=link.id_chan     	  AND
      	     nick.id=link.id_nick     	  AND
      	     proto.id=link.id_proto       AND
      	     hostname.id=link.id_hostname AND
      	     url.id=link.id_url;

-- #9 clean last test
DELETE FROM link     WHERE date='$date';
DELETE FROM url      WHERE path='$path';
DELETE FROM hostname WHERE hostname='$hostname';
DELETE FROM proto    WHERE proto='$proto';
DELETE FROM nick     WHERE nick='$nick';
DELETE FROM chan     WHERE chan='$chan';
DELETE FROM server   WHERE server='$server';
