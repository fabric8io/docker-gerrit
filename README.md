# Docker Gerrit Server

Gerrit version supported: [2.11](https://gerrit-documentation.storage.googleapis.com/ReleaseNotes/ReleaseNotes-2.11.html))

This is a [Gerrit](https://code.google.com/p/gerrit/) Docker image which runs a ssh & web server of the gerrit based code review system, facilitating online code reviews for projects using the Git version control system.
the project improves existing available Gerrit Docker images as it support to pass as parameter the authentication mode to be ised and the env variables to be used to replicate
the git repositories with a Git Server platform like Gogs or Gitlab.

The following gerrit plugins are packaged with this image :

- download-commands
- delete-project
- replication


# Running this container

To run a daemon container exposing the HTTP server with the port `8080` and the ssh daemon under the port 29418` , launch the following command within a unix terminal

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
       -e AUTH_TYPE='DEVELOPMENT_BECOME_ANY_ACCOUNT' \
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


