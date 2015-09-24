#!/usr/bin/env bash

PROJECT_DIR=`pwd`

USER=${1:-cmoulliard} # Username to be used to create the image
GERRIT_TEMP_DIR=${2:-~/temp/gerrit-site} # Temp dir where we will mount the volume locally
DOCKER_HOST=${3:-172.28.128.4}
KEYS_DIR=$PROJECT_DIR/ssh-keys
ADMIN_KEY=$PROJECT_DIR/ssh-admin-key

docker stop gerrit
docker rm gerrit
rm -rf $GERRIT_TEMP_DIR

export DOCKER_HOST=tcp://$DOCKER_HOST:2375
export DOCKER_TLS_VERIFY=

docker build -t $USER/gerrit .