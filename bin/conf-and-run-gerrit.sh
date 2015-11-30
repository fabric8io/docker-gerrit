#!/bin/bash

set -e

# Rename keys imported within the root directory from ssh-key to id_rsa
# This step is required as gerrit, when the admin user is created during the generation site process will import the key using this path ${home_dir}/.ssh/id_rsa
# Copy the root public key ssh-key.pub renamed into id_rsa.pub to the SSH-KEYS dir under the name id-admin-rsa.pub to allow the admin user to use this key for SSH connections (git, ...)
for f in $GERRIT_SSH_PATH/*; do
   echo $f
   file=$(basename $f)
   DIR=$(dirname $f)
   new=$(echo $file | sed -e 's/ssh-key/id_rsa/')
  
   if [ -f "$DIR/$new" ]; then
       rm -f $DIR/$new && mv "$DIR/$file" "$DIR/$new"
   else
       mv "$DIR/$file" "$DIR/$new"
   fi

   if [ "$new" = "id_rsa.pub" ]; then
      echo $DIR/$new
      cp $DIR/$new $GERRIT_PUBLIC_KEYS_PATH/id-admin-rsa.pub
   fi
   
   if [ "$new" = "id_rsa" ]; then
      echo $DIR/$new
      cp $DIR/$new $GERRIT_PUBLIC_KEYS_PATH/id-admin-rsa
   fi
done

# lets make sure that the ssh keys have their permissions setup correctly
# chmod 700 /root/.ssh
# chmod 400 /root/.ssh/*

# Initialize gerrit & reindex the site if the gerrit-configured doesn't exist
if [ -f $GERRIT_SITE/.gerrit-configured ]; then
  echo ">> Gerrit has been configured, then will not generate a new setup"
else
  echo ">> .gerrit-configured doesn't exist. We will start gerrit to generate it"
  java -jar ${GERRIT_HOME}/$GERRIT_WAR init --install-plugin=replication --install-plugin=download-commands --batch --no-auto-start -d ${GERRIT_SITE}
  java -jar ${GERRIT_HOME}/$GERRIT_WAR reindex -d ${GERRIT_HOME}/site

  # Copy plugins including : add-user-plugin, delete-project
  cp ${GERRIT_HOME}/plugins/*.jar ${GERRIT_SITE}/plugins

  # Copy our config files
  cp ${GERRIT_HOME}/configs/gerrit.config ${GERRIT_SITE}/etc/gerrit.config
  cp ${GERRIT_HOME}/configs/replication.config ${GERRIT_SITE}/etc/replication.config
  
  # Configure Git Replication
  echo ">> Configure Git Replication & replace variables : GIT_SERVER_IP, GIT_SERVER_PORT, GIT_SERVER_USER, GIT_SERVER_PASSWORD & GIT_SERVER_PROJ_ROOT"
  sed -i  's/__GIT_SERVER_IP__/'${GIT_SERVER_IP}'/g' ${GERRIT_SITE}/etc/replication.config
  sed -i  's/__GIT_SERVER_PORT__/'${GIT_SERVER_PORT}'/g' ${GERRIT_SITE}/etc/replication.config
  sed -i  's/__GIT_SERVER_USER__/'${GIT_SERVER_USER}'/g' ${GERRIT_SITE}/etc/replication.config
  sed -i  's/__GIT_SERVER_PASSWORD__/'${GIT_SERVER_PASSWORD}'/g' ${GERRIT_SITE}/etc/replication.config
  sed -i  's/__GIT_SERVER_PROJ_ROOT__/'${GIT_SERVER_PROJ_ROOT}'/g' ${GERRIT_SITE}/etc/replication.config

  # Configure Gerrit
  echo ">> Configure Git Config and change AUTH_TYPE"
  sed -i  's/__AUTH_TYPE__/'${AUTH_TYPE}'/g' ${GERRIT_SITE}/etc/gerrit.config
  
  # Regenerate the site but using now our add-user-plugin to import the users and their keys including also
  # the ssh public key for the admin user. Without the admin public key, it is not possible to ssh to the gerrit server
  # or to use the change-project-config plugin which issue a ssh command through the git client
  java -jar ${GERRIT_HOME}/$GERRIT_WAR init --batch --no-auto-start -d ${GERRIT_SITE}
  
  # Add a .gerrit-configured file
  echo "Add .gerrit-configured file"
  touch $GERRIT_SITE/.gerrit-configured
 
fi

# Reset the gerrit_war variable as the path must be defined to the /home/gerrit/ directory
export GERRIT_WAR=${GERRIT_HOME}/gerrit.war
chown -R gerrit:gerrit $GERRIT_HOME

echo "Launching job to update Project Config. It will wait till a connection can be established with the SSHD of Gerrit"
exec java -jar ${GERRIT_HOME}/job/change-project-config-2.11.2.jar &

echo "Starting Gerrit ... "
exec java -jar ${GERRIT_WAR} daemon --console-log -d ${GERRIT_SITE}
