# JFrog Distribution Helm Chart

**Heads up: Our Helm Chart docs have moved to our main documentation site. For Distribution installers, see [Installing Distribution](https://www.jfrog.com/confluence/display/JFROG/Installing+Distribution).**

## Prerequisites Details

* Kubernetes 1.12+

## Chart Details
This chart does the following:

* Deploy PostgreSQL database.
* Deploy Redis.
* Deploy distributor.
* Deploy distribution.

## Requirements
- A running Kubernetes cluster
- Dynamic storage provisioning enabled
- Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory Enterprise Plus
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) v2 or v3 installed

## Installation Steps

1. Download the relevant package from the [Download JFrog Platform page](https://jfrog.com/download-jfrog-platform/).
2. Install Distribution either as a single node installation, or high availability cluster.
  * Install third party dependencies (PostgreSQL database, included in the archive)
  * Install Distribution
3. Configure Distribution basic settings:
  * Connect to an Artifactory instance (requires a `joinKey` and a `jfrogUrl`).
  * Optional: Configure the PostgreSQL database connection details if you have set Postgres as an external database.
4. Start the Service using the start scripts or OS service management.
5. Check the Service Log to check the status of the service.

### Install JFrog Distribution
*Note:** The chart directory includes three values files, one for each installation type–small/medium/large. These values files are recommendations for setting resources requests and limits for your installation. You can find the files in the corresponding chart directory. The values are derived from the following [documentation](https://www.jfrog.com/confluence/display/EP/Installing+on+Kubernetes#InstallingonKubernetes-Systemrequirements). 

### Add ChartCenter Helm repository
1. Add the ChartCenter Helm repository to your Helm client.

```
helm repo add center https://repo.chartcenter.io
```

2. Update the repository.

```
helm repo update
```

3. Next, create a unique master key; JFrog Distribution requires a unique master key to be used by all micro-services in the same cluster. By default the chart has one set in `values.yaml` (`distribution.masterKey`).
**Note:** For production grade installations it is strongly recommended to use a custom master key. If you initially use the default master key it will be very hard to change the master key at a later stage This key is for demo purpose and should not be used in a production environment.
Generate a unique key and pass it to the template during installation/upgrade.

```
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}
 
# Pass the created master key to Helm
helm upgrade --install --set distribution.masterKey=${MASTER_KEY} --namespace distribution center/jfrog/distribution
```
Alternatively, you can create a secret containing the master key manually and pass it to the template during installation/upgrade.

```
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}
 
# Create a secret containing the key. The key in the secret must be named master-key
kubectl create secret generic my-secret --from-literal=master-key=${MASTER_KEY}
 
# Pass the created secret to Helm
helm upgrade --install distribution --set distribution.masterKeySecretName=my-secret --namespace distribution center/jfrog/distribution
```

**Note:** In either case, make sure to pass the same master key on all future calls to helm install and helm upgrade. In the first case, this means always passing `--set distribution.masterKey=${MASTER_KEY}`. In the second, this means always passing `--set distribution.masterKeySecretName=my-secret` and ensuring the contents of the secret remain unchanged.

4. Initiate installation by providing a join key and JFrog url as a parameter to the Distribution chart installation.

```
helm upgrade --install --set distribution.joinKey=<YOUR_PREVIOUSLY_RETRIEVED_JOIN_KEY> \
             --set distribution.jfrogUrl=<YOUR_PREVIOUSLY_RETRIEVED_BASE_URL>  --namespace distribution center/jfrog/distribution
```

Alternatively, you can create a secret containing the join key manually and pass it to the template at install/upgrade time.

```
# Create a secret containing the key. The key in the secret must be named join-key
kubectl create secret generic my-secret --from-literal=join-key=<YOUR_PREVIOUSLY_RETIREVED_JOIN_KEY>

# Pass the created secret to helm
helm upgrade --install --set distribution.joinKeySecretName=my-secret --namespace distribution center/jfrog/distribution
```

**NOTE:** In either case, make sure to pass the same join key on all future calls to `helm install` and `helm upgrade`! This means always passing `--set distribution.joinKey=<YOUR_PREVIOUSLY_RETRIEVED_JOIN_KEY>`. In the second, this means always passing `--set distribution.joinKeySecretName=my-secret` and ensuring the contents of the secret remain unchanged.

5. Customize the product configuration (optional) including database, Java Opts, and filestore. Unlike other installations, Helm Chart configurations are made to the values.yaml and are then applied to the system.yaml. Make the changes to the `values.yaml` and then run the following commmand: 

```
helm upgrade --install distribution --namespace distribution -f values.yaml
```
6. Access Distribution from your browser at: http://<jfrogUrl>/ui/and go to the Distribution tab in the Application module in the UI.
7. Check the status of your deployed Helm releases.
```
helm status distribution
```

## Non-compatible Upgrades
In cases where a new version is not compatible with existing deployed version (look in the CHANGELOG.md) you should do the following:
* Deploy a new version alongside the old version (set a new release name)
* Copy configurations and data from the old deployment to the new one (/var/opt/jfrog)
* Update DNS to point to the new Distribution service
* Remove the old release


## Useful links
- https://www.jfrog.com/confluence/display/EP/Getting+Started
- https://www.jfrog.com/confluence/display/DIST/Installing+Distribution
