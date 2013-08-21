#! /usr/bin/python

import os
from fabric import *

class Server():
    """ 
    Add/Remove server
    """
    
    def __init__(self):
        self.configuration_file=""
        self.listing=[]

    def parse_file(self,configuration_file):
        """ Parse configuration and store result in 
            listing. Set all server with 
                dict: id, name, host, protocol, port 
        """
        if not os.path.exists(self.configuration_file):
            print 'Configuration file doesnt exist.'
        else:
            file = open(self.configuration_file, mode="r")
            for line in file:
                count=0
                t_server, t_host, t_proto, t_port = line.split(':')
                if ((t_server or t_host) == None):
                    print "Split error"
                else:
                    if not t_proto:
                        t_proto="ssh"
                    
                    if not t_port:
                        t_proto="22"
                        
                    t_buffer = { 'id': count,
                                 'name': t_server, 
                                 'host': t_host, 
                                 'protocol': t_proto,
                                 'port': t_port }
                    self.listing.append(t_buffer)
                count += 1

    def insert(self, id):
        return 1
    
    def delete(self, id):
        return 1
        
    def view(self, id):
        return 1
        
    def search(self, id):
        return 1

inst = Server()
inst.listing