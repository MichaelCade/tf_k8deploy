terraform {
  backend "gcs" {
    bucket = "tf_k8deploy_150422"
    prefix = "learn-terraform-provision-gke-cluster/terraform"
  }
}