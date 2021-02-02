# JFrog Artifactory Helm Chart

**Our Helm Chart docs have moved to our main documentation site. For JFrog Artifactory installers, see [Installing Artifactory](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory#InstallingArtifactory-HelmInstallation).**

## Prerequisites Details
* Kubernetes 1.12+
* Artifactory Pro trial license [get one from here](https://www.jfrog.com/artifactory/free-trial/)

## Chart Details
This chart will do the following:

* Deploy Artifactory-Pro/Artifactory-Edge (or OSS/CE if custom image is set)
* Deploy a PostgreSQL database using the stable/postgresql chart (this can be changed) **Note:** For production grade installations it is recommended to use an external PostgreSQL.
* Deploy an optional Nginx server
* Optionally expose Artifactory with Ingress [Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## Installation Steps
1. Download the relevant package from the [Download JFrog Platform](https://jfrog.com/download-jfrog-platform/) page.
2. Install Artifactory.
3. Customize the product configuration (optional) including database, Java Opts, and filestore.
4. Start the service using the start scripts or OS service management.
5. Check the Artifactory Log to check the status of the service.
6. Implement post-installation steps including changing the default password.

## Installing Artifactory

**Note:** The chart directory, includes three values files, one for each installation type–small/medium/large. These values files are recommendations for setting resources requests and limits for your installation. You can find the files in the corresponding chart directory.

1. Add the ChartCenter Helm repository to your Helm client.

```bash
helm repo add center https://repo.chartcenter.io
```

2. Update the repository.

```bash
helm repo update
```

3. Create a unique Master Key (Artifactory requires a unique master key).

**Note:** For production grade installations it is strongly recommended to use a custom master key. If you initially use the default master key it will be very hard to change the master key at a later stage. Therefore, generate a unique key and pass it to the template at install/upgrade time.

```bash
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}
```

4. Install the chart with the release name ```artifactory```.

```bash
helm upgrade --install artifactory --namespace artifactory center/jfrog/artifactory
```
5. [Customize the product configuration](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory#InstallingArtifactory-ProductConfiguration) including database, Java Opts, and filestore. Unlike other installations, Helm Chart configurations are made to the values.yaml and are then applied to the system.yaml. 
Follow these steps to apply the configuration changes.
a. Make the changes to the values.yaml file. 
b. Run the command.

```bash
helm upgrade --install artifactory --namespace artifactory -f values.yaml
```

7. Connect to Artifactory. 
It may take a few minutes for Artifactory's public IP to become available. Follow the instructions that are output by the install command above to get the Artifactory IP to access it. Below you will find a sample instruction of what to look for to pick the URL to reach Artifactory (in the example below, art77 is the release name and art is the namespace).

Congratulations. You have just deployed JFrog Artifactory.

8. To get the Artifactory URL, run the following commands.
   NOTE: It may take a few minutes for the LoadBalancer IP to be available. You can watch the status of the service by running 'kubectl get svc --namespace art -w art77-artifactory-nginx'
   ```bash
   export SERVICE_IP=$(kubectl get svc --namespace art art77-artifactory-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
   echo http://$SERVICE_IP/
   ```
9. Open Artifactory in your browser; the default credentials for Artifactory are:
   user: admin
   password: password

10. To access the logs, find the name of the pod using this command.

```bash
kubectl --namespace <your namespace> get pods
```

11. To get the container logs, run the following command.

```bash
kubectl --namespace <your namespace> logs -f <name of the pod>
```


## Post-Install Steps
Once the installation is complete, 
1. Make sure you have applied your licenses.
2. Change the [default admin password](https://www.jfrog.com/confluence/display/JFROG/Users+and+Groups#UsersandGroups-RecreatingtheDefaultAdminUserrecreate).
3. Configure the system, including the [database/storage](https://www.jfrog.com/confluence/display/JFROG/Configuring+the+Database) and [filestore](https://www.jfrog.com/confluence/display/JFROG/Configuring+the+Filestore).


# Helm Charts Installers for Advanced Users
Helm Chart for Artifactory provides a wide range of advanced options, which are documented [here](https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+Installers+for+Advanced+Users).

# Useful Links
* [Installing Artifactory](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory)
* [Onboarding Best Practices: JFrog Artifactory](https://www.jfrog.com/confluence/display/JFROG/Onboarding+Best+Practices%3A+JFrog+Artifactory)
* [JFrog Artifactory](https://www.jfrog.com/confluence/display/JFROG/JFrog+Artifactory)



