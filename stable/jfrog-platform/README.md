# JFrog Platform Helm Chart

**NOTE:** This is the **GA** release of the JFrog Platform chart (Backward compatibility with versions < 10.0.0 is not supported)

## Prerequisites Details

* Kubernetes 1.14+
* Artifactory Enterprise(+) trial license [get one from here](https://jfrog.com/platform/free-trial/) or Pro trial license [get one from here](https://www.jfrog.com/artifactory/free-trial/)

## Chart Details
This chart will do the following:

* Deploy JFrog Platform (artifactory, xray, distribution, insight and pipelines). Fully customizable.
* Deploy a PostgreSQL database using the bitnami/postgresql chart (can be changed) **NOTE:** For production grade installations it is recommended to use an external PostgreSQL.
* Deploy a Rabbitmq using the bitnami/rabbitmq chart (can be changed)
* Deploy a Redis using the bitnami/redis chart (can be changed)
* Deploy an optional Nginx server

## Installing the Chart

### Add JFrog Helm repository

Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io) to your helm client

```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Install Chart
To install the chart with the release name `jfrog-platform`
```bash
helm upgrade --install jfrog-platform --namespace jfrog-platform jfrog/jfrog-platform
```

### High Availability

For **high availability** of Artifactory, set the replica count to be equal or higher than **2**. Recommended is **3**.
```bash
# Start artifactory with 3 replicas per service
helm upgrade --install jfrog-platform --namespace jfrog-platform --set artifactory.artifactory.replicaCount=3
```

### Install Artifactory license
The JFrog platform chart requires an artifactory license. There are three ways to manage the license. **Artifactory UI**, **REST API**, or a **Kubernetes Secret**.

The easier and recommended way is the **Artifactory UI**. Using the **Kubernetes Secret** or **REST API** is for advanced users and is better suited for automation.

**IMPORTANT:** You should use only one of the following methods. Switching between them while a cluster is running might disable your Artifactory!

##### Artifactory UI
Once primary cluster is running, open Artifactory UI and insert the license(s) in the UI. See [HA installation and setup](https://www.jfrog.com/confluence/display/RTF/HA+Installation+and+Setup) for more details. **Note that you should enter all licenses at once, with each license is separated by a newline.** If you add the licenses one at a time, you may get redirected to a node without a license and the UI won't load for that node.

##### REST API
You can add licenses via REST API (https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API#ArtifactoryRESTAPI-InstallHAClusterLicenses). Note that the REST API expects "\n" for the newlines in the licenses.

##### Kubernetes Secret
You can deploy the Artifactory license(s) as a [Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/).
Prepare a text file with the license(s) written in it. If writing multiple licenses (must be in the same file), it's important to put **two new lines between each license block**!
```bash
# Create the Kubernetes secret (assuming the local license file is 'art.lic')
kubectl create secret generic artifactory-cluster-license --from-file=./art.lic
```

```yaml
# Create a customvalues.yaml file
artifactory:
  enabled: true
  artifactory:
    license:
      secret: artifactory-cluster-license
      dataKey: art.lic
```
```bash
# Apply the values file during install
helm upgrade --install jfrog-platform --namespace jfrog-platform jfrog/jfrog-platform -f customvalues.yaml
```
**NOTE:** This method is relevant for initial deployment only! Once Artifactory is deployed, you should not keep passing these parameters as the license is already persisted into Artifactory's storage (they will be ignored).
Updating the license should be done via Artifactory UI or REST API.

##### Create the secret as part of the helm release
customvalues.yaml
```yaml
artifactory:
  enabled: true
  artifactory:
    license:
      licenseKey: |-
      <LICENSE_KEY1>


      <LICENSE_KEY2>


      <LICENSE_KEY3>
```

```bash
helm upgrade --install jfrog-platform --namespace jfrog-platform jfrog/jfrog-platform -f customvalues.yaml
```
**NOTE:** This method is relevant for initial deployment only! Once Artifactory is deployed, you should not keep passing these parameters as the license is already persisted into Artifactory's storage (they will be ignored).
Updating the license should be done via Artifactory UI or REST API.
If you want to keep managing the artifactory license using the same method, you can use the copyOnEveryStartup example shown in the values.yaml file

### Customizations of Chart

This chart would provide flexibility to enable one or more of the jfrog products.
1. Xray
2. Distribution
3. Insight
4. Pipelines
5. PDN server

For example to enable xray and insight with artifactory, you can refer the following yaml and pass it during install.
customvalues.yaml
```yaml
xray:
  enabled: true
insight:
  enabled: true
````
```bash
helm upgrade --install jfrog-platform --namespace jfrog-platform jfrog/jfrog-platform -f customvalues.yaml
```

### Uninstalling Jfrog Platform chart.

```bash
helm uninstall jfrog-platform --namespace jfrog-platform
```
This will completely delete your Jfrog Platform chart. NOTE: The removal of the helm release will not completely remove the persistent volumes. You need to explicitly remove them.

## Useful links

- https://www.jfrog.com/confluence/display/JFROG/Installing+the+JFrog+Platform+Using+Helm+Chart
