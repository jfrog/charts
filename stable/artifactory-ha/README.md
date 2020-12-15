# JFrog Artifactory High Availability Helm Chart

**Our Helm Chart docs have moved to our main documentation site. For JFrog Artifactory installers, see [Installing Artifactory](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory).**

## Prerequisites Details

* Kubernetes 1.12+
* Artifactory HA license

## Chart Details
This chart will do the following:

* Deploy Artifactory highly available cluster. 1 primary node and 2 member nodes.
* Deploy a PostgreSQL database  **NOTE:** For production grade installations it is recommended to use an external PostgreSQL
* Deploy an Nginx server

## Artifactory HA architecture
The Artifactory HA cluster in this chart is made up of the following:
- A single primary node
- Two member nodes, which can be resized at will

Load balancing is done to the member nodes only. This leaves the primary node free to handle jobs and tasks and not be interrupted by inbound traffic.
This can be controlled by the parameter `artifactory.service.pool`.
**NOTE:**
 Using the Artifactory pro license (which supports single node only), set `artifactory.node.replicaCount=0` in the `values.yaml` file.
 To scale from a single node to multiple nodes(>1), use an Enterprise(+) license and then perform a Helm upgrade (each node will require a separate license).

## Installation Steps
1. Download the relevant package from the [Download JFrog Platform page](https://jfrog.com/download-jfrog-platform/).
2. Install Artifactory.
c. Customize the product configuration (optional) including database, Java Opts, and filestore.
4. Start the service using the start scripts or OS service management.
5. Check the Artifactory Log to check the status of the service.
6. Implement post-installation steps including changing the default password.

## Installing the Chart
**Note:** The chart directory, includes three values files, one for each installation type–small/medium/large. These values files are recommendations for setting resources requests and limits for your installation. You can find the files in the corresponding chart directory.

1. Add the ChartCenter Helm repository to your Helm client.

```bash
helm repo add center https://repo.chartcenter.io
```

2. Update the repository.

```bash
helm repo update
```

**Note:** Passing masterKey is mandatory for fresh install of chart (7.x Appversion)

3. Create a unique Master Key (the Artifactory HA cluster requires a unique master key) and pass it to the template 

**Note:** For production grade installations it is strongly recommended to use a custom master key. If you initially use the default master key it will be difficult to change the master key at a later stage. Therefore, generate a unique key and pass it to the template at install/upgrade time.

```bash
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}
```
4. Install the chart with the release name `artifactory-ha`.

```bash
helm upgrade --install artifactory-ha --set artifactory.masterKey=${MASTER_KEY} --namespace artifactory-ha center/jfrog/artifactory-ha
```
5. [Customize the product configuration](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory#InstallingArtifactory-ProductConfiguration) including database, Java Opts, and filestore. Unlike other installations, Helm Chart configurations are made to the `values.yaml` and are then applied to the system.yaml. To override the default `system.yaml` configuration, do the following:

```bash
artifactory:
  systemYaml: |
    <YOUR_SYSTEM_YAML_CONFIGURATION>
```
6. Follow these steps to apply the configuration changes.
a. Make the changes to the `values.yaml` file. 
b. Run the command.

```bash
helm upgrade --install artifactory-ha --namespace artifactory-ha -f values.yaml
``` 
7. Connect to Artifactory. 
It may take a few minutes for Artifactory's public IP to become available. Follow the instructions that are output by the install command above to get the Artifactory IP to access it. Below you will find a sample instruction of what to look for to pick the URL to reach Artifactory (in the example below, art77 is the release name and art is the namespace).

Congratulations. You have just deployed JFrog Artifactory.
a. Get the Artifactory URL by running these commands:
   NOTE: It may take a few minutes for the LoadBalancer IP to be available.
         You can watch the status of the service by running 'kubectl get svc --namespace art -w art77-artifactory-nginx'
   export SERVICE_IP=$(kubectl get svc --namespace art art77-artifactory-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
   echo http://$SERVICE_IP/
b. Open Artifactory in your browser
   Default credential for Artifactory:
   user: admin
   password: password

8. To access the logs, find the name of the pod using this command.

```bash
kubectl --namespace <your namespace> get pods
```
9. To get the container logs, run the following command.

```bash
kubectl --namespace <your namespace> logs -f <name of the pod>
```

## Updating Artifactory
Once you have a new chart version, you can update your deployment with
```bash
helm upgrade artifactory-ha --namespace artifactory-ha center/jfrog/artifactory-ha
```

If artifactory was installed without providing a value to postgresql.postgresqlPassword (a password was autogenerated), follow these instructions:
1. Get the current password by running:
```bash
POSTGRES_PASSWORD=$(kubectl get secret -n <namespace> <myrelease>-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
```
2. Upgrade the release by passing the previously auto-generated secret:
```bash
helm upgrade <myrelease> --namespace artifactory-ha center/jfrog/artifactory-ha --set postgresql.postgresqlPassword=${POSTGRES_PASSWORD}
```

This will apply any configuration changes on your existing deployment.

## Post-Install Steps
Once the installation is complete, 
1. Make sure you have applied your licenses.
2. Change the [default admin password](https://www.jfrog.com/confluence/display/JFROG/Users+and+Groups#UsersandGroups-RecreatingtheDefaultAdminUserrecreate).
3. Configure the system, including the [database/storage](https://www.jfrog.com/confluence/display/JFROG/Configuring+the+Database) and [filestore](https://www.jfrog.com/confluence/display/JFROG/Configuring+the+Filestore).


# Helm Charts Installers for Advanced Users
Helm Chart for Artifactory provides a wide range of advanced options, which are documented [here](https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+Installers+for+Advanced+Users).
