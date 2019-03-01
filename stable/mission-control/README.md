# JFrog Mission-Control Helm Chart

## Prerequisites Details

* Kubernetes 1.8+

## Chart Details
This chart will do the following:

* Deploy PostgreSQL database.
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
Follow the instructions outputted by the install command to get the Mission Control IP and URL to access it.

### Updating Mission Control
Once you have a new chart version, you can update your deployment with
```
helm upgrade mission-control jfrog/mission-control
```

### Use an external Database
There are cases where you will want to use an external **PostgreSQL** and not the enclosed **PostgreSQL**.
See more details on [configuring the database](https://www.jfrog.com/confluence/display/MC/Using+External+Databases#UsingExternalDatabases-ExternalizingPostgreSQL)

This can be done with the following parameters
```bash
...
--set postgresql.enabled=false \
--set database.host=${DB_HOST} \
--set database.port=${DB_PORT} \
--set database.user=${DB_USER} \
--set database.password=${DB_PASSWORD} \
...
```
**NOTE:** You must set `postgresql.enabled=false` in order for the chart to use the `database.*` parameters. Without it, they will be ignored!

#### Use existing secrets for PostgreSQL connection details
You can use already existing secrets for managing the database connection details.

Pass them to the install command with the following parameters
```bash
export POSTGRES_USERNAME_SECRET_NAME=
export POSTGRES_USERNAME_SECRET_KEY=
export POSTGRES_PASSWORD_SECRET_NAME=
export POSTGRES_PASSWORD_SECRET_KEY=
...
    --set database.secrets.user.name=${POSTGRES_USERNAME_SECRET_NAME} \
    --set database.secrets.user.key=${POSTGRES_USERNAME_SECRET_KEY} \
    --set database.secrets.password.name=${POSTGRES_PASSWORD_SECRET_NAME} \
    --set database.secrets.password.key=${POSTGRES_PASSWORD_SECRET_KEY} \
...
```

### Logger sidecars
This chart provides the option to add sidecars to tail various logs from Mission Control containers. See the available values in `values.yaml`

Get list of containers in the pod
```bash
kubectl get pods -n <NAMESPACE> <POD_NAME> -o jsonpath='{.spec.containers[*].name}' | tr ' ' '\n'
```

View specific log
```bash
kubectl logs -n <NAMESPACE> <POD_NAME> -c <LOG_CONTAINER_NAME>
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
The following table lists the configurable parameters of the mission-control chart and their default values.

|         Parameter                            |           Description                           |          Default                      |
|----------------------------------------------|-------------------------------------------------|---------------------------------------|
| `initContainerImage`                         | Init Container Image                            | `alpine:3.6`                          |
| `imagePullPolicy`                            | Container pull policy                           | `IfNotPresent`                        |
| `imagePullSecrets`                           | Docker registry pull secret                     |                                       |
| `serviceAccount.create`                      | Specifies whether a ServiceAccount should be created | `true`                           |
| `serviceAccount.name`                        | The name of the ServiceAccount to create             | Generated using the fullname template |
| `rbac.create`                                | Specifies whether RBAC resources should be created   | `true`                           |
| `rbac.role.rules`                            | Rules to create                                 | `[]`                                  |
| `mongodb.enabled`                            | Enable Mongodb                                  | `false`                                |
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
| `postgresql.enabled`                         | Enable PostgreSQL                               | `true`                                |
| `postgresql.imageTag`                        | PostgreSQL docker image tag                     | `9.6.11`                              |
| `postgresql.image.pullPolicy`                | PostgreSQL Container pull policy                | `IfNotPresent`                        |
| `postgresql.persistence.enabled`             | PostgreSQL persistence volume enabled           | `true`                                |
| `postgresql.persistence.existingClaim`       | Use an existing PVC to persist data             | `nil`                                 |
| `postgresql.persistence.size`                | PostgreSQL persistence volume size              | `50Gi`                                |
| `postgresql.postgresUsername`                | PostgreSQL admin username                       | `postgres`                            |
| `postgresql.postgresPassword`                | PostgreSQL admin password                       | ` `                                   |
| `postgresql.db.name`                         | PostgreSQL Database name                        | `mission_control`                     |
| `postgresql.db.sslmode`                      | PostgreSQL Database SSL Mode                    | `false`                               |
| `postgresql.db.tablespace`                   | PostgreSQL Database Tablespace                  | `pg_default`                          |
| `postgresql.db.jfmcUsername`                 | PostgreSQL Database mission control User        | `jfmc`                                |
| `postgresql.db.jfisUsername`                 | PostgreSQL Database insight server User         | `jfis`                                |
| `postgresql.db.jfscUsername`                 | PostgreSQL Database insight scheduler User      | `jfsc`                                |
| `postgresql.db.jfexUsername`                 | PostgreSQL Database mission executor User       | `jfex`                                |
| `postgresql.db.jfmcPassword`                 | PostgreSQL Database mission control Password    | ` `                                   |
| `postgresql.db.jfisPassword`                 | PostgreSQL Database insight server Password     | ` `                                   |
| `postgresql.db.jfscPassword`                 | PostgreSQL Database insight scheduler Password  | ` `                                   |
| `postgresql.db.jfexPassword`                 | PostgreSQL Database mission executor Password   | ` `                                   |
| `postgresql.db.jfmcSchema`                   | PostgreSQL Database mission control Schema      | `jfmc_server`                         |
| `postgresql.db.jfisSchema`                   | PostgreSQL Database insight server Schema       | `insight_server`                      |
| `postgresql.db.jfscSchema`                   | PostgreSQL Database insight scheduler Schema    | `insight_scheduler`                   |
| `postgresql.db.jfexSchema`                   | PostgreSQL Database mission executor Schema     | `insight_executor`                    |
| `postgresql.service.port`                    | PostgreSQL Database Port                        | `5432`                                |
| `database.type`                              | External database type (`postgresql`)           | `postgresql`                          |
| `database.host`                              | External database Connection Host               | ` `                                   |
| `database.port`                              | External database Connection Port               | ` `                                   |
| `database.name`                              | External database name                          | `mission_control`                     |
| `database.user`                              | External database user                          | ` `                                   |
| `database.password`                          | External database password                      | ` `                                   |
| `database.jfmcUsername`                      | External database mission control User          | `jfmc`                                |
| `database.jfisUsername`                      | External database insight server User           | `jfis`                                |
| `database.jfscUsername`                      | External database insight scheduler User        | `jfsc`                                |
| `database.jfexUsername`                      | External database mission executor User         | `jfex`                                |
| `database.jfmcPassword`                      | External database mission control Password      | ` `                                   |
| `database.jfisPassword`                      | External database insight server Password       | ` `                                   |
| `database.jfscPassword`                      | External database insight scheduler Password    | ` `                                   |
| `database.jfexPassword`                      | External database mission executor Password     | ` `                                   |
| `database.jfmcSchema`                        | External database mission control Schema        | `jfmc_server`                         |
| `database.jfisSchema`                        | External database insight server Schema         | `insight_server`                      |
| `database.jfscSchema`                        | External database insight scheduler Schema      | `insight_scheduler`                   |
| `database.jfexSchema`                        | External database mission executor Schema       | `insight_executor`                    |
| `database.secrets.user.name`                 | External database username `Secret` name        |                                       |
| `database.secrets.user.key`                  | External database username `Secret` key         |                                       |
| `database.secrets.password.name`             | External database password `Secret` name        |                                       |
| `database.secrets.password.key`              | External database password `Secret` key         |                                       |
| `elasticsearch.enabled`                      | Enable Elasticsearch                            | `true`                                |
| `elasticsearch.persistence.enabled`          | Elasticsearch persistence volume enabled        | `true`                                |
| `elasticsearch.persistence.existingClaim`    | Use an existing PVC to persist data             | `nil`                                 |
| `elasticsearch.persistence.storageClass`     | Storage class of backing PVC                    | `generic`                             |
| `elasticsearch.persistence.size`             | Elasticsearch persistence volume size           | `50Gi`                                |
| `elasticsearch.javaOpts.xms`                 | Elasticsearch ES_JAVA_OPTS -Xms                 | ` `                                   |
| `elasticsearch.javaOpts.xmx`                 | Elasticsearch ES_JAVA_OPTS -Xmx                 | ` `                                   |
| `elasticsearch.env.clusterName`              | Elasticsearch Cluster Name                      | `es-cluster`                          |
| `logger.image.repository`                    | repository for logger image                     | `busybox`                             |
| `logger.image.tag`                           | tag for logger image                            | `1.30`                                |
| `missionControl.name`                        | Mission Control name                            | `mission-control`                     |
| `missionControl.image`                       | Container image                                 | `docker.jfrog.io/jfrog/mission-control`     |
| `missionControl.version`                     | Container image tag                             | `.Chart.AppVersion`                   |
| `missionControl.customInitContainers`        | Custom init containers                          | ` `                                   |
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
| `missionControl.javaOpts.xms`                | Mission Control JAVA_OPTIONS -Xms               | ` `                                   |
| `missionControl.propertyOverride`            | Force write of properties on mc startup         | ` `                                   |
| `missionControl.loggers`                     | Mission Control loggers (see values.yaml for possible values)          | ` `            |
| `insightServer.name`                         | Insight Server name                             | `insight-server`                      |
| `insightServer.image`                        | Container image                                 | `docker.jfrog.io/jfrog/insight-server`|
| `insightServer.version`                      | Container image tag                             | `.Chart.AppVersion`                   |
| `insightServer.service.type`                 | Insight Server service type                     | `ClusterIP`                           |
| `insightServer.externalHttpPort`             | Insight Server service external port            | `8082`                                |
| `insightServer.internalHttpPort`             | Insight Server service internal port            | `8082`                                |
| `insightServer.allowIP`                      | Range of IPs allowed to be served by Insight Server service  | `"0.0.0.0/0"`            |
| `insightServer.loggers`                      | Insight Server loggers (see values.yaml for possible values)           | ` `            |
| `insightScheduler.name`                      | Insight Scheduler name                          | `insight-scheduler`                   |
| `insightScheduler.image`                     | Container image                                 | `docker.jfrog.io/jfrog/insight-scheduler`  |
| `insightScheduler.version`                   | Container image tag                             | `.Chart.AppVersion`                   |
| `insightScheduler.service.type`              | Insight Scheduler service type                  | `ClusterIP`                           |
| `insightScheduler.externalPort`              | Insight Scheduler service external port         | `8080`                                |
| `insightScheduler.internalPort`              | Insight Scheduler service internal port         | `8080`                                |
| `insightScheduler.javaOpts.other`            | Insight Scheduler JFMC_EXTRA_JAVA_OPTS          | ``                                    |
| `insightScheduler.javaOpts.xms`              | Insight Scheduler JFMC_EXTRA_JAVA_OPTS -Xms     | ``                                    |
| `insightScheduler.javaOpts.xmx`              | Insight Scheduler JFMC_EXTRA_JAVA_OPTS -Xmx     | ``                                    |
| `insightServer.loggers`                      | Insight Scheduler loggers (see values.yaml for possible values)           | ` `            |
| `insightExecutor.name`                       | Insight Executor name                           | `insight-scheduler`                   |
| `insightExecutor.image`                      | Container image                                 | `docker.jfrog.io/jfrog/insight-executor`   |
| `insightExecutor.version`                    | Container image tag                             | `.Chart.AppVersion`                   |
| `insightExecutor.service.type`               | Insight Executor service type                   | `ClusterIP`                           |
| `insightExecutor.externalPort`               | Insight Executor service external port          | `8080`                                |
| `insightExecutor.internalPort`               | Insight Executor service internal port          | `8080`                                |
| `insightExecutor.javaOpts.other`             | Insight Executor JFMC_EXTRA_JAVA_OPTS           | ``                                    |
| `insightExecutor.javaOpts.xms`               | Insight Executor JFMC_EXTRA_JAVA_OPTS -Xms      | ``                                    |
| `insightExecutor.javaOpts.xmx`               | Insight Executor JFMC_EXTRA_JAVA_OPTS -Xmx      | ``                                    |
| `insightExecutor.loggers`                    | Insight Executor loggers (see values.yaml for possible values)         | ` `            |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.


## Useful links
- https://www.jfrog.com
- https://www.jfrog.com/confluence/
- https://www.jfrog.com/confluence/display/EP/Getting+Started
