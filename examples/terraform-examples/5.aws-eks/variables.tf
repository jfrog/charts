variable "region" {
  default = "eu-central-1"
}

# WARNING: CIDR "0.0.0.0/0" is full public access to the cluster, you should use a more restrictive CIDR
variable "cluster_public_access_cidrs" {
  default = ["0.0.0.0/0"]
}

variable "cluster_name" {
  default = "demo-eks-cluster"
}

variable "pool_max_size" {
  default = 3
}

variable "pool_desired_size" {
  default = 1
}
