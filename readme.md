# tf_k8deploy

<!-- TOC -->

- [tf_k8deploy](#tf_k8deploy)
- [Introduction](#introduction)
- [Deploy a New Cluster with GitHub Actions](#deploy-a-new-cluster-with-github-actions)
  - [Requirements](#requirements)
  - [Step 1. Google Cloud Account](#step-1-google-cloud-account)
  - [Step 2. GitHub Actions Secret](#step-2-github-actions-secret)
  - [Step 3. Trigger CI to Create a New GKE Cluster](#step-3-trigger-ci-to-create-a-new-gke-cluster)
  - [Step 4. Destroy an Existing GKE Cluster](#step-4-destroy-an-existing-gke-cluster)
- [Deploy a New Cluster with your Workstation](#deploy-a-new-cluster-with-your-workstation)
- [Configure access to your GKE Cluster with kubectl](#configure-access-to-your-gke-cluster-with-kubectl)

<!-- /TOC -->
---
# Introduction

This project deploys a new GKE cluster using Infrastructure-as-Code to Google Cloud with GitHub Actions CI.

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
* The `terraform apply` stage runs on merge, if a file named `destroy.tf` does not exist.
* The `terraform destroy` stage runs on merge, if a file named `destroy.tf` exists.

---
# Deploy a New Cluster with GitHub Actions

## Requirements

* Google Cloud Account
  * Project
  * Region
  * Service Account
  * Storage
  * Compute Engine API
  * Kubernetes Engine API
* `gcloud`
* `kubectl`
* `terraform`

## Step 1. Google Cloud Account

<details>
<summary>Click here to <strong>setup your Google Cloud Account.</strong></summary>
1. Create a [New GCP Account](https://cloud.google.com/free) with $300 in free credits for three months (credit card required).

2. Navigate to the GCP Console and create a New GCP Project, e.g. `tf-k8deploy`.

3. Navigate to the Storage and create a New GCP Storage, e.g. `tf-k8deploy`.

4. Navigate to IAM and create a [Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts) under the new project. Add the `Owner` role to the SA.

5. Under the new service account menu, Click on Manage Keys, then Add Key > Create New Key. You will need this key in your GitHub Actions secrets.

6. Navigate to GCP Compute Engine and enable its API.

7. Navigate to GCP Kubernetes Engine and enable its API.

> Download and save the key as JSON file for your Google credentials.
</details>

## Step 2. GitHub Actions Secret

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
  "project_id": "PROJECT_ID",
  "private_key_id": "PRIVATE_KEY_ID",
  "private_key": "PRIVATE_KEY",
  "client_email": "CLIENT_EMAIL",
  "client_id": "CLIENT_ID",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/sa-PROJECT_ID%40PROJECT_ID.iam.gserviceaccount.com"
}
```
</details>

## Step 3. Trigger CI to Create a New GKE Cluster

1. Clone this repo to your workstation.

2. Navigate to your GitHub repo folder and create a new git branch.

```sh
git checkout -b BRANCH_NAME
```

3. Navigate to the subfolder `cd learn-terraform-provision-gke-cluster`.

4. Update the `terraform.tfvars` file with your PROJECT_ID and GCP_REGION. 

> Find the cheapest instance by provider and `region` at [Instance Pricing](https://www.instance-pricing.com).

```yml
project_id = "PROJECT_ID"
region     = "GCP_REGION"
```

5. Update the `providers.tf` file with your GCP_STORAGE_NAME and GCP_STORAGE_PREFIX.

```yml
terraform {
  backend "gcs" {
    bucket = "GCP_STORAGE_NAME"
    prefix = "GCP_STORAGE_PREFIX"
  }
}
```

> Terraform stores a `default.state` file under the prefix GCP_STORAGE_PREFIX in the GCP_STORAGE_NAME.

6. If the `destroy.tf` file exists then `git rm destroy.tf`. Otherwise, make any changes to the `README.md` file.

7. Add and commit the files, then `git push --set-upstream origin BRANCH_NAME`

8. Navigate to your GitHub console and create a merge request. This will trigger a GitHub Actions CI.

9. Merge your pull request to `main` branch to perform `terraform apply`.

> Warning: The MR automatically sets the target branch of the upstream's repo, i.e. the repo that you forked from. You need to change the target to your repo's `main` branch.

## Step 4. Destroy an Existing GKE Cluster

1. Navigate to your GitHub repo folder and create a new git branch.

```sh
git checkout -b BRANCH_NAME
```

2. Navigate to the subfolder `cd learn-terraform-provision-gke-cluster`.

3. Create a file `touch destroy.tf`.

4. Commit the file, then `git push --set-upstream origin BRANCH_NAME`.

5. Navigate to your GitHub console and create a merge request. This will trigger a GitHub Actions CI.

6. Merge your pull request to `main` branch to perform `terraform destroy`.

---
# Deploy a New Cluster with your Workstation

<details>
<summary>Click here to <strong>deploy a New Cluster with your Workstation.</strong></summary>
## Step 1 - Deploy GKE Cluster

1. Clone this repo to your workstation.

2. Navigate to the subfolder `cd learn-terraform-provision-gke-cluster`.

3. Initialize the Terraform code with the following command:

```sh
terraform init
gcloud auth application-default login
```

4. Update the file `terraform.tfvars` and change the values to your GCP.

> Find the cheapest instance by provider and `region` at [Instance Pricing](https://www.instance-pricing.com).

```tf
project_id = "PROJECT_ID"
region     = "GCP_REGION"
```

5. Provision the GKE Cluster with the following command:

```sh
terraform plan
terraform apply
``` 

The above will run through the code and confirm that terraform will deploy a total number of resources (2-node separately managed node pool GKE cluster using Terraform. This GKE cluster will be distributed across multiple zones for high availability. it will also create VPC) you should respond "yes" to this in the "enter a value" prompt if you wish to auto approve this you could run.

```sh
terraform apply -auto-approve
```

The above process will likely take around 5-10 minutes to complete successfully. 

6. Ensure that the following objects were created using command `terraform state list`.

```sh
google_compute_network.vpc
google_compute_subnetwork.subnet
google_container_cluster.primary
google_container_node_pool.primary_nodes
```

7. Delete the GKE Cluster when not in used to save on cost.

```
terraform destroy -auto-approve
```
</details>

---
# Configure access to your GKE Cluster with kubectl 

1. Google Cloud authentication.

``` 
gcloud auth login
gcloud config set project PROJECT_ID
```

2. Configure GKE access if you deployed your GKE Cluster with GitHub Actions CI.

You can retrieve the KUBERNETES_CLUSTER_NAME from the `Outputs` section of the Terraform Apply stage.

```sh
gcloud container clusters get-credentials KUBERNETES_CLUSTER_NAME --region GCP_REGION
```

<details>
<summary>Alternatively, <strong>configure GKE access if you deployed your GKE Cluster with your Workstation.</strong></summary><br>

```sh
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)
```
</details>

3. Confirm now that you have connected to the correct GKE Cluster with the following 

```
kubectl get nodes
```

4. You can also check the contexts available within the KUBECONFIG file by using the following command 

```
kubectl config get-contexts
```

> At this stage we have a fully working Kubernetes cluster running in Google Cloud.