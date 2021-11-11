# JFrog Distribution Helm Chart

**IMPORTANT!** Our Helm Chart docs have moved to our main documentation site. Below you will find the basic instructions for installing Distribution. For all other information, refer to [Installing Distribution](https://www.jfrog.com/confluence/display/JFROG/Installing+Distribution).

## Prerequisites Details
* Kubernetes 1.12+

## Chart Details
This chart does the following:
* Deploy PostgreSQL database
* Deploy Redis
* Deploy distribution

## Requirements
- A running Kubernetes cluster
- Dynamic storage provisioning enabled
- Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory Enterprise Plus
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) v2 or v3 installed

## Installing the Chart

### Add the JFrog Helm Repository
Before installing JFrog helm charts, you will need to add the [JFrog helm repository](https://charts.jfrog.io) to your Helm client.

```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Artifactory Connection Details
To connect Distribution to your Artifactory installation, you will need to use a join key. To learn how to retrieve the connection details of your Artifactory installation (join key and JFrog URL) from the UI, see https://www.jfrog.com/confluence/display/JFROG/General+Security+Settings#GeneralSecuritySettings-ViewingtheJoinKey. 

### Initiate Installation
Provide a join key and the JFrog URL as a parameter to the Distribution chart installation:

```bash
helm upgrade --install distribution --set distribution.joinKey=<YOUR_PREVIOUSLY_RETIREVED_JOIN_KEY> \
             --set distribution.jfrogUrl=<YOUR_PREVIOUSLY_RETIREVED_BASE_URL> --namespace distribution jfrog/distribution
```

## Uninstalling Distribution

**IMPORTANT:** Uninstalling distribution using the commands below will also delete your data volumes and you will lose all of your data. You must back up all this information before deletion.

To uninstall Distribution use the following command.

```bash
helm uninstall distribution --namespace distribution && sleep 90 && kubectl delete pvc -l app=distribution
```
