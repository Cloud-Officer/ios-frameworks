#!/usr/bin/env bash
set -ex

docker exec -it flang /root/host/setup-container.sh ${PWD}${@}
cp -rf inbox/* ${PWD}&> /dev/null
rm -rf inbox/* &> /dev/null
