# JFrog Mission-Control Helm Chart

## Prerequisites Details

* Kubernetes 1.8+

## Chart Details
This chart will do the following:

* Deploy Mongodb database.
* Deploy Elasticsearch.
* Deploy Mission Control.

## Requirements
- A running Kubernetes cluster
- Dynamic storage provisioning enabled
- Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory Enterprise
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) installed and setup to use the cluster (helm init)

## Add JFrog Helm repository
Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io/) to your helm client
```bash
helm repo add jfrog https://charts.jfrog.io
```

### Installing the Chart
```bash
helm install --name mission-control jfrog/mission-control
```

## Set Mission Control base URL
* Get mission-control url by running following commands:
`export SERVICE_IP=$(kubectl get svc --namespace default mission-control-mission-control -o jsonpath='{.status.loadBalancer.ingress[0].ip}')`

`export MISSION_CONTROL_URL="http://$SERVICE_IP:8080/"`

* Set mission-control by running helm upgrade command:
```
helm upgrade --name mission-control --set missionControl.missionControlUrl=$MISSION_CONTROL_URL jfrog/mission-control
```

### Accessing Mission Control
**NOTE:** It might take a few minutes for Mission Control's public IP to become available, and the nodes to complete initial setup.
Follow the instructions outputted by the install command to get the Distribution IP and URL to access it.

### Updating Mission Control
Once you have a new chart version, you can update your deployment with
```
helm upgrade mission-control jfrog/mission-control
```

### Custom init containers
There are cases where a special, unsupported init processes is needed like checking something on the file system or testing something before spinning up the main container.

For this, there is a section for writing a custom init container in the [values.yaml](values.yaml). By default it's commented out
```
missionControl:
  ## Add custom init containers
  customInitContainers: |
    ## Init containers template goes here ##
```

## Configuration
The following table lists the configurable parameters of the distribution chart and their default values.

|         Parameter                            |           Description                           |          Default                      |
|----------------------------------------------|-------------------------------------------------|---------------------------------------|
| `initContainerImage`                         | Init Container Image                            | `alpine:3.6`                          |
| `imagePullPolicy`                            | Container pull policy                           | `IfNotPresent`                        |
| `imagePullSecrets`                           | Docker registry pull secret                     |                                       |
| `serviceAccount.create`                      | Specifies whether a ServiceAccount should be created | `true`                           |
| `serviceAccount.name`                        | The name of the ServiceAccount to create             | Generated using the fullname template |
| `rbac.create`                                | Specifies whether RBAC resources should be created   | `true`                           |
| `rbac.role.rules`                            | Rules to create                                 | `[]`                                  |
| `mongodb.enabled`                            | Enable Mongodb                                  | `true`                                |
| `mongodb.image.tag`                          | Mongodb docker image tag                        | `3.6.8-debian-9`                      |
| `mongodb.image.pullPolicy`                   | Mongodb Container pull policy                   | `IfNotPresent`                        |
| `mongodb.persistence.enabled`                | Mongodb persistence volume enabled              | `true`                                |
| `mongodb.persistence.existingClaim`          | Use an existing PVC to persist data             | `nil`                                 |
| `mongodb.persistence.storageClass`           | Storage class of backing PVC                    | `generic`                             |
| `mongodb.persistence.size`                   | Mongodb persistence volume size                 | `50Gi`                                |
| `mongodb.livenessProbe.initialDelaySeconds`  | Mongodb delay before liveness probe is initiated   | `40`                               |
| `mongodb.readinessProbe.initialDelaySeconds` | Mongodb delay before readiness probe is initiated  | `30`                               |
| `mongodb.mongodbExtraFlags`                  | MongoDB additional command line flags           | `["--wiredTigerCacheSizeGB=1"]`       |
| `mongodb.usePassword`                        | Enable password authentication                  | `false`                               |
| `mongodb.db.adminUser`                       | Mongodb Database Admin User                     | `admin`                               |
| `mongodb.db.adminPassword`                   | Mongodb Database Password for Admin user        | ` `                                   |
| `mongodb.db.mcUser`                          | Mongodb Database Mission Control User           | `mission_platform`                    |
| `mongodb.db.mcPassword`                      | Mongodb Database Password for Mission Control user | ` `                                |
| `mongodb.db.insightUser`                     | Mongodb Database Insight User                   | `jfrog_insight`                       |
| `mongodb.db.insightPassword`                 | Mongodb Database password for Insight User      | ` `                                   |
| `mongodb.db.insightSchedulerDb`              | Mongodb Database for Scheduler                  | `insight_scheduler`                   |
| `elasticsearch.enabled`                      | Enable Elasticsearch                            | `true`                                |
| `elasticsearch.persistence.enabled`          | Elasticsearch persistence volume enabled        | `true`                                |
| `elasticsearch.persistence.existingClaim`    | Use an existing PVC to persist data             | `nil`                                 |
| `elasticsearch.persistence.storageClass`     | Storage class of backing PVC                    | `generic`                             |
| `elasticsearch.persistence.size`             | Elasticsearch persistence volume size           | `50Gi`                                |
| `elasticsearch.javaOpts.xms`                 | Elasticsearch ES_JAVA_OPTS -Xms                 | ``                                    |
| `elasticsearch.javaOpts.xmx`                 | Elasticsearch ES_JAVA_OPTS -Xmx                 | ``                                    |
| `elasticsearch.env.clusterName`              | Elasticsearch Cluster Name                      | `es-cluster`                          |
| `elasticsearch.env.esUsername`               | Elasticsearch User Name                         | `elastic`                             |
| `elasticsearch.env.esPassword`               | Elasticsearch User Name                         | `changeme`                            |
| `missionControl.name`                        | Mission Control name                            | `mission-control`                     |
| `missionControl.replicaCount`                | Mission Control replica count                   | `1`                                   |
| `missionControl.image`                       | Container image                                 | `docker.jfrog.io/jfrog/mission-control`     |
| `missionControl.version`                     | Container image tag                             | `.Chart.AppVersion`                               |
| `missionControl.customInitContainers`        | Custom init containers                          | ``                                    |
| `missionControl.service.type`                | Mission Control service type                    | `LoadBalancer`                        |
| `missionControl.externalPort`                | Mission Control service external port           | `80`                                  |
| `missionControl.internalPort`                | Mission Control service internal port           | `8080`                                |
| `missionControl.missionControlUrl`           | Mission Control URL                             | ` `                                   |
| `missionControl.persistence.mountPath`       | Mission Control persistence volume mount path   | `"/var/opt/jfrog/mission-control"`    |
| `missionControl.persistence.storageClass`    | Storage class of backing PVC                    | `nil (uses alpha storage class annotation)` |
| `missionControl.persistence.existingClaim`   | Provide an existing PersistentVolumeClaim       | `nil`                                 |
| `missionControl.persistence.enabled`         | Mission Control persistence volume enabled      | `true`                                |
| `missionControl.persistence.accessMode`      | Mission Control persistence volume access mode  | `ReadWriteOnce`                       |
| `missionControl.persistence.size`            | Mission Control persistence volume size         | `100Gi`                               |
| `missionControl.javaOpts.other`              | Mission Control JAVA_OPTIONS                    | `-server -XX:+UseG1GC -Dfile.encoding=UTF8` |
| `missionControl.javaOpts.xms`                | Mission Control JAVA_OPTIONS -Xms               | ``                                    |
| `missionControl.javaOpts.xmx`                | Mission Control JAVA_OPTIONS -Xmx               | ``                                    |
| `insightServer.name`                         | Insight Server name                             | `insight-server`                      |
| `insightServer.replicaCount`                 | Insight Server replica count                    | `1`                                   |
| `insightServer.image`                        | Container image                                 | `docker.jfrog.io/jfrog/insight-server`|
| `insightServer.version`                      | Container image tag                             | `.Chart.AppVersion`                               |
| `insightServer.service.type`                 | Insight Server service type                     | `ClusterIP`                           |
| `insightServer.externalHttpPort`             | Insight Server service external port            | `8082`                                |
| `insightServer.internalHttpPort`             | Insight Server service internal port            | `8082`                                |
| `insightServer.allowIP`                      | Range of IPs allowed to be served by Insight Server service  | `"0.0.0.0/0"`            |
| `insightScheduler.name`                      | Insight Scheduler name                          | `insight-scheduler`                   |
| `insightScheduler.replicaCount`              | Insight Scheduler replica count                 | `1`                                   |
| `insightScheduler.image`                     | Container image                                 | `docker.jfrog.io/jfrog/insight-scheduler`  |
| `insightScheduler.version`                   | Container image tag                             | `.Chart.AppVersion`                               |
| `insightScheduler.service.type`              | Insight Scheduler service type                  | `ClusterIP`                           |
| `insightScheduler.externalPort`              | Insight Scheduler service external port         | `8080`                                |
| `insightScheduler.internalPort`              | Insight Scheduler service internal port         | `8080`                                |
| `insightScheduler.javaOpts.other`            | Insight Scheduler JFMC_EXTRA_JAVA_OPTS          | ``                                    |
| `insightScheduler.javaOpts.xms`              | Insight Scheduler JFMC_EXTRA_JAVA_OPTS -Xms     | ``                                    |
| `insightScheduler.javaOpts.xmx`              | Insight Scheduler JFMC_EXTRA_JAVA_OPTS -Xmx     | ``                                    |
| `insightExecutor.name`                       | Insight Executor name                           | `insight-scheduler`                   |
| `insightExecutor.replicaCount`               | Insight Executor replica count                  | `1`                                   |
| `insightExecutor.image`                      | Container image                                 | `docker.jfrog.io/jfrog/insight-executor`   |
| `insightExecutor.version`                    | Container image tag                             | `.Chart.AppVersion`                               |
| `insightExecutor.service.type`               | Insight Executor service type                   | `ClusterIP`                           |
| `insightExecutor.externalPort`               | Insight Executor service external port          | `8080`                                |
| `insightExecutor.internalPort`               | Insight Executor service internal port          | `8080`                                |
| `insightExecutor.javaOpts.other`             | Insight Executor JFMC_EXTRA_JAVA_OPTS           | ``                                    |
| `insightExecutor.javaOpts.xms`               | Insight Executor JFMC_EXTRA_JAVA_OPTS -Xms      | ``                                    |
| `insightExecutor.javaOpts.xmx`               | Insight Executor JFMC_EXTRA_JAVA_OPTS -Xmx      | ``                                    |
| `insightExecutor.persistence.mountPath`      | Insight Executor persistence volume mount path  | `"/var/cloudbox"`                     |
| `insightExecutor.persistence.enabled`        | Insight Executor persistence volume enabled     | `true`                                |
| `insightExecutor.persistence.storageClass`   | Storage class of backing PVC                    | `nil (uses alpha storage class annotation)`|
| `insightExecutor.persistence.existingClaim`  | Provide an existing PersistentVolumeClaim       | `nil`                                 |
| `insightExecutor.persistence.accessMode`     | Insight Executor persistence volume access mode | `ReadWriteOnce`                       |
| `insightExecutor.persistence.size`           | Insight Executor persistence volume size        | `100Gi`                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.


## Useful links
- https://www.jfrog.com
- https://www.jfrog.com/confluence/
- https://www.jfrog.com/confluence/display/EP/Getting+Started
