# JFrog Artifactory OSS Helm Chart

JFrog Artifactory OSS is a free Artifactory edition to host Generic repositories.

## Prerequisites Details

* Kubernetes 1.12+

## Chart Details
This chart will do the following:

* Deploy JFrog Artifactory OSS
* Deploy an optional Nginx server
* Deploy an optional PostgreSQL Database
* Optionally expose Artifactory with Ingress [Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## Installing the Chart

### Add ChartCenter Helm repository

Before installing JFrog helm charts, you need to add the [ChartCenter helm repository](https://chartcenter.io) to your helm client.

```bash
helm repo add center https://repo.chartcenter.io
helm repo update
```

### Install Chart
To install the chart with the release name `artifactory-oss`:
```bash
helm upgrade --install artifactory-oss --set postgresql.postgresqlPassword=<postgres_password> --namespace artifactory-oss center/jfrog/artifactory-oss
```

### Accessing Artifactory OSS
**NOTE:** If using artifactory or nginx service type `LoadBalancer`, it might take a few minutes for Artifactory OSS's public IP to become available.

### Updating Artifactory OSS
Once you have a new chart version, you can upgrade your deployment with
```bash
helm upgrade artifactory-oss center/jfrog/artifactory-oss
```

### Deleting Artifactory OSS

On helm v2:
```bash
helm delete --purge artifactory-oss
```

On helm v3:
```bash                                                                                                                                                                 
helm delete artifactory-oss --namespace artifactory-oss                                                                                                                                     
``` 
This will delete your Artifactory OSS deployment.<br>
**NOTE:** You might have left behind persistent volumes. You should explicitly delete them with
```bash
kubectl delete pvc ...
kubectl delete pv ...
```

## Database
The Artifactory OSS chart comes with PostgreSQL deployed by default.<br>
For details on the PostgreSQL configuration or customising the database, Look at the options described in the [Artifactory helm chart](https://github.com/jfrog/charts/tree/master/stable/artifactory). 

## Configuration
The following table lists the **basic** configurable parameters of the Artifactory OSS chart and their default values.

**NOTE:** All supported parameters are documented in the main [artifactory helm chart](https://github.com/jfrog/charts/tree/master/stable/artifactory).

|         Parameter                              |           Description             |                         Default                   |
|------------------------------------------------|-----------------------------------|---------------------------------------------------|
| `artifactory.artifactory.image.repository`     | Container image                   | `docker.bintray.io/jfrog/artifactory-oss`         |
| `artifactory.artifactory.image.version`        | Container tag                     | `.Chart.AppVersion`                               |
| `artifactory.artifactory.resources`            | Artifactory container resources   | `{}`                                              |
| `artifactory.artifactory.javaOpts`             | Artifactory Java options          | `{}`                                              |
| `artifactory.nginx.enabled`                    | Deploy nginx server               | `true`                                            |
| `artifactory.nginx.service.type`               | Nginx service type                | `LoadBalancer`                                    |
| `artifactory.nginx.tlsSecretName`              | TLS secret for Nginx pod          | ``                                                |
| `artifactory.ingress.enabled`                  | Enable Ingress (should come with `artifactory.nginx.enabled=false`) | `false`         |
| `artifactory.ingress.tls`                      | Ingress TLS configuration (YAML)  | `[]`                                              |
| `artifactory.postgresql.enabled`               | Use the Artifactory PostgreSQL sub chart       | `true`                               |
| `artifactory.database`                         | Custom database configuration (if not using bundled PostgreSQL sub-chart) |           |
| `postgresql.enabled`                           | Enable the Artifactory PostgreSQL sub chart    | `true`                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

### Ingress and TLS
To get Helm to create an ingress object with a hostname, add these two lines to your Helm command:
```bash
helm upgrade --install artifactory-oss \
  --set artifactory.nginx.enabled=false \
  --set artifactory.ingress.enabled=true \
  --set artifactory.ingress.hosts[0]="artifactory.company.com" \
  --set artifactory.artifactory.service.type=NodePort \
  --namespace artifactory-oss center/jfrog/artifactory-oss
```

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

```bash
kubectl create secret tls artifactory-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the Artifactory Ingress TLS section of your custom `values.yaml` file:

```yaml
artifactory:
  artifactory:
    ingress:
      ## If true, Artifactory Ingress will be created
      ##
      enabled: true

      ## Artifactory Ingress hostnames
      ## Must be provided if Ingress is enabled
      ##
      hosts:
        - artifactory-oss.domain.com
      annotations:
        kubernetes.io/tls-acme: "true"
      ## Artifactory Ingress TLS configuration
      ## Secrets must be manually created in the namespace
      ##
      tls:
        - secretName: artifactory-tls
          hosts:
            - artifactory-oss.domain.com
```

## Useful links
https://www.jfrog.com
https://www.jfrog.com/confluence/
