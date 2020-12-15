# JFrog Mission-Control Helm Chart

**Our Helm Chart docs have moved to our main documentation site. For Mission Control installers, see [Installing Mission Control](https://www.jfrog.com/confluence/display/JFROG/Installing+Mission+Control).**

## Prerequisites Details

* Kubernetes 1.12+

## Chart Details
This chart will do the following:

* Deploy PostgreSQL database **NOTE:** For production grade installations it is recommended to use an external PostgreSQL.
* Deploy Elasticsearch.
* Deploy Mission Control.

## Requirements
- A running Kubernetes cluster
- Dynamic storage provisioning enabled
- Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory Enterprise
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) installed and setup to use the cluster (helm init)

## Installation Steps

1. Download the relevant package from the [Download JFrog Platform page](https://jfrog.com/download-jfrog-platform/).
2. Install Mission Control either as a single node installation, or high availability cluster.
 * Install third party dependencies (PostgreSQL database, included in the archive)
 * Install Mission Control
3. Configure Mission Control basic settings:
 * Connect to an Artifactory instance (requires a `joinKey` and a `jfrogUrl`).
 * Optional: Configure the PostgreSQL database connection details if you have set Postgres as an external database.
4. Start the Service using the start scripts or OS service management.
5. Check the Service Log to check the status of the service.

### Install JFrog Mission Control
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

3. Next, create a unique master key; JFrog Mission Control requires a unique master key to be used by all micro-services in the same cluster. By default the chart has one set in `values.yaml` (`mission-control.masterKey`).
**Note:** For production grade installations it is strongly recommended to use a custom master key. If you initially use the default master key it will be very hard to change the master key at a later stage This key is for demo purpose and should not be used in a production environment.
Generate a unique key and pass it to the template during installation/upgrade.

```
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}
 
# Pass the created master key to Helm
helm upgrade --install --set mission-control.masterKey=${MASTER_KEY} --namespace mission-control center/jfrog/mission-control
```
Alternatively, you can create a secret containing the master key manually and pass it to the template during installation/upgrade.

```
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}
 
# Create a secret containing the key. The key in the secret must be named master-key
kubectl create secret generic my-secret --from-literal=master-key=${MASTER_KEY}
 
# Pass the created secret to Helm
helm upgrade --install mission-control --set mission-control.masterKeySecretName=my-secret --namespace mission-control center/jfrog/mission-control
```

**Note:** In either case, make sure to pass the same master key on all future calls to helm install and helm upgrade. In the first case, this means always passing `--set mission-control.masterKey=${MASTER_KEY}`. In the second, this means always passing `--set mission-control.masterKeySecretName=my-secret` and ensuring the contents of the secret remain unchanged.

4. Initiate installation by providing a join key and JFrog url as a parameter to the Mission Control chart installation.

```
helm upgrade --install --set mission-control.joinKey=<YOUR_PREVIOUSLY_RETRIEVED_JOIN_KEY> \
             --set mission-control.jfrogUrl=<YOUR_PREVIOUSLY_RETRIEVED_BASE_URL>  --namespace mission-control center/jfrog/mission-control
```

Alternatively, you can create a secret containing the join key manually and pass it to the template at install/upgrade time.

```
# Create a secret containing the key. The key in the secret must be named join-key
kubectl create secret generic my-secret --from-literal=join-key=<YOUR_PREVIOUSLY_RETIREVED_JOIN_KEY>

# Pass the created secret to helm
helm upgrade --install --set mission-control.joinKeySecretName=my-secret --namespace mission-control center/jfrog/mission-control
```

**NOTE:** In either case, make sure to pass the same join key on all future calls to `helm install` and `helm upgrade`! This means always passing `--set mission-control.joinKey=<YOUR_PREVIOUSLY_RETRIEVED_JOIN_KEY>`. In the second, this means always passing `--set mission-control.joinKeySecretName=my-secret` and ensuring the contents of the secret remain unchanged.

5. Customize the product configuration (optional) including database, Java Opts, and filestore. Unlike other installations, Helm Chart configurations are made to the values.yaml and are then applied to the system.yaml. Make the changes to the `values.yaml` and then run the following commmand: 

```
helm upgrade --install mission-control --namespace mission-control -f values.yaml
```
6. Access Mission Control from your browser at: http://<jfrogUrl>/ui/and go to the Dashboard tab in the Application module in the UI.
7. Check the status of your deployed Helm releases.
```
helm status mission-control
```
  
## Non-compatible Upgrades
In cases where a new version is not compatible with existing deployed version (look in CHANGELOG.md) you should
* Deploy a new version alongside the old version (set a new release name)
* Copy configurations and data from old deployment to new one (The following instructions were tested for chart migration from 0.9.4 (3.4.3) to 1.0.0 (3.5.0))
  * Copy data and config from old deployment to local filesystem
    ```
    kubectl cp <elasticsearch-pod>:/usr/share/elasticsearch/data                                   /<local_disk_path>/mission-control-data/elastic_data               -n <old_namespace>
    kubectl cp <postgres-pod>:/var/lib/postgresql/data                                             /<local_disk_path>/mission-control-data/postgres_data              -n <old_namespace>
    kubectl cp <mission-control-pod>:/var/opt/jfrog/mission-control/etc/mission-control.properties /<local_disk_path>/mission-control-data/mission-control.properties -n <old_namespace> -c mission-control
    kubectl cp <mission-control-pod>:/var/opt/jfrog/mission-control/data/security/mc.key           /<local_disk_path>/mission-control-data/mc.key                     -n <old_namespace> -c mission-control
    ```
  * This point applies only if you have used autogenerated password for postgres in your previous deploy or in your new deployement.
    * Get the postgres password from previous deploy, (refer [decoding-a-secret](https://kubernetes.io/docs/concepts/configuration/secret/#decoding-a-secret) for more info on reading a sceret value)
      ```
      POSTGRES_PASSWORD=$(kubectl get secret -n <old_namespace> <old_release_name>-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
      ```
      **NOTE** This needs to be passed with every `helm --set postgresql.postgresqlPassword=${POSTGRES_PASSWORD} install` and `helm --set postgresql.postgresqlPassword=${POSTGRES_PASSWORD} upgrade` 
  * Copy data and config from local filesystem to new deployment
    ```bash
    kubectl cp /<local_disk_path>/mission-control-data/mc.key                     <mission-control-pod>:/var/opt/jfrog/mission-control/data/security/mc.key            -n <new_namespace> -c mission-control
    # Note : This mission-control.properties has to be copied to all the replicas if you plan to scale to more replicas in future
    kubectl cp /<local_disk_path>/mission-control-data/mission-control.properties <mission-control-pod>:/var/opt/jfrog/mission-control/etc/mission-control.properties  -n <new_namespace> -c mission-control
    kubectl cp /<local_disk_path>/mission-control-data/elastic_data               <mission-control-pod>:/usr/share/elasticsearch                                       -n <new_namespace> -c elasticsearch
    kubectl cp /<local_disk_path>/mission-control-data/postgres_data              <postgres-pod>:/var/lib/postgresql                                                   -n <new_namespace>

    kubectl exec -it <postgres-pod> -n <new_namespace> -- bash
        rm -fr /var/lib/postgresql/data
        cp -fr /var/lib/postgresql/postgres_data/* /var/lib/postgresql/data/
        rm -fr /var/lib/postgresql/postgres_data
    kubectl exec -it <mission-control-pod> -n <new_namespace> -c elasticsearch -- bash
        rm -fr /usr/share/elasticsearch/data
        cp -fr /usr/share/elasticsearch/elastic_data/* /usr/share/elasticsearch/data
        rm -fr /usr/share/elasticsearch/elastic_data
    ```
* Restart the new deployment
  ```bash
  kubectl scale deployment <postgres-deployment> --replicas=0 -n <new_namespace>
  kubectl scale statefulset <mission-control-statefulset> --replicas=0 -n <new_namespace>

  kubectl scale deployment <postgres-deployment> --replicas=1 -n <new_namespace>
  kubectl scale statefulset <mission-control-statefulset> --replicas=1 -n <new_namespace>

  # if you are using autogenerated password for postgres, set the postgres password from previous deploy by running an upgrade
  # helm --set postgresql.postgresqlPassword=${POSTGRES_PASSWORD} upgrade ...
  ```
* A new mc.key will be generated after this upgrade, save a copy of this key. **NOTE**: This should be passed on all future calls to `helm install` and `helm upgrade`!
```bash
export MC_KEY=$(kubectl exec -it <mission-control-pod> -n <new_namespace> -c mission-control -- cat /var/opt/jfrog/mission-control/data/security/mc.key )
```
* Remove old release

# Helm Charts Installers for Advanced Users
Helm Chart provides a wide range of advanced options, which are documented [here](https://www.jfrog.com/confluence/display/JFROG/Helm+Charts+Installers+for+Advanced+Users).


## Useful links
- https://www.jfrog.com/confluence/display/JFROG/JFrog+Mission+Control
- https://www.jfrog.com/confluence/display/EP/Getting+Started
