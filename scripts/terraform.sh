#!/bin/bash
set -e
apt-get -qq update --fix-missing
apt-get -qq install -y gnupg2 lsb-release
apt-get -qq clean all
apt-get -qq install -y software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get -qq update
apt-get -qq install -y terraform
