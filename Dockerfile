FROM ubuntu:16.04
RUN apt-get update && \
    apt-get -y install build-essential golang mercurial openssl git

ARG NGROK_SERVER_DOMAIN
ARG NGROK_SERVER_PORT=4443

ENV NGROK_SERVER_DOMAIN=${NGROK_SERVER_DOMAIN} \
    NGROK_SERVER_PORT=${NGROK_SERVER_PORT}

WORKDIR /cf-tunnel
ENTRYPOINT ["./entrypoint.sh"]

COPY ngrok ./ngrok
COPY README.md client.sh server.sh entrypoint.sh build.sh ./

RUN chmod +x *.sh && DOCKER_BUILD=true ./build.sh

