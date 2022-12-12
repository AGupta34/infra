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
  project      = var.project_id
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

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
  project = var.project_id
}

# It will allow Cloud SQL to be accessible from Cloud Run

resource "google_compute_global_address" "google_managed_services_vpn_connector" {
    name          = "google-managed-services-vpn-connector"
    purpose       = "VPC_PEERING"
    address_type  = "INTERNAL"
    prefix_length = 16
    network       = google_compute_network.vpc_network.name
    project       = var.project_id
}
resource "google_service_networking_connection" "vpcpeerings" {
    network                 = "${google_compute_network.vpc_network.self_link}"
    service                 = "servicenetworking.googleapis.com"
    reserved_peering_ranges = [google_compute_global_address.google_managed_services_vpn_connector.name]
}

# Connects Cloud Run to Database and Caching 

resource "google_vpc_access_connector" "connector" {
    provider      = google-beta
    project       = var.project_id
    name          = "vpc-connector"
    ip_cidr_range = "10.8.0.0/28"
    network       = "${google_compute_network.vpc_network.name}"
    region        = "northamerica-northeast1"
    depends_on    = [google_compute_global_address.google_managed_services_vpn_connector]
}

resource "google_redis_instance" "todo_cache" {
    authorized_network      = "${google_compute_network.vpc_network.name}"
    connect_mode            = "DIRECT_PEERING"
    location_id             = "northamerica-northeast1-a"
    memory_size_gb          = 1
    name                    = "${var.basename}-cache"
    project                 = var.project_id
    redis_version           = "REDIS_6_X"
    region                  = "northamerica-northeast1"
    reserved_ip_range       = "10.137.125.88/29"
    tier                    = "BASIC"
    transit_encryption_mode = "DISABLED"
}

resource "google_sql_database_instance" "todo_database" {
    name="${var.basename}-db"
    database_version = "MYSQL_5_7"
    region           = "northamerica-northeast1"
    project          = var.project_id
    settings {
        tier                  = "db-g1-small"
        disk_autoresize       = true
        disk_autoresize_limit = 0
        disk_size             = 10
        disk_type             = "PD_SSD"
        ip_configuration {
            ipv4_enabled    = "false"
            private_network = "projects/${var.project_id}/global/networks/${google_compute_network.vpc_network.name}"
        }
        location_preference {
            zone = "northamerica-northeast1-a"
        }
    }
    deletion_protection = false
    depends_on = [
        google_service_networking_connection.vpcpeerings
    ]
    # This handles loading the schema after the database installs.
    provisioner "local-exec" {
        working_dir = "../../database"
        command     = "./load_schema.sh ${var.project_id} ${google_sql_database_instance.todo_database.name}"
    }
}
