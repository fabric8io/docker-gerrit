#!/usr/bin/env bash


# Cmds to be issued within Vagrant machine
# sudo mkdir -p /home/gerrit/admin-ssh-key/
# sudo chown -R vagrant /home/gerrit/
# mkdir -p /home/gerrit/ssh-keys/
# sudo chown -R vagrant /home/gerrit/ssh-keys/

cd /Users/chmoulli/Fuse/projects/fabric8/fabric8-forked

# Change these settings to match what you are wanting to do
ROOT='/Users/chmoulli/Fuse/Fuse-projects/fabric8/docker-gerrit/ssh-keys/'
FILE1=$ROOT/admin/id_rsa
FILE2=$ROOT/admin/id_rsa.pub
FILE3=$ROOT/users/id_jenkins_rsa.pub
FILE4=$ROOT/users/id_sonar_rsa.pub
PATH1='/home/gerrit/admin-ssh-key'
PATH2='/home/gerrit/ssh-keys'
SERVER='vagrant.local'
IDENTITY='/Users/chmoulli/Fuse/Fuse-projects/fabric8/fabric8-forked/.vagrant/machines/default/virtualbox/private_key'

/usr/bin/scp -i $IDENTITY $FILE1 $FILE2 vagrant@172.28.128.4:$PATH1
/usr/bin/scp -i $IDENTITY $FILE3 $FILE4 vagrant@172.28.128.4:$PATH2