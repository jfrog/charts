# JFrog Artifactory CE for C++ Helm Chart

JFrog Artifactory CE for C++ is a free Artifactory edition to host C/C++ packages in Conan repositories.

**Heads up: Our Helm Chart docs are moving to our main documentation site. For Artifactory installers, see [Installing Artifactory](https://www.jfrog.com/confluence/display/JFROG/Installing+Artifactory).**

## Prerequisites Details

* Kubernetes 1.19+

## Chart Details
This chart will do the following:

* Deploy JFrog Artifactory CE for C++
* Deploy an optional Nginx server
* Deploy an optional PostgreSQL Database
* Optionally expose Artifactory with Ingress [Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## Installing the Chart

### Add JFrog Helm repository

Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io) to your helm client.

```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Install Chart
To install the chart with the release name `artifactory-cpp-ce`:
```bash
helm upgrade --install artifactory-cpp-ce --set artifactory.postgresql.postgresqlPassword=<postgres_password> --namespace artifactory-cpp-ce jfrog/artifactory-cpp-ce
```

### Accessing Artifactory CE for C++
**NOTE:** If using artifactory or nginx service type `LoadBalancer`, it might take a few minutes for Artifactory CE for C++'s public IP to become available.

### Updating Artifactory CE for C++
Once you have a new chart version, you can upgrade your deployment with
```bash
helm upgrade artifactory-cpp-ce --namespace artifactory-cpp-ce jfrog/artifactory-cpp-ce
```

### Special Upgrade Notes
#### Artifactory upgrade from 6.x to 7.x (App Version)
Arifactory 6.x to 7.x upgrade requires a one time migration process. This is done automatically on pod startup if needed.
It's possible to configure the migration timeout with the following configuration in extreme cases. The provided default should be more than enough for completion of the migration.
```yaml
artifactory:
  artifactory:
    # Migration support from 6.x to 7.x
    migration:
      enabled: true
      timeoutSeconds: 3600
```
* Note: If you are upgrading from 1.x to 3.x and above chart versions, please delete the existing statefulset of postgresql before upgrading the chart due to breaking changes in postgresql subchart.
```bash
kubectl delete statefulsets <OLD_RELEASE_NAME>-postgresql
```
* For more details about artifactory chart upgrades refer [here](https://github.com/jfrog/charts/blob/master/stable/artifactory/UPGRADE_NOTES.md)

### Deleting Artifactory CE for C++

```bash                                                                                                                                                                 
helm delete artifactory-cpp-ce --namespace artifactory-cpp-ce                                                                                                                                 
``` 

This will delete your Artifactory CE for C++ deployment.<br>
**NOTE:** You might have left behind persistent volumes. You should explicitly delete them with
```bash
kubectl delete pvc ...
kubectl delete pv ...
```

## Database
The Artifactory CE for C++ chart comes with PostgreSQL deployed by default.<br>
For details on the PostgreSQL configuration or customising the database, Look at the options described in the [Artifactory helm chart](https://github.com/jfrog/charts/tree/master/stable/artifactory).

### Ingress and TLS
To get Helm to create an ingress object with a hostname, add these two lines to your Helm command:
```bash
helm upgrade --install artifactory-cpp-ce \
  --set artifactory.nginx.enabled=false \
  --set artifactory.ingress.enabled=true \
  --set artifactory.ingress.hosts[0]="artifactory.company.com" \
  --set artifactory.artifactory.service.type=NodePort \
  --namespace artifactory-cpp-ce jfrog/artifactory-cpp-ce
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
        - artifactory-cpp-ce.domain.com
      annotations:
        kubernetes.io/tls-acme: "true"
      ## Artifactory Ingress TLS configuration
      ## Secrets must be manually created in the namespace
      ##
      tls:
        - secretName: artifactory-tls
          hosts:
            - artifactory-cpp-ce.domain.com
```

## Useful links
https://www.jfrog.com
https://www.jfrog.com/confluence/
