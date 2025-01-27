# Configure the Helm provider to use the EKS cluster
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.jfrog_cluster.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

# Install the metrics server
resource "helm_release" "metrics_server" {
  count = var.deploy_metrics_server ? 1 : 0

  name       = "metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"

  # Repository to install the chart from
  repository = "https://kubernetes-sigs.github.io/metrics-server/"

  # Don't wait for the release to complete deployment
  wait = false
}
