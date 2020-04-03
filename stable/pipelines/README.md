# JFrog Pipelines on Kubernetes Helm Chart

[JFrog Pipelines](https://jfrog.com/pipelines/)

## Prerequisites Details

* Kubernetes 1.12+

## Chart Details

This chart will do the following:

- Deploy PostgreSQL (optionally with an external PostgreSQL instance)
- Deploy RabbitMQ (optionally as an HA cluster)
- Deploy Redis (optionally as an HA cluster)
- Deploy Vault (optionally as an HA cluster)
- Deploy JFrog Pipelines

## Requirements

- A running Kubernetes cluster
  - Dynamic storage provisioning enabled
  - Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory 7 with Enterprise+ License
  - Precreated repository `jfrogpipelines` in Artifactory type `Generic` with layout `maven-2-default`
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) v2 or v3 installed


## Install JFrog Pipelines

### Add JFrog Helm repository

Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io/) to your helm client

```bash
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Artifactory Connection Details

In order to connect Pipelines to your Artifactory installation, you have to use a Join Key, hence it is *MANDATORY* to provide a Join Key and Jfrog Url to your Pipelines installation. Here's how you do that:

Retrieve the connection details of your Artifactory installation, from the UI - https://www.jfrog.com/confluence/display/JFROG/General+Security+Settings#GeneralSecuritySettings-ViewingtheJoinKey.

### Install Pipelines Chart with Ingress

#### Pre-requisites

Before deploying Pipelines you need to have the following
- A running Kubernetes cluster
- An [Artifactory ](https://hub.helm.sh/charts/jfrog/artifactory) or [Artifactory HA](https://hub.helm.sh/charts/jfrog/artifactory-ha) with Enterprise+ License
  - Precreated repository `jfrogpipelines` in Artifactiry type `Generic` with layout `maven-2-default`
- Deployed [Nginx-ingress controller](https://hub.helm.sh/charts/stable/nginx-ingress)
- [Optional] Deployed [Cert-manager](https://hub.helm.sh/charts/jetstack/cert-manager) for automatic management of TLS certificates with [Lets Encrypt](https://letsencrypt.org/)
- [Optional] TLS secret needed for https access

#### Prepare configurations

Fetch the JFrog Pipelines helm chart to ge the needed configuration files

```bash
helm fetch jfrog/pipelines --untar
```

Edit local copies of `values-ingress.yaml`, `values-ingress-passwords.yaml` and `values-ingress-external-secret.yaml` with the needed configuration values 

- URLs in `values-ingress.yaml`
  - Artifactory URL
  - Ingress hosts
  - Ingress tls secrets
- Passwords, `masterKey` and `joinKey` in `values-ingress-passwords.yaml`

#### Install JFrog Pipelines

Install JFrog Pipelines

```bash
helm upgrade --install pipelines --namespace pipelines jfrog/pipelines -f pipelines/values-ingress.yaml -f pipelines/values-ingress-passwords.yaml
```

### Use external secret

**Note:** Best practice is to use external secrets instead of storing passwords in `values.yaml` files.

Don't forget to **update** URLs in `values-ingress-external-secret.yaml` file.

Fill in all required passwords, `masterKey` and `joinKey` in `values-ingress-passwords.yaml` and then create and install the external secret.

**Note:** Helm release name for secrets generation and `helm install` must be set the same, in this case it is `pipelines`.

With Helm v2:

```bash
helm template --name-template pipelines pipelines/ -x templates/pipelines-system-yaml.yaml \
    -f pipelines/values-ingress-external-secret.yaml -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -

helm template --name-template pipelines pipelines/ -x templates/database-secret.yaml \
    -f pipelines/values-ingress-external-secret.yaml -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -

helm template --name-template pipelines pipelines/ -x templates/rabbitmq-secret.yaml \
    -f pipelines/values-ingress-external-secret.yaml -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -
```

With Helm v3:

```bash
helm3 template --name-template pipelines pipelines/ -s templates/pipelines-system-yaml.yaml \
    -f pipelines/values-ingress-external-secret.yaml -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -

helm3 template --name-template pipelines pipelines/ -s templates/database-secret.yaml \
    -f pipelines/values-ingress-external-secret.yaml -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -

helm3 template --name-template pipelines pipelines/ -s templates/rabbitmq-secret.yaml \
    -f pipelines/values-ingress-external-secret.yaml -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -
```

Install JFrog Pipelines:

```bash
helm upgrade --install pipelines --namespace pipelines jfrog/pipelines -f values-ingress-external-secret.yaml
```

### Status

See the status of deployed **helm** release:

```bash
helm status pipelines
```

### Build Plane

#### Build Plane with static and dynamic node-pool VMs

Be default Pipelines comes with a Build Plane with a static node-pool VMs setup, please read [Managing Node Pools](https://www.jfrog.com/confluence/display/JFROG/Choosing+Node+Pools) how to set it up.

For the Dynamic Nodes only on AWs for now, please read [Managing Dynamic Node Pools](https://www.jfrog.com/confluence/display/JFROG/Configuring+Pipelines#ConfiguringPipelines-dynamic-nodesDynamicNodeIntegrations).

#### Kubernetes native Build Plane

Pipelines also supports an experimental Build Plane with Kubernetes StatefulSet as a static node-pool.

**NOTE:** It uses privileged DinD container.

To enable it create `node-pool.yaml` file and pass it with `-f` when doing `helm install/upgrade`:

```
buildPlane:
  ## Build Nodes as Kubernetes StatefulSet
  ## Experimental feature for static nodes
  k8s:
    enabled: true
    ## Node Count
    replicaCount: 5  
```

## Useful links

- https://www.jfrog.com/confluence/display/JFROG/Pipelines+Quickstart
- https://www.jfrog.com/confluence/display/JFROG/Using+Pipelines
- https://www.jfrog.com/confluence/display/JFROG/Managing+Runtimes
