# JFrog Helm Charts

This repository hosts the official **JFrog Helm Charts** to deploy **JFrog** products to [Kubernetes](https://kubernetes.io/)

## Install Helm

Get the latest [Helm release](https://github.com/kubernetes/helm#install).

## Install Charts

You need to add this Chart repo to Helm:
```console
$ helm repo add jfrog https://charts.jfrog.io/
$ helm repo update
```

**Note:** https://charts.jfrog.io/ is also a proxy for the central helm repository https://storage.googleapis.com/kubernetes-charts

Now you can then run `helm search jfrog` to see the available charts.

**Note:** For instructions on how to install charts follow instructions in chart's _README.md_.

## Contributing to JFrog Charts

Fork the `repo`, make changes and then please run `make lint` to lint charts locally, and at last install the chart to see it is working. :)
On Mac you can run `make test` which will lint, install and test charts on `Docker for Mac`.

On success make a [pull request](https://help.github.com/articles/using-pull-requests) (PR).

Upon successful review, someone will give the PR a __LGTM__ (_looks good to me_) in the review thread.
Two __LGTM__ are needed to get the PR approved and merged.

## Docs

For more information on using Helm, refer to the Helm's [documentation](https://docs.helm.sh/using_helm/#quickstart-guide).

To get a quick introduction to Charts see this Chart's [documentation](https://docs.helm.sh/developing_charts/#charts).  
