#!/usr/bin/env bash
#
DIR=$(dirname $0)

case "$1" in
    server)
        ${DIR}/server.sh ${@:2}
        ;;

    client)
        ${DIR}/client.sh ${@:2}
        ;;
    *)
        $@
esac


