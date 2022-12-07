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
