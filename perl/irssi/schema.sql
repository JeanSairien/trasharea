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

-- please set foreign_keys to ON!
PRAGMA foreign_keys = ON;

-- init table, drop all data
DROP TABLE IF EXISTS link;
DROP TABLE IF EXISTS chan;
DROP TABLE IF EXISTS server;

-- create table server (contain all server name)
CREATE TABLE server ( id     INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                      server TEXT UNIQUE NOT NULL
);

-- create table chan (contain chan and server)
CREATE TABLE chan   ( id          INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                      chan        TEXT UNIQUE,
                      id_server   INTEGER UNIQUE NOT NULL,
                      FOREIGN KEY (id_server) REFERENCES server(id)
);

-- create table link (nickname, url and date)
CREATE TABLE link   ( id          INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                      date        CURRENT_TIMESTAMP,
                      nick        TEXT,
                      url         TEXT,
                      id_chan     INTEGER NOT NULL,
                      id_server   INTEGER NOT NULL,
		      FOREIGN KEY (id_chan) REFERENCES chan(id),
		      FOREIGN KEY (id_server) REFERENCES server(id)
);

-- #1 insert default test
INSERT INTO server VALUES ( NULL, 'test');
INSERT INTO chan   VALUES ( NULL, '#test', 1);
INSERT INTO link   VALUES ( NULL, NULL, 'test', 'test', 1, 1);
INSERT INTO link   VALUES ( NULL, NULL, 'test2', 'test2',
			    (select id from chan   where chan='#test'), 
			    (select id from server where server='test'));

-- #2 insert some server
INSERT INTO server VALUES ( NULL, 'test1');
INSERT INTO server VALUES ( NULL, 'test2');
INSERT INTO server VALUES ( NULL, 'test3');
INSERT INTO server VALUES ( NULL, 'test4');
INSERT INTO server VALUES ( NULL, 'test5');
INSERT INTO server VALUES ( NULL, 'test6');
INSERT INTO server VALUES ( NULL, 'test7');
INSERT INTO server VALUES ( NULL, 'test8');
INSERT INTO server VALUES ( NULL, 'test9');
INSERT INTO server VALUES ( NULL, 'test10');
INSERT INTO server VALUES ( NULL, 'test11');
INSERT INTO server VALUES ( NULL, 'test12');
INSERT INTO server VALUES ( NULL, 'test13');
INSERT INTO server VALUES ( NULL, 'test14');
INSERT INTO server VALUES ( NULL, 'test15');

-- #3 insert some chan 
INSERT INTO chan VALUES ( NULL, '#test1', 1);
INSERT INTO chan VALUES ( NULL, '#test2', 2);
INSERT INTO chan VALUES ( NULL, '#test3', 3);
INSERT INTO chan VALUES ( NULL, '#test4', 4);
INSERT INTO chan VALUES ( NULL, '#test5', 5);
INSERT INTO chan VALUES ( NULL, '#test6', 6);
INSERT INTO chan VALUES ( NULL, '#test7', 7);
INSERT INTO chan VALUES ( NULL, '#test8', 8);
INSERT INTO chan VALUES ( NULL, '#test9', 9);
INSERT INTO chan VALUES ( NULL, '#test10', 10);
INSERT INTO chan VALUES ( NULL, '#test11', 11);
INSERT INTO chan VALUES ( NULL, '#test12', 12);
INSERT INTO chan VALUES ( NULL, '#test13', 13);
INSERT INTO chan VALUES ( NULL, '#test14', 14);
INSERT INTO chan VALUES ( NULL, '#test15', 15);

-- ## remote default test
DELETE FROM link   WHERE (SELECT id FROM link);
DELETE FROM chan   WHERE (SELECT id FROM chan);
DELETE FROM server WHERE (SELECT id FROM server);
