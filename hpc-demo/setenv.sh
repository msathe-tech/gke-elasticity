export PROJECT_ID="prj-gke-mt-spike"
export GCP_ZONE="us-east1-b"
export GCP_REGION="us-east1"
export GKE_CLUSTER_NAME="hpc-demo-cluster"
export GKE_BURST_POOL="burst-zone"
export GKE_VERSION="1.24.2-gke.1900"
export RELEASE_CHANNEL="regular"
pwd=`pwd`
export KUBECONFIG="${pwd}/my-kubeconfig"