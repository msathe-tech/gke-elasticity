# Use Case 2: Autoscale GKE to using external metric 

## Architecture
We are going to demonstrate the use case using PubSub instead of RabbitMQ. 
Idea is to load messages/jobs to PubSub topic. The GKE app will autoscale to process the messages/jobs.
With pod autoscaling we will also see the Nodes autoscaling. Once all the messages/jobs are processed the pods will scale down to zero.
With that the nodes too will scale down to zero.


Following is the 
![architecture](hpc-jobs-gke-autoscale.png) of this demos.

## Prereq
The demo is currently hardcoded to a project name and topics/subscriptions in the project. 
Following is the project name 
- prj-gke-mt-spike
Following are the topics we need to configure 
- projects/prj-gke-mt-spike/topics/topic-one
- projects/prj-gke-mt-spike/topics/topic-two

Following are the subscriptions we need to configure 
- projects/prj-gke-mt-spike/subscriptions/sub-one
  - Please configure this Subscription to use a Label `subscription_id: sub-one`
- projects/prj-gke-mt-spike/subscriptions/sub-two

## Logical steps 
1. Create a regular GKE cluster 
2. Setup custom stackdriver metrics
3. Update cluster to use Workload Identity
4. Create a new nodepool for app workload 
5. Setup IAM SA on the new namespace 

## GKE setup
```
. ./setenv
gcloud container clusters create ${GKE_CLUSTER_NAME} \
       --machine-type=g1-small \
       --num-nodes=1 \
       --enable-autoscaling --min-nodes "0" --max-nodes "3" \
       --zone=${GCP_ZONE} \
       --project=${PROJECT_ID} \
       --cluster-version "1.24.3-gke.200" --release-channel "rapid" \
       --enable-ip-alias \
       --default-max-pods-per-node 50 \
       --autoscaling-profile optimize-utilization

gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --zone ${GCP_ZONE} --project ${PROJECT_ID}

gcloud container clusters update ${GKE_CLUSTER_NAME} \
    --zone=${GCP_ZONE} \
    --workload-pool=${PROJECT_ID}.svc.id.goog

kubectl create ns burst 

kubectl annotate serviceaccount \
  --namespace burst \
  default \
  iam.gke.io/gcp-service-account=burst-sa@${PROJECT_ID}.iam.gserviceaccount.com \
  --overwrite=true

gcloud container node-pools create ${GKE_BURST_POOL} \
       --cluster=${GKE_CLUSTER_NAME} \
       --machine-type=n1-standard-2 \
       --node-labels=gpu=autoscale-to-zero \
       --node-taints=reserved-pool=true:NoSchedule  \
       --num-nodes=0 \
       --enable-autoscaling \
       --min-nodes=0 \
       --max-nodes=4 \
       --zone=${GCP_ZONE} \
       --project=${PROJECT_ID} \
       --node-version="1.24.3-gke.200" \
       --workload-metadata=GKE_METADATA

cd k8s
kubectl apply -f hpc-job-processor.yaml -n burst
kubectl apply -f hpc-job-processor-hpa.yaml -n burst
```