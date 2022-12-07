#!/bin/sh

set -e
set -u

run_common_pre_terraform_items() {
  echo "There are no common pre terraform items to apply"
}
run_pre_terraform_items() {
  if [ "${IS_DEV}" = "true" ]; then
    echo "Provisioning Infrastructure.  Granting firestore admin to th-gcp-rapids-contributors"
    gcloud projects add-iam-policy-binding "${RAPIDS_PROJECT_ID}" --member='group:th-gcp-rapids-contributors@telushealth.com' --role='roles/datastore.owner'

    echo "Granting fhirStore admin to th-gcp-rapids-contributors and th-gcp-rapids-architects"
    gcloud projects add-iam-policy-binding "${RAPIDS_PROJECT_ID}" --member='group:th-gcp-rapids-contributors@telushealth.com' --role='roles/healthcare.fhirStoreAdmin'
    gcloud projects add-iam-policy-binding "${RAPIDS_PROJECT_ID}" --member='group:th-gcp-rapids-contributors@telushealth.com' --role='roles/healthcare.fhirResourceEditor'

    gcloud projects add-iam-policy-binding "${RAPIDS_PROJECT_ID}" --member='group:th-gcp-rapids-architects@telushealth.com' --role='roles/healthcare.fhirStoreAdmin'
    gcloud projects add-iam-policy-binding "${RAPIDS_PROJECT_ID}" --member='group:th-gcp-rapids-architects@telushealth.com' --role='roles/healthcare.fhirResourceEditor'
    gcloud projects add-iam-policy-binding "${RAPIDS_PROJECT_ID}" --member='group:th-gcp-rapids-architects@telushealth.com' --role='roles/secretmanager.secretAccessor'

    echo "Provisioned"
  fi

  gcloud services enable --project="$PROJECT_ID" \
         "dns.googleapis.com" \
         "appengine.googleapis.com" \
         "firestore.googleapis.com" \
         "domains.googleapis.com" \
         "run.googleapis.com" \
         "iap.googleapis.com" \
         "secretmanager.googleapis.com" \
         "healthcare.googleapis.com" \
         "cloudbuild.googleapis.com" \
         "bigquery.googleapis.com" \
         "dlp.googleapis.com" \
         "monitoring.googleapis.com" \
         "cloudkms.googleapis.com"

  gcloud services enable --project="$PROJECT_ID" \
         "sqladmin.googleapis.com" \
         "servicenetworking.googleapis.com" \
         "dlp.googleapis.com"  \
         "cloudresourcemanager.googleapis.com"  \
         "artifactregistry.googleapis.com"  \
         "secretmanager.googleapis.com" \
         "iap.googleapis.com" \
         "dns.googleapis.com"  \
         "domains.googleapis.com" \
         "monitoring.googleapis.com" \
         "cloudkms.googleapis.com"

}

echo "PROJECT_ID: $PROJECT_ID"
echo "IS_DEV: $IS_DEV"

PATH=$PATH:/gcloud/bin
gcloud config set auth/impersonate_service_account "sa-terraform@${PROJECT_ID}.iam.gserviceaccount.com"
echo "Adding SA serviceAccount:sa-terraform@${PROJECT_ID}.iam.gserviceaccount.com as object storage admin"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:sa-terraform@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/storage.admin"

run_common_pre_terraform_items
run_pre_terraform_items
