#!/bin/sh

set -e

# Initialize gerrit & reindex the site if the gerrit-configured doesn't exist
if [ -f $GERRIT_SITE/.gerrit-configured ]; then
  echo ">> Gerrit has been configured, then will not generate a new setup"
else
  echo ">> .gerrit-configured doesn't exist. We will start gerrit to generate it"
  java -jar ${GERRIT_HOME}/$GERRIT_WAR init --install-plugin=replication --install-plugin=download-commands --batch --no-auto-start -d ${GERRIT_SITE}
  java -jar ${GERRIT_HOME}/$GERRIT_WAR reindex -d ${GERRIT_HOME}/site

  # Download Gerrit plugin
  echo ">> Download gerrit plugins - delete project <<"
  curl -sSL https://ci.gerritforge.com/view/Plugins-stable-2.11/job/Plugin_delete-project_stable-2.11/lastSuccessfulBuild/artifact/target/delete-project-2.11.jar -o ${GERRIT_SITE}/plugins/delete-project.jar

  # Copy our config files
  cp bin/gerrit.config ${GERRIT_SITE}/etc/gerrit.config
  cp bin/replication.config ${GERRIT_SITE}/etc/replication.config
  
  # Configure Git Replication
  echo ">> Configure Git Replication"
  sed -i  's/__GIT_SERVER_IP__/'${GIT_SERVER_IP}'/g' ${GERRIT_SITE}/etc/replication.config
  sed -i  's/__GIT_SERVER_PORT__/'${GIT_SERVER_PORT}'/g' ${GERRIT_SITE}/etc/replication.config
  sed -i  's/__GIT_SERVER_USER__/'${GIT_SERVER_USER}'/g' ${GERRIT_SITE}/etc/replication.config
  sed -i  's/__GIT_SERVER_PASSWORD__/'${GIT_SERVER_PASSWORD}'/g' ${GERRIT_SITE}/etc/replication.config
  sed -i  's/__GIT_SERVER_PROJ_ROOT__/'${GIT_SERVER_PROJ_ROOT}'/g' ${GERRIT_SITE}/etc/replication.config

  # Configure Gerrit
  echo ">> Configure Git"
  sed -i  's/__AUTH_TYPE__/'${AUTH_TYPE}'/g' ${GERRIT_SITE}/etc/gerrit.config
  
  # Add a .gerrit-configured file
  echo "Add .gerrit-configured file"
  touch $GERRIT_SITE/.gerrit-configured
 
fi

# Debug purpose
# ls -la $GERRIT_HOME/SITE/db
# ls -la $GERRIT_HOME/site/etc
# cat /home/gerrit/site/etc/replication.config
# cat /home/gerrit/site/etc/gerrit.config

# Start gerrit

# Reset the gerrit_war variable as the path must be defined to the /home/gerrit/ directory
export GERRIT_WAR=${GERRIT_HOME}/gerrit.war
chown -R gerrit:gerrit $GERRIT_HOME

# Error reported when we launch gerrit with the bash script
# /home/gerrit/site/bin/gerrit.sh: line 429: echo: write error: Permission denied
# ${GERRIT_SITE}/bin/gerrit.sh start
# 
# To debug it, run this command after starting the container intereactive mode
# docker run -it -p 0.0.0.0:8080:8080 -p 127.0.0.1:29418:29418 --name my-gerrit cmoulliard/gerrit:1.0 bash
# bash -x ${GERRIT_SITE}/bin/gerrit.sh start

echo "Gerrit started using the java cmd : java -jar ${GERRIT_WAR} daemon -d ${GERRIT_SITE}"
exec java -jar ${GERRIT_WAR} daemon -d ${GERRIT_SITE}
