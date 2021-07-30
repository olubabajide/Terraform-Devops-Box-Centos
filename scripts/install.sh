#!/bin/bash
set -x

TERRAFORM_VERSION="1.0.3"
PACKER_VERSION="1.7.4"
# create new ssh key
[[ ! -f /home/centos/.ssh/mykey ]] \
&& useradd centos && echo "password" |passwd --stdin centos
mkdir -p /home/centos/.ssh 
ssh-keygen -f /home/centos/.ssh/mykey 
chown -R centos:centos /home/centos/.ssh

# install packages
yum -y update 
yum -y install epel-release
yum -y install ansible
yum -y install wget
yum -y install unzip
yum makecache

# install pip
yum install -y python2 python38 python39

if [[ $? == 127 ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    python3 get-pip.py
fi
# install awscli and ebcli
yum install -y awscli

#terraform
T_VERSION=$(terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
T_VERSION=$(terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)

# packer
P_VERSION=$(packer -v)
P_RETVAL=$?

[[ $P_VERSION != $PACKER_VERSION ]] || [[ $P_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
&& unzip -o packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm packer_${PACKER_VERSION}_linux_amd64.zip

# clean up
yum clean
