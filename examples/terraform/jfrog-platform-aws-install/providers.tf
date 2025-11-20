# Setup the providers
terraform {
  required_version = ">= 1.0"
  # Use a local backend
  backend "local" {
    path = "./state/terraform.tfstate"
  }

  ## Configure the remote backend (Artifactory)
  ## This will store the state file in Artifactory.
  ## Follow https://jfrog.com/help/r/jfrog-artifactory-documentation/terraform-backend-repository
  ## Create a new terraform workspace in Artifactory named "jfrog"
  # backend "remote" {
  #   hostname = "acme.domain.com"
  #   organization = "terraform-backend"
  #   workspaces {
  #     prefix = "jfrog"
  #   }
  # }

  required_providers {
    # AWS provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Kubernetes provider
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    # Helm provider
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.jfrog_cluster.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}
