# JFrog Common Library Chart

A [Helm Library Chart](https://helm.sh/docs/topics/library_charts/#helm) for grouping common logic between JFrog charts.

## TL;DR

```yaml
dependencies:
  - name: jfrog-common
    version: 0.x.x
    repository: https://charts.jfrog.io/
```

```bash
$ helm dependency update
```

## Introduction

This chart provides a common template helpers which can be used to develop new charts using [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Acknowledgement
 
This chart is forked from bitnami [charts](https://github.com/bitnami/charts/tree/main/bitnami/common)
 