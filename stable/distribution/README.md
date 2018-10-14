# JFrog Distribution Helm Chart

## Prerequisites Details

* Kubernetes 1.8+

## Chart Details
This chart does the following:

* Deploy Mongodb database.
* Deploy Redis.
* Deploy distributor.
* Deploy distribution.

## Requirements
- A running Kubernetes cluster
- Dynamic storage provisioning enabled
- Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory Enterprise Plus
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) installed and setup to use the cluster (helm init)

## Installing the Chart

### Add JFrog Helm repository
Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io/) to your helm client
```bash
helm repo add jfrog https://charts.jfrog.io
```

### Install Chart
To install the chart with the release name `distribution`:
```bash
helm install --name distribution jfrog/distribution
```

### Accessing Distribution
**NOTE:** It might take a few minutes for Distribution's public IP to become available, and the nodes to complete initial setup.
Follow the instructions outputted by the install command to get the Distribution IP and URL to access it.

### Updating Distribution
Once you have a new chart version, you can update your deployment with
```bash
helm upgrade distribution jfrog/distribution
```

### Create a unique Master Key
JFrog Distribution requires a unique master key to be used by all micro-services in the same cluster. By default the chart has one set in values.yaml (`distribution.masterKey`).

**This key is for demo purpose and should not be used in a production environment!**

You should generate a unique one and pass it to the template at install/upgrade time.
```bash
# Create a key
export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}

# Pass the created master key to helm
helm install --set distribution.masterKey=${MASTER_KEY} -n distribution jfrog/distribution
```
**NOTE:** Make sure to pass the same master key with `--set distribution.masterKey=${MASTER_KEY}` on all future calls to `helm install` and `helm upgrade`!

### High Availability
JFrog Distribution can run in High Availability by having multiple replicas of the Distribution service.

To enable this, pass replica count to the `helm install` and `helm upgrade` commands.
```bash
# Run 3 replicas of the Distribution service
helm install --name distribution --set replicaCount=3 jfrog/distribution
```

### External Database
There is an option to use an external MongoDB database for your Distribution.

To use an external **MongoDB**, You need to set the Distribution **MongoDB** connection URL.

For this, pass the parameter: `mongodb.enabled=false,global.mongoUrl=${DISTRIBUTION_MONGODB_CONN_URL},global.mongoAuditUrl=${DISTRIBUTION_MONGODB_AUDIT_URL}`.

**IMPORTANT:** Make sure the DB is already created before deploying Distribution services
```bash
# Passing a custom MongoDB to Distribution

# Example
# MongoDB host: custom-mongodb.local
# MongoDB port: 27017
# MongoDB user: distribution
# MongoDB password: password1_X

export DISTRIBUTION_MONGODB_CONN_URL='mongodb://${MONGODB_USER}:${MONGODB_PASSWORD}@custom-mongodb.local:27017/${MONGODB_DATABSE}'
export DISTRIBUTION_MONGODB_AUDIT_URL='mongodb://${MONGODB_USER}:${MONGODB_PASSWORD}@custom-mongodb.local:27017/audit?maxpoolsize=500'
helm install -n distribution --set global.mongoUrl=${DISTRIBUTION_MONGODB_CONN_URL},global.mongoAuditUrl=${DISTRIBUTION_MONGODB_AUDIT_URL} jfrog/distribution
```

## Upgrade
Upgrading Distribution is a simple helm command
```bash
helm upgrade distribution jfrog/distribution
```

### Non compatible upgrades
In cases where a new version is not compatible with existing deployed version (look in CHANGELOG.md) you should
* Deploy new version along side old version (set a new release name)
* Copy configurations and data from old deployment to new one (/var/opt/jfrog)
* Update DNS to point to new Distribution service
* Remove old release


## Configuration

The following table lists the configurable parameters of the distribution chart and their default values.

|         Parameter                            |           Description                      |               Default              |
|----------------------------------------------|--------------------------------------------|------------------------------------|
| `imagePullSecrets`                           | Docker registry pull secret                |                                    |
| `replicaCount`                               | HA - Number of instances per service       |                                    |
| `serviceAccount.create`   | Specifies whether a ServiceAccount should be created          | `true`                             |
| `serviceAccount.name`     | The name of the ServiceAccount to create                      | Generated using fullname template  |
| `rbac.create`             | Specifies whether RBAC resources should be created            | `true`                             |
| `rbac.role.rules`         | Rules to create                   | `[]`                                                           |
| `ingress.enabled`                            | If true, distribution Ingress will be created | `false`                         |
| `ingress.annotations`                        | distribution Ingress annotations              | `{}`                            |
| `ingress.hosts`                              | distribution Ingress hostnames                | `[]`                            |
| `ingress.tls`                                | distribution Ingress TLS configuration (YAML) | `[]`                            |
| `mongodb.enabled`                            | Enable Mongodb                             | `true`                             |
| `mongodb.image.tag`                          | Mongodb docker image tag                   | `3.6.8-debian-9`                   |
| `mongodb.image.pullPolicy`                   | Mongodb Container pull policy              | `IfNotPresent`                     |
| `mongodb.persistence.enabled`                | Mongodb persistence volume enabled         | `true`                             |
| `mongodb.persistence.existingClaim`          | Mongodb use an existing PVC to persist data        | `nil`                      |
| `mongodb.persistence.storageClass`           | Mongodb storage class of backing PVC               | `generic`                  |
| `mongodb.persistence.size`                   | Mongodb persistence volume size            | `10Gi`                             |
| `mongodb.livenessProbe.initialDelaySeconds`  | Mongodb delay before liveness probe is initiated    | `40`                      |
| `mongodb.readinessProbe.initialDelaySeconds` | Mongodb delay before readiness probe is initiated   | `30`                      |
| `mongodb.mongodbExtraFlags`                  | MongoDB additional command line flags      | `["--wiredTigerCacheSizeGB=1"]`    |
| `mongodb.usePassword`                        | Enable password authentication             | `false`                            |
| `mongodb.mongodbDatabase`                    | Mongodb Database for distribution          | `distribution`                     |
| `mongodb.mongodbRootPassword`                | Mongodb Database Password for root user    | ` `                                |
| `mongodb.mongodbUsername`                    | Mongodb Database User                      | `distribution`                     |
| `mongodb.mongodbPassword`                    | Mongodb Database Password for Mission Control user  | ` `                       |
| `mongodb.nodeSelector`                       | Mongodb node selector                      | `{}`                               |
| `mongodb.affinity`                           | Mongodb node affinity                      | `{}`                               |
| `mongodb.tolerations`                        | Mongodb node tolerations                   | `[]`                               |
| `redis.password`                             | Redis password                             | ` `                                |
| `redis.port`                                 | Redis Port                                 | `6379`                             |
| `redis.persistence.enabled`                  | Redis use a PVC to persist data            | `true`                             |
| `redis.persistence.existingClaim`            | Redis use an existing PVC to persist data  | `nil`                              |
| `redis.persistence.storageClass`             | Redis storage class of backing PVC         | `generic`                          |
| `redis.persistence.size`                     | Redis size of data volume                  | `10Gi`                             |
| `redis.nodeSelector`                         | Redis node selector                        | `{}`                               |
| `redis.affinity`                             | Redis node affinity                        | `{}`                               |
| `redis.tolerations`                          | Redis node tolerations                     | `[]`                               |
| `distribution.name`                          | Distribution name                          | `distribution`                     |
| `distribution.image.pullPolicy`              | Container pull policy                      | `IfNotPresent`                     |
| `distribution.image.repository`              | Container image                            | `docker.jfrog.io/jf-distribution`  |
| `distribution.image.version`                 | Container image tag                        | `.Chart.AppVersion`                |
| `distribution.service.type`                  | Distribution service type                  | `LoadBalancer`                     |
| `distribution.externalPort`                  | Distribution service external port         | `80`                               |
| `distribution.internalPort`                  | Distribution service internal port         | `8080`                             |
| `distribution.env.artifactoryUrl`            | Distribution Environment Artifactory URL   | ` `                                |
| `distribution.persistence.mountPath`         | Distribution persistence volume mount path | `"/jf-distribution"`               |
| `distribution.persistence.enabled`           | Distribution persistence volume enabled    | `true`                             |
| `distribution.persistence.storageClass`      | Storage class of backing PVC               | `nil`                              |
| `distribution.persistence.existingClaim`     | Provide an existing PersistentVolumeClaim  | `nil`                              |
| `distribution.persistence.accessMode`        | Distribution persistence volume access mode| `ReadWriteOnce`                    |
| `distribution.persistence.size`              | Distribution persistence volume size       | `50Gi`                             |
| `distribution.nodeSelector`                  | Distribution node selector                 | `{}`                               |
| `distribution.affinity`                      | Distribution node affinity                 | `{}`                               |
| `distribution.tolerations`                   | Distribution node tolerations              | `[]`                               |
| `distributor.name`                           | Distribution name                          | `distribution`                     |
| `distributor.image.pullPolicy`               | Container pull policy                      | `IfNotPresent`                     |
| `distributor.image.repository`               | Container image                            | `docker.jfrog.io/jf-distribution`  |
| `distributor.image.version`                  | Container image tag                        | `.Chart.AppVersion`                |
| `distributor.token`                          | Distributor token                          | ` `                                |
| `distributor.persistence.mountPath`          | Distributor persistence volume mount path  | `"/bt-distributor"`                |
| `distributor.persistence.existingClaim`      | Provide an existing PersistentVolumeClaim  | `nil`                              |
| `distributor.persistence.storageClass`       | Storage class of backing PVC | `nil (uses alpha storage class annotation)`      |
| `distributor.persistence.enabled`            | Distributor persistence volume enabled     | `true`                             |
| `distributor.persistence.accessMode`         | Distributor persistence volume access mode | `ReadWriteOnce`                    |
| `distributor.persistence.size`               | Distributor persistence volume size        | `50Gi`                             |
| `distributor.nodeSelector`                   | Distributor node selector                  | `{}`                               |
| `distributor.affinity`                       | Distributor node affinity                  | `{}`                               |
| `distributor.tolerations`                    | Distributor node tolerations               | `[]`                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

### Ingress and TLS
To get Helm to create an ingress object with a hostname, add these two lines to your Helm command:
```bash
helm install --name distribution \
  --set ingress.enabled=true \
  --set ingress.hosts[0]="distribution.company.com" \
  --set distribution.service.type=NodePort \
  jfrog/distribution
```

If your cluster allows automatic creation/retrieval of TLS certificates (e.g. [cert-manager](https://github.com/jetstack/cert-manager)), please refer to the documentation for that mechanism.

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

```bash
kubectl create secret tls distribution-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the Distribution Ingress TLS section of your custom `values.yaml` file:

```
  ingress:
    ## If true, Distribution Ingress will be created
    ##
    enabled: true

    ## Distribution Ingress hostnames
    ## Must be provided if Ingress is enabled
    ##
    hosts:
      - distribution.domain.com
    annotations:
      kubernetes.io/tls-acme: "true"
    ## Distribution Ingress TLS configuration
    ## Secrets must be manually created in the namespace
    ##
    tls:
      - secretName: distribution-tls
        hosts:
          - distribution.domain.com
```

## Useful links
- https://www.jfrog.com/confluence/display/EP/Getting+Started
- https://www.jfrog.com/confluence/display/DIST/Installing+Distribution
- https://www.jfrog.com/confluence/
