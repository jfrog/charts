# JFrog Helm-hub-sync Helm Chart

A tool to synchronize [Helm Hub](https://github.com/helm/hub) repositories with [JFrog Artifactory](https://jfrog.com/artifactory/)

## Why do I need this

That's a really good question to begin with! [Helm Hub](https://hub.helm.sh) with the new UI is super awesome, but it only can be used as distributed public repository to search for charts in UI.
You might still want to have a single central location where you can find the Helm charts for your organization. `helm-hub-sync` helps you maintain a virtual repository in Artifactory that can be a single source of truth, using the configuration from Helm Hub.

## Prerequisites Details

* Kubernetes 1.12+

## Chart Details

This chart will do the following:

* Deploy JFrog Helm-hub-sync

## Requirements

- A running Kubernetes cluster
- A running Artifactory and user which can add/edit/delete virtual and remote Helm repositories
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) installed and setup to use the cluster (helm init) or or [Tillerless Helm](https://github.com/rimusz/helm-tiller)

## Install

### Add JFrog Helm repository

Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io/) to your helm client

```console
helm repo add jfrog https://charts.jfrog.io
helm repo update
```

### Install Helm-hub-sync Chart

**Note:** You need to have Artifactory URL, username and password.

#### Install chart

```console
helm upgrade --install helm-hub-sync --namespace helm-hub-sync jfrog/helm-hub-sync \
    --set artifactory.host="https://art.domain.com/artifactory",artifactory.authData="username:artifactory_api_key"
```

After install you will be able to access Artifactory Virtual helm repository `helmhub`

```console
helm repo add helmhub https://art.domain.com/artifactory/helmhub/ --username username --password artifactory_api_key
helm repo update
helm search helmhub
```

**Note:** As Artifactory Virtual Repositories do not support showing remote repositories names, if there are charts with the
same names in different repositories, only the chart with most highest version will be shown.

To see the same named charts from few repositories you need to specify `-l` flag:

```console
helm search helmhub/chart-name -l
```

**Note:** As `stable` charts repo is going away it is excluded from being added in to `helmhub` virtual repository.
The reason is that `stable` and some repos from the Helm Hub might have charts with the same name.

If you want to see `stable` repo chart in `helmhub` remove it from `githubIgnoreList:`.

Or you can add it manually as Artifactory helm remote repository.

#### Use external secret

**Note:** Best practice is to use external secrets instead of storing passwords in `values.yaml` files.

Alternatively, you can create a secret containing the Artifactory Authentication data manually and pass it to the template at install/upgrade time.

```console
# Create a secret containing the Authentication data. The key in the secret must be named artifactory-auth-data
kubectl create secret generic my-secret --from-literal=artifactory-auth-data="username:api_key"

# Pass the created secret to helm
helm upgrade --install helm-hub-sync --namespace helm-hub-sync jfrog/helm-hub-sync \
    --set artifactory.host="https://art.domain.com/artifactory",existingSecret="my-secret"
```

## Remove

Removing a **helm** release is done with

```console
helm delete --purge helm-hub-sync
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the helm-hub-sync chart and their default values.

|         Parameter            |                    Description                   |           Default                  |
|------------------------------|--------------------------------------------------|------------------------------------|
| `nameOverride`               | Chart name override                              | ``                                 |
| `fullNameOverride`           | Chart full name override                         | ``                                 |
| `existingSecret`             | An existing secret holding secrets               | ``                                 |
| `existingConfigMap`          | An existing configmap holding env vars           | ``                                 |
| `replicaCount`               | Replica count                                    | `1`                                |
| `image.repository`           | Image repository                                 | `docker.bintray.io/helm-hub-sync`  |
| `image.PullPolicy`           | Container pull policy                            | `IfNotPresent`                     |
| `imagePullSecrets`           | List of imagePullSecrets                         | ``                                 |
| `securityContext.enabled`    | Enables Security Context                         | `true`                             |
| `securityContext.userId`     | Security UserId                                  | `1000`                             |
| `securityContext.groupId`    | Security GroupId                                 | `1000`                             |
| `env.timeInterval`           | The time in seconds between two successive runs  | `14400`                            |
| `env.logLevel`               | Logs level                                       | `info`                             |
| `env.consoleLog`             | To create human-friendly, colorized output       | `true`                             |
| `env.artifactory.host`       | The hostname of JFrog Artifactory to connect to  | ``                                 |
| `env.artifactory.helmRepo`   | The Helm Virtual Repository to use               | `helmhub`                          |
| `env.artifactory.authType`   | The authentication type to use                   | `basic`                            |
| `env.artifactory.authData`   | The authentication data to use                   | ``                                 |
| `env.artifactory.keepList`   | List containing Helm Remote repos that will never be removed | ``                     |
| `env.artifactory.keepDeletedRepos`| Whether to keep repos that have been removed from the Helm Hub | `true`          |
| `env.githubIgnoreList`       | A comma separated list containing Helm repos that should never be created | `stable`  | 
| `resources`                  | Specify resources                                | `{}`                               |
| `nodeSelector`               | kubexray micro-service node selector             | `{}`                               |
| `tolerations`                | kubexray micro-service node tolerations          | `[]`                               |
| `affinity`                   | kubexray micro-service node affinity             | `{}`                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install/upgrade`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example

```console
helm upgrade --install helm-hub-sync --namespace helm-hub-sync jfrog/helm-hub-sync -f override-values.yaml 
```
