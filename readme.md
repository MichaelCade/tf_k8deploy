# tf_k8deploy

<!-- TOC -->

- [tf_k8deploy](#tf_k8deploy)
- [Introduction](#introduction)
- [Deploy a New Cluster with GitHub Actions](#deploy-a-new-cluster-with-github-actions)
  - [Requirements](#requirements)
  - [Google Cloud Account](#google-cloud-account)
  - [GitHub Actions Secret](#github-actions-secret)
  - [Trigger CI to Create a New GKE Cluster](#trigger-ci-to-create-a-new-gke-cluster)
  - [Destroy an Existing GKE Cluster](#destroy-an-existing-gke-cluster)
- [Deploy a New Cluster with your Workstation](#deploy-a-new-cluster-with-your-workstation)
  - [Step 1 - Deploy GKE Cluster](#step-1---deploy-gke-cluster)
- [Configure access to your GKE Cluster with kubectl](#configure-access-to-your-gke-cluster-with-kubectl)

<!-- /TOC -->
---
# Introduction

We will deploy a new GKE cluster with **Terraform** to Google Cloud with GitHub Actions.

There are six stages in the CI, of which the last two stages are conditional.
* terraform init
* terraform validate
* terraform state list
* terraform plan
* terraform apply (conditional)
* terraform destroy (conditional)

There are two ways of triggering the CI:
* Create a `pull_request`
  * Init, Validate, State List, Plan
* Merge `pull_request` to `main` branch
  * Init, Validate, State List, Plan
  * Apply | Destroy (either condition)

Conditions:
* The `terraform apply` stage runs on merge, if pull request's branch name does not start with `destroy`.
* The `terraform destroy` stage runs on merge, if pull request's branch name starts with `destroy`.

---
# Deploy a New Cluster with GitHub Actions

## Requirements

* Google Cloud Account
  * Project
  * Region
  * Service Account
  * Storage
* `gcloud`
* `kubectl`
* `terraform`

## Google Cloud Account

<details>
<summary>Click here to <strong>setup your Google Cloud Account.</strong></summary>
1. Create a [New GCP Account](https://cloud.google.com/free) with $300 in free credits for three months (credit card required).

2. Navigate to the GCP Console and create a New GCP Project, e.g. `tf-k8deploy`.

3. Navigate to the Storage and create a New GCP Storage, e.g. `tf-k8deploy`.

4. Navigate to IAM and create a [Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts) under the new project.

5. Under the new service account menu, Click on Manage Keys, then Add Key > Create New Key. You will need this key in your GitHub Actions secrets.

> Download and save the key as JSON file for your Google credentials.
</details>

## GitHub Actions Secret

<details>
<summary>Click here to <strong>setup your GitHub Actions Secret.</strong></summary>
1. Navigate to your GitHub repo and Click Settings. 

2. Under Security menu, Click Secrets > Actions.

3. Click New Repository Secret, and enter the following:
  * Name: `GOOGLE_CREDENTIALS`
  * Value: *Copy and paste the contents of your Google credentials JSON file. For example:*
```json
{
  "type": "service_account",
  "project_id": "tf-k8deploy",
  "private_key_id": "PRIVATE_KEY_ID",
  "private_key": "PRIVATE_KEY",
  "client_email": "CLIENT_EMAIL",
  "client_id": "CLIENT_ID",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/sa-tf-k8deploy%40tf-k8deploy.iam.gserviceaccount.com"
}
```
</details>

## Trigger CI to Create a New GKE Cluster

1. Clone this repo to your workstation.

2. Navigate to your GitHub repo folder and create a new git branch.

```sh
git checkout -b BRANCH_NAME
```

3. Navigate to the subfolder `cd learn-terraform-provision-gke-cluster`.

4. Update the `terraform.tfvars` file with your PROJECT_ID and GCP_REGION. 

> Find the cheapest instance by provider and `region` at [Instance Pricing](https://www.instance-pricing.com)

```yml
project_id = "PROJECT_ID"
region     = "GCP_REGION"
```

5. Add and commit the file, then `git push --set-upstream origin BRANCH_NAME`

6. Navigate to your GitHub console and create a merge request. This will trigger a GitHub Actions CI.

7. Merge your pull request to `main` branch to perform `terraform apply`.

## Destroy an Existing GKE Cluster

1. Create a new branch that starts with 'destroy', e.g. `destroy_mybranch`

2. Update any file.

3. Add and commit the file, then `git push --set-upstream origin DESTROY_BRANCH_NAME`.

4. Navigate to your GitHub console and create a merge request. This will trigger a GitHub Actions CI.

5. Merge your pull request to `main` branch to perform `terraform destroy`.

---
# Deploy a New Cluster with your Workstation

## Step 1 - Deploy GKE Cluster
Navigate to code repository for GKE Deployment 

```
cd learn-terraform-provision-gke-cluster 
```
Initialize the Terraform code with the following command

```
terraform init
gcloud auth application-default login
```
Open the file `terraform.tfvars` and change the values to your GCP.

```
project_id = "tf-k8deploy"
region     = "us-central1"
```
Provision the GKE Cluster with the following command 

```
terraform plan
terraform apply
``` 
The above will run through the code and confirm that terraform will deploy a total number of resources (2-node separately managed node pool GKE cluster using Terraform. This GKE cluster will be distributed across multiple zones for high availability. it will also create VPC) you should respond "yes" to this in the "enter a value" prompt if you wish to auto approve this you could run 

```
terraform apply --auto-approve
```
The above process will likely take around 5-10 minutes to complete successfully. Ensure that the following objects were created using command `terraform state list`.

```
google_compute_network.vpc
google_compute_subnetwork.subnet
google_container_cluster.primary
google_container_node_pool.primary_nodes
```
Delete the GKE Cluster when not in used to save on cost.

```
terraform destroy
```

# Configure access to your GKE Cluster with kubectl 

``` 
gcloud auth login
gcloud config set project PROJECT_ID
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)
```

confirm now that you have connected to the correct GKE Cluster with the following 

```
kubectl get nodes
```

You can also check the contexts available within the KUBECONFIG file by using the following command 

```
kubectl config get-contexts
```

> At this stage we have a fully working Kubernetes cluster running in Google Cloud.