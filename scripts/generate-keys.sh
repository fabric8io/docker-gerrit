#!/bin/bash

rm -rf ssh-admin-key
rm -rf ssh-keys

echo ">> Generate new keys for admin"
mkdir ssh-admin-key
cd ssh-admin-key/
ssh-keygen -b 4096 -t rsa -f ssh-key -q -N "" -C "admin@fabric8.io"
cd ..

echo ">> Generate new keys for jenkins & sonar users"
mkdir ssh-keys
cd ssh-keys/

ssh-keygen -b 4096 -t rsa -f id-jenkins-rsa -q -N "" -C "jenkins@fabric8.io"
ssh-keygen -b 4096 -t rsa -f id-sonar-rsa -q -N "" -C "sonar@fabric8.io"

cd ..

