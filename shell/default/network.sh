#! /usr/bin/env sh
######################################################################
#                                                                    #
# Copyright (c) 2013, Niamkik <niamkik@gmail.com>                    #
# All rights reserved.                                               #
#                                                                    #
# Redistribution and use in source and binary forms, with or without #
# modification, are permitted provided that the following conditions #
# are met:                                                           #
#                                                                    #
# 1. Redistributions of source code must retain the above copyright  #
#    notice, this list of conditions and the following disclaimer.   #
#                                                                    #
# 2. Redistributions in binary form must reproduce the above         #
#    copyright notice, this list of conditions and the following     #
#    disclaimer in the documentation and/or other materials provided #
#    with the distribution.                                          #
#                                                                    #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND             #
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,        #
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF           #
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE           #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS  #
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,           #
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    #
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,      #
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION)HOWEVER CAUSED AND ON   #
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR #
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF #
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF    #
# SUCH DAMAGE.                                                       #
#                                                                    #
######################################################################

######################################################################
# ethernet function                                                  #
######################################################################

ethernet_random () {
    print "work in progress..."
    return 1
}

######################################################################
# ipv4 function                                                      #
######################################################################

ipv4_random () {
    print "work in progress..."
    return 1

    FIELD_ONE="" # 0..255
    FIELD_TWO="" # 0..255
    FIELD_THR="" # 0..255
    FIELD_FOU="" # 0..255

    print "${FIELD_ONE}.${FIELD_TWO}.${FIELD_THR}.${FIELD_FOU}"
}

######################################################################
# ipv6 function                                                      #
######################################################################

ipv6_random () {
    print "work in progress..."
    return 1
}

######################################################################
# port function                                                      #
######################################################################

port_random () {
    print "work in progress"
    return 1
}

port_random_admin () {
    print "work in progress"
    return 1
}

port_random_range () {
    print "work in progress"
    return 1
}