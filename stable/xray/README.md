# JFrog Xray HA on Kubernetes Helm Chart

**Heads up: Our Helm Chart docs have moved to our main documentation site. For Xray, see [Installing Xray](https://www.jfrog.com/confluence/display/JFROG/Installing+Xray#InstallingXray-HelmInstallation.1).**

## Requirements
See [Helm Chart Requirements](https://www.jfrog.com/confluence/display/JFROG/System+Requirements#SystemRequirements-HelmChartRequirements) for details.

## Chart Details
This chart will do the following:

* Optionally deploy PostgreSQL (**NOTE:** For production grade installations it is recommended to use an external PostgreSQL.)
* Deploy RabbitMQ (optionally as an HA cluster)
* Deploy JFrog Xray micro-services

## Deploying Artifactory for Small, Medium or Large Installations

In the chart directory, includes three values files, one for each installation type - small/medium/large. These values files are recommendations for setting resources requests and limits for your installation. You can find the files in the corresponding chart directory.

# Installation Steps

The installation procedure involves the following main steps:

1. Download Xray.
2. Install third party dependencies (PostgreSQL database, included in the archive)
3. Install Xray.
4. Configure Xray basic settings:
  a. Connect to an Artifactory instance (requires a joinKey and a jfrogUrl).
  b. Optional: Configure the PostgreSQL database connection details if you have set Postgres as an external database.
5. Start the Service using the start scripts or OS service management.
6. Check the Service Log to check the status of the service.

## Helm Charts Installers for Advanced Users
Helm Chart for Artifactory provides a wide range of advanced options, which are documented [here](https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+Installers+for+Advanced+Users).

**Default Home Directory / $JFROG_HOME**
The default Xray home directory is defined according to the installation type. For additional details see the Product Directory Structure page.
**Note:** This guide uses $JFROG_HOME to represent the JFrog root directory containing the deployed product.

## Installing Xray
In the chart directory, include three values files, one for each installation type - small/medium/large. These values files are recommendations for setting resources requests and limits for your installation. You can find the files in the corresponding chart directory.

**Note:** To set Xray for high availability, set the replicaCount in the values.yaml file to >1 (the recommended is 3). It is highly recommended to also set RabbitMQ to run as an HA cluster. Start Xray with 3 replicas per service and 3 replicas for RabbitMQ.
```bash
helm upgrade --install xray --namespace xray --set replicaCount=3  --set rabbitmq-ha.replicaCount=3 center/jfrog/xray
```

1. Add the ChartCenter Helm repository to your Helm client.

```bash
helm repo add center https://repo.chartcenter.io
```
2. Update the repository.

```bash
helm repo update
```
3. Next, create a unique master key; JFrog Xray requires a unique master key to be used by all micro-services in the same cluster. By default the chart has one set in values.yaml (xray.masterKey). For production grade installations it is strongly recommended to use a custom master key. If you initially use the default master key it will be very hard to change the master key at a later stage This key is for demo purpose and should not be used in a production environment.

Generate a unique key and pass it to the template during installation/upgrade.

```bash
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}

# Pass the created master key to Helm
helm upgrade --install --set xray.masterKey=${MASTER_KEY} --namespace xray center/jfrog/xray
Alternatively, you can create a secret containing the master key manually and pass it to the template during installation/upgrade.

# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}

# Create a secret containing the key. The key in the secret must be named master-key
kubectl create secret generic my-secret --from-literal=master-key=${MASTER_KEY}

# Pass the created secret to Helm
helm upgrade --install xray --set xray.masterKeySecretName=my-secret --namespace xray center/jfrog/xray
```

In either case, make sure to pass the same master key on all future calls to helm install and helm upgrade. In the first case, this means always passing --set xray.masterKey=${MASTER_KEY}. In the second, this means always passing --set xray.masterKeySecretName=my-secret and ensuring the contents of the secret remain unchanged.

4. [Customize the product configuration (optional) including database, Java Opts, and filestore](https://www.jfrog.com/confluence/display/JFROG/Installing+Xray#InstallingXray-ProductConfiguration).

**Note:** Unlike other installations, Helm Chart configurations are made to the values.yaml and are then applied to the system.yaml.
Follow these steps to apply the configuration changes.
a. Make the changes to values.yaml. 
b. Run the command.

```bash
helm upgrade --install xray --namespace xray -f values.yaml
```
5. Access Xray from your browser at: http://<jfrogUrl>/ui/, then go to the Security & Compliance tab in the Application module in the UI.
6. Check the status of your deployed helm releases.

```bash
helm status xray
```
