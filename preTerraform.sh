#!/bin/sh

set -e
set -u


  gcloud services enable --project="$PROJECT_ID" \
         "appengine.googleapis.com" \
         "run.googleapis.com" \
         "iap.googleapis.com" \
         "secretmanager.googleapis.com" \
         "cloudbuild.googleapis.com" \
         "monitoring.googleapis.com" \
         "cloudkms.googleapis.com" \
         "sqladmin.googleapis.com" \
         "servicenetworking.googleapis.com" \
         "cloudresourcemanager.googleapis.com"  \
         "artifactregistry.googleapis.com"  

}

echo "PROJECT_ID: $PROJECT_ID"
echo "IS_DEV: $IS_DEV"

PATH=$PATH:/gcloud/bin
gcloud config set auth/impersonate_service_account "sa-terraform@${PROJECT_ID}.iam.gserviceaccount.com"
echo "Adding SA serviceAccount:sa-terraform@${PROJECT_ID}.iam.gserviceaccount.com as object storage admin"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:sa-terraform@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/storage.admin"
