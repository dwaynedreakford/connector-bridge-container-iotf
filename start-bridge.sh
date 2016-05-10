#!/bin/sh

IP=192.168.1.230

set -x

docker run -d -p ${IP}:8883:8883 -p ${IP}:28519:28519 -p ${IP}:28520:28520 -p ${IP}:22:22 -p ${IP}:8234:8234 -t mbed/connector-bridge  /home/arm/start_instance.sh
