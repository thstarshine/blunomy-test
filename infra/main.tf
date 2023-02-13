terraform {
  backend "local" {
    # This is only for demo purpose. The state will not persist between each GitHub Action pipeline.
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.17.0"
    }
  }
  required_version = ">= 1.3.2"
}

variable "gcp_project" { type = string }
variable "gcp_region" { type = string }
variable "gcp_zone" { type = string }
variable "gke_cluster_name" { type = string }
variable "gke_node_pool_name" { type = string }

provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = var.gcp_zone
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.blunomy_demo.endpoint}"
  token                  = data.google_client_config.blunomy_demo.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.blunomy_demo.master_auth[0].cluster_ca_certificate)
}
# Access the configuration of the Google Cloud provider.
data "google_client_config" "blunomy_demo" {
  depends_on = [google_container_cluster.blunomy_demo]
}
data "google_container_cluster" "blunomy_demo" {
  name = var.gke_cluster_name
  location = var.gcp_zone
  depends_on = [google_container_cluster.blunomy_demo]
}
