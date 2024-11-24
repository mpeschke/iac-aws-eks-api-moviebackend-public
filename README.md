# iac-aws-eks-api-moviebackend-public

## Continuous Integration and Continuous Delivery

CD is implemented using Terraform Cloud. There is no CI at the moment, but it can be easily implemented by automating the commands in the following sections (see 'Initializing', 'Planning' and 'Applying the Infrastructure').

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

## AWS Organizational Unit, AWS Accounts, Environments

All users are managed in a 'management' AWS Account. Cross Account Roles, User Groups and policies to configure users' authorization to access the environment accounts are automated by the https://bitbucket.org/matheuspeschke/iac-aws-shared project.

Development, Staging and Production environments are deployed to completely separate AWS Accounts, grouped under the 'mpeschke.org' AWS Organization Unit.

## Environments, Internet Domain, DNS

The mpeschke.org internet domain is managed by the GoDaddy registrar. The 01-mpeschke-org-wildcard-domain project creates the DNS entries (NS - list of DNS servers) that were later manually configured on GoDaddy registrar records. This project creates the Hosted Zone for the API running on the production environment.

This project was initially designed to work on three environments: development, staging and production.

The wildcard configuration *.mpeschke.org DNS has been arbitrarily chosen to be done on the production account's AWS Route53 Hosted Zone.

03-mpeschke-org-k8s-subdomain project creates the AWS Route53 Hosted Zones for dev and staging environments on their respective AWS Accounts.

04-mpeschke-org-k8s-subdomain-records project adds the DNS records on the production account, routing DNS resolution from the production's DNS Hosted Zone to the proper environment's Hosted Zones.

Securing these DNS integrations using DNSSEC signing is work in progress. It still needs to be completed (if possible, automated) and tested.

## TLS Certificates

Certificates are automatically managed by LetsEncrypt.

## Deploying moviesbackend service (Ingress Architecture)

A monolith API is deployed using the following architecture:

- Public AWS NLB (no API Gateway)
- K8S Ingress exposing the service endpoint publicly via the NLB 
- No micro services (hence no Service Mesh)
- Database backend using RDS MySQL Aurora

## Observability

Prometheus, Grafana and Loki running as self-hosted services in the K8S cluster.

## Connect to the K8S cluster

```console
aws eks update-kubeconfig --region eu-west-1 --name dev|staging|prod --profile (select your profile)
```
