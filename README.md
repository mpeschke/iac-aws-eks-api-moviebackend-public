# iac-aws-eks-api-moviebackend-public

## Initializing

The following commands will connect with TFC workspaces and run in TFC remotely (CLI):

terraform login  

terraform init -backend-config=dev|staging|prod/config.remote.tfbackend

## Planning

terraform plan

## Applying the Infrastructure

terraform apply

## Deploying moviesbackend k8s service (Ingress Architecture)

Before deploying this chart, make sure you configured kubectl to point to the correct
default eks cluster.  

First test if your template is parsing correctly:

cd standard-application/  
helm template --values dev|staging|prod/values.yaml ./

Then deploy:  

cd standard-application/  
helm install moviesbackend ./ -n standard-application -f dev|staging|prod/values.yaml --create-namespace --namespace moviesbackend 

