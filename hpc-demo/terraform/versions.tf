terraform {
  required_version = ">= 1.3.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.38.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}