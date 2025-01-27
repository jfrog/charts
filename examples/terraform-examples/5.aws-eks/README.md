# AWS EKS (Kubernetes) Example
The work here assumes you have an AWS account and have the AWS CLI installed and configured to this account.

## Files
- The [variables.tf](variables.tf) contains the different variables configurable in this example.
- The [providers.tf](providers.tf) contains the terraform providers needed for this example.
- The [main.tf](main.tf) contains the configuration that Terraform will use to create all the resources needed for running an [EKS](https://aws.amazon.com/eks/) cluster.

Set and store the needed variables values in a [terraform.tfvars](terraform.tfvars) file
```text
region = "eu-central-1"
cluster_name = "demo-eks-cluster-test"
cluster_public_access_cidrs = "1.2.3.4/0"
```

1. Initialize the Terraform configuration by running the following command
```shell
terraform init
```

2. Plan the Terraform configuration by running the following command
```shell
terraform plan
```

3. Apply the Terraform configuration by running the following command
```shell
terraform apply
```

To get the `kubectl` configuration for the EKS cluster, run the following command
```shell
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

Check the connection to the EKS cluster by running the following command
```shell
kubectl get nodes
```

4. When you are done, you can destroy the resources by running the following command
```shell
terraform destroy
```
