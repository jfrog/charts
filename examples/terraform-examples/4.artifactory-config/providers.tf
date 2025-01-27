# Define the required JFrog Artifactory provider
terraform {
  required_providers {
    artifactory = {
      source  = "jfrog/artifactory"
    }
  }
}

# Configure the JFrog Artifactory server and access
provider "artifactory" {
  url           = "${var.artifactory_url}/artifactory"
  access_token  = var.artifactory_access_token
}
