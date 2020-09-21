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
- A running Artifactory 7.7.x with Enterprise+ License
  - Precreated repository `jfrogpipelines` in Artifactory type `Generic` with layout `maven-2-default`
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) v2 or v3 installed


## Install JFrog Pipelines

### Add ChartCenter Helm repository

Before installing JFrog helm charts, you need to add the [ChartCenter helm repository](https://chartcenter.io) to your helm client

```bash
helm repo add center https://repo.chartcenter.io
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

Fetch the JFrog Pipelines helm chart to get the needed configuration files

```bash
helm fetch center/jfrog/pipelines --untar
```

Edit local copies of `values-ingress.yaml`, `values-ingress-passwords.yaml` and `values-ingress-external-secret.yaml` with the needed configuration values 

- URLs in `values-ingress.yaml`
  - Artifactory URL
  - Ingress hosts
  - Ingress tls secrets
- Passwords `uiUserPassword`, `postgresqlPassword` and `rabbitmq.password` must be set, and same for `masterKey` and `joinKey` in `values-ingress-passwords.yaml`

#### Install JFrog Pipelines

Install JFrog Pipelines

```bash
kubectl create ns pipelines
helm upgrade --install pipelines --namespace pipelines center/jfrog/pipelines -f pipelines/values-ingress.yaml -f pipelines/values-ingress-passwords.yaml
```

### Use external secret

**Note:** Best practice is to use external secrets instead of storing passwords in `values.yaml` files.

Don't forget to **update** URLs in `values-ingress-external-secret.yaml` file.

Fill in all required passwords, `masterKey` and `joinKey` in `values-ingress-passwords.yaml` and then create and install the external secret.

**Note:** Helm release name for secrets generation and `helm install` must be set the same, in this case it is `pipelines`.

With Helm v2:

```bash
## Generate pipelines-system-yaml secret
helm template --name-template pipelines pipelines/ -x templates/pipelines-system-yaml.yaml \
    -f pipelines/values-ingress-external-secret.yaml -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -

## Generate pipelines-database secret
helm template --name-template pipelines pipelines/ -x templates/database-secret.yaml \
    -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -

## Generate pipelines-rabbitmq-secret secret
helm template --name-template pipelines pipelines/ -x templates/rabbitmq-secret.yaml \
    -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -
```

With Helm v3:

```bash
## Generate pipelines-system-yaml secret
helm template --name-template pipelines pipelines/ -s templates/pipelines-system-yaml.yaml \
    -f pipelines/values-ingress-external-secret.yaml -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -

## Generate pipelines-database secret
helm template --name-template pipelines pipelines/ -s templates/database-secret.yaml \
    -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -

## Generate pipelines-rabbitmq-secret secret
helm template --name-template pipelines pipelines/ -s templates/rabbitmq-secret.yaml \
    -f pipelines/values-ingress-passwords.yaml | kubectl apply --namespace pipelines -f -
```

Install JFrog Pipelines:

```bash
helm upgrade --install pipelines --namespace pipelines center/jfrog/pipelines -f values-ingress-external-secret.yaml
```

### Using external Rabbitmq

If you want to use external Rabbitmq, set `rabbitmq.enabled=false` and create `values-external-rabbitmq.yaml` with below yaml configuration

```yaml
rabbitmq:
  enabled: false
  internal_ip: "{{ .Release.Name }}-rabbitmq"
  msg_hostname: "{{ .Release.Name }}-rabbitmq"
  port: 5672
  manager_port: 15672
  ms_username: admin
  ms_password: password
  cp_username: admin
  cp_password: password
  build_username: admin
  build_password: password    
  root_vhost_exchange_name: rootvhost
  erlang_cookie: secretcookie
  build_vhost_name: pipelines
  root_vhost_name: pipelinesRoot
  protocol: amqp
```

```bash
helm upgrade --install pipelines --namespace pipelines center/jfrog/pipelines -f values-external-rabbitmq.yaml
```

### Status

See the status of deployed **helm** release:

With Helm v2:

```bash
helm status pipelines
```

With Helm v3:

```bash
helm status pipelines --namespace pipelines
```

### Pipelines Version
- By default, the pipelines images will use the value `appVersion` in the Chart.yml. This can be over-ridden by adding `version` to the pipelines section of the values.yml

### Build Plane

#### Build Plane with static and dynamic node-pool VMs

To start using Pipelines you need to setup a Build Plane:
- For Static VMs Node-pool setup, please read [Managing Node Pools](https://www.jfrog.com/confluence/display/JFROG/Managing+Pipelines+Node+Pools#ManagingPipelinesNodePools-static-node-poolsAdministeringStaticNodePools).

- For Dynamic VMs Node-pool setup, please read [Managing Dynamic Node Pools](https://www.jfrog.com/confluence/display/JFROG/Managing+Pipelines+Node+Pools#ManagingPipelinesNodePools-dynamic-node-poolsAdministeringDynamicNodePools).

- For Kubernetes Node-pool setup, please read [Managing Dynamic Node Pools](https://www.jfrog.com/confluence/display/JFROG/Managing+Pipelines+Node+Pools#ManagingPipelinesNodePools-dynamic-node-poolsAdministeringDynamicNodePools).

### Using Vault in Production environments
To use vault securely you must set the disablemlock setting in the values.yaml to false as per the Hashicorp Vault recommendations here:

https://www.vaultproject.io/docs/configuration#disable_mlock

For dev or test environment it is acceptable to leave this value set to true.

Note however this does enable a potential security issue where encrypted credentials could potentially be swapped onto an unencrypted disk. 

For this reason we recommend you always set this value to false to ensure mlock is enabled.

Dev/TEST environments:

````
vault:
  disablemlock: true
````

Production environments:

````
vault:
  disablemlock: false
````

## Useful links

- https://www.jfrog.com/confluence/display/JFROG/Pipelines+Quickstart
- https://www.jfrog.com/confluence/display/JFROG/Using+Pipelines
- https://www.jfrog.com/confluence/display/JFROG/Managing+Runtimes
