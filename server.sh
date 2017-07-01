#!/usr/bin/env bash
set -e

echo -e "\n------ Generating ca certificate and key for ${NGROK_SERVER_DOMAIN} "
CERTS_DIR=/certs

SERVER_KEY=${CERTS_DIR}/server.key
SERVER_CRT=${CERTS_DIR}/server.crt
mkdir -vp ${CERTS_DIR}

if [[ -f ${SERVER_CRT} && -f ${SERVER_KEY} ]]; then
   echo "Using server certificate ${SERVER_CRT} and key ${SERVER_KEY} "
else
    CA_KEY=${CERTS_DIR}/ca.key
    CA_PEM=${CERTS_DIR}/ca.pem
    echo "Building server certificates signed by CA at ${CA_PEM} ... "
    if [[ ! -f ${CA_KEY} ]]; then
       echo "Error: CA KEY file ${CA_KEY} does not exist"
       exit 1
    fi

    SERVER_CSR=${CERTS_DIR}/server.csr
    CERT_SUBJ=$(openssl x509 -noout -subject -in certs/ca.pem | cut -d' ' -f 2)

    openssl genrsa -out ${SERVER_KEY} 2048
    openssl req -new -key ${SERVER_KEY} -subj "${CERT_SUBJ}" -out ${SERVER_CSR}
    openssl x509 -req -in ${SERVER_CSR} -CA ${CA_PEM} -CAkey ${CA_KEY} -CAcreateserial -days 10000 -out ${SERVER_CRT}
fi

echo -e "\nStarting ngrokd -domain ${NGROK_SERVER_DOMAIN} -tlsCrt certs/server.crt -tlsKey certs/server.key $@ "
ngrokd -domain ${NGROK_SERVER_DOMAIN} -tlsCrt ${SERVER_CERT} -tlsKey ${SERVER_KEY} $@