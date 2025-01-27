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

# Output the command to configure kubectl config to the newly created EKS cluster
output "_04_setting_cluster_kubectl_context" {
  description = "Connect kubectl to Kubernetes Cluster"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}
