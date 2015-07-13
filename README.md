# Docker Gerrit Server

Gerrit version supported: [2.11](https://gerrit-documentation.storage.googleapis.com/ReleaseNotes/ReleaseNotes-2.11.html)

## Why use this image?
This is a [Gerrit](https://code.google.com/p/gerrit/) Docker image which can be used to facilitate online code reviews for projects using the Git version control system.

This project improves the existing available Gerrit Docker images as it allows you to control the authentication options (default is OpenID) as well as enable replication to git hosting sites like Github, GitLab, or Gogs.
 

The following gerrit plugins are packaged with this image :

- download-commands (gerrit project)
- delete-project (gerrit project)
- replication (gerrit project)
- add-user-plugin (custom)
- change-project-config (custom)
 

## Automate adding users
The [`add-user-plugin`](https://github.com/cmoulliard/gerrit-create-adminuser-plugin/blob/master/create-users/src/main/java/com/googlesource/gerrit/plugins/AddUser.java) is a custom plugin to automate creation of an Admin user so that you can use this Docker image in an autoamted Continuous Integration/Continuous Delivery platform (like the one we use in [fabric8.io](http://fabric8.io). It can also automate adding users (like those used for automatic code checking, e.g., jenkins or sonaqube users)l

The users to be created can be added using a Docker environment variale `GERRIT_ACCOUNTS` using this convention :

```
GERRIT_ACCOUNTS='user1,fullname1,email1,pwd1,group1:group2:...;user2,fullname2,email2,pwd2,group1:group2:...;...'

Example : -e GERRIT_ACCOUNTS='jenkins,jenkins,jenkins@fabric8.io,secret,Non-Interactive Users:Administrators;sonar,sonar,sonar@fabric8.io,secret,Non-Interactive Users'
```

The Gerrit groups that you can use are : 'Non-Interactive Users','Administrators'

To properly set up the Public keys for the users, you should pass the location of the keys via an environment variable `GERRIT_PUBLIC_KEYS_PATH`. The public keys for both admin and all of the other users (passed as part of the `GERRIT_ACCOUNTS`) should reside in this location and should follow the convention <prefix>userid<suffix> where prefix and suffix are by default `id_` and `_rsa.pub` respectively. You can change these defaults by passing in environment variables to `GERRIT_USER_PUBLIC_KEY_PREFIX` and `GERRIT_USER_PUBLIC_KEY_SUFFIX`. 
  
How the keys get into the container is up to you, though typically bind mounted in as a docker volume. This could also be done in Kubernetes using [secret](http://linkhere.com) volumes.

The volume of the folder containing the public keys of the users must be mounted and the value of the volume passed as an env variable to the docker container ("GERRIT_PUBLIC_KEYS_PATH").

The `admin-user-plugin` uses these env variables :

       -e GERRIT_ADMIN_USER='admin' \
       -e GERRIT_ADMIN_EMAIL='admin@fabric8.io' \
       -e GERRIT_ADMIN_FULLNAME='Administrator' \
       -e GERRIT_ADMIN_PWD='mysecret' \
       -e GERRIT_ACCOUNTS='jenkins,jenkins,jenkins@fabric8.io,secret,Non-Interactive Users:Administrators;sonar,sonar,sonar@fabric8.io,secret,Non-Interactive Users' \
       -e GERRIT_PUBLIC_KEYS_PATH='/VolumeMounted/ssh-keys' 


## Automate updating user groups and permissions
When gerrit starts inside the docker container, it will expose two endpoints/ports: HTTP and SSH. As part of this docker image, we will also start a Java job to update the permissions of the project using the procedure described here ((http://blog.bruin.sg/2013/04/how-to-edit-the-project-config-for-all-projects-in-gerrit/) but implemented using the Eclipse JGit API.

Like the previous plugin, this java job is a custom plugin, [and is not part of the core Gerrit plugins](https://github.com/cmoulliard/gerrit-create-adminuser-plugin/blob/master/change-project-config/src/main/java/io/fabric8/docker/gerrit/ChangeProjectConfig.java#L23-22).

In order to allow the job to run, the private / public keys to be used by the gerrit admin user and also the Root User account must be mounted using Docker volumes.

The java job uses the following env variables :

       -e GERRIT_GIT_LOCALPATH='/home/gerrit/git' \
       -e GERRIT_GIT_PROJECT_CONFIG='/home/gerrit/config/project.config' \
       -e GERRIT_GIT_REMOTEPATH='ssh://admin@localhost:29418/All-Projects' \
       -e GERRIT_ADMIN_PRIVATE_KEY='/path/to/private/id_rsa' \
       -e GERRIT_ADMIN_PRIVATE_KEY_PASSWORD='passcode to use the private key'

## Running this container

To run a daemon container exposing the HTTP server with the port `8080` and the ssh daemon under the port `29418`, launch the following command within a shell terminal

```
docker run -dP -p 0.0.0.0:8080:8080 -p 127.0.0.1:29418:29418 \
       -e GERRIT_GIT_LOCALPATH='/home/gerrit/git' \
       -e GERRIT_GIT_PROJECT_CONFIG='/home/gerrit/configs/project.config' \
       -e GERRIT_GIT_REMOTEPATH='ssh://admin@localhost:29418/All-Projects' \
       -e GIT_SERVER_IP='gogs-http-service.default.local' \
       -e GIT_SERVER_PORT='80' \
       -e GIT_SERVER_USER=root \
       -e GIT_SERVER_PASSWORD=fabric01 \
       -e GIT_SERVER_PROJ_ROOT=root \
       -e GERRIT_ADMIN_USER='admin' \
       -e GERRIT_ADMIN_EMAIL='admin@fabric8.io' \
       -e GERRIT_ADMIN_FULLNAME='Administrator' \
       -e GERRIT_ADMIN_PWD='mysecret' \
       -e GERRIT_ACCOUNTS='jenkins,jenkins,jenkins@fabric8.io,secret,Non-Interactive Users:Administrators;sonar,sonar,sonar@fabric8.io,secret,Non-Interactive Users' \
       -e GERRIT_PUBLIC_KEYS_PATH='/VolumeMounted/ssh-keys' \
       -e GERRIT_ADMIN_PRIVATE_KEY='/VolumeMounted/private-keys' \
       -e AUTH_TYPE='DEVELOPMENT_BECOME_ANY_ACCOUNT' \
       -v /admin_user/home/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
       -v /admin_user/home/.ssh/id_rsa:/root/.ssh/id_rsa \
       -v /accounts/ssh-keys/:/home/gerrit/ssh-keys \       
       -v /home/gerrit-site:/home/gerrit/site \
       --name gerrit-server fabric8/gerrit
```

When the container is created, we mount/map the volume of the host `/home/gerrit-site` to this volume of the docker container `/home/gerrit/site` in order to restore previously configured configurations (database, etc files, ...). The name of the docker container volume can't be changed.

## Environment variables

This image supports different environment variables to specifiy : 

1) Change Project Permissions


- `GERRIT_GIT_LOCALPATH` - location on disk that the gerrit plugin will use to checkout any gerrit-specific config files (default: /home/gerrit/git)
- `GERRIT_GIT_REMOTEPATH` - the location in a running gerrit instance where the config project resides (default: ssh://admin@localhost:29418/All-Projects)
- `GERRIT_GIT_PROJECT_CONFIG` - the config file to use (replace) when updating the gerrit config (default: /home/gerrit/config/project.config)
- `GERRIT_ADMIN_PRIVATE_KEY` - the location and name of the admin private key to use to connect to the gerrit config repo as admin user eg, `/path/to/file/id_rsa`
- `GERRIT_ADMIN_PRIVATE_KEY_PASSWORD` - the password to use the private key, if applicable. if there is no password, just leave it blank



2) Replicate to a Git Server

* `GIT_SERVER_IP` hostname of the Git Server (gogs, gitlab) used to [replicate the git project](https://gerrit.googlesource.com/plugins/replication/+doc/master/src/main/resources/Documentation/config.md)
* `GIT_SERVER_PORT` port of the http Git Server (gogs, gitlab)
* `GIT_SERVER_USER` user name to be used to be authenticated with the Git Http Server when replication will take place 
* `GIT_SERVER_PASSWORD` password of the `GIT_SERVER_USER`
* `GIT_SERVER_PROJ_ROOT` root of the web project hosting the git repositories (Default : root)

3) Admin user & accounts to be created

- `GERRIT_ADMIN_USER` - the name of the admin user to create if one does not exist, or of an existing admin user to update
- `GERRIT_ADMIN_EMAIL` - the email to use for creating/updating the admin user
- `GERRIT_ADMIN_FULLNAME` - the admin user's full name to be displayed, ie, Administrator or John Doe
- `GERRIT_ADMIN_PWD` - the HTTP password to assign to the admin user; can be used for git http access
- `GERRIT_ACCOUNTS` - a `;` delimited string of user accounts to automatically create when first starting up. example: 
    `'jenkins,jenkins,jenkins@fabric8.io,secret,Non-Interactive Users:Administrators;sonar,sonar,sonar@fabric8.io,secret,Non-Interactive Users'`
    the format of the string is `<user_id><full_name><email><password><roles/groups>`
- `GERRIT_PUBLIC_KEYS_PATH` - the location/path on disk for where the admin and any users (if applicable, pass as GERRIT_ACCOUNTS described above) public keys should be found. By default, public keys will be matched by this convention `id_`user_id`_rsa.pub`
         
4) Authentication mode
      
* `AUTH_TYPE` : the authentication mode to use to authenticate the incoming user (Default : OpenID, Values : OpenID, DEVELOPMENT_BECOME_ANY_ACCOUNT, HTTP, LDAP, OAUTH, ...) - See [doc](https://gerrit-documentation.storage.googleapis.com/Documentation/2.11/config-gerrit.html#auth) for more info

## Volumes

This image requires that we pass mount different volumes :

* Host SSH Public Key Volume : Container SSH Public Volume (Example : -v /user/home/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub)
* Host SSH Private Key Volume : Container SSH Private Volume (Example : -v /user/home/.ssh/id_rsa:/root/.ssh/id_rsa)
  
  Those keys will be used by the Java Job to git clone the project using the SSHD of gerrit. The public key will also be imported as the admin user key
  
* Host Gerrit Site generated Volume (backup) : Container Gerrit Site Volume (Example : -v /home/gerrit-site:/home/gerrit/site)
* Host Users/Accounts Public Volume : Container Gerrit SSh-Keys of the accounts (Example : -v /home/accounts/ssh-keys/:/home/gerrit/ssh-keys) 

## Build Docker image and test it

The docker image can be built using pre-defined keys part of that project (located under the folder ssh-keys/admin and ssh-keys/users) and a docker container started. 

For that purpose, use the bash script `/scripts/daemon-interactive` and pass as parameter; the name of the image, your local temp directory hosting the gerrit site generated, the location of the admin ssh keys (private and public) and the location of the users ssh public key

Example :

```
./scripts/daemon-gerrit.sh cmoulliard /Users/chmoulli/Temp/gerrit-site ssh-keys/admin ssh-keys/users

```


