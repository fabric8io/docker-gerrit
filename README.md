# Docker Gerrit Server

Gerrit version supported: [2.11](https://gerrit-documentation.storage.googleapis.com/ReleaseNotes/ReleaseNotes-2.11.html)

This is a [Gerrit](https://code.google.com/p/gerrit/) Docker image which runs a ssh & web server of the gerrit based code review system, facilitating online code reviews for projects using the Git version control system.
the project improves existing available Gerrit Docker images as it support to pass as parameter the authentication mode, the env variables to be used to replicate
the git repositories with a Git Server platform like Gogs or Gitlab.

The following gerrit plugins are packaged with this image :

- download-commands
- delete-project
- replication
- create-user-plugin. This plugin will add new users to the database created by Gerrit during the creation of the site. The users to be created can be created using a Gerrit ENV VAR : GERRIT_USERS_ACCOUNT

Remark: When the Gerrit SSHD & HTTP Servers will be launched by the Docker container, we will also launch a Java job in charge to update the permissions of the project using the procedure described here ((http://blog.bruin.sg/2013/04/how-to-edit-the-project-config-for-all-projects-in-gerrit/) but implemented
using the Eclipse JGit API. In order to allow the job to run, the private / public keys to be used by the gerrit admin user and also the Root User account must be mounted using Docker volumes.

# Running this container

To run a daemon container exposing the HTTP server with the port `8080` and the ssh daemon under the port `29418`, launch the following command within a unix terminal

```
docker run -dP -p 0.0.0.0:8080:8080 -p 127.0.0.1:29418:29418 |
       -e GIT_SERVER_IP='gogs-http-service.default.local' \
       -e GIT_SERVER_PORT='80' \
       -e GIT_SERVER_USER=root \
       -e GIT_SERVER_PASSWORD=fabric01 \
       -e GIT_SERVER_PROJ_ROOT=root \
       -e GERRIT_ADMIN_USER='admin' \
       -e GERRIT_ADMIN_EMAIL='admin@fabric8.io' \
       -e GERRIT_ADMIN_FULLNAME='Administrator' \
       -e GERRIT_ADMIN_PWD='mysecret' \
       -e GERRIT_GIT_LOCALPATH='/home/gerrit/git' \
       -e GERRIT_GIT_PROJECT_CONFIG='/home/gerrit/config/project.config' \
       -e GERRIT_GIT_REMOTEPATH='ssh://admin@localhost:29418/All-Projects' \
       -e AUTH_TYPE='DEVELOPMENT_BECOME_ANY_ACCOUNT' \
       -v /user/home/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
       -v /user/home/.ssh/id_rsa:/root/.ssh/id_rsa \
       -v /home/gerrit-site:/home/gerrit/site \
       --name gerrit-server fabric8/gerrit
```

Remark : When the container is created, we mount/map the volume of the host `/home/gerrit-site` to this volume of the docker container `/home/gerrit/site` in order to restore previously configured configurations (database, etc files, ...). The name of the docker container volume can't be changed.

# Environment variables

This image supports different environment variables to specifiy : 

* `AUTH_TYPE` : the authentication mode to use to authenticate the incoming user (Default : OpenID, Values : OpenID, DEVELOPMENT_BECOME_ANY_ACCOUNT, HTTP, LDAP, OAUTH, ...) - See [doc](https://gerrit-documentation.storage.googleapis.com/Documentation/2.11/config-gerrit.html#auth) for more info
* `GIT_SERVER_IP` hostname of the Git Server (gogs, gitlab) used to [replicate the git project](https://gerrit.googlesource.com/plugins/replication/+doc/master/src/main/resources/Documentation/config.md)
* `GIT_SERVER_PORT` port of the http Git Server (gogs, gitlab)
* `GIT_SERVER_USER` user name to be used to be authenticated with the Git Http Server when replication will take place 
* `GIT_SERVER_PASSWORD` password of the `GIT_SERVER_USER`
* `GIT_SERVER_PROJ_ROOT` root of the web project hosting the git repositories (Default : root)
* `GERRIT_ADMIN_USER` admin user to be created in order to log in to the gerrit http server (Default: admin)
* `GERRIT_ADMIN_EMAIL` email address of the admin user. Could be used to send email notification during review process (Default: admin@fabric8.io)
* `GERRIT_ADMIN_FULLNAME` full name of the Administrator (Default: Administrator)
* `GERRIT_ADMIN_PWD` password used for http access to the web site (Default: mysecret)
* `GERRIT_GIT_LOCALPATH` Temporary folder used to clone locally the Git AllProjects Repo of gerrit (Default : /home/gerrit/git)
* `GERRIT_GIT_PROJECT_CONFIG` Location of the project config file to be changed within the Gerrit Git AllProjects repo (Default: /home/gerrit/config/project.config)
* `GERRIT_GIT_REMOTEPATH` git ssh address of the Gerrit Git Repo containing the Project Permissions (Default : ssh://admin@localhost:29418/All-Projects)

# Volumes

This image requires that we pass mount different volumes :

* Host SSH Public Key Volume : Container SSH Public Volume (Example : -v /user/home/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub)
* Host SSH Private Key Volume : Container SSH Private Volume (Example : -v /user/home/.ssh/id_rsa:/root/.ssh/id_rsa)
  
  Those keys will be used by the Java Job to git clone the project using the SSHD of gerrit. The public key will also be imported as the admin user key
  
* Host Gerrit Site generated Volume (backup) : Container Gerrit Site Volume (Example :-v /home/gerrit-site:/home/gerrit/site)


