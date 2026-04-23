# This file is used to create an S3 bucket for Artifactory to store binaries
locals {
  artifactory_s3_bucket_name = "artifactory-${var.region}-${var.env_name}"
}

resource "aws_s3_bucket" "artifactory_binarystore" {
  bucket = local.artifactory_s3_bucket_name

  # WARNING: force_destroy = true allows the bucket to be destroyed even if it contains objects.
  # Set s3_force_destroy = false in terraform.tfvars to protect against accidental data loss.
  force_destroy = var.s3_force_destroy

  tags = {
    Group = var.common_tag
    Env   = var.env_name
  }

  lifecycle {
    prevent_destroy = false
  }
}
