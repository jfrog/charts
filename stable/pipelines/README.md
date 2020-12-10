# JFrog Pipelines on Kubernetes Helm Chart

[JFrog Pipelines](https://jfrog.com/pipelines/)

## Prerequisites Details

* Kubernetes 1.12+

## Chart Details

This chart will do the following:

- Deploy PostgreSQL (optionally with an external PostgreSQL instance)
- Deploy RabbitMQ (optionally as an HA cluster)
- Deploy Redis (optionally as an HA cluster)
- Deploy Vault (optionally with an external Vault instance)
- Deploy JFrog Pipelines

## Requirements

- A running Kubernetes cluster
  - Dynamic storage provisioning enabled
  - Default StorageClass set to allow services using the default StorageClass for persistent storage
- A running Artifactory 7.11.x with Enterprise+ License
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

In order to connect Pipelines to your Artifactory installation, you have to use a Join Key, hence it is *MANDATORY* to provide a Join Key, jfrogUrl and jfrogUrlUI to your Pipelines installation. Here's how you do that:

Retrieve the connection details of your Artifactory installation, from the UI - https://www.jfrog.com/confluence/display/JFROG/General+Security+Settings#GeneralSecuritySettings-ViewingtheJoinKey.

```yaml
pipelines:
  ## Artifactory URL - Mandatory
  ## If Artifactory and Pipelines are in same namespace, jfrogUrl is Artifactory service name, otherwise its external URL of Artifactory
  jfrogUrl: ""
  ## Artifactory UI URL - Mandatory
  ## This must be the external URL of Artifactory, for example: https://artifactory.example.com
  jfrogUrlUI: ""

  ## Join Key to connect to Artifactory
  ## IMPORTANT: You should NOT use the example joinKey for a production deployment!
  joinKey: EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
  ## Alternatively, you can use a pre-existing secret with a key called join-key by specifying joinKeySecretName
  ## Note: This feature is available on pipelines app version 1.9.x and later
  # joinKeySecretName:

  ## Pipelines requires a unique master key
  ## You can generate one with the command: "openssl rand -hex 32"
  ## IMPORTANT: You should NOT use the example masterKey for a production deployment!
  masterKey: FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  ## Alternatively, you can use a pre-existing secret with a key called master-key by specifying masterKeySecretName
  ## Note: This feature is available on pipelines app version 1.9.x and later
  # masterKeySecretName:
```

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
- Passwords `uiUserPassword`, `postgresqlPassword` and `auth.password` must be set, and same for `masterKey` and `joinKey` in `values-ingress-passwords.yaml`

#### Install JFrog Pipelines

Install JFrog Pipelines

```bash
kubectl create ns pipelines
helm upgrade --install pipelines --namespace pipelines center/jfrog/pipelines -f pipelines/values-ingress.yaml -f pipelines/values-ingress-passwords.yaml
```

### Special Upgrade Notes

While upgrading from Pipelines chart version 1.x to 2.x and above, due to breaking changes in rabbitmq subchart (6.x to 7.x chart version when `rabbitmq.enabled=true`) and postgresql subchart(8.x to 9.x chart version when `postgresql.enabled=true`) please run below manual commands (downtime is required)

**Note:** Also, Make sure all existing pipelines build runs are completed (rabbitmq queues are empty) when you start an upgrade

**Important:** This is a breaking change from 6.x to 7.x (chart versions) of Rabbitmq chart - Please refer [here](https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq#to-700)

 RabbitMQ password configuration in the Values.yaml has changed from rabbit.rabbit.password to rabbit.auth.password

```bash
kubectl --namespace <namespace> delete statefulsets <release_name>-pipelines-services
kubectl --namespace <namespace> delete statefulsets <release_name>-pipelines-vault
kubectl --namespace <namespace> delete statefulsets <release_name>-postgresql
kubectl --namespace <namespace> delete statefulsets <release_name>-rabbitmq
kubectl --namespace <namespace> delete pvc data-<release_name>-rabbitmq-0
helm upgrade --install pipelines --namespace <namespace> center/jfrog/pipelines
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

### Using external Postgresql

If you want to use external postgresql, set `postgresql.enabled=false` and create `values-external-postgresql.yaml` with below yaml configuration

```yaml
global:
  # Internal Postgres must be set to false
  postgresql:
    user: db_username
    password: db_user_password
    host: db_host
    port: 5432
    database: db_name
    ssl: false / true
postgresql:
  enabled: false
```
Make sure User `db_username` and database `db_name` exists before running helm install / upgrade

```bash
helm upgrade --install pipelines --namespace pipelines center/jfrog/pipelines -f values-external-postgresql.yaml
```

### Using external Vault

If you want to use external Vault, set `vault.enabled=false` and create `values-external-vault.yaml` with below yaml configuration

```yaml
vault:
  enabled: false

global:
  vault:
    ## Vault url examples
    # external one: https://vault.example.com
    # internal one running in the same Kubernetes cluster: http://vault-active:8200
    url: vault_url
    token: vault_token
    ## Set Vault token using existing secret
    # existingSecret: vault-secret
```

If you store external Vault token in a pre-existing Kubernetes Secret, you can specify it via `existingSecret`.

To create a secret containing the Vault token:
```
kubectl create secret generic vault-secret --from-literal=token=${VAULT_TOKEN}
```

```
helm upgrade --install pipelines --namespace pipelines center/jfrog/pipelines -f values-external-vault.yaml
```

### Using an external systemYaml with existingSecret

This is for advanced usecases where users wants to provide their own systemYaml for configuring pipelines. Refer - https://www.jfrog.com/confluence/display/JFROG/Pipelines+System+YAML
Note: This will override existing systemYaml in values.yaml.

```yaml
systemYamlOverride:
## You can use a pre-existing secret by specifying existingSecret
  existingSecret:
## The dataKey should be the name of the secret data key created.
  dataKey:
```
Note: From chart version 2.2.0 and above `.Values.existingSecret` is changed to `.Values.systemYaml.existingSecret` and `.Values.systemYaml.dataKey`.
Note: From chart version 2.3.7 and above `.Values.systemYaml` is changed to `.Values.systemYamlOverride`.

```bash
helm upgrade --install pipelines --namespace pipelines center/jfrog/pipelines -f values-external-systemyaml.yaml
```

### Using Vault in Production environments
To use vault securely you must set the disablemlock setting in the values.yaml to false as per the Hashicorp Vault recommendations here:

https://www.vaultproject.io/docs/configuration#disable_mlock

For non-prod environments it is acceptable to leave this value set to true.

Note however this does enable a potential security issue where encrypted credentials could potentially be swapped onto an unencrypted disk. 

For this reason we recommend you always set this value to false to ensure mlock is enabled.

Non-Prod environments:

````
vault:
  disablemlock: true
````

Production environments:

````
vault:
  disablemlock: false
````

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


## Useful links

- https://www.jfrog.com/confluence/display/JFROG/Pipelines+Quickstart
- https://www.jfrog.com/confluence/display/JFROG/Using+Pipelines
- https://www.jfrog.com/confluence/display/JFROG/Managing+Runtimes
