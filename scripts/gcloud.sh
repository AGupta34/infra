#!/bin/bash
set -e
cd /tmp
mkdir tmp
cd tmp
curl -s -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-367.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-sdk-367.0.0-linux-x86_64.tar.gz
mv google-cloud-sdk /gcloud && rm google-cloud-sdk-367.0.0-linux-x86_64.tar.gz
/gcloud/install.sh -q --path-update=true
/gcloud/bin/gcloud components update -q
/gcloud/bin/gcloud components install alpha
rm -rf /tmp/tmp

rm -rf /var/lib/apt/lists/*
