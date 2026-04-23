# Centralized sizing configuration map.
# All sizing-driven values are defined here and referenced as local.s.* throughout the configuration.
# To add a new sizing tier, add an entry to sizing_config and update the variable validation in variables.tf.

locals {
  sizing_config = {
    small = {
      # EKS node instance types
      artifactory_instance = var.artifactory_node_size_default
      xray_instance        = var.xray_node_size_default
      nginx_instance       = var.nginx_node_size_default

      # EKS desired node counts
      artifactory_desired = 1
      xray_desired        = 1
      nginx_desired       = 1

      # Artifactory EBS data volume
      artifactory_disk_size       = var.artifactory_disk_size_default
      artifactory_disk_iops       = var.artifactory_disk_iops_default
      artifactory_disk_throughput = var.artifactory_disk_throughput_default

      # Xray EBS data volume
      xray_disk_size       = var.xray_disk_size_default
      xray_disk_iops       = var.xray_disk_iops_default
      xray_disk_throughput = var.xray_disk_throughput_default

      # RDS instance classes
      artifactory_rds_instance = var.artifactory_rds_size_default
      xray_rds_instance        = var.xray_rds_size_default

      # RDS allocated storage (GiB)
      artifactory_rds_disk = var.artifactory_rds_disk_size_default
      xray_rds_disk        = var.xray_rds_disk_size_default
    }

    medium = {
      artifactory_instance = var.artifactory_node_size_default
      xray_instance        = var.xray_node_size_default
      nginx_instance       = var.nginx_node_size_default

      artifactory_desired = 2
      xray_desired        = 2
      nginx_desired       = 2

      artifactory_disk_size       = var.artifactory_disk_size_default
      artifactory_disk_iops       = var.artifactory_disk_iops_default
      artifactory_disk_throughput = var.artifactory_disk_throughput_default

      xray_disk_size       = var.xray_disk_size_default
      xray_disk_iops       = var.xray_disk_iops_default
      xray_disk_throughput = var.xray_disk_throughput_default

      artifactory_rds_instance = var.artifactory_rds_size_medium
      xray_rds_instance        = var.xray_rds_size_medium

      artifactory_rds_disk = var.artifactory_rds_disk_size_medium
      xray_rds_disk        = var.xray_rds_disk_size_medium
    }

    large = {
      artifactory_instance = var.artifactory_node_size_large
      xray_instance        = var.xray_node_size_default
      nginx_instance       = var.nginx_node_size_default

      artifactory_desired = 3
      xray_desired        = 3
      nginx_desired       = 2

      artifactory_disk_size       = var.artifactory_disk_size_large
      artifactory_disk_iops       = var.artifactory_disk_iops_large
      artifactory_disk_throughput = var.artifactory_disk_throughput_large

      xray_disk_size       = var.xray_disk_size_large
      xray_disk_iops       = var.xray_disk_iops_large
      xray_disk_throughput = var.xray_disk_throughput_large

      artifactory_rds_instance = var.artifactory_rds_size_large
      xray_rds_instance        = var.xray_rds_size_large

      artifactory_rds_disk = var.artifactory_rds_disk_size_large
      xray_rds_disk        = var.xray_rds_disk_size_large
    }

    xlarge = {
      artifactory_instance = var.artifactory_node_size_large
      xray_instance        = var.xray_node_size_xlarge
      nginx_instance       = var.nginx_node_size_large

      artifactory_desired = 4
      xray_desired        = 4
      nginx_desired       = 2

      artifactory_disk_size       = var.artifactory_disk_size_large
      artifactory_disk_iops       = var.artifactory_disk_iops_large
      artifactory_disk_throughput = var.artifactory_disk_throughput_large

      xray_disk_size       = var.xray_disk_size_large
      xray_disk_iops       = var.xray_disk_iops_large
      xray_disk_throughput = var.xray_disk_throughput_large

      artifactory_rds_instance = var.artifactory_rds_size_xlarge
      xray_rds_instance        = var.xray_rds_size_xlarge

      artifactory_rds_disk = var.artifactory_rds_disk_size_xlarge
      xray_rds_disk        = var.xray_rds_disk_size_xlarge
    }

    "2xlarge" = {
      artifactory_instance = var.artifactory_node_size_large
      xray_instance        = var.xray_node_size_xlarge
      nginx_instance       = var.nginx_node_size_large

      artifactory_desired = 6
      xray_desired        = 6
      nginx_desired       = 3

      artifactory_disk_size       = var.artifactory_disk_size_large
      artifactory_disk_iops       = var.artifactory_disk_iops_large
      artifactory_disk_throughput = var.artifactory_disk_throughput_large

      xray_disk_size       = var.xray_disk_size_large
      xray_disk_iops       = var.xray_disk_iops_large
      xray_disk_throughput = var.xray_disk_throughput_large

      artifactory_rds_instance = var.artifactory_rds_size_2xlarge
      xray_rds_instance        = var.xray_rds_size_2xlarge

      artifactory_rds_disk = var.artifactory_rds_disk_size_2xlarge
      xray_rds_disk        = var.xray_rds_disk_size_2xlarge
    }
  }

  # Shorthand for the selected sizing tier — all resources use local.s.*
  s = local.sizing_config[var.sizing]

  # Artifactory cache size: 80% of the data disk, expressed in bytes for the Helm value
  cache_fs_size = local.s.artifactory_disk_size * 0.8
}
