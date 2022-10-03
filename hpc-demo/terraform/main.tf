variable "project_id" {
  description = "GCP Project ID where clusters will be deployed"
}

variable "gke_cluster_name" {
  default     = "gke-cluster-1"
  description = "Name of the GKE Cluster"
}

variable "gke_cluster_location" {
  default     = "northamerica-northeast1"
  description = "GCP Region or Zone of the GKE Cluster"
}

variable "gke_burst_pool_name" {
  default     = "gke-burst-pool-1"
  description = "Name of the autoscaling GKE node pool"
}

# GKE cluster for HPC demo
resource "google_container_cluster" "primary" {

  name               = var.gke_cluster_name
  location           = var.gke_cluster_location
  project            = var.project_id
  network            = "sandbox-vpc-1"
  networking_mode    = "VPC_NATIVE"
  initial_node_count = 2
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  node_config {
    machine_type = "g1-small"
    shielded_instance_config {
      enable_secure_boot = true
    }
  }

  release_channel {
    channel = "RAPID"
  }

  ip_allocation_policy {}

  addons_config {
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = "2022-09-25T04:00:00Z"
      end_time   = "2022-09-26T04:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SU"
    }
  }
}

# Fetching GCP client config data for kubectl authentication
data "google_client_config" "provider" {}

# Authenticating kubectl to GKE
provider "kubectl" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.provider.access_token
}

# Fetching Kubernetes document from YAML file
data "kubectl_path_documents" "manifests" {
  pattern = "adapter_new_resource_model.yaml"
}

# Parsing multi-doc YAML file
resource "kubectl_manifest" "test" {
  for_each  = toset(data.kubectl_path_documents.manifests.documents)
  yaml_body = each.value
}

# An autoscaling node pool for the demo
resource "google_container_node_pool" "np" {

  depends_on = [
    kubectl_manifest.test
  ]

  name     = var.gke_burst_pool_name
  cluster  = google_container_cluster.primary.id
  location = google_container_cluster.primary.location
  version  = google_container_cluster.primary.master_version

  initial_node_count = 0
  max_pods_per_node  = 10

  node_config {
    machine_type = "n1-standard-1"
    disk_size_gb = 25
    labels = {
      gpu = "autoscale-to-zero"
    }
    taint {
      effect = "NO_SCHEDULE"
      key    = "reserved-pool"
      value  = "true"
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 100
  }
}