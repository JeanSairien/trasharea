#! /bin/sh
######################################################################
# very small script for remote control access. 
#
# Copyright (c) 2013, Niamkik
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met: * Redistributions of source code must
# retain the above copyright notice, this list of conditions and
# the following disclaimer.  * Redistributions in binary form
# must reproduce the above copyright notice, this list of
# conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.  *
# Neither the name of the <organization> nor the names of its
# contributors may be used to endorse or promote products derived
# from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,                                                                                
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY                                                                                
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
# OF SUCH DAMAGE.
######################################################################

TARGET_HOST=""
TARGET_PORT=""
TARGET_USER=""
TARGET_PKEY=""
SSH_FORWARD="-R 12345:localhost:22"
SSH_OPTIONS="-i $TARGET_PKEY -p $TARGET_PORT -C -N $SSH_FORWARD"
SSH_LAUNCH="ssh $TARGET_USER@$TARGET_HOST $SSH_OPTIONS"

print () {
    printf "$*\n"
}

check_icmp () {
    ping -c 1 "$1" 2>&1 > /dev/null
}

check_tcp () {
    nc -z -p "$2" "$1" 2>&1 > /dev/null
}

ssh_thief () {
    if ! pgrep -f "$SSH_LAUNCH" 2>&1 > /dev/null
    then
        $SSH_LAUNCH &
    fi
}

if (check_icmp 8.8.8.8) || \
   (check_tcp $TARGET_HOST $TARGET_PORT)
then
   ssh_thief
fi

