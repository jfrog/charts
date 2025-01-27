output "_01_region" {
  description = "AWS region"
  value       = var.region
}

output "_02_eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "_03_eks_cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "_04_resources_tag" {
  description = "The common tag applied on all resources"
  value       = "Group: ${var.common_tag}"
}

# Output the command to configure kubectl config to the newly created EKS cluster
output "_05_setting_cluster_kubectl_context" {
  description = "Connect kubectl to Kubernetes Cluster"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

# Output the command to install Artifactory with Helm
output "_06_artifactory_install_command" {
  description = "The Helm command to install Artifactory (after setting up kubectl context)"
  value = "helm upgrade --install artifactory jfrog/artifactory --version ${var.artifactory_chart_version} --namespace ${var.namespace} --create-namespace -f ${path.module}/artifactory-values.yaml -f ${path.module}/artifactory-license.yaml -f ${path.module}/artifactory/sizing/artifactory-${var.sizing}.yaml -f ${path.module}/artifactory-custom.yaml --timeout 600s"
}
