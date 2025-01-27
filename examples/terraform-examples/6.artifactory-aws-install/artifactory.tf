# Terraform script to deploy Artifactory on the AWS EKS created earlier

data "aws_eks_cluster_auth" "jfrog_cluster" {
  name = module.eks.cluster_name
}

# Configure the Kubernetes provider to use the EKS cluster
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.jfrog_cluster.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

# Fetch the Artifactory Helm chart and untar it to the current directory so helm install can use the sizing files
resource "null_resource" "shell" {
  provisioner "local-exec" {
    command = "rm -rf artifactory-*.tgz"
  }
  provisioner "local-exec" {
    command = "helm fetch artifactory --version ${var.artifactory_chart_version} --repo https://charts.jfrog.io --untar"
  }
}

# Create an empty artifactory-license.yaml if missing
resource "local_file" "empty_license" {
  count = fileexists("${path.module}/artifactory-license.yaml") ? 0 : 1
  filename = "${path.module}/artifactory-license.yaml"
  content = "## Empty file to satisfy Helm requirements"
}

# Set the cache-fs-size based on the sizing variable to 80% of the disk size
locals {
  cache-fs-size = (var.sizing == "large"  ? var.artifactory_disk_size_large * 0.8 :
                  var.sizing == "xlarge"  ? var.artifactory_disk_size_large * 0.8 :
                  var.sizing == "2xlarge" ? var.artifactory_disk_size_large * 0.8 :
                  var.artifactory_disk_size_default * 0.8)
}

# Write the artifactory-custom.yaml file with the variables needed
resource "local_file" "artifactory_values" {
  content  = <<-EOT
  artifactory:
    persistence:
      maxCacheSize: "${local.cache-fs-size}000000000"
      awsS3V3:
        region: "${var.region}"
        bucketName: "artifactory-${var.region}-${var.s3_bucket_name_suffix}"

  database:
    url: "jdbc:postgresql://${aws_db_instance.artifactory_db.endpoint}/${var.db_name}?sslmode=require"
    user: "${var.db_username}"
    password: "${var.db_password}"
  EOT
  filename = "${path.module}/artifactory-custom.yaml"

  depends_on = [
    aws_db_instance.artifactory_db,
    aws_s3_bucket.artifactory_binarystore,
    module.eks,
    helm_release.metrics_server
  ]
}

## Create a Helm release for Artifactory
## Leaving this as an example of how to deploy Artifactory with Helm using multiple values files

## Create a namespace for the JFrog resources
# resource "kubernetes_namespace" "jfrog_namespace" {
#   metadata {
#     annotations = {
#       name = var.namespace
#     }
#
#     labels = {
#       app = "jfrog"
#     }
#
#     name = var.namespace
#   }
# }

## Configure the Helm provider to use the EKS cluster
# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     token                  = data.aws_eks_cluster_auth.jfrog_cluster.token
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   }
# }
#
# # Create a Helm release for Artifactory
# resource "helm_release" "artifactory" {
#   name       = "artifactory"
#   chart      = "jfrog/artifactory"
#   version    = var.artifactory_chart_version
#   namespace  = var.namespace
#   create_namespace = true
#
#   max_history = 3
#
#   lint = true
#   # upgrade_install = true
#
#   depends_on = [
#     aws_db_instance.artifactory_db,
#     aws_s3_bucket.artifactory_binarystore,
#     module.eks,
#     helm_release.metrics_server
#   ]
#
#   values = [
#     file("${path.module}/artifactory-values.yaml"),
#     file("${path.module}/artifactory-license.yaml"),
#     file("${path.module}/artifactory/sizing/artifactory-${var.sizing}.yaml")
#   ]
#
#   set {
#     name  = "artifactory.persistence.awsS3V3.region"
#     value = var.region
#   }
#
#   set {
#     name  = "artifactory.persistence.awsS3V3.bucketName"
#     value = aws_s3_bucket.artifactory_binarystore.bucket
#   }
#
#   set {
#     name  = "database.url"
#     value = "jdbc:postgresql://${aws_db_instance.artifactory_db.endpoint}/${var.db_name}"
#   }
#
#   set {
#     name  = "database.user"
#     value = var.db_username
#   }
#
#   set {
#     name  = "database.password"
#     value = var.db_password
#   }
#
#   # Wait for the release to complete deployment
#   wait = true
#
#   # Increase the timeout to 10 minutes for Artifactory to deploy
#   timeout = 600
# }
#
