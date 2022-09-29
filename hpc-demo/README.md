# End to end HPC demo
## GKE setup
```
. ./setenv
gcloud container clusters create ${GKE_CLUSTER_NAME} \
       --machine-type=g1-small \
       --num-nodes=1 \
       --enable-autoscaling --min-nodes "0" --max-nodes "3" \
       --zone=${GCP_ZONE} \
       --project=${PROJECT_ID} \
       --cluster-version ${GKE_VERSION} --release-channel ${RELEASE_CHANNEL} \
       --enable-ip-alias \
       --default-max-pods-per-node 50 \
       --autoscaling-profile optimize-utilization \
       --addons=GcpFilestoreCsiDriver \
       --image-type "COS_CONTAINERD" \
       --maintenance-window-start "2022-09-25T04:00:00Z" \
       --maintenance-window-end "2022-09-26T04:00:00Z" \
       --maintenance-window-recurrence "FREQ=WEEKLY;BYDAY=SU" \
       --enable-shielded-nodes 

gcloud container clusters create ${GKE_CLUSTER_NAME} \
       --machine-type=g1-small \
       --num-nodes=1 \
       --enable-autoscaling --min-nodes "0" --max-nodes "3" \
       --region=${GCP_REGION} \
       --node-locations=${GCP_ZONE} \
       --project=${PROJECT_ID} \
       --cluster-version ${GKE_VERSION} --release-channel ${RELEASE_CHANNEL} \
       --enable-ip-alias \
       --default-max-pods-per-node=25 \
       --autoscaling-profile optimize-utilization \
       --addons=GcpFilestoreCsiDriver \
       --image-type "COS_CONTAINERD" \
       --maintenance-window-start "2022-09-25T04:00:00Z" \
       --maintenance-window-end "2022-09-26T04:00:00Z" \
       --maintenance-window-recurrence "FREQ=WEEKLY;BYDAY=SU" 

gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --region ${GCP_REGION} --project ${PROJECT_ID}

kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/k8s-stackdriver/master/custom-metrics-stackdriver-adapter/deploy/production/adapter_new_resource_model.yaml

gcloud container clusters update ${GKE_CLUSTER_NAME} \
    --zone=${GCP_ZONE} \
    --workload-pool=${PROJECT_ID}.svc.id.goog

kubectl create ns burst 

kubectl annotate serviceaccount \
  --namespace burst \
  default \
  iam.gke.io/gcp-service-account=burst-sa@${PROJECT_ID}.iam.gserviceaccount.com \
  --overwrite=true

gcloud beta container node-pools create ${GKE_BURST_POOL} \
       --cluster=${GKE_CLUSTER_NAME} \
       --machine-type=n1-standard-1 \
       --node-labels=gpu=autoscale-to-zero \
       --node-taints=reserved-pool=true:NoSchedule  \
       --num-nodes=0 \
       --enable-autoscaling \
       --min-nodes=0 \
       --max-nodes=4 \
       --zone=${GCP_ZONE} \
       --project=${PROJECT_ID} \
       --node-version=${GKE_VERSION} \
       --workload-metadata=GKE_METADATA
       

gcloud container node-pools create ${GKE_BURST_POOL} \
       --cluster=${GKE_CLUSTER_NAME} \
       --machine-type=n1-standard-1 \
       --node-labels=gpu=autoscale-to-zero \
       --node-taints=reserved-pool=true:NoSchedule  \
       --num-nodes=0 \
       --enable-autoscaling \
       --min-nodes=0 \
       --max-nodes=100 \
       --region=${GCP_REGION} \
       --project=${PROJECT_ID} \
       --node-version=${GKE_VERSION} \
       --workload-metadata=GKE_METADATA \
       --max-pods-per-node=10 \
       --disk-size="25"


cd k8s
kubectl apply -f filestore-storage-class.yaml
kubectl apply -f pvc.yaml -n burst
kubectl apply -f hpc-job-processor-with-filestore-wo-antiaffinity.yaml -n burst
kubectl apply -f hpc-job-processor-hpa-100.yaml -n burst
```