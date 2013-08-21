#! /usr/bin/env sh
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
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,                                                                               # OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY                                                                               # THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
# OF SUCH DAMAGE.
#
# Note: please set default variables, script is not ready to work
#       only with the prompt.
######################################################################

# default variables
TARGET_HOST=""
TARGET_PORT=""
TARGET_USER=""
TARGET_PKEY=""

# ssh specific variables
SSH_FORWARD=("-R 127.0.0.1:12345:127.0.0.1:22"
             "-D 127.0.0.1:9999")
SSH_OPTIONS="-i $TARGET_PKEY -p $TARGET_PORT -C -N $SSH_FORWARD"
SSH_EXTOPTS="-o Compression=yes -o CompressionLevel=9"
SSH_LAUNCH="ssh $TARGET_USER@$TARGET_HOST $SSH_OPTIONS $SSH_EXTOPTS"

# command variables may change on some systems
CMD_PING=$(which ping 2>/dev/null || print "/bin/ping")
CMD_NC=$(which nc 2>/dev/null || print "/usr/bin/nc")
CMD_PGREP=$(which pgrep 2>/dev/null || print "/usr/bin/pgrep")
CMD_PRINTF=$(which printf 2>/dev/null || print "/usr/bin/printf")

# default flags
FLAG_DEBUG="yes"
FLAG_PING=""
FLAG_NC=""

ICMP_HOST="8.8.8.8"

# define default print
print () {
    printf -- "$*\n"
}

# define debug print
print_d () {
    print "debug: $*"
}

usage () {
    print "usage: $0 set [target_host|target_port|target_user|target_pkey]"
    print "       $0 usage"
    print "       $0 check"
}

# check all softs
check_soft () {
    if [ -x "${CMD_PING}" ]
    then
	FLAG_PING="yes"
    fi

    if [ -x "${CMD_NC}" ]
    then
	FLAG_NC="yes"
    fi
}

# check variables
check_variables () {
    # check command variables
    for cmd in $(set | egrep "^CMD_.*")
    do
	if [ -x "${cmd##*=}" ]
	then
	    print_d "${cmd%%=*} => ${cmd##*=} is ok"
	fi
    done
}

# check icmp status (not very important)
check_icmp () {
    ${CMD_PING} -c 1 "$1" 2>&1 > /dev/null
}

# check tcp port status
check_tcp () {
    ${CMD_NC} -z -p "$2" "$1" 2>&1 > /dev/null
}

# init ssh thief command
ssh_thief () {
    if ! ${CMD_PGREP} -f "$SSH_LAUNCH" 2>&1 > /dev/null
    then
        ${SSH_LAUNCH} &
    fi
}

# make all data test with flag_debug
#if [ "$FLAG_DEBUG" ]
#then
#    check_variables
#fi

if [ "$1" ]
then
    case "$1" in
	"set") print "work in progress" ;;
	"check") print "work in progress" ;;
	*) usage ;;
    esac
else
    # check ICMP or TCP status
    if (check_icmp ${ICMP_HOST}) || (check_tcp ${TARGET_HOST} ${TARGET_PORT})
    then
	ssh_thief
    fi
fi
