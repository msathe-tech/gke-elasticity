For deployment with Terraform

Disclaimer: 
This Terraform template utilizes a widely used third-party Terraform provider "gavinbunney/kubectl."
Please use at your own risk.

1. Make sure Kubernetes API is enabled in your GCP environment. Here is a direct link.
https://console.cloud.google.com/marketplace/product/google/container.googleapis.com

2. Download the "terraform" folder in this repo to where you usually maintain your Terraform deployments.

3. Edit the variables in "terraform.tfvars" according to your own environment.

4. Deploy the Terraform template after you configure your Terraform authentication to your GCP environment. 
Here is a link to the official how-to guide.
https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication