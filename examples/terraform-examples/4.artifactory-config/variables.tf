# Declare the variables with default values.
# These can be overridden in the terraform.tfvars file
variable "artifactory_url" {
  default = "http://localhost"
}

variable "artifactory_access_token" {
  default = ""
}
