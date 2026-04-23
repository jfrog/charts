# Setup the required variables

variable "region" {
  description = "The AWS region to deploy resources into"
  default     = "us-east-1"
}

variable "env_name" {
  description = "The environment name, used to prefix resource names and tags"
  default     = "jfrog-platform"
}

# WARNING: CIDR "0.0.0.0/0" is full public access to the cluster. Use a more restrictive CIDR.
variable "cluster_public_access_cidrs" {
  description = "List of CIDR blocks allowed to access the EKS cluster API endpoint publicly"
  default     = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (one per availability zone)"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (one per availability zone)"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster"
  default     = "1.35"
}

variable "rds_postgres_version" {
  description = "The PostgreSQL engine version for all RDS instances"
  default     = "17.7"
}

variable "artifactory_rds_size_default" {
  description = "RDS instance class for Artifactory database (small sizing)"
  default     = "db.m8g.2xlarge"
}

variable "artifactory_rds_size_medium" {
  description = "RDS instance class for Artifactory database (medium sizing)"
  default     = "db.m8g.4xlarge"
}

variable "artifactory_rds_size_large" {
  description = "RDS instance class for Artifactory database (large sizing)"
  default     = "db.m8g.8xlarge"
}

variable "artifactory_rds_size_xlarge" {
  description = "RDS instance class for Artifactory database (xlarge sizing)"
  default     = "db.m8g.12xlarge"
}

variable "artifactory_rds_size_2xlarge" {
  description = "RDS instance class for Artifactory database (2xlarge sizing)"
  default     = "db.m8g.16xlarge"
}

variable "artifactory_rds_disk_size_default" {
  description = "Allocated storage in GiB for Artifactory RDS (small sizing)"
  default     = 100
}

variable "artifactory_rds_disk_size_medium" {
  description = "Allocated storage in GiB for Artifactory RDS (medium sizing)"
  default     = 250
}

variable "artifactory_rds_disk_size_large" {
  description = "Allocated storage in GiB for Artifactory RDS (large sizing)"
  default     = 500
}

variable "artifactory_rds_disk_size_xlarge" {
  description = "Allocated storage in GiB for Artifactory RDS (xlarge sizing)"
  default     = 1000
}

variable "artifactory_rds_disk_size_2xlarge" {
  description = "Allocated storage in GiB for Artifactory RDS (2xlarge sizing)"
  default     = 1500
}

variable "artifactory_rds_disk_max_size" {
  description = "Maximum auto-scaling storage in GiB for Artifactory RDS"
  default     = 2000
}

variable "catalog_rds_size_default" {
  description = "RDS instance class for Catalog database"
  default     = "db.t4g.micro"
}

variable "catalog_rds_disk_size_default" {
  description = "Allocated storage in GiB for Catalog RDS"
  default     = 20
}

variable "catalog_rds_disk_max_size" {
  description = "Maximum auto-scaling storage in GiB for Catalog RDS"
  default     = 50
}

variable "xray_rds_size_default" {
  description = "RDS instance class for Xray database (small sizing)"
  default     = "db.m8g.xlarge"
}

variable "xray_rds_size_medium" {
  description = "RDS instance class for Xray database (medium sizing)"
  default     = "db.m8g.2xlarge"
}

variable "xray_rds_size_large" {
  description = "RDS instance class for Xray database (large sizing)"
  default     = "db.m8g.4xlarge"
}

variable "xray_rds_size_xlarge" {
  description = "RDS instance class for Xray database (xlarge sizing)"
  default     = "db.m8g.8xlarge"
}

variable "xray_rds_size_2xlarge" {
  description = "RDS instance class for Xray database (2xlarge sizing)"
  default     = "db.m8g.12xlarge"
}

variable "xray_rds_disk_size_default" {
  description = "Allocated storage in GiB for Xray RDS (small sizing)"
  default     = 100
}

variable "xray_rds_disk_size_medium" {
  description = "Allocated storage in GiB for Xray RDS (medium sizing)"
  default     = 250
}

variable "xray_rds_disk_size_large" {
  description = "Allocated storage in GiB for Xray RDS (large sizing)"
  default     = 500
}

variable "xray_rds_disk_size_xlarge" {
  description = "Allocated storage in GiB for Xray RDS (xlarge sizing)"
  default     = 1000
}

variable "xray_rds_disk_size_2xlarge" {
  description = "Allocated storage in GiB for Xray RDS (2xlarge sizing)"
  default     = 1500
}

variable "xray_rds_disk_max_size" {
  description = "Maximum auto-scaling storage in GiB for Xray RDS"
  default     = 2000
}

variable "artifactory_node_size_default" {
  description = "EC2 instance type for Artifactory node group (small/medium sizing)"
  default     = "m8g.2xlarge"
}

variable "artifactory_node_size_large" {
  description = "EC2 instance type for Artifactory node group (large/xlarge/2xlarge sizing)"
  default     = "m8g.4xlarge"
}

variable "artifactory_disk_size_default" {
  description = "EBS data volume size in GiB for Artifactory nodes (small/medium sizing)"
  default     = 500
}

variable "artifactory_disk_size_large" {
  description = "EBS data volume size in GiB for Artifactory nodes (large/xlarge/2xlarge sizing)"
  default     = 1000
}

variable "artifactory_disk_iops_default" {
  description = "EBS data volume IOPS for Artifactory nodes (small/medium sizing)"
  default     = 3000
}

variable "artifactory_disk_iops_large" {
  description = "EBS data volume IOPS for Artifactory nodes (large/xlarge/2xlarge sizing)"
  default     = 6000
}

variable "artifactory_disk_throughput_default" {
  description = "EBS data volume throughput in MiB/s for Artifactory nodes (small/medium sizing)"
  default     = 500
}

variable "artifactory_disk_throughput_large" {
  description = "EBS data volume throughput in MiB/s for Artifactory nodes (large/xlarge/2xlarge sizing)"
  default     = 1000
}

variable "xray_node_size_default" {
  description = "EC2 instance type for Xray node group (small/medium/large sizing)"
  default     = "c8g.2xlarge"
}

variable "xray_node_size_xlarge" {
  description = "EC2 instance type for Xray node group (xlarge/2xlarge sizing)"
  default     = "c8g.4xlarge"
}

variable "xray_disk_size_default" {
  description = "EBS data volume size in GiB for Xray nodes (small/medium sizing)"
  default     = 100
}

variable "xray_disk_size_large" {
  description = "EBS data volume size in GiB for Xray nodes (large/xlarge/2xlarge sizing)"
  default     = 200
}

variable "xray_disk_iops_default" {
  description = "EBS data volume IOPS for Xray nodes (small/medium sizing)"
  default     = 3000
}

variable "xray_disk_iops_large" {
  description = "EBS data volume IOPS for Xray nodes (large/xlarge/2xlarge sizing)"
  default     = 6000
}

variable "xray_disk_throughput_default" {
  description = "EBS data volume throughput in MiB/s for Xray nodes (small/medium sizing)"
  default     = 500
}

variable "xray_disk_throughput_large" {
  description = "EBS data volume throughput in MiB/s for Xray nodes (large/xlarge/2xlarge sizing)"
  default     = 1000
}

variable "nginx_node_size_default" {
  description = "EC2 instance type for Nginx ingress node group (small/medium/large sizing)"
  default     = "c8g.xlarge"
}

variable "nginx_node_size_large" {
  description = "EC2 instance type for Nginx ingress node group (xlarge/2xlarge sizing)"
  default     = "c8g.2xlarge"
}

variable "extra_node_count" {
  description = "Desired number of nodes in the extra (general-purpose) node group"
  default     = 3
}

variable "extra_node_size" {
  description = "EC2 instance type for the extra (general-purpose) node group"
  default     = "c8g.xlarge"
}

variable "artifactory_db_name" {
  description = "The Artifactory database name"
  default     = "artifactory"
}

variable "artifactory_db_username" {
  description = "The username for the Artifactory database"
  default     = "artifactory"
}

variable "artifactory_db_password" {
  description = "The password for the Artifactory PostgreSQL database. Must be set in terraform.tfvars."
  sensitive   = true
  default     = null

  validation {
    condition     = var.artifactory_db_password != null
    error_message = "artifactory_db_password must be set in terraform.tfvars."
  }
}

variable "xray_db_name" {
  description = "The Xray database name"
  default     = "xray"
}

variable "xray_db_username" {
  description = "The username for the Xray database"
  default     = "xray"
}

variable "xray_db_password" {
  description = "The password for the Xray PostgreSQL database. Must be set in terraform.tfvars."
  sensitive   = true
  default     = null

  validation {
    condition     = var.xray_db_password != null
    error_message = "xray_db_password must be set in terraform.tfvars."
  }
}

variable "catalog_db_name" {
  description = "The Catalog database name"
  default     = "ctlg"
}

variable "catalog_db_username" {
  description = "The username for the Catalog database"
  default     = "ctlg"
}

variable "catalog_db_password" {
  description = "The password for the Catalog PostgreSQL database. Must be set in terraform.tfvars."
  sensitive   = true
  default     = null

  validation {
    condition     = var.catalog_db_password != null
    error_message = "catalog_db_password must be set in terraform.tfvars."
  }
}

# The AMI type for the EKS Managed Node Groups.
# Currently using Graviton (ARM64) instances, with the AL2023_ARM_64_STANDARD image type.
# For AMD64 instances, use the AL2023_x86_64_STANDARD image type.
# Make sure to adjust the instance types accordingly.
variable "ami_type" {
  description = "The AMI type for the EKS Managed Node Groups."
  default     = "AL2023_ARM_64_STANDARD"
}

variable "jfrog_charts_repository" {
  description = "The Helm repository URL for JFrog charts"
  default     = "https://charts.jfrog.io"
}

variable "jfrog_platform_chart_version" {
  description = "The jfrog-platform chart version"
  default     = ""

  validation {
    condition     = var.jfrog_platform_chart_version != null && var.jfrog_platform_chart_version != ""
    error_message = "The jfrog_platform_chart_version variable must be set. Specify a valid chart version in a terraform.tfvars file (e.g., 'jfrog_platform_chart_version = \"11.5.0\"')."
  }
}

variable "deploy_metrics_server" {
  description = "If true, deploy the metrics-server Helm chart into kube-system"
  default     = true
}

variable "metrics_server_chart_version" {
  description = "The metrics-server Helm chart version to deploy"
  default     = "3.12.2"
}

variable "eks_root_volume_size" {
  description = "Root EBS volume size in GiB for all EKS node groups"
  default     = 50
}

variable "eks_root_throughput" {
  description = "Root EBS volume throughput in MiB/s for all EKS node groups"
  default     = 125
}

variable "s3_force_destroy" {
  description = "If true, the S3 bucket can be destroyed even when it contains objects. WARNING: set to false in production to prevent accidental data loss."
  default     = true
}

variable "common_tag" {
  description = "The 'Group' tag to apply to all resources"
  default     = "jfrog"
}

variable "sizing" {
  type        = string
  description = "The sizing template for the infrastructure and Artifactory. Controls instance types, node counts, disk sizes, and RDS classes."
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "large", "xlarge", "2xlarge"], var.sizing)
    error_message = "Invalid sizing set. Supported sizings are: 'small', 'medium', 'large', 'xlarge' or '2xlarge'"
  }
}
