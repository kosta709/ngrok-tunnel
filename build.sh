#!/usr/bin/env bash
#
set -e
DIR=$(dirname $0)
NGROK_DIR=${DIR}/ngrok

# Generating Certificates
if [[ -z "${NGROK_SERVER_DOMAIN}" ]]; then
   echo "Error: NGROK_SERVER_DOMAIN is not set - should be set for server base domain (like tunnel.my.domain) "
   exit 1
fi

echo -e "\n------ Generating ca certificate and key for ${NGROK_SERVER_DOMAIN} "
CERTS_DIR=/certs
CA_KEY=${CERTS_DIR}/ca.key
CA_PEM=${CERTS_DIR}/ca.pem
mkdir -vp ${CERTS_DIR}

openssl genrsa -out ${CA_KEY} 2048
openssl req -new -x509 -nodes -key ${CA_KEY} -days 10000 -subj "/CN=${NGROK_SERVER_DOMAIN}" -out ${CA_PEM}

cp -v ${CA_PEM} ${NGROK_DIR}/assets/client/tls/ngrokroot.crt

###### Make ngrok

echo -e "\n------ make ngrok "
make -C ${NGROK_DIR} release-server release-client

cp -v ${NGROK_DIR}/bin/{ngrok,ngrokd} /usr/local/bin/

###### Writing client ngrok.conf
CONFIG_FILE=${DIR}/ngrok.conf

cat <<EOF > ${CONFIG_FILE}
server_addr: ${NGROK_SERVER_DOMAIN}:${NGROK_SERVER_PORT:=4443}
trust_host_root_certs: false
EOF

###### Printing CA PRIVATE KEY and then removing it
echo -e "Printing CA private key: \n"
cat $CA_KEY

echo -e "\nSAVE THE PRIVATE KEY ABOVE and mount it for starting ngrok server. \nNext command removes it from the image"
rm -vf $CA_KEY
