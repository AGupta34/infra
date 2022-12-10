provider "google" {
  region  = var.location
}

provider "google-beta" {
  region  = var.location
}

terraform {
  backend "gcs" {
  }
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_artifact_registry_repository" "docker-builds" {
  project = var.project_id
  provider = google-beta
  location = var.location
  repository_id = "docker-builds"
  description = "Docker Builds"
  format = "DOCKER"
}

resource "google_service_account" "cloud-run-sa" {
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
  project      = var.project
}

resource "google_project_iam_member" "sa-editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.cloud-run-sa.email}"
}

resource "google_project_iam_member" "object-storage-admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:sa-terraform@${var.project_id}.iam.gserviceaccount.com"
}
resource "google_project_iam_member" "storage-admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:sa-terraform@${var.project_id}.iam.gserviceaccount.com"
}