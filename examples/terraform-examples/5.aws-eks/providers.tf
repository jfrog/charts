# Define the required providers
terraform {
  required_providers {
    # AWS provider
    aws = {
      source  = "hashicorp/aws"
    }
    # Kubernetes provider
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}

provider "aws" {
  region = var.region
}

# Configure the Kubernetes provider to use the EKS cluster
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.jfrog_cluster.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}
