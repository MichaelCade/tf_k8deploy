provider "aws" {
  region = "us-east-2"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

locals {
  tags = {
    Project   = "Terraform K8s Example Applications"
    Terraform = "True"
  }
}