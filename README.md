# JFrog Helm Charts

This repository hosts the official **[JFrog](https://jfrog.com/) Helm Charts** for deploying **JFrog** products to [Kubernetes](https://kubernetes.io/)

For older version please refer to https://github.com/jfrog/charts/tree/pre-unified-platform

## Install Helm

Get the latest [Helm release](https://github.com/kubernetes/helm#install).

## Install Charts

### Add ChartCenter Helm repository

Before installing JFrog helm charts, you need to add the [ChartCenter helm repository](https://chartcenter.io) to your helm client.

```bash
helm repo add center https://repo.chartcenter.io
helm repo update
```

**Note:** For instructions on how to install a chart follow instructions in its _README.md_.

## Contributing to JFrog Charts

Fork the `repo`, make changes and then please run `make lint` to lint charts locally, and at least install the chart to see it is working. :)

On success make a [pull request](https://help.github.com/articles/using-pull-requests) (PR) on to the `master` branch.

Upon successful review, someone will give the PR a __LGTM__ (_looks good to me_) in the review thread.
Three __LGTM__ are needed to get the PR approved and merged.

## Linting charts locally

**Note:** Docker must be running on your Mac/Linux machine. 
The command will only lint changed charts.

To lint all charts:

```console
make lint
```

### Forcing to lint unchanged charts

**Note:** Chart version bump check will be ignored.

You can force to lint one chart with `--charts` flag:

```console
make lint -- --charts stable/artifactory
```

You can force to lint a list of charts (separated by comma) with `--charts` flag:

```console
make lint -- --charts stable/artifactory,stable/xray
```

You can force to lint all charts with `--all` flag:

```console
make lint -- --all
```

## Manually testing charts with Docker for Mac Kubernetes Cluster

**Note:** Make sure **'Show system containers (advanced)'** is enabled in `Preferences/Kubernetes`.

On the Mac you can install and test all changed charts in `Docker for Mac`:

```console
make mac
```

### Forcing to install unchanged charts

You can force to install one chart with `--charts` flag:

```console
make mac -- --charts stable/artifactory
```

You can force to install a list of charts (separated by comma) with `--charts` flag:

```console
make mac -- --charts stable/artifactory,stable/xray
```

You can force to install all charts with `--all` flag:

```console
make mac -- --all
```

**Note:** It might take a while to run install test for all charts in `Docker for Mac`.

## Manually testing charts with remote GKE cluster

You can install and test changed charts with `GKE` cluster set in kubeconfig `context`:

```console
make gke
```

### Forcing to install unchanged charts

You can force to install one chart with `--charts` flag:

```console
make gke -- --charts stable/artifactory
```

You can force to install a list of charts (separated by comma) with `--charts` flag:

```console
make gke -- --charts stable/artifactory,stable/xray
```

You can force to install all charts with `--all` flag:

```console
make gke -- --all
```

### Using dedicated GKE cluster for manual charts testing

By default it uses the `GKE` cluster set in kubeconfig `context`, you can specify the dedicated cluster (it must be set in the kubeconfig) in the file `CLUSTER`:

```
GKE_CLUSTER=gke_my_cluster_context_name
```

Then store the `CLUSTER` file in the root folder of the repo. It is also ignored by git.

In such setup your local default cluster can be different from the charts testing one.


## Docs

For more information on using Helm, refer to the Helm's [documentation](https://docs.helm.sh/using_helm/#quickstart-guide).

To get a quick introduction to Charts see this Chart's [documentation](https://docs.helm.sh/developing_charts/#charts).  
