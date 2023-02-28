export PROJECT_ID="hpc-feb-2023"
export GCP_ZONE="us-central1-c"
export GKE_CLUSTER_NAME="external-metrics-autoscale"
export GKE_BURST_POOL="burst-zone"
pwd=`pwd`
export KUBECONFIG="${pwd}/my-kubeconfig"
export GCP_SA="burst-sa"
export GKE_VERSION="1.24.9-gke.3200"