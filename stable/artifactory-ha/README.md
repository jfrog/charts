# JFrog Artifactory High Availability Helm Chart

**IMPORTANT!** Our Helm Chart docs have moved to our main documentation site. Below you will find the basic instructions for installing, uninstalling, and deleting Artifactory. For all other information, refer to [Installing Artifactory - Helm HA Installation](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory#InstallingArtifactory-HelmHAInstallation).

**Note:** From Artifactory 7.17.4 and above, the Helm HA installation can be installed so that each node you install can run all tasks in the cluster.

Below you will find the basic instructions for installing, uninstalling, and deleting Artifactory. For all other information, refer to the documentation site.

## Prerequisites Details

* Kubernetes 1.14+
* Artifactory HA license

## Chart Details
This chart will do the following:

* Deploy Artifactory highly available cluster. 1 primary node and 2 member nodes.
* Deploy a PostgreSQL database  **NOTE:** For production grade installations it is recommended to use an external PostgreSQL
* Deploy an Nginx server

## Installing the Chart

### Add JFrog Helm repository

Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io) to your helm client

```bash
helm repo add jfrog https://charts.jfrog.io
```
2. Next, create a unique Master Key (Artifactory requires a unique master key) and pass it to the template during installation.
3. Now, update the repository.

```bash
helm repo update
```

### Install Chart
To install the chart with the release name `artifactory`:
```bash
helm upgrade --install artifactory-ha --namespace artifactory-ha jfrog/artifactory-ha
```

## Uninstalling Artifactory

Uninstall is supported only on Helm v3 and on.

Uninstall Artifactory using the following command.

```bash
helm uninstall artifactory-ha && sleep 90 && kubectl delete pvc -l app=artifactory-ha
```

## Deleting Artifactory

**IMPORTANT:** Deleting Artifactory will also delete your data volumes and you will lose all of your data. You must back up all this information before deletion. You do not need to uninstall Artifactory before deleting it.

To delete Artifactory use the following command.

```bash
helm delete artifactory-ha --namespace artifactory-ha
```

