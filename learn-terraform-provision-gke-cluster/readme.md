## Step By Step on How to use terraform to deploy a new EKS Cluster and then Deploy Kasten K10 and access

Resource - https://learn.hashicorp.com/tutorials/terraform/gke?in=terraform/kubernetes

## Requirements

* Google Cloud Account
  * Create a [New GCP Account](https://cloud.google.com/free) with $300 in free credits (credit card required)
* Google Cloud `project_id`
* Google Cloud Region
  * Find the cheapest instance by provider and `region` at [Instance Pricing](https://www.instance-pricing.com)
* Google Cloud SDK `gcloud`
* `kubectl`
* `terraform`

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

## Configure access to your GKE Cluster with kubectl 

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
## At this stage we have a fully working Kubernetes Cluster running in Google Cloud 

We now want to deploy Kasten K10 with some configuration specifically for GKE 

```
cd .. 
cd helm 
cd "Google GKE"
```

now we can run the following to create a new namespace and deploy K10 via a helm chart. 

```
terraform apply 
```

```
terraform apply --auto-approve
```
you can check the process of the installation with the following command

```
kubectl get pods -n kasten-io -w
```
when all pods are ready then you can obtain the public IP to access the K10 dashboard with the following command 

```
kubectl get svc -n kasten-io
```

## Clean up your workspace 
Note: make sure you are in the correct path to run this you should be in  

```
cd learn.terraform.provision-gke-cluster
```

To delete your cluster you can simply run the following command:

```
terraform destroy
```

or to avoid prompt 

```
terraform destroy --auto-approve
```


We then also need to remove the context and cluster from our KUBECONFIG file, first we need to find the detail we need 

```
kubectl config get-contexts
```

then delete context 

```
kubectl config delete-context <Insert name>
```

then delete cluster 

```
kubectl config delete-cluster <Insert name>
```

