#!/bin/bash

export GERRIT_SSH_PATH=/Users/chmoulli/Fuse/Fuse-projects/fabric8/docker-gerrit/ssh-admin-key
export GERRIT_SSH_KEYS=/Users/chmoulli/Fuse/Fuse-projects/fabric8/docker-gerrit/ssh-keys

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

cd $CURRENT_DIR

for f in $GERRIT_SSH_PATH/*; do
   echo $f
   file=$(basename $f)
   DIR=$(dirname $f)
   new=$(echo $file | sed -e 's/ssh-key/id_rsa/')
   mv "$DIR/$file" "$DIR/$new"

   if [ "$new" = "id_rsa.pub" ]; then
      echo $DIR/$new
      cp $DIR/$new $GERRIT_SSH_KEYS/id-admin-rsa.pub
   fi
done

