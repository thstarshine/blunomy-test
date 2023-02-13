resource "google_container_cluster" "blunomy_demo" {
  name     = var.gke_cluster_name
  location = var.gcp_zone
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  networking_mode = "VPC_NATIVE"

  # https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#creating_cluster
  ip_allocation_policy {
    cluster_ipv4_cidr_block = "192.168.0.0/20"
    services_ipv4_cidr_block = "192.168.16.0/20"
  }

  private_cluster_config {
    enable_private_nodes = false
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#enable_private_endpoint
    # * true: the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled
    # * false: either endpoint can be used
    # enable_private_endpoint = false
    # master_ipv4_cidr_block = "172.130.0.0/28"
  }
  // define where we can run `kubectl`
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
      display_name = "public"
    }
  }

  network    = "default"
  subnetwork = "default"
  resource_labels = {
    service = "blunomy-demo"
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "blunomy_demo_nodes" {
  name       = var.gke_node_pool_name
  location   = var.gcp_zone
  cluster    = google_container_cluster.blunomy_demo.name

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool#initial_node_count
  initial_node_count = 1
  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }
  autoscaling {
    min_node_count = 1
    max_node_count = 2
    location_policy = "BALANCED"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "blunomy-demo"
    }

    machine_type = "n1-standard-1"
    tags         = ["blunomy-demo-node"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
