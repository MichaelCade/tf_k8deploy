## Instructions for fast public cloud Kubernetes cluster deployment 

In this folder you will find folders to enable you to provision your public cloud of choice Kubernetes cluster following best practices from Hashicorp learning, you can find the original code and more here. 

Resource - https://learn.hashicorp.com/collections/terraform/kubernetes

```
learn-terraform-provision-aks-cluster = Microsoft AKS cluster deployment using az locally configured
```
```
learn-terraform-provision-eks-cluster = AWS EKS cluster deployment using aws cli locally configured
```
``` 
learn-terraform-provision-gke-cluster = Google GKE cluster deployment using gcloud sdk locally configured
```

## Instructions for Kasten K10 deployment on each cluster deployment

You will also find in this folder terraform files to deploy kasten k10 from helm chart using the helm provider. 

``` 
cd helm
```

Be sure to check the code prior to using as some will require secrets. 

