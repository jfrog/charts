# JFrog Artifactory Helm Chart

## Prerequisites Details

* Kubernetes 1.6+
* Artifactory Pro trial license [get one from here](https://www.jfrog.com/artifactory/free-trial/)

## Chart Details
This chart will do the following:

* Deploy Artifactory-Pro/Artifactory-Edge (or OSS if set custom image)
* Deploy a PostgreSQL database using the jfrog/postgresql chart
* Deploy an optional Nginx server
* Optionally expose Artifactory with Ingress [Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## Installing the Chart

### Add JFrog Helm repository
Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io/) to your helm client
```bash
helm repo add jfrog https://charts.jfrog.io
```

### Install Chart
To install the chart with the release name `artifactory`:
```bash
helm install --name artifactory jfrog/artifactory
```

### Deploying Artifactory OSS
By default it will run Artifactory-Pro to run Artifactory-Oss use following command:
```bash
helm install --name artifactory --set artifactory.image.repository=docker.bintray.io/jfrog/artifactory-oss jfrog/artifactory
```

### Deploying Artifactory with replicator enabled
```bash
## Artifactory replicator is disabled by default. To enable it use the following:
helm install --name artifactory --set artifactory.replicator.enabled=true jfrog/artifactory
```

### Accessing Artifactory
**NOTE:** It might take a few minutes for Artifactory's public IP to become available.
Follow the instructions outputted by the install command to get the Artifactory IP to access it.

### Updating Artifactory
Once you have a new chart version, you can update your deployment with
```bash
helm upgrade artifactory --namespace artifactory jfrog/artifactory
```

This will apply any configuration changes on your existing deployment.

### Artifactory memory and CPU resources
The Artifactory Helm chart comes with support for configured resource requests and limits to Artifactory, Nginx and PostgreSQL. By default, these settings are commented out.
It is **highly** recommended to set these so you have full control of the allocated resources and limits.
Artifactory java memory parameters can (and should) also be set to match the allocated resources with `artifactory.javaOpts.xms` and `artifactory.javaOpts.xmx`.
```bash
# Example of setting resource requests and limits to all pods (including passing java memory settings to Artifactory)
helm install --name artifactory \
               --set artifactory.resources.requests.cpu="500m" \
               --set artifactory.resources.limits.cpu="2" \
               --set artifactory.resources.requests.memory="1Gi" \
               --set artifactory.resources.limits.memory="4Gi" \
               --set artifactory.javaOpts.xms="1g" \
               --set artifactory.javaOpts.xmx="4g" \
               --set nginx.resources.requests.cpu="100m" \
               --set nginx.resources.limits.cpu="250m" \
               --set nginx.resources.requests.memory="250Mi" \
               --set nginx.resources.limits.memory="500Mi" \
               jfrog/artifactory
```
Get more details on configuring Artifactory in the [official documentation](https://www.jfrog.com/confluence/).


### Customizing Database password
You can override the specified database password (set in [values.yaml](values.yaml)), by passing it as a parameter in the install command line
```bash
helm install --name artifactory --namespace artifactory --set postgresql.postgresPassword=12_hX34qwerQ2 jfrog/artifactory
```

You can customise other parameters in the same way, by passing them on `helm install` command line.

### Deleting Artifactory
```bash
helm delete --purge artifactory
```
This will completely delete your Artifactory Pro deployment.  
**IMPORTANT:** This will also delete your data volumes. You will lose all data!

### Create Distribution Cert for Artifactory Edge
```bash
# Create private.key and root.crt
openssl req -newkey rsa:2048 -nodes -keyout private.key -x509 -days 365 -out root.crt
```

Once Created, Use it to create ConfigMap
```bash
# Create ConfigMap distribution-certs
kubectl create configmap distribution-certs --from-file=private.key=private.key --from-file=root.crt=root.crt
```
Pass it to `helm`
```bash
helm install --name artifactory --set artifactory.distributionCerts=distribution-certs jfrog/artifactory
```

### Kubernetes Secret for Artifactory License
You can deploy the Artifactory license as a [Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/).
Prepare a text file with the license written in it.
```bash
# Create the Kubernetes secret (assuming the local license file is 'art.lic')
kubectl create secret generic artifactory-license --from-file=./art.lic

# Pass the license to helm
helm install --name artifactory --set artifactory.license.secret=artifactory-license,artifactory.license.dataKey=art.lic jfrog/artifactory
```
**NOTE:** You have to keep passing the license secret parameters as `--set artifactory.license.secret=artifactory-license,artifactory.license.dataKey=art.lic` on all future calls to `helm install` and `helm upgrade`!

### Bootstrapping Artifactory
**IMPORTANT:** Bootstrapping Artifactory needs license. Pass license as shown in above section.

* User guide to [bootstrap Artifactory Global Configuration](https://www.jfrog.com/confluence/display/RTF/Configuration+Files#ConfigurationFiles-BootstrappingtheGlobalConfiguration)
* User guide to [bootstrap Artifactory Security Configuration](https://www.jfrog.com/confluence/display/RTF/Configuration+Files#ConfigurationFiles-BootstrappingtheSecurityConfiguration)

1. Create `bootstrap-config.yaml` with artifactory.config.import.xml and security.import.xml as shown below:
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-release-bootstrap-config
data:
  artifactory.config.import.xml: |
    <config contents>
  security.import.xml: |
    <config contents>
```

2. Create configMap in Kubernetes:
```bash
kubectl apply -f bootstrap-config.yaml
```
3. Pass the configMap to helm
```bash
helm install --name artifactory --set artifactory.license.secret=artifactory-license,artifactory.license.dataKey=art.lic,artifactory.configMapName=my-release-bootstrap-config jfrog/artifactory
```

### Use custom nginx.conf with Nginx

Steps to create configMap with nginx.conf
* Create `nginx.conf` file.
```bash
kubectl create configmap nginx-config --from-file=nginx.conf
```
* Pass configMap to helm install
```bash
helm install --name artifactory --set nginx.customConfigMap=nginx-config jfrog/artifactory
```

### Use an external Database
There are cases where you will want to use a different database and not the enclosed **PostgreSQL**.
See more details on [configuring the database](https://www.jfrog.com/confluence/display/RTF/Configuring+the+Database)
> The official Artifactory Docker images include the PostgreSQL database driver.
> For other database types, you will have to add the relevant database driver to Artifactory's tomcat/lib 

This can be done with the following parameters
```bash
# Make sure your Artifactory Docker image has the MySQL database driver in it
...
--set postgresql.enabled=false \
--set artifactory.postStartCommand="curl -L -o /opt/jfrog/artifactory/tomcat/lib/mysql-connector-java-5.1.41.jar https://jcenter.bintray.com/mysql/mysql-connector-java/5.1.41/mysql-connector-java-5.1.41.jar && chown 1030:1030 /opt/jfrog/artifactory/tomcat/lib/mysql-connector-java-5.1.41.jar" \
--set database.type=mysql \
--set database.host=${DB_HOST} \
--set database.port=${DB_PORT} \
--set database.user=${DB_USER} \
--set database.password=${DB_PASSWORD} \
...
```
**NOTE:** You must set `postgresql.enabled=false` in order for the chart to use the `database.*` parameters. Without it, they will be ignored!

If you store your database credentials in a pre-existing Kubernetes `Secret`, you can specify them via `database.secrets` instead of `database.user` and `database.password`:
```bash
# Create a secret containing the database credentials
kubectl create secret generic my-secret --from-literal=user=${DB_USER} --from-literal=password=${DB_PASSWORD}
...
--set postgresql.enabled=false \
--set database.secrets.user.name=my-secret \
--set database.secrets.user.key=user \
--set database.secrets.password.name=my-secret \
--set database.secrets.password.key=password \
...
```

### Deleting Artifactory
To delete the Artifactory.
```bash
helm delete --purge artifactory
```
This will completely delete your Artifactory HA cluster.  

### Custom Docker registry for your images
If you need to pull your Docker images from a private registry, you need to create a
[Kubernetes Docker registry secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) and pass it to helm
```bash
# Create a Docker registry secret called 'regsecret'
kubectl create secret docker-registry regsecret --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```
Once created, you pass it to `helm`
```bash
helm install --name artifactory --set imagePullSecrets=regsecret jfrog/artifactory
```

## Configuration

The following table lists the configurable parameters of the artifactory chart and their default values.

|         Parameter         |           Description             |                         Default                          |
|---------------------------|-----------------------------------|----------------------------------------------------------|
| `imagePullSecrets`        | Docker registry pull secret       |                                                          |
| `serviceAccount.create`   | Specifies whether a ServiceAccount should be created | `true`                                |
| `serviceAccount.name`     | The name of the ServiceAccount to create             | Generated using the fullname template |
| `rbac.create`             | Specifies whether RBAC resources should be created   | `true`                                |
| `rbac.role.rules`         | Rules to create                   | `[]`                                                     |
| `artifactory.name`        | Artifactory name                  | `artifactory`                                            |
| `artifactory.replicaCount`            | Replica count for Artifactory deployment| `1`                                    |
| `artifactory.image.pullPolicy`         | Container pull policy             | `IfNotPresent`                              |
| `artifactory.image.repository`    | Container image                   | `docker.bintray.io/jfrog/artifactory-pro`        |
| `artifactory.image.version`       | Container tag                     |  `.Chart.AppVersion`                             |
| `artifactory.service.name`| Artifactory service name to be set in Nginx configuration | `artifactory`                    |
| `artifactory.service.type`| Artifactory service type | `ClusterIP`                                                       |
| `artifactory.externalPort` | Artifactory service external port | `8081`                                                  |
| `artifactory.internalPort` | Artifactory service internal port | `8081`                                                  |
| `artifactory.internalPortReplicator` | Replicator service internal port | `6061`                                         |
| `artifactory.externalPortReplicator` | Replicator service external port | `6061`                                         |
| `artifactory.livenessProbe.enabled`              | Enable liveness probe                     | `true`                    |
| `artifactory.livenessProbe.initialDelaySeconds`  | Delay before liveness probe is initiated  | 180                       |
| `artifactory.livenessProbe.periodSeconds`        | How often to perform the probe            | 10                        |
| `artifactory.livenessProbe.timeoutSeconds`       | When the probe times out                  | 10                        |
| `artifactory.livenessProbe.successThreshold`     | Minimum consecutive successes for the probe to be considered successful after having failed. | 1 |
| `artifactory.livenessProbe.failureThreshold`     | Minimum consecutive failures for the probe to be considered failed after having succeeded.   | 10 |
| `artifactory.masterKey`                          | master.key to be used on bootstrap | `FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF` |
| `artifactory.masterKeySecretName`                | Artifactory Master Key secret name |                                                                    |
| `artifactory.readinessProbe.enabled`             | would you like a readinessProbe to be enabled           |  `true`     |
| `artifactory.readinessProbe.initialDelaySeconds` | Delay before readiness probe is initiated | 60                        |
| `artifactory.readinessProbe.periodSeconds`       | How often to perform the probe            | 10                        |
| `artifactory.readinessProbe.timeoutSeconds`      | When the probe times out                  | 10                        |
| `artifactory.readinessProbe.successThreshold`    | Minimum consecutive successes for the probe to be considered successful after having failed. | 1 |
| `artifactory.readinessProbe.failureThreshold`    | Minimum consecutive failures for the probe to be considered failed after having succeeded.   | 10 |
| `artifactory.persistence.mountPath` | Artifactory persistence volume mount path | `"/var/opt/jfrog/artifactory"`         |
| `artifactory.persistence.enabled` | Artifactory persistence volume enabled | `true`                                      |
| `artifactory.persistence.accessMode` | Artifactory persistence volume access mode | `ReadWriteOnce`                      |
| `artifactory.persistence.size` | Artifactory persistence or local volume size | `20Gi`                                   |
| `artifactory.resources.requests.memory` | Artifactory initial memory request                  |                          |
| `artifactory.resources.requests.cpu`    | Artifactory initial cpu request     |                                          |
| `artifactory.resources.limits.memory`   | Artifactory memory limit            |                                          |
| `artifactory.resources.limits.cpu`      | Artifactory cpu limit               |                                          |
| `artifactory.javaOpts.xms`              | Artifactory java Xms size           |                                          |
| `artifactory.javaOpts.xmx`              | Artifactory java Xms size           |                                          |
| `artifactory.javaOpts.other`            | Artifactory additional java options |                                          |
| `artifactory.replicator.enabled`            | Enable Artifactory Replicator | `false`                                    |
| `artifactory.distributionCerts`            | Name of ConfigMap for Artifactory Distribution Certificate  | ``            |
| `artifactory.replicator.publicUrl`            | Artifactory Replicator Public URL |                                      |
| `ingress.enabled`           | If true, Artifactory Ingress will be created | `false`                                     |
| `ingress.annotations`       | Artifactory Ingress annotations     | `{}`                                                 |
| `ingress.hosts`             | Artifactory Ingress hostnames       | `[]`                                                 |
| `ingress.tls`               | Artifactory Ingress TLS configuration (YAML) | `[]`                                        |
| `ingress.defaultBackend.enabled` | If true, the default `backend` will be added using serviceName and servicePort | `true` |
| `ingress.annotations`       | Ingress annotations, which are written out if annotations section exists in values. Everything inside of the annotations section will appear verbatim inside the resulting manifest. See `Ingress annotations` section below for examples of how to leverage the annotations, specifically for how to enable docker authentication. |  |
| `nginx.name` | Nginx name | `nginx`                                                                                      |
| `nginx.enabled` | Deploy nginx server | `true`                                                                           |
| `nginx.replicaCount` | Nginx replica count | `1`                                                                         |
| `nginx.uid`                 | Nginx User Id                     | `104`                                                  |
| `nginx.git`                 | Nginx Group Id                    | `107`                                                  |
| `nginx.image.repository`    | Container image                   | `docker.bintray.io/jfrog/nginx-artifactory-pro`        |
| `nginx.image.version`       | Container tag                     | `.Chart.AppVersion`                                    |
| `nginx.image.pullPolicy`    | Container pull policy                   | `IfNotPresent`                                   |
| `nginx.service.type`| Nginx service type | `LoadBalancer`                                                                |
| `nginx.service.loadBalancerSourceRanges`| Nginx service array of IP CIDR ranges to whitelist (only when service type is LoadBalancer) |  |
| `nginx.service.externalTrafficPolicy`| Nginx service desires to route external traffic to node-local or cluster-wide endpoints. | `Cluster` |
| `nginx.loadBalancerIP`| Provide Static IP to configure with Nginx |                                                      |
| `nginx.externalPortHttp` | Nginx service external port | `80`                                                            |
| `nginx.internalPortHttp` | Nginx service internal port | `80`                                                            |
| `nginx.externalPortHttps` | Nginx service external port | `443`                                                          |
| `nginx.internalPortHttps` | Nginx service internal port | `443`                                                          |
| `nginx.internalPortReplicator` | Replicator service internal port | `6061`                                               |
| `nginx.externalPortReplicator` | Replicator service external port | `6061`                                               |
| `nginx.livenessProbe.enabled`              | Enable liveness probe                     | `true`                          |
| `nginx.livenessProbe.initialDelaySeconds`  | Delay before liveness probe is initiated  | 60                              |
| `nginx.livenessProbe.periodSeconds`        | How often to perform the probe            | 10                              |
| `nginx.livenessProbe.timeoutSeconds`       | When the probe times out                  | 10                              |
| `nginx.livenessProbe.successThreshold`     | Minimum consecutive successes for the probe to be considered successful after having failed. | 10 |
| `nginx.livenessProbe.failureThreshold`     | Minimum consecutive failures for the probe to be considered failed after having succeeded.   | 1|
| `nginx.readinessProbe.enabled`              | would you like a readinessProbe to be enabled           |  `true`          |
| `nginx.readinessProbe.initialDelaySeconds` | Delay before readiness probe is initiated | 60                              |
| `nginx.readinessProbe.periodSeconds`       | How often to perform the probe            | 10                              |
| `nginx.readinessProbe.timeoutSeconds`      | When the probe times out                  | 10                              |
| `nginx.readinessProbe.successThreshold`    | Minimum consecutive successes for the probe to be considered successful after having failed. | 10 |
| `nginx.readinessProbe.failureThreshold`    | Minimum consecutive failures for the probe to be considered failed after having succeeded.   | 1 |
| `nginx.tlsSecretName` |  SSL secret that will be used by the Nginx pod |                                                 |
| `nginx.env.artUrl` | Nginx Environment variable Artifactory URL | `"http://artifactory:8081/artifactory"`                |
| `nginx.env.ssl` | Nginx Environment enable ssl | `true`                                                                  |
| `nginx.env.skipAutoConfigUpdate`  | Nginx Environment to disable auto configuration update | `false`                     |
| `nginx.customConfigMap`           | Nginx CustomeConfigMap name for `nginx.conf` | ` `                               |
| `nginx.persistence.mountPath` | Nginx persistence volume mount path | `"/var/opt/jfrog/nginx"`                           |
| `nginx.persistence.enabled` | Nginx persistence volume enabled | `true`                                                  |
| `nginx.persistence.accessMode` | Nginx persistence volume access mode | `ReadWriteOnce`                                  |
| `nginx.persistence.size` | Nginx persistence volume size | `5Gi`                                                         |
| `nginx.resources.requests.memory` | Nginx initial memory request  |                                                      |
| `nginx.resources.requests.cpu`    | Nginx initial cpu request     |                                                      |
| `nginx.resources.limits.memory`   | Nginx memory limit            |                                                      |
| `nginx.resources.limits.cpu`      | Nginx cpu limit               |                                                      |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

### Ingress and TLS
To get Helm to create an ingress object with a hostname, add these two lines to your Helm command:
```
helm install --name artifactory \
  --set ingress.enabled=true \
  --set ingress.hosts[0]="artifactory.company.com" \
  --set artifactory.service.type=NodePort \
  --set nginx.enabled=false \
  jfrog/artifactory
```

If your cluster allows automatic creation/retrieval of TLS certificates (e.g. [cert-manager](https://github.com/jetstack/cert-manager)), please refer to the documentation for that mechanism.

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

```console
kubectl create secret tls artifactory-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the Artifactory Ingress TLS section of your custom `values.yaml` file:

```
  ingress:
    ## If true, Artifactory Ingress will be created
    ##
    enabled: true

    ## Artifactory Ingress hostnames
    ## Must be provided if Ingress is enabled
    ##
    hosts:
      - artifactory.domain.com
    annotations:
      kubernetes.io/tls-acme: "true"
    ## Artifactory Ingress TLS configuration
    ## Secrets must be manually created in the namespace
    ##
    tls:
      - secretName: artifactory-tls
        hosts:
          - artifactory.domain.com
```

### Ingress annotations

This example specifically enables Artifactory to work as a Docker Registry using the Repository Path method. See [Artifactory as Docker Registry](https://www.jfrog.com/confluence/display/RTF/Getting+Started+with+Artifactory+as+a+Docker+Registry) documentation for more information about this setup.

```
ingress:
  enabled: true
  defaultBackend:
    enabled: false
  hosts:
    - myhost.example.com
  annotations:
    ingress.kubernetes.io/force-ssl-redirect: "true"
    ingress.kubernetes.io/proxy-body-size: "0"
    ingress.kubernetes.io/proxy-read-timeout: "600"
    ingress.kubernetes.io/proxy-send-timeout: "600"
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/configuration-snippet: |
      rewrite ^/(v2)/token /artifactory/api/docker/null/v2/token;
      rewrite ^/(v2)/([^\/]*)/(.*) /artifactory/api/docker/$2/$1/$3;
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  tls:
    - hosts:
      - "myhost.example.com"
```

## Useful links
https://www.jfrog.com
https://www.jfrog.com/confluence/
