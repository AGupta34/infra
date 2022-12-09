#!/bin/sh

set -e
set -u

echo "PROJECT_ID=${PROJECT_ID}"

create_bucket()
{
  BUCKET="${PROJECT_ID}-$1"
  echo "Checking to create bucket $BUCKET"
  if gsutil ls -b "gs://${BUCKET}"
  then
    echo "Bucket $1 already exists"
  else
    echo "Creating bucket $1"
    gsutil mb -l northamerica-northeast1 "gs://${BUCKET}"
    echo "Bucket created"
  fi
}

gcloud config set auth/impersonate_service_account sa-terraform@${PROJECT_ID}.iam.gserviceaccount.com
create_bucket 'tf-state'
create_bucket 'reports'
