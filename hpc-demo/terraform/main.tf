variable "gke_cluster_name" {
  default     = "gke-cluster-1"
  description = "Name of the GKE Cluster"
}

variable "gke_cluster_location" {
  default     = "northamerica-northeast1-a"
  description = "GCP Region or Zone of the GKE Cluster"
}

# GKE cluster
resource "google_container_cluster" "primary" {

  name               = var.gke_cluster_name
  location           = var.gke_cluster_location
  project            = "jacobzhang-sandbox-1"
  network            = "sandbox-vpc-1"
  networking_mode    = "VPC_NATIVE"
  initial_node_count = 2

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

provider "kubectl" {
  host                   = google_container_cluster.primary.endpoint
  //client_key             = google_container_cluster.primary.master_auth.0.client_key
  //client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
  //cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  load_config_file       = false
}

data "http" "adapter_new_resource_model_yaml" {
  url = "https://raw.githubusercontent.com/GoogleCloudPlatform/k8s-stackdriver/master/custom-metrics-stackdriver-adapter/deploy/production/adapter_new_resource_model.yaml"
}

resource "kubectl_manifest" "my_service" {
  yaml_body = data.http.adapter_new_resource_model_yaml.response_body
}