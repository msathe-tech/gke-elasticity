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

data "google_client_config" "provider" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.provider.access_token
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "scalable-nginx-example"
    labels = {
      App = "ScalableNginxExample"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "ScalableNginxExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableNginxExample"
        }
      }
      spec {
        container {
          image = "nginx:1.7.8"
          name  = "example"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}