#!/bin/bash
# vim: syntax=sh textwidth=80 expandtab tabstop=4 softtabstop=4 shiftwidth=4 autoindent
set +x
set -e

# guest current workspace and go to it.
g_workspace=$(pwd)/$(dirname $0)
echo "INFO: changing workspace directory to : ${g_workspace}"
cd ${g_workspace}

export ASSETS_FOLDER=${ASSETS_FOLDER:-assets}
export INIT_REQUIREMENTS_BIN="openssl"

# load local config.
g_prog_name=$(basename $0)

function usage ()
{
    echo
    echo "$0 usage : "
    echo
    echo -n "You can generate jwt keys"
    echo "Available commands :"
    echo
    echo " - gen-jwt-keys : just a helper to create jwt keys."
    echo "   usage : $0 gen-jwt-keys <subject>"
    echo "   subject format : /C=FR/ST=French/L=Paris/O=Linagora/CN=smartsla.org"
    echo "   examples:"
    echo "     $0 gen-jwt-keys /C=FR/ST=French/L=Paris/O=Linagora/CN=smartsla.org"
    echo
    echo "Available funtions for interactive mode (SUPERUSER):"
    for l_func in $(declare -F | grep init_ | cut -d' ' -f3)
    do
        echo " - ${l_func}"
    done
    echo
    exit 1
}

function gen-jwt-keys ()
{
    local l_subject=$1

    if [ -z ${l_subject} ] ; then
        echo "ERROR: Missing JWT subject"
        exit 1
    fi
    local l_private_key=./${ASSETS_FOLDER}/jwt-keys/private.pem
    local l_public_key=./${ASSETS_FOLDER}/jwt-keys/public.pem

    echo "INFO: Generating JWT private and public keys for SmartSLA."
    mkdir -p ./${ASSETS_FOLDER}/jwt-keys
    if [ -f ${l_private_key} -o -f ${l_public_key} ] ; then
        echo "ERROR: ${l_private_key} or ${l_public_key} already exists ! "
        echo "aborted."
        exit 1
    fi
    openssl req \
        -new -x509 -sha256 -newkey rsa:2048 -nodes \
        -keyout ${l_private_key} \
        -days 365
    openssl rsa \
        -in ${l_private_key} \
        -pubout > ${l_public_key}
    echo "INFO: Private and public keys generated."
    echo "INFO: See: ${l_private_key}"
    echo "INFO: See: ${l_public_key}"
}

function check_bin_requirements ()
{
    local l_requirements=$@
    local l_pkg=""
    local l_error=0
    for l_pkg in ${l_requirements}; do
      if ! which ${l_pkg} > /dev/null ; then
        echo "ERROR: ${g_prog_name}: ${l_pkg} is missing !"
        l_error=1
      fi
    done
    if [ ${l_error} -eq 1 ] ; then
        echo "ERROR: Some requirements are missing : ${l_requirements}"
	exit 127
    fi
}

#### main
export DEBUG=${DEBUG:-0}
if [ ${DEBUG} -eq 1 ] ; then
    set -x
fi
check_bin_requirements ${INIT_REQUIREMENTS_BIN}

if [ "$1" == "gen-jwt-keys" ] ; then
    gen-jwt-keys $2 $3
else
    if [ -z ${@} ] ; then
        usage
    fi
    for l_func in ${@}
    do
        echo "INFO: Running function : ${l_func}"
        ${l_func}
        echo "INFO: function ${l_func} completed."
    done
fi
echo "INFO: ${g_prog_name}  completed."
