#!/usr/bin/env bash

DOCKER_IP_PORT=${1:-192.168.99.100:2376}

export DOCKER_CERT_PATH="/Users/chmoulli/.docker/machine/machines/default"
export DOCKER_HOST="tcp://$DOCKER_IP_PORT"
export DOCKER_MACHINE_NAME="default"
export DOCKER_TLS_VERIFY="1"