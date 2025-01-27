### Artifactory Configuration Example
The [Artifactory Provider](https://github.com/jfrog/terraform-provider-artifactory) allows you to manage resources in Artifactory using Terraform.

The work here assumes you have an Artifactory instance running and accessible.

If not already installed, you can easily install Artifactory in Kubernetes with the [Artifactory Install Example](../3.artifactory-install) in this repository.

You can also easily install Artifactory in Kubernetes directly with [helm](https://helm.sh) by running the following command
```shell
helm upgrade --install artifactory jfrog/artifactory --set postgresql.postgresqlPassword="password1"
```

## Files
- The [variables.tf](variables.tf) contains the different variables configurable in this example.
- The [providers.tf](providers.tf) contains the terraform providers needed for this example.
- The [main.tf](main.tf) file has the configuration that Terraform will use to configure the Artifactory server.

Create an [Artifactory access token](https://jfrog.com/help/r/how-to-generate-an-access-token-video/artifactory-creating-access-tokens-in-artifactory) and store it in a [terraform.tfvars](terraform.tfvars) file
```text
artifactory_url = "http://localhost"
artifactory_access_token = "eyJ2ZXI..."
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

4. When you are done, you can destroy the resources by running the following command
```shell
terraform destroy
```
