# Setup the required variables

variable "region" {
  default = "us-east-1"
}

# WARNING: CIDR "0.0.0.0/0" is full public access to the cluster. You should use a more restrictive CIDR
variable "cluster_public_access_cidrs" {
  default = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "rds_postgres_version" {
  default     = "16.4"
}

variable "s3_bucket_name_suffix" {
  default = "jfrog-demo"
}

variable "artifactory_rds_size_default" {
  default = "db.m7g.2xlarge"
}

variable "artifactory_rds_size_medium" {
  default = "db.m7g.4xlarge"
}

variable "artifactory_rds_size_large" {
  default = "db.m7g.8xlarge"
}

variable "artifactory_rds_size_xlarge" {
  default = "db.m7g.12xlarge"
}

variable "artifactory_rds_size_2xlarge" {
  default = "db.m7g.16xlarge"
}

variable "artifactory_rds_disk_size_default" {
  default = 100
}

variable "artifactory_rds_disk_size_medium" {
  default = 250
}

variable "artifactory_rds_disk_size_large" {
  default = 500
}

variable "artifactory_rds_disk_size_xlarge" {
  default = 1000
}

variable "artifactory_rds_disk_size_2xlarge" {
  default = 1500
}

variable "artifactory_rds_disk_max_size" {
  default = 2000
}

variable "catalog_rds_size_default" {
  default = "db.t4g.micro"
}

variable "catalog_rds_disk_size_default" {
  default = 20
}

variable "catalog_rds_disk_max_size" {
  default = 50
}

variable "xray_rds_size_default" {
  default = "db.m7g.xlarge"
}

variable "xray_rds_size_medium" {
  default = "db.m7g.2xlarge"
}

variable "xray_rds_size_large" {
  default = "db.m7g.4xlarge"
}

variable "xray_rds_size_xlarge" {
  default = "db.m7g.8xlarge"
}

variable "xray_rds_size_2xlarge" {
  default = "db.m7g.12xlarge"
}

variable "xray_rds_disk_size_default" {
  default = 100
}

variable "xray_rds_disk_size_medium" {
  default = 250
}

variable "xray_rds_disk_size_large" {
  default = 500
}

variable "xray_rds_disk_size_xlarge" {
  default = 1000
}

variable "xray_rds_disk_size_2xlarge" {
  default = 1500
}

variable "xray_rds_disk_max_size" {
  default = 2000
}

variable "artifactory_node_size_default" {
  default = "m7g.2xlarge"
}

variable "artifactory_node_size_large" {
  default = "m7g.4xlarge"
}

variable "artifactory_disk_size_default" {
  default = 500
}

variable "artifactory_disk_size_large" {
  default = 1000
}

variable "artifactory_disk_iops_default" {
  default = 3000
}

variable "artifactory_disk_iops_large" {
  default = 6000
}

variable "artifactory_disk_throughput_default" {
  default = 500
}

variable "artifactory_disk_throughput_large" {
  default = 1000
}

variable "xray_node_size_default" {
  default = "c7g.2xlarge"
}

variable "xray_node_size_xlarge" {
  default = "c7g.4xlarge"
}

variable "xray_disk_size_default" {
  default = 100
}

variable "xray_disk_size_large" {
  default = 200
}

variable "xray_disk_iops_default" {
  default = 3000
}

variable "xray_disk_iops_large" {
  default = 6000
}

variable "xray_disk_throughput_default" {
  default = 500
}

variable "xray_disk_throughput_large" {
  default = 1000
}

variable "nginx_node_size_default" {
  default = "c7g.xlarge"
}

variable "nginx_node_size_large" {
  default = "c7g.2xlarge"
}

variable "extra_node_count" {
  default = "3"
}

variable "extra_node_size" {
  default = "c7g.xlarge"
}

variable "artifactory_db_name" {
  description = "The database name"
  default     = "artifactory"
}

variable "artifactory_db_username" {
  description = "The username for the database"
  default     = "artifactory"
}

variable "artifactory_db_password" {
  description = "The password for the database"
  sensitive   = true
  default     = "Password321"
}

variable "xray_db_name" {
  description = "The database name"
  default     = "xray"
}

variable "xray_db_username" {
  description = "The username for the database"
  default     = "xray"
}

variable "xray_db_password" {
  description = "The password for the database"
  sensitive   = true
  default     = "PasswordX321"
}

variable "catalog_db_name" {
  description = "The database name"
  default     = "ctlg"
}

variable "catalog_db_username" {
  description = "The username for the database"
  default     = "ctlg"
}

variable "catalog_db_password" {
  description = "The password for the database"
  sensitive   = true
  default     = "PasswordC321"
}

variable "cluster_name" {
  default = "jfrog"
}

variable "namespace" {
  default = "jfrog"
}

variable "jfrog_charts_repository" {
  default = "https://charts.jfrog.io"
}

variable "jfrog_platform_chart_version" {
  default = "11.0.1"
}

variable "deploy_metrics_server" {
  default = true
}

variable "common_tag" {
  description = "The 'Group' tag to apply to all resources"
  default = "jfrog"
}

variable "sizing" {
  type        = string
  description = "The sizing templates for the infrastructure and Artifactory"
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "large", "xlarge", "2xlarge"], var.sizing)
    error_message = "Invlid sizing set. Supported sizings are: 'small', 'medium', 'large', 'xlarge' or '2xlarge'"
  }
}