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
# Make replacement for echo command with printf. Better portability. #
######################################################################

COMMAND_PRINTF="$(which printf)"
COMMAND_SED="$(which sed)"
COMMAND_GREP="$(which grep)"
COMMAND_FIND="$(which find)"
COMMAND_MAIL="$(which mailx)"

debug_variable () {
    print_debug "COMMAND_PRINTF=${COMMAND_PRINTF}"
    print_debug "COMMAND_SED=${COMMAND_SED}"
    print_debug "COMMAND_GREP=${COMMAND_GREP}"
    print_debug "COMMAND_FIND=${COMMAND_FIND}"
    print_debug "COMMAND_MAIL=${COMMAND_MAIL}"
    return 0
}

print () {
    ${COMMAND_PRINTF} -- "$*\n"
    return 0
}

printn () {
    ${COMMAND_PRINTF} -- "$*"
    return 0
}

print_ok () {
    print "[+] $*"
    return 0
}

print_info () {
    print "[i] $*"
    return 0
}

print_error () {
    print "[!] $*"
    return 0
}

print_debug () {
    print "[DEBUG] $*"
    return 0
}