# JFrog Helm-hub-sync Helm Chart

A tool to synchronize [Helm Hub](https://github.com/helm/hub) repositories with [JFrog Artifactory](https://jfrog.com/artifactory/)

![diagram](https://raw.githubusercontent.com/jfrog/helm-hub-sync/master/images/helm-hub-sync.png)

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
    --set env.artifactory.url="https://art.domain.com/artifactory",env.artifactory.authData="username:artifactory_api_key"
```

After install you will be able to access Artifactory Virtual helm repository `helmhub`

```console
helm repo add helmhub https://art.domain.com/artifactory/helmhub/ --username username --password artifactory_api_key
helm repo update
helm search helmhub
```

**Note:** The remote repository where the chart is actually held is not identified. That’s the way Artifactory’s virtual repositories work -- they masquerade as a single repo for your convenience.
But if there are two or more charts with the same name, each in different remote repositories, then `helm search` will only show the chart of that name whose version number is the highest.To see all charts of the same name from all remote repositories, specify `-l` flag.
This will force the Helm CLI to show the long listing, with each version of the chart:

```console
helm search helmhub/chart-name -l
```

It’s also worth noting that the `stable` charts repository is excluded from the `helmhub` virtual repository. We’ve chosen to do that because Helm Hub is expected to replace stable as the common public repository, and Helm v3 beta no longer adds the `stable` repo by default. The charts that `stable` contains are increasingly likely to be duplicated in other repos. 

If you want to access stable repo charts through an Artifactory helm remote repository, you must add it manually. If you choose, you can also add that remote repo to the `helmhub` virtual repository.

#### Use external secret

**Note:** Best practice is to use external secrets instead of storing passwords in `values.yaml` files.

Alternatively, you can create a secret containing the Artifactory Authentication data manually and pass it to the template at install/upgrade time.

```console
# Create a secret containing the Authentication data. The key in the secret must be named artifactory-auth-data
kubectl create secret generic my-secret --from-literal=artifactory-auth-data="username:api_key"

# Pass the created secret to helm
helm upgrade --install helm-hub-sync --namespace helm-hub-sync jfrog/helm-hub-sync \
    --set env.artifactory.url="https://art.domain.com/artifactory",existingSecret="my-secret"
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
| `env.artifactory.url`        | The JFrog Artifactory URL to connect to          | ``                                 |
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
