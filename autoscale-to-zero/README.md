# Autoscale to zero nodepool demo

### Create a GKE cluster
gcloud container clusters create ${GKE_CLUSTER_NAME} \
       --machine-type=g1-small \
       --num-nodes=1 \
       --enable-autoscaling --min-nodes "0" --max-nodes "3" \
       --zone=${GCP_ZONE} \
       --project=${PROJECT_ID} \
       --cluster-version "1.24.3-gke.200" --release-channel "rapid" \
       --enable-ip-alias \
       --default-max-pods-per-node 50 \
       --autoscaling-profile optimize-utilization \
       --workload-pool=${PROJECT_ID}.svc.id.goog

### Add a node pool
gcloud container node-pools create ${GKE_BURST_POOL} \
       --cluster=${GKE_CLUSTER_NAME} \
       --machine-type=n1-standard-2 \
       --node-labels=gpu=tesla-v100 \
       --node-taints=reserved-pool=true:NoSchedule  \
       --num-nodes=0 \
       --enable-autoscaling \
       --min-nodes=0 \
       --max-nodes=4 \
       --zone=${GCP_ZONE} \
       --project=${PROJECT_ID} \
       --node-version="1.24.3-gke.200"

