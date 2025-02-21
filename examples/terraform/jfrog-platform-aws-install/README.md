# JFrog Platform Installation in AWS with Terraform
This example will prepare the AWS infrastructure and services required to run Artifactory and Xray (installed with the [jfrog-platform Helm Chart](https://github.com/jfrog/charts/tree/master/stable/jfrog-platform)) using Terraform:
1. The AWS VPC
2. RDS (PostgreSQL) as the database for each application
2. S3 as the Artifactory object storage
3. EKS as the Kubernetes cluster for running Artifactory and Xray with pre-defined node groups for the different services

The resources are split between individual files for easy and clear separation.


## Prepare the JFrog Platform Configurations
Ensure that the AWS CLI is set up and properly configured before starting with Terraform. 
A configured AWS account with the necessary permissions is required to provision and manage resources successfully. 

The [jfrog-values.yaml](jfrog-values.yaml) file has the values that Helm will use to configure the JFrog Platform installation.

The [artifactory-license-template.yaml](artifactory-license-template.yaml) file has the license key(s) template that you will need to copy to a `artifactory-license.yaml` file.
```shell
cp artifactory-license-template.yaml artifactory-license.yaml
```

If you plan on skipping the license key(s) for now, you can leave the `artifactory-license.yaml` file empty. Terraform will create an empty one for you if you don't create it.

## JFrog Platform Sizing
Artifactory and Xray have pre-defined sizing templates that you can use to deploy them. The supported sizing templates in this project are `small`, `medium`, `large`, `xlarge`, and `2xlarge`.

The sizing templates will be pulled from the [official Helm Charts](https://github.com/jfrog/charts) during the execution of the Terraform configuration.

## Terraform


1. Initialize the Terraform configuration by running the following command
```shell
terraform init
```

2. Plan the Terraform configuration by running the following command
```shell
terraform plan -var 'sizing=small'
```

3. Apply the Terraform configuration by running the following command
```shell
terraform apply -var 'sizing=small'
```

4. When you are done, you can destroy the resources by running the following command
```shell
terraform destroy
```

## Accessing the EKS Cluster and Artifactory Installation
To get the `kubectl` configuration for the EKS cluster, run the following command
```shell
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
### Add JFrog Helm repository
Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io) to your helm client

```shell
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Install JFrog Platform
Once done, install the JFrog Platform (Artifactory and Xray) using the Helm Chart with the following command.

Terraform will create the needed configuration files to be used for the `helm install` command.
This command will auto generate and be writen to the console when you run the `Terraform apply` command.
```shell
helm upgrade --install jfrog jfrog/jfrog-platform \
  --version <version> \
  --namespace <namesapce>> --create-namespace \
  -f ./jfrog-values.yaml \
  -f ./artifactory-license.yaml \
  -f ./jfrog-platform/sizing/platform-<sizing>-.yaml \
  -f ./jfrog-custom.yaml \
  --timeout 600s
```
