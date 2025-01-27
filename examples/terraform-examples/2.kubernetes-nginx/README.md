# Nginx In Kubernetes Example
The work here assumes you have a Kubernetes cluster with `kubectl` installed and configured to this cluster.

## Files
- The [variables.tf](variables.tf) contains the different variables configurable in this example.
- The [providers.tf](providers.tf) contains the terraform providers needed for this example.
- The [main.tf](main.tf) file has the configuration that Terraform will use to create the Nginx in the Kubernetes cluster.

This example also has a commented out snippet of using Artifactory as the [Terraform backend](https://jfrog.com/help/r/jfrog-artifactory-documentation/terraform-backend-repository).

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
# Run the following command to create the resources
terraform apply

# Run with a custom value to one of the variables
terraform apply -var 'nginx_replicas=3'
```

4. When you are done, you can destroy the resources by running the following command
```shell
terraform destroy
```
