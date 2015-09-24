#!/usr/bin/env bash

PROJECT_DIR=`pwd`

USER=${1:-cmoulliard} # Username to be used to create the image
GERRIT_TEMP_DIR=${2:-~/temp/gerrit-site} # Temp dir where we will mount the volume locally
KEYS_DIR=$PROJECT_DIR/ssh-keys
ADMIN_KEY=$PROJECT_DIR/ssh-admin-key

. ./scripts/set_docker_env.sh

docker stop gerrit
docker rm gerrit
rm -rf $GERRIT_TEMP_DIR

docker build -t $USER/gerrit .

docker run -it -p 0.0.0.0:8080:8080 -p 0.0.0.0:29418:29418 \
 -e GERRIT_GIT_LOCALPATH='/home/gerrit/git' \
 -e GERRIT_GIT_PROJECT_CONFIG='/home/gerrit/configs/project.config' \
 -e GERRIT_GIT_REMOTEPATH='ssh://admin@localhost:29418/All-Projects' \
 -e GIT_SERVER_IP='gogs-service.default.local' \
 -e GIT_SERVER_PORT='80' \
 -e GIT_SERVER_USER='root'  \
 -e GIT_SERVER_PASSWORD='redhat01' \
 -e GIT_SERVER_PROJ_ROOT='root'  \
 -e GERRIT_ADMIN_USER='admin'  \
 -e GERRIT_ADMIN_EMAIL='admin@fabric8.io' \
 -e GERRIT_ADMIN_FULLNAME='Administrator' \
 -e GERRIT_ADMIN_PWD='mysecret' \
 -e GERRIT_ACCOUNTS='jenkins,jenkins,jenkins@fabric8.io,secret,Non-Interactive Users:Administrators;sonar,sonar,sonar@fabric8.io,secret,Non-Interactive Users' \
 -e GERRIT_SSH_PATH='/root/.ssh' \
 -e GERRIT_ADMIN_PRIVATE_KEY='/root/.ssh/id_rsa' \
 -e GERRIT_PUBLIC_KEYS_PATH='/home/gerrit/ssh-keys' \
 -e GERRIT_USER_PUBLIC_KEY_PREFIX='id_' \
 -e GERRIT_USER_PUBLIC_KEY_SUFFIX='_rsa.pub' \
 -e AUTH_TYPE='DEVELOPMENT_BECOME_ANY_ACCOUNT' \
 -v $ADMIN_KEY:/root/.ssh \
 -v $KEYS_DIR:/home/gerrit/ssh-keys \
 -v $GERRIT_TEMP_DIR:/home/gerrit/site \
  --name gerrit $USER/gerrit bash