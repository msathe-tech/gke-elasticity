export PROJECT_ID="prj-gke-mt-spike"
export GCP_ZONE="us-east1-b"
export GKE_CLUSTER_NAME="hpc-demo-cluster"
export GKE_BURST_POOL="burst-zone"
export GKE_VERSION="1.25.0-gke.1100"
pwd=`pwd`
export KUBECONFIG="${pwd}/my-kubeconfig"