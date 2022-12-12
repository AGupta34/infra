#!/bin/sh

run_terraform() {
  start_dir=$(pwd)
  cd "terraform" || exit

  echo "Init'ing terraform"
  terraform init -backend-config "bucket=${PROJECT_ID}-tf-state" -backend-config "prefix=$1" || exit

  echo "Planning terraform"
  terraform plan -lock=false
  terraform plan || exit
  
  if [ "$BRANCH_NAME" = "main" ]
  then
      echo "Applying terraform"
      terraform apply -auto-approve || exit
  fi

  cd "$start_dir" || exit
}


PATH=$PATH:/gcloud/bin
export TF_VAR_project=${PROJECT_ID}
export TF_VAR_branch_tag=${BRANCH_TAG}

echo "===================================================================="
echo "Prepping infrastructure as defined in ${BRANCH_NAME}"
echo "===================================================================="

run_terraform "${PROJECT_ID}"
rm -rf /var/lib/apt/lists/*
