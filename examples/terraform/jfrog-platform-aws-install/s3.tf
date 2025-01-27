# This file is used to create an S3 bucket for Artifactory to store binaries

locals {
  artifactory_s3_bucket_name = "artifactory-${var.region}-${var.s3_bucket_name_suffix}-${random_pet.unique_name.id}"
}

resource "aws_s3_bucket" "artifactory_binarystore" {
  bucket = local.artifactory_s3_bucket_name

  # WARNING: This will force the bucket to be destroyed even if it's not empty
  force_destroy = true

  tags = {
    Group = var.common_tag
  }

  lifecycle {
    prevent_destroy = false
  }
}
