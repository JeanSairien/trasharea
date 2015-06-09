#! /bin/sh
######################################################################
# Copyright (c) 2015, niamkik <niamkik@gmail.com>                    #
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
# ------------------------------------------------------------------ #
#                                                                    #
# This is script was created for check fan speed and sensor on       #
# lenovo thinkpad x61 and thinkpad x220. You need to launch it with  #
# sudo or via root account (UID==0).                                 #
#                                                                    #
# Need:                                                              #
#   - random level mode                                              #
#   - average temperature                                            #
#   - voltage sensor                                                 #
#   - CPU freq                                                       #
#   - more debug information                                         #
#   - linux/openbsd/netbsd support                                   #
#   - autoload acpi_ibm kernel module if not loaded                  #
#                                                                    #
######################################################################

FAN_LEVEL="7"
COUNTER="1"
SLEEP="10"
DEBUG=""
SENSORS="hw.acpi.thermal.tz0.temperature
         hw.acpi.thermal.tz1.temperature
         dev.cpu.0.temperature
         dev.cpu.1.temperature"

THERMAL_KEYS="hw\.acpi\.thermal\.tz[0-9]+\.temperature
              dev\.cpu\.[0-9]+.temperature"

_BUF_SPEED=""
_BUF_TEMP=""

######################################################################
# global functions                                                   #
######################################################################

# print information messages
_print_info () {
  printf -- "info: %s\n" "$*"
}

# print debug messages (on sterr)
_print_debug () {
  if [ "${DEBUG}" ]
  then
    printf -- "debug: %s\n" "$*" 1>&2
  fi
}

# print warning messages (on sterr)
_print_warning () {
  printf -- "warning: %s\n" "$*" 1>&2
}

# print error messages (on sterr)
_print_error () {
  printf -- "error: %s\n" "$*" 1>&2
}

######################################################################
# main functions                                                     #
######################################################################

# return usage/help information
# if first argument is set, return extended usage.
usage () {
  note="  !!! Currently work only on FreeBSD !!!  "
  flags="[-adhL]"
  args="[-s second] [-l level] [-c level]"

  a_msg="auto search thermal information in sysctl."
  d_msg="debug mode, print debug information during execution."
  h_msg="standard help, show simple usage."
  H_msg="extended help, show extended usage with informations."
  L_msg="loop mode, stop it with Ctrl-C or SIGKILL"

  c_msg="(integer) fan level start, default 1."
  l_msg="(integer) fan level, 0<level<7 for ibm fan, default 7."
  s_msg="(integer) sleep time in second."

  printf -- "usage: %s %s %s\n" "$0" "${flags}" "${args}"

  if [ "${note}" ]
  then
    printf -- "%s\n" "${note}"
  fi

  if [ "$1" ]
  then
    printf -- "       -a: %s \n" "${a_msg}"
    printf -- "       -d: %s \n" "${d_msg}"
    printf -- "       -h: %s \n" "${h_msg}"
    printf -- "       -H: %s \n" "${H_msg}"
    printf -- "       -L: %s \n" "${L_msg}" 
    printf -- "       -c: %s \n" "${c_msg}"
    printf -- "       -l: %s \n" "${l_msg}"
    printf -- "       -s: %s \n" "${s_msg}"
  fi
  exit 0
}

_check_int () {
  local arg="${1}"
  if printf -- "%s" "${arg}" | egrep "^[0-9]+$"
  then
    return 0
  else
    return 1
  fi
}

_sum_speed () {
  local tot=$(echo ${_BUF_SPEED}|wc -w|sed -r 's/\ +//g')
  local sum

  for int in ${_BUF_SPEED}
  do
    sum=$((sum+$int))
  done

  echo "${sum}/${tot}" | bc
}

# switch to automatic mode
_automatic () {
  _print_info "automatic mode enabled"
  local ret=$(sysctl dev.acpi_ibm.0.fan=1 2>&1)
  _print_debug "${ret}"
}

# switch to manual mode
_manual () {
  _print_info "manual mode enabled"
  local ret=$(sysctl dev.acpi_ibm.0.fan=0 2>&1)
  _print_debug "${ret}"
}

# switch to level
# first argument set level. Only integer.
_level () {
  local level="$1"
  if echo "${level}" | egrep "^[0-9]+$" 2>&1 >/dev/null
  then
    _print_info "change to level '${level}'"
    ret=$(sysctl dev.acpi_ibm.0.fan_level="${level}" 2>&1)
    _print_debug "${ret}"
  else
    _print_error "not a valid mode."
  fi
}

# return fan speed
_speed () {
  local fan_speed=$(sysctl -n dev.acpi_ibm.0.fan_speed)
  if _check_int "${fan_speed}"
  then
    return "${fan_speed}"
  fi
}

# return temperature and thermal informations
_temp () {
  local buf=""
  for sensor in ${SENSORS}
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
 if [ "${buf}" ]
 then
   printf -- "%s" "${buf}"
 else
   _print_debug "no sensors informations set"
 fi
}

# search thermal information in sysctl
_find_thermal () {
  _print_debug "launch thermal information search..."
  local b=""
  local buf=""

  for key in ${THERMAL_KEYS}
  do
    b=$(sysctl -a \
             | egrep -re "^$key" \
             | cut -d: -f1)
    if [ "${buf}" ]
    then
      buf="${buf} ${b}"
    else
      buf="${b}"
    fi
    if [ "${b}" ]
    then
      _print_debug "thermal information found: ${b}"
    fi
  done

  if [ "${buf}" ]
  then
    printf -- "%s" "${buf}"
    return 0
  else
    _print_debug "no thermal information found!"
    printf --
    return 1
  fi
}

# main function for check fan
_main () {
  while [ "${COUNTER}" -le "${FAN_LEVEL}" ]
  do
    _level "${COUNTER}"
    _print_info "fan speed is: $(_speed)"
    _BUF_SPEED=$(_speed)" "${_BUF_SPEED}
    _print_info "temperature: $(_temp)"
    _BUF_TEMP=$(_temp)" "${_BUF_TEMP}
    sleep $SLEEP
    COUNTER=$(($COUNTER+1))
  done
  return 0
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

args=$(getopt hHdaLs:c:l: $*)
set -- $args

while true
do
  case "$1" in
    -h) usage; 
        break;;
    -H) usage extended
        break;;

    -d) DEBUG="yes";
        _print_debug "set debug";
        shift;;

    -L) LOOP_MODE="yes";
        _print_debug "set loop_mode";
        shift;;

    -a) AUTO_KEYS="yes";
        _print_debug "set auto_keys";
        SENSORS=$(_find_thermal);
        shift;;

    -s) if _check_int "${2}" 2>&1 >/dev/null
        then 
          SLEEP="${2}";
          _print_debug "set sleep to ${2}";
        else 
          _print_error "sleep flags (-s) need an integer." 
          exit 201
        fi
        shift; shift;;

    -c) if _check_int "${2}" 2>&1 >/dev/null 
        then 
          COUNTER="${2}";
          _print_debug "set counter to ${2}";
        else 
          _print_error "counter flag (-c) need an integer."
          exit 202
        fi
        shift; shift;;

    -l) if _check_int "${2}" 2>&1 >/dev/null
        then
          FAN_LEVEL="${2}";
          _print_debug "set level to ${2}";
        else
          _print_error "fan level flag (-l) need an integer."
          exit 203
        fi
        shift; shift;;

    --) shift; break;;
  esac
done

if [ "$(id -u)" -ne 0 ]
then
  _print_error "this software need root privilege."
  exit 1
fi

_manual

if [ "${LOOP_MODE}" ]
then
  while _main
  do 
    sleep "${SLEEP}"
  COUNTER=0
  done
else
  _main
fi

_automatic

_print_info "fan speed average: $(_sum_speed)"

