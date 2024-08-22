# JFrog Xray HA on Helm Chart

**IMPORTANT!** Our Helm Chart docs have moved to our main documentation site. Below you will find the basic instructions for installing and deleting Xray. For all other information, refer to [Installing Xray](https://www.jfrog.com/confluence/display/JFROG/Installing+Xray).

## Prerequisites Details

* Kubernetes 1.14+

## Chart Details

This chart will do the following:

* Optionally deploy PostgreSQL (**NOTE:** For production grade installations it is recommended to use an external PostgreSQL)
* Deploy RabbitMQ (optionally as an HA cluster)
* Deploy JFrog Xray micro-services

## Requirements

- A running Kubernetes cluster
  - Dynamic storage provisioning enabled
  - Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) v2 or v3 installed


## Install JFrog Xray

### Add the JFrog Helm Repository

Before installing JFrog helm charts, you will need to add the [JFrog helm repository](https://charts.jfrog.io) to your Helm client.
```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Install the Chart

#### Artifactory Connection Details

To connect Xray to your Artifactory installation, you will need to use a join key. To learn how to retrieve the connection details of your Artifactory installation (join key and JFrog URL) from the UI, see https://www.jfrog.com/confluence/display/JFROG/General+Security+Settings#GeneralSecuritySettings-ViewingtheJoinKey. 

### Initiate Installation
Provide the join key and JFrog URL as a parameter to the Xray chart installation:

```bash
helm upgrade --install xray --set xray.joinKey=<YOUR_PREVIOUSLY_RETIREVED_JOIN_KEY> \
             --set xray.jfrogUrl=<YOUR_PREVIOUSLY_RETIREVED_BASE_URL> jfrog/xray --namespace xray --create-namespace
```

### Apply Sizing configurations to the Chart
To apply the chart with recommended sizing configurations :
For small configurations :
```bash
helm upgrade --install xray jfrog/xray -f sizing/xray-sizing-small.yaml --namespace xray --create-namespace
```

## Uninstalling Xray

**IMPORTANT:** Uninstalling Xray using the commands below will also delete your data volumes and you will lose all of your data. You must back up all this information before deletion.

To uninstall Xray use the following command.

```bash
helm uninstall xray --namespace xray && sleep 90 && kubectl delete pvc -l app=xray
```
