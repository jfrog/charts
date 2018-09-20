# JFrog Helm Charts

This repository hosts the official **JFrog Helm Charts** to deploy **JFrog** products to [Kubernetes](https://kubernetes.io/)

## Install Helm

Get the latest [Helm release](https://github.com/kubernetes/helm#install).

## Install Charts

You need to add this Chart repo to Helm:

```console
helm repo add jfrog https://charts.jfrog.io/
helm repo update
```

**Note:** https://charts.jfrog.io/ is also a proxy for the central helm repository https://storage.googleapis.com/kubernetes-charts

Now you can then run `helm search jfrog` to see the available charts.

**Note:** For instructions on how to install charts follow instructions in chart's _README.md_.

## Contributing to JFrog Charts

Fork the `repo`, make changes and then please run `make lint` to lint charts locally, and at last install the chart to see it is working. :)

On success make a [pull request](https://help.github.com/articles/using-pull-requests) (PR).

Upon successful review, someone will give the PR a __LGTM__ (_looks good to me_) in the review thread.
Two __LGTM__ are needed to get the PR approved and merged.


## Manually testing charts with Docker for Mac

On the Mac you can run `make mac` which will lint, install and test changed charts in `Docker for Mac`.

**Note:** Make sure **'Show system containers (advanced)'** is enabled in `Preferences/Kubernetes`.

### Forcing to lint unchanged charts

**Note:** Chart version bump check will be ignored.

You can force to lint one chart with `--charts` flag:

```console
make mac -- --no-install --charts stable/artifactory
```

You can force to lint a list of charts (separated by comma) with `--charts` flag:

```console
make mac -- --no-install --charts stable/artifactory,stable/xray
```

You can force to lint all charts with `--all` flag:

```console
make mac -- --no-install --all
```

### Forcing to install unchanged charts

**Note:** Chart version bump check will be ignored.

You can force to install one chart with `--charts` flag:

```console
make mac -- --no-lint --charts stable/artifactory
```

You can force to install a list of charts (separated by comma) with `--charts` flag:

```console
make mac -- --no-lint --charts stable/artifactory,stable/xray
```

You can force to install all charts with `--all` flag:

```console
make mac -- --no-lint --all
```

**Note:** It might take a while to run install test for all charts in `Docker for Mac`.

## Manually testing charts with remote GKE cluster

You can run `make gke` which will lint, install and test changed charts with `GKE` cluster set in kubeconfig `context`.

### Forcing to lint unchanged charts

**Note:** Chart version bump check will be ignored.

You can force to lint one chart with `--charts` flag:

```console
make gke -- --no-install --charts stable/artifactory
```

You can force to lint all charts with `--all` flag:

```console
make gke -- --no-install --all
```

### Forcing to install unchanged charts

**Note:** Chart version bump check will be ignored.

You can force to install one chart with `--charts` flag:

```console
make gke -- --no-lint --charts stable/artifactory
```

You can force to install all charts with `--all` flag:

```console
make gke -- --no-lint --all
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
