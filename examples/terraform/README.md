# Terraform Playground
This repository contains a collection of Terraform configurations that we used to learn and experiment with Terraform.

## Install Terraform
Follow the [Install Terraform](https://developer.hashicorp.com/terraform/install) page to install Terraform on your machine.

## Setting up Terraform with Artifactory
The recommended way to manage Terraform state is to use a remote backend.
Some of the repository examples use JFrog Artifactory as the remote backend (commented out).

To set up Terraform with Artifactory, follow the instructions in the [Terraform Artifactory Backend](https://jfrog.com/help/r/jfrog-artifactory-documentation/terraform-backend-repository-structure) documentation.

## Examples
1. Create the needed [AWS infrastructure for running JFrog Artifactory and Xray in AWS](jfrog-platform-aws-install) using RDS, S3, and EKS. This uses the [JFrog Platform Helm Chart](https://github.com/jfrog/charts/tree/master/stable/jfrog-platform) to install Artifactory and Xray
