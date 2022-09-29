terraform {
  required_version = ">= 1.2.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.38.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.1.0"
    }
  }
}