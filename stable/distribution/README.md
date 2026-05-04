# JFrog Distribution Helm Chart

> [!NOTE]
> See the [JFrog Helm Charts README](https://github.com/jfrog/charts#container-image-migration-notice) for important notices including the container image migration.

**IMPORTANT!** Our Helm Chart docs have moved to our main documentation site. Below you will find the basic instructions for installing Distribution. For all other information, refer to [Installing Distribution](https://jfrog.com/help/r/jfrog-installation-setup-documentation/installing-distribution).

## Prerequisites Details
* Kubernetes 1.23+

## Chart Details
This chart does the following:
* Deploy PostgreSQL database
* Deploy distribution

> **Note:** From Distribution 2.37.0, Redis is no longer included in this chart. For more information, see the [Distribution 2.37.0 release notes](https://docs.jfrog.com/releases/docs/distribution-release-notes#distribution-2370).

## Requirements
- A running Kubernetes cluster
- Dynamic storage provisioning enabled
- Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory Enterprise Plus
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) v3 installed

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
             --set distribution.jfrogUrl=<YOUR_PREVIOUSLY_RETIREVED_BASE_URL> jfrog/distribution --namespace distribution --create-namespace
```

### Apply Sizing configurations to the Chart
To apply the chart with recommended sizing configurations :
For small configurations :
```bash
helm upgrade --install distribution jfrog/distribution -f sizing/distribution-small.yaml --namespace distribution --create-namespace
```

## Upgrading to Distribution 2.37.0 or Later

From Distribution 2.37.0, Redis has been removed from the chart. For more details, please refer to the [Distribution 2.37.0 release notes](https://docs.jfrog.com/releases/docs/distribution-release-notes#distribution-2370).

When upgrading from a version prior to 2.37.0, a pre-upgrade webhook (`distribution-upgrade-hook`) is automatically executed. This webhook handles the migration by deleting the existing StatefulSet with `--cascade=orphan` (preserving running pods) to allow the updated spec — which no longer includes Redis — to be applied cleanly.

In most cases, no manual intervention is required. However, if the hook job fails (for example, due to RBAC permissions or image pull issues), you may need to manually delete the StatefulSet before retrying the upgrade:

```bash
kubectl delete statefulset <release-name>-distribution --cascade=orphan -n <namespace>
```

## Uninstalling Distribution

**IMPORTANT:** Uninstalling distribution using the commands below will also delete your data volumes and you will lose all of your data. You must back up all this information before deletion.

To uninstall Distribution use the following command.

```bash
helm uninstall distribution --namespace distribution && sleep 90 && kubectl delete pvc -l app=distribution
```