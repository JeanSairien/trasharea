# Copyright (c) 2014, Niamkik
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met: * Redistributions of source code must
# retain the above copyright notice, this list of conditions and
# the following disclaimer. * Redistributions in binary form
# must reproduce the above copyright notice, this list of
# conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution. *
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
#
######################################################################
# auto-logging script with script for bash, sh and ksh.              #
# set this in ~/.bashrc, ~/.shrc, ~/.kshrc or ~/.profile.            #
# tested on debian7 and FreeBSD10                                    #
######################################################################

LOGGING_PATH="${HOME}/.logging"
LOGGING_DATE=$(date +"%Y%m%d-%H%M%S")
LOGGING_NAME="log.${LOGGING_DATE}"

# first init directory
logging_init () {
   if ! [ -e "${LOGGING_PATH}" ]
   then
      mkdir "${LOGGING_PATH}"
      chmod -R 700 "${LOGGING_PATH}"
   fi
}

# next launch logging_session
logging_session () {
   # if parent pid is "script" we don't launch another logger.
   if ! ps o pid,comm \
         | sed '1d' \
         | grep -e "$PPID" \
         | grep -e "script" 2>&1 > /dev/null
   then
      LOGGING_BUFFER=$(mktemp "${LOGGING_PATH}"/${LOGGING_NAME}.XXXXXXXX)
      case "$(uname)" in
         "FreeBSD") script -t 1 -a -q "${LOGGING_BUFFER}" "${SHELL}"
                    exit ;;
         "Linux") script -f -a -q -c "${SHELL}" "${LOGGING_BUFFER}"
                  exit ;;
      esac
   fi
}

logging_init && logging_session
