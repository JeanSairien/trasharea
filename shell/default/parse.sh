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
# Default function for shell script for parsing some types of files. #
# You can use all function with pipe or with a file on first         #
# argument.                                                          #
######################################################################

# load default local command for "print"
. ./standard.sh

remove_personal_comment () {
    print "Work in progress..."
    return 1 
}

remove_sharp_comment () {
    FILENAME="$1"
    IFS=$'\n'
    for line in $(cat ${FILENAME})
    do
	print "${line}" \
	    | ${COMMAND_SED} "/\#.*/d"
    done
    return 0
}

remove_exclam_comment () {
    FILENAME="$1"
    IFS=$'\n'
    for line in $(cat ${FILENAME})
    do
	print "${line}" \
	    | ${COMMAND_SED} "/\!.*/d"
    done
    return 0
}

remove_all_comment () {
    FILENAME="$1"
    IFS=$'\n'
    for line in $(cat ${FILENAME})
    do
	print "${line}" \
	    | ${COMMAND_SED} -e "/\!.*/d" \
	                     -e "/\#.*/d" \
	                     -e "/\/\/.*/d" 
    done
    return 0
}

parse_colon () {
    print "Work in progress..."
    return 1
}

parse_comma () {
    print "Work in progress"
    return 1
}