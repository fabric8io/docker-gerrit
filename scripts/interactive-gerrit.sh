#!/usr/bin/env bash

USER=$1
GERRIT_TEMP_DIR=$2
USER_HOME_KEYS=$3

docker stop gerrit-server
docker rm gerrit-server
rm -rf $GERRIT_TEMP_DIR

docker build -t $USER/gerrit .

docker run -it -p 0.0.0.0:8080:8080 -p 0.0.0.0:29418:29418 \
 -e GERRIT_GIT_LOCALPATH='/home/gerrit/git' \
 -e GERRIT_GIT_PROJECT_CONFIG='/home/gerrit/config/project.config' \
 -e GERRIT_GIT_REMOTEPATH='ssh://admin@localhost:29418/All-Projects' \
 -e GERRIT_ADMIN_USER='admin'  \
 -e GERRIT_ADMIN_EMAIL='admin@fabric8.io' \
 -e GERRIT_ADMIN_FULLNAME='Administrator' \
 -e GERRIT_ADMIN_PWD='mysecret' \
 -e GIT_SERVER_IP='gogs-http-service.default.local' \
 -e GIT_SERVER_PORT='80' \
 -e GIT_SERVER_USER='root'  \
 -e GIT_SERVER_PASSWORD='redhat01' \
 -e GIT_SERVER_PROJ_ROOT='root'  \
 -e AUTH_TYPE='DEVELOPMENT_BECOME_ANY_ACCOUNT' \
 -v $USER_HOME_KEYS/id_rsa.pub:/root/.ssh/id_rsa.pub \
 -v $USER_HOME_KEYS/id_rsa:/root/.ssh/id_rsa \
 -v $GERRIT_TEMP_DIR:/home/gerrit/site \
 --name gerrit-server cmoulliard/gerrit bash