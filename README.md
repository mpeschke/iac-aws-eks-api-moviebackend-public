# iac-aws-eks-api-moviebackend-public

## Initializing

First create the workspaces (each for a subfolder under iac/) in Terraform Cloud (CLI workspace). The expected names of the workspaces can be found under:  

dev|staging|prod/config.remote.tfbackend

Then create the required variables in the workspace (see variables.tf).  

The following commands will connect with TFC workspaces (subfolders under iac/) and run in TFC remotely (CLI):

```console
terraform login  
terraform init -backend-config=dev|staging|prod/config.remote.tfbackend
```

## Planning

```console
terraform plan
```

## Applying the Infrastructure

```console
terraform apply
```

## Deploying moviesbackend k8s service (Ingress Architecture)

The TF project '70-moviesbackend-api' automates the deploy of a k8s service using the Ingress Architecture:
- Public AWS ALB
- No Service Mesh
- Classic Ingress to expose the k8s service endpoint publicly via the ALB 

## Connect to the K8S cluster

```console
aws eks update-kubeconfig --region eu-west-1 --name dev|staging|prod --profile (select your profile)
```
