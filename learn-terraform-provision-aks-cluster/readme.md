## Step By Step on How to use terraform to deploy a new EKS Cluster and then Deploy Kasten K10 and access

Resource - https://learn.hashicorp.com/tutorials/terraform/aks?in=terraform/kubernetes

## Step 1 - Deploy AKS Cluster
Navigate to code repository for AKS Deployment 

```
cd learn-terraform-provision-aks-cluster 
```
Provision the AKS Cluster with the following command 

```
terraform apply
``` 
The above will run through the code and confirm that terraform will deploy a total number of resources (AD SP, Resource Groups, AKS Cluster etc) you should respond "yes" to this in the "enter a value" prompt if you wish to auto approve this you could run 

```
terraform apply --auto-approve
```
The above process will likely take around 5-10 minutes to complete successfully

## Configure access to your AKS Cluster with kubectl 

``` 
az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)
```

confirm now that you have connected to the correct AKS Cluster with the following 

```
kubectl get nodes
```

You can also check the contexts available within the KUBECONFIG file by using the following command 

```
kubectl config get-contexts
```
## At this stage we have a fully working Kubernetes Cluster running in Microsoft Azure 

We now want to deploy Kasten K10 with some configuration specifically for AWS 

```
cd .. 
cd helm 
cd "Azure AKS"
```

now we can run the following to create a new namespace and deploy K10 via a helm chart. 

```
 terraform apply -var-file="secrets.tfvars"
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
cd learn.terraform.provision-aks-cluster
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

