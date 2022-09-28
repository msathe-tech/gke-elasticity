# GKE cluster
resource "google_container_cluster" "primary" {

  provider                  = google-beta
  name                      = "gke-cluster-1"
  location                  = "northamerica-northeast1-a"
  networking_mode           = "VPC_NATIVE"
  initial_node_count        = 1
  default_max_pods_per_node = 50

  node_config {
    machine_type = "g1-small"
  }

  release_channel {
    channel = "RAPID"
  }

  cluster_autoscaling {
    enabled             = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    //still missing control of min and max numbers of nodes
  }

  ip_allocation_policy {}

  addons_config {
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }
}