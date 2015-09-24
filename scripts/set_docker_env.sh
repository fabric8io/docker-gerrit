#!/usr/bin/env bash

# Docker Machine
# DOCKER_IP_PORT=${1:-192.168.99.100:2376}
# export DOCKER_CERT_PATH="/Users/chmoulli/.docker/machine/machines/default"
# export DOCKER_HOST="tcp://$DOCKER_IP_PORT"
# export DOCKER_MACHINE_NAME="default"
# export DOCKER_TLS_VERIFY="1"

# Boot2docker
DOCKER_IP_PORT=${1:-192.168.59.103:2376}
export DOCKER_HOST=tcp://$DOCKER_IP_PORT
export DOCKER_CERT_PATH=/Users/chmoulli/.boot2docker/certs/boot2docker-vm
export DOCKER_TLS_VERIFY=1
