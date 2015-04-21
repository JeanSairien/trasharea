#! /bin/sh
######################################################################
# Copyright (c) 2015, niamkik <niamkik@gmail.com>                    #
# All rights reserved.                                               #
#                                                                    #
# Redistribution and use in source and binary forms, with or         #
# without modification, are permitted provided that the              #
# following conditions are met:                                      #
#                                                                    #
# 1. Redistributions of source code must retain the above            #
# copyright notice, this list of conditions and the                  #
# following disclaimer.                                              #
#                                                                    #
# 2. Redistributions in binary form must reproduce the above         #
# copyright notice, this list of conditions and the                  #
# following disclaimer in the documentation and/or other             #
# materials provided with the distribution.                          #
#                                                                    #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND             #
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED                    #
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED             #
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR         #
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT            #
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         #
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES           #
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE          #
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR               #
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF         #
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT          #
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT         #
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE                #
# POSSIBILITY OF SUCH DAMAGE.                                        #
#                                                                    #
######################################################################

FAN_LEVEL="7"
COUNTER="1"
SLEEP="10"
DEBUG=""

######################################################################
# global functions                                                   #
######################################################################

_print_info () {
  printf -- "info: %s\n" "$*"
}

_print_debug () {
  if [ "${DEBUG}" ]
  then
    printf -- "debug: %s\n" "$*" 1>&2
  fi
}

_print_warning () {
  printf -- "warning: %s\n" "$*" 1>&2
}

_print_error () {
  printf -- "error: %s\n" "$*" 1>&2
}

######################################################################
# main functions                                                     #
######################################################################

usage () {
  printf -- "usage: %s [-s sleep] [-l level] [-c counter]\n" "$0"
  exit 1
}

_automatic () {
  _print_info "automatic mode enabled"
  ret=$(sysctl dev.acpi_ibm.0.fan=1 2>&1)
  _print_debug "${ret}"
}

_manual () {
  _print_info "manual mode enabled"
  ret=$(sysctl dev.acpi_ibm.0.fan=0 2>&1)
  _print_debug "${ret}"
}

_level () {
  level="$1"
  if echo "${level}" | egrep "^[0-9]+$" 2>&1 >/dev/null
  then
    _print_info "change to level '${level}'"
    ret=$(sysctl dev.acpi_ibm.0.fan_level="${level}" 2>&1)
    _print_debug "${ret}"
  else
    _print_error "not a valid mode."
  fi
}

_speed () {
  sysctl -n dev.acpi_ibm.0.fan_speed
}

_temp () {
  sensors="hw.acpi.thermal.tz0.temperature
           hw.acpi.thermal.tz1.temperature
           dev.cpu.0.temperature
           dev.cpu.1.temperature"
  buf=""
  for sensor in ${sensors}
  do
    ret=$(sysctl -n "${sensor}")
    if [ "${ret}" ]
    then
      if [ -z "${buf}" ]
      then 
        buf=${ret}
      else
        buf=${buf}:${ret}
      fi
    fi
  done
 printf -- "%s" "${buf}"
}

######################################################################
# main script                                                        #
######################################################################

trap "_automatic;"          SIGHUP
trap "_automatic; exit 1;"  SIGINT
trap "_automatic; exit 0;"  SIGQUIT
trap "_automatic; exit 1;"  SIGKILL
trap "_automatic; exit 1;"  SIGTERM
trap "_level 0;"            SIGUSR1
trap "_level ${FAN_LEVEL};" SIGUSR2

args=$(getopt ds:c:l: $*)
set -- $args

while true
do
  case "$1" in
    -d) DEBUG="yes";
        _print_debug "set debug";
        shift;;
    -s) SLEEP="$2";
        _print_debug "set sleep to $2";
        shift; shift;;
    -c) COUNTER="$2";
        _print_debug "set counter to $2";
        shift; shift;;
    -l) FAN_LEVEL="$2";
        _print_debug "set level to $2";
        shift; shift;;
    --) shift; break;;
  esac
done

_manual

while [ "${COUNTER}" -le "${FAN_LEVEL}" ]
do
  _level "${COUNTER}"
  _print_info "fan speed is: $(_speed)"
  _print_info "temperature: $(_temp)"
  sleep $SLEEP
  COUNTER=$(($COUNTER+1))
done

_automatic
