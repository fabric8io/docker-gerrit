#!/usr/bin/env bash


# Cmds to be issued within Vagrant machine
# sudo mkdir -p /home/gerrit/admin-ssh-key/
# sudo chown -R vagrant /home/gerrit/
# mkdir -p /home/gerrit/ssh-keys/
# sudo chown -R vagrant /home/gerrit/ssh-keys/

cd /Users/chmoulli/Fuse/projects/fabric8/fabric8-forked

# Change these settings to match what you are wanting to do
ROOT='/Users/chmoulli/Fuse/Fuse-projects/fabric8/docker-gerrit/ssh-keys'
PATH='/home/gerrit/ssh-keys'
SERVER='vagrant.local'
IDENTITY='/Users/chmoulli/Fuse/Fuse-projects/fabric8/fabric8-forked/.vagrant/machines/default/virtualbox/private_key'

/usr/bin/scp -i $IDENTITY $ROOT/* vagrant@$SERVER:$PATH