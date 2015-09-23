#!/bin/sh

set -e

# Rename keys imported within the root directory
# Replace "-" char with "_" char
# This step is required as gerrit, when the admin user is created, at the startup of the gerrit server, will
# import the key using this path ${home_dir}/.ssh/id_rsa
FILES='/root/.ssh/*'
for f in $FILES; do
   file=$(basename $f)
   DIR=$(dirname $f)
   #if [[ ! "$file" =~ ^id_rsa*|^id_rsa.pub* ]]; then
   if [[  "$file" =~ ^ssh-key* ]]; then
      new=$(echo $file | sed -e 's/ssh-key/id_rsa/')
      echo "!! SSH-KEY : -> " mv "$DIR/$file" "$DIR/$new"
      sudo mv "$DIR/$file" "$DIR/$new"
   fi
done

# lets make sure that the ssh keys have their permissions setup correctly
chmod 700 /root/.ssh
chmod 400 /root/.ssh/*

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
  cp configs/gerrit.config ${GERRIT_SITE}/etc/gerrit.config
  cp configs/replication.config ${GERRIT_SITE}/etc/replication.config
  
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
exec java -jar ./job/change-project-config-2.11.2.jar &

echo "Starting Gerrit ... "
exec java -jar ${GERRIT_WAR} daemon --console-log -d ${GERRIT_SITE}
