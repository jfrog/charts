# JFrog Distribution Helm Chart

**Our Helm Chart docs have moved to our main documentation site. For Distribution installers, see [Installing Distribution](https://www.jfrog.com/confluence/display/JFROG/Installing+Distribution#InstallingDistribution-HelmInstallation).**

## Requirements
See [Helm Chart Requirements](https://www.jfrog.com/confluence/display/JFROG/System+Requirements#SystemRequirements-HelmChartRequirements) for details.

## Chart Details
This chart does the following:

* Deploy PostgreSQL database
* Deploy Redis
* Deploy distributor
* Deploy Distribution

# Installation Steps
The installation procedure involves the following main steps:

1. Dwnload Distribution.
2. Install Distribution either as a single node installation, or high availability cluster.
 a. Install third party dependencies (PostgreSQL and Redis database, included in the archive).
 b. Install Distribution
3. Configure the service
 a. Connect to Artifactory (joinKey and jfrogUrl).
 b. Implement additional optional configuration including changing default credentials for databases.
4. Start the Service using the start scripts or OS service management.
5. Check the Service Log to check the status of the service.

Once you have finished the set up of JFrog Distribution, continue to Configuring Distribution.

**Default Home Directory / $JFROG_HOME**
The default Distribution home directory is defined according to the installation type. For additional details see the Product Directory Structure page.
**Note:** This guide uses $JFROG_HOME to represent the JFrog root directory containing the deployed product.

## Helm Charts Installers for Advanced Users
Helm Chart for Artifactory provides a wide range of advanced options, which are documented [here](https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+Installers+for+Advanced+Users).

## Deploying Distribution for Small, Medium or Large Installations

In the chart directory, include three values files, one for each installation type--small/medium/large. These values files are recommendations for setting resources requests and limits for your installation. You can find the files in the corresponding chart directory.

# Installing Distribution
1. Add the ChartCenter Helm repository to your Helm client.

```bash
helm repo add center https://repo.chartcenter.io
```

2. Update the repository.

```bash
helm repo update
```

3. Initiate installation by providing a join key and JFrog url as a parameter to the Distribution chart installation.

```bash
helm upgrade --install distribution --set distribution.joinKey=<YOUR_PREVIOUSLY_RETIREVED_JOIN_KEY> \
             --set distribution.jfrogUrl=<YOUR_PREVIOUSLY_RETIREVED_BASE_URL> --namespace distribution center/jfrog/distribution
```

Alternatively, you can create a secret containing the join key manually and pass it to the template during install/upgrade.

```bash
# Create a secret containing the key. The key in the secret must be named join-key
kubectl create secret generic my-secret --from-literal=join-key=<YOUR_PREVIOUSLY_RETIREVED_JOIN_KEY>
 
# Pass the created secret to helm
helm upgrade --install distribution --set distribution.joinKeySecretName=my-secret --namespace distribution center/jfrog/distribution
In either case, make sure to pass the same join key on all future calls to helm install and helm upgrade. This means always passing --set distribution.joinKey=<YOUR_PREVIOUSLY_RETRIEVED_JOIN_KEY>. In the second, this means always passing --set distribution.joinKeySecretName=my-secret and ensuring the contents of the secret remain unchanged.

Customize the product configuration (optional) including database, Java Opts, and filestore.
Unlike other installations, Helm Chart configurations are made to the values.yaml and are then applied to the system.yaml.
```
4. Follow these steps to apply the configuration changes.
a. Make the changes to values.yaml. 
b. Run the command.

```bash
helm upgrade --install distribution --namespace distribution -f values.yaml
```

5. Access Distribution from your browser at: http://<jfrogUrl>/ui/, then go to the Security & Compliance tab in the Application module in the UI.
6. Check the status of your deployed Helm releases.

```bash
helm status distribution
```bash
