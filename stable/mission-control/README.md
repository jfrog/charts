# JFrog Mission-Control Helm Chart

**IMPORTANT!** Our Helm Chart docs have moved to our main documentation site. Below you will find the basic instructions for installing Mission Control. For all other information, refer to [Installing Mission Control](https://www.jfrog.com/confluence/display/JFROG/Installing+Mission+Control).

## Prerequisites Details

* Kubernetes 1.12+

## Chart Details
This chart will do the following:

* Deploy PostgreSQL database **NOTE:** For production grade installations it is recommended to use an external PostgreSQL.
* Deploy Elasticsearch.
* Deploy Mission Control.

## Requirements
- A running Kubernetes cluster
- Dynamic storage provisioning enabled
- Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory Enterprise
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) installed and setup to use the cluster (helm init)

## Installing the Chart

### Add the JFrog Helm Repository
Before installing JFrog helm charts, you will need to add the [JFrog helm repository](https://charts.jfrog.io) to your Helm client.

```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Artifactory Connection Details
To connect Mission Control to your Artifactory installation, you will need to use a join key. To learn how to retrieve the connection details of your Artifactory installation (join key and JFrog URL) from the UI, see https://www.jfrog.com/confluence/display/JFROG/General+Security+Settings#GeneralSecuritySettings-ViewingtheJoinKey. 

### Initiate Installation
Provide a join key and the JFrog URL as a parameter to the Mission Control chart installation:

```bash
helm upgrade --install mission-control --set missionControl.joinKey=<YOUR_PREVIOUSLY_RETIREVED_JOIN_KEY> \
             --set missionControl.jfrogUrl=<YOUR_PREVIOUSLY_RETIREVED_BASE_URL> --namespace mission-control jfrog/mission-control
```

## Uninstalling the Chart

Uninstall is supported only on Helm v3 and on.

Uninstall Mission-control using the following command.

```bash
helm uninstall mission-control && sleep 90 && kubectl delete pvc -l app=mission-control
```
