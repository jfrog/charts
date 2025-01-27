# Artifactory Installation in AWS with Terraform
This example will prepare the AWS infrastructure and services required to run [JFrog Artifactory](https://jfrog.com/artifactory) using Terraform:
1. The AWS VPC
2. RDS (PostgreSQL) as the database
2. S3 as the object storage
3. EKS as the Kubernetes cluster for running Artifactory

The resources are split between individual files for easy and clear separation.

After all the resources are created, you can install Artifactory using the [official Artifactory Helm Chart](https://github.com/jfrog/charts/tree/master/stable/artifactory).

The Terraform configuration will output the Artifactory install command.

## Prepare the Artifactory Configurations
The [artifactory-values.yaml](artifactory-values.yaml) file has the values that Helm will use to configure the Artifactory installation.

The [artifactory-license-template.yaml](artifactory-license-template.yaml) file has the license key(s) template that you will need to copy to a `artifactory-license.yaml` file.
```shell
cp artifactory-license-template.yaml artifactory-license.yaml
```

If you plan on skipping the license key(s) for now, you can leave the `artifactory-license.yaml` file empty. Terraform will create an empty one for you if you don't create it.

## Artifactory Sizing
Artifactory has pre-defined sizing templates that you can use to deploy Artifactory. The supported sizing templates in this project are `small`, `medium`, `large`, `xlarge`, and `2xlarge`.

The sizing templates will be pulled from the [official Artifactory Helm Chart](https://github.com/jfrog/charts/tree/master/stable/artifactory) during the execution of the Terraform configuration.

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

### Install Artifactory
Once done, install Artifactory using the Helm Chart with the following command.

Terraform will create the needed configuration files to be used for the `helm install` command.
This command will auto generate and be writen to the console when you run the `Terraform apply` command.
```shell
helm upgrade --install artifactory jfrog/artifactory \
  --version <version> \
  --namespace <namespace> --create-namespace \
  -f artifactory-values.yaml \
  -f artifactory-license.yaml \
  -f artifactory/sizing/artifactory-<sizing>.yaml \
  -f artifactory-custom.yaml \
  --timeout 600s
```
