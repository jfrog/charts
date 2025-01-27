# AWS VPC and EC2 Instance Example
The work here assumes you have an AWS account and have the AWS CLI installed and configured to this account.

## Files
- The [variables.tf](variables.tf) contains the different variables configurable in this example.
- The [providers.tf](providers.tf) contains the terraform providers needed for this example.
- The [main.tf](main.tf) contains the configuration that Terraform will use to create the resources in the cloud.

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
terraform apply -var 'instance_type=t3.medium'
```

4. When you are done, you can destroy the resources by running the following command
```shell
terraform destroy
```
