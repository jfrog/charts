# JFrog Xray HA on Kubernetes Helm Chart

**Our Helm Chart docs have moved to our main documentation site. For Xray installers, see [Installing Xray](https://www.jfrog.com/confluence/display/JFROG/Installing+Xray).**

## Prerequisites
* Kubernetes 1.12+

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

## Installation Steps

1. Download the relevant package from the [Download JFrog Platform page](https://jfrog.com/download-jfrog-platform/).
2. Install Xray either as a single node installation, or high availability cluster.
 * Install third party dependencies (PostgreSQL database, included in the archive)
 * Install Xray
3. Configure Xray basic settings:
 * Connect to an Artifactory instance (requires a `joinKey` and a `jfrogUrl`).
 * Optional: Configure the PostgreSQL database connection details if you have set Postgres as an external database.
4. Start the Service using the start scripts or OS service management.
5. Check the Service Log to check the status of the service.

## Install JFrog Xray

**Note:** The chart directory includes three values files, one for each installation type–small/medium/large. These values files are recommendations for setting resources requests and limits for your installation. You can find the files in the corresponding chart directory. The values are derived from the following [documentation](https://www.jfrog.com/confluence/display/EP/Installing+on+Kubernetes#InstallingonKubernetes-Systemrequirements). 

### Add ChartCenter Helm repository
1. Add the ChartCenter Helm repository to your Helm client.

```
helm repo add center https://repo.chartcenter.io
```

2. Update the repository.

```
helm repo update
```
3. Next, create a unique master key; JFrog Xray requires a unique master key to be used by all micro-services in the same cluster. By default the chart has one set in `values.yaml` (`xray.masterKey`).
**Note:** For production grade installations it is strongly recommended to use a custom master key. If you initially use the default master key it will be very hard to change the master key at a later stage This key is for demo purpose and should not be used in a production environment.
Generate a unique key and pass it to the template during installation/upgrade.

```
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}
 
# Pass the created master key to Helm
helm upgrade --install --set xray.masterKey=${MASTER_KEY} --namespace xray center/jfrog/xray
```
Alternatively, you can create a secret containing the master key manually and pass it to the template during installation/upgrade.

```
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}
 
# Create a secret containing the key. The key in the secret must be named master-key
kubectl create secret generic my-secret --from-literal=master-key=${MASTER_KEY}
 
# Pass the created secret to Helm
helm upgrade --install xray --set xray.masterKeySecretName=my-secret --namespace xray center/jfrog/xray
```

**Note:** In either case, make sure to pass the same master key on all future calls to helm install and helm upgrade. In the first case, this means always passing `--set xray.masterKey=${MASTER_KEY}`. In the second, this means always passing `--set xray.masterKeySecretName=my-secret` and ensuring the contents of the secret remain unchanged.

4. Initiate installation by providing a join key and JFrog url as a parameter to the Xray chart installation.

```
helm upgrade --install --set xray.joinKey=<YOUR_PREVIOUSLY_RETRIEVED_JOIN_KEY> \
             --set xray.jfrogUrl=<YOUR_PREVIOUSLY_RETRIEVED_BASE_URL>  --namespace xray center/jfrog/xray
```

Alternatively, you can create a secret containing the join key manually and pass it to the template at install/upgrade time.

```
# Create a secret containing the key. The key in the secret must be named join-key
kubectl create secret generic my-secret --from-literal=join-key=<YOUR_PREVIOUSLY_RETIREVED_JOIN_KEY>

# Pass the created secret to helm
helm upgrade --install --set xray.joinKeySecretName=my-secret --namespace xray center/jfrog/xray
```

**NOTE:** In either case, make sure to pass the same join key on all future calls to `helm install` and `helm upgrade`! This means always passing `--set xray.joinKey=<YOUR_PREVIOUSLY_RETRIEVED_JOIN_KEY>`. In the second, this means always passing `--set xray.joinKeySecretName=my-secret` and ensuring the contents of the secret remain unchanged.

5. Customize the product configuration (optional) including database, Java Opts, and filestore. Unlike other installations, Helm Chart configurations are made to the values.yaml and are then applied to the system.yaml. Make the changes to the `values.yaml` and then run the following commmand: 

```
helm upgrade --install xray --namespace xray -f values.yaml
```
6. Access Xray from your browser at: http://<jfrogUrl>/ui/: go to the Xray Security & Compliance tab in the Administration module in the UI
7. Check the status of your deployed Helm releases.
```
helm status xray
```

## High Availability
To set up Xray using a **high availability** configuration, set the replica count to be equal or higher than **2**. The recommended is **3**.
> It is highly recommended to also set **RabbitMQ** to run as an HA cluster.

```bash
# Start Xray with 3 replicas per service and 3 replicas for RabbitMQ
helm upgrade --install xray --namespace xray --set replicaCount=3  --set rabbitmq-ha.replicaCount=3 center/jfrog/xray
```

# Helm Charts Installers for Advanced Users
Helm Chart provides a wide range of advanced options, which are documented [here](https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+Installers+for+Advanced+Users).

