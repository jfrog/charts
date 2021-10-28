# JFrog Pipelines on Helm Chart

[JFrog Pipelines](https://jfrog.com/pipelines/)

**IMPORTANT!** Our Helm Chart docs have moved to our main documentation site. Below you will find the basic instructions for installing Pipelines. For all other information, refer to [[Installing Pipelines - Helm Installation](https://www.jfrog.com/confluence/display/JFROG/Installing+Pipelines#InstallingPipelines-HelmInstallation).

## Prerequisites
* Kubernetes 1.14+

## Chart Details
This chart will do the following:
- Deploy PostgreSQL (optionally with an external PostgreSQL instance)
- Deploy RabbitMQ (optionally as an HA cluster)
- Deploy Redis (optionally as an HA cluster)
- Deploy Vault (optionally with an external Vault instance)
- Deploy JFrog Pipelines

## Requirements
- A running Kubernetes cluster
  - Dynamic storage provisioning enabled
  - Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory 7.19.x with Enterprise+ License
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) v3 installed

## Installing JFrog Pipelines

### Add the JFrog Helm Repository
Before installing JFrog Helm charts, you will need to add the [JFrog helm repository](https://charts.jfrog.io) to your Helm client.

```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Artifactory Connection Details
To connect Pipelines to your Artifactory installation, you will need to use a join key. To learn how to retrieve the connection details of your Artifactory installation (join key and JFrog URL) from the UI, see https://www.jfrog.com/confluence/display/JFROG/General+Security+Settings#GeneralSecuritySettings-ViewingtheJoinKey.

### Install JFrog Pipelines
```bash
kubectl create ns pipelines
helm upgrade --install pipelines --namespace pipelines jfrog/pipelines -f pipelines/values-ingress.yaml -f pipelines/values-ingress-passwords.yaml
```

## Uninstalling the Chart

Uninstall is supported only on Helm v3 and on.

Uninstall Pipelines using the following command.

```bash
helm uninstall pipelines && sleep 90 && kubectl delete pvc -l name=pipelines
```
