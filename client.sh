#!/usr/bin/env bash
#
# start ngrok client
# Usage:
#    ./client.sh local_address remote_adderss

DIR=$(dirname $0)

LOCAL_ADDR=$1
REMOTE_ADDR=$2
if [[ -n ${REMOTE_ADDR} ]]; then
   SUBDOMAIN=$(echo ${REMOTE_ADDR} | cut -d'.' -f1)
   NGROK_SERVER=$(echo ${REMOTE_ADDR} | cut -d'.' -f2- )
   shift
fi

if [[ -z ${NGROK_SERVER} || ${NGROK_SERVER} == ${SUBDOMAIN} ]]; then
   NGROK_SERVER=${NGROK_SERVER_DOMAIN}
   SUBDOMAIN=$(echo ${LOCAL_ADDR} | cut -d'.' -f1 | cut -d':' -f1)
fi
shift

###### Writing client ngrok.conf
CONFIG_FILE=${DIR}/ngrok.conf
cat <<EOF > ${CONFIG_FILE}
server_addr: ${NGROK_SERVER}:${NGROK_SERVER_PORT:-4443}
trust_host_root_certs: false
EOF

echo -e "\nStarting  ngrok -log stdout -log-level INFO --config ${CONFIG_FILE} -subdomain ${SUBDOMAIN} $@ ${LOCAL_ADDR}"
ngrok -log stdout -log-level INFO --config ${CONFIG_FILE} -subdomain ${SUBDOMAIN} $@ ${LOCAL_ADDR}
