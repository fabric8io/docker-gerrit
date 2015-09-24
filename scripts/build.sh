#!/usr/bin/env bash

PROJECT_DIR=`pwd`

USER=${2:-cmoulliard} # Username to be used to create the image
GERRIT_TEMP_DIR=${3:-~/temp/gerrit-site} # Temp dir where we will mount the volume locally
KEYS_DIR=$PROJECT_DIR/ssh-keys
ADMIN_KEY=$PROJECT_DIR/ssh-admin-key

. ./scripts/set_docker_env.sh

docker stop gerrit
docker rm gerrit
rm -rf $GERRIT_TEMP_DIR

docker build -t $USER/gerrit .