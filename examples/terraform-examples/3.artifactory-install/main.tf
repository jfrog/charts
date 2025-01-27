# Create an empty artifactory-license.yaml if missing
resource "local_file" "empty_license" {
  count = fileexists("${path.module}/artifactory-license.yaml") ? 0 : 1
  filename = "${path.module}/artifactory-license.yaml"
  content = "## Empty file to satisfy Helm requirements"
}

# Create a Helm release for Artifactory (including the license)
resource "helm_release" "artifactory" {
  name        = "artifactory"
  repository  = "https://charts.jfrog.io"
  chart       = "artifactory"
  version     = var.chart_version

  depends_on = [
    local_file.empty_license
  ]

  values = [
    file("${path.module}/artifactory-values.yaml"),
    file("${path.module}/artifactory-license.yaml")
  ]
}
