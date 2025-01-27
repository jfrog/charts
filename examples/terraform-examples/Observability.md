# Observability

## EKS Monitoring
Many of the examples here spin up an EKS cluster in AWS.</br>
An easy way to get an observability stack for the EKS is by using [coroot](https://coroot.com/). The following steps will guide you on how to install coroot in EKS.

NOTE: The instructions are also available in the [coroot operator install page](https://docs.coroot.com/installation/kubernetes/?edition=ce)

### Install
```shell
# Setup the coroot helm repository
helm repo add coroot https://coroot.github.io/helm-charts
helm repo update coroot

# Install the coroot operator
helm install -n coroot --create-namespace coroot-operator coroot/coroot-operator

# Install the coroot community edition helm chart
helm install -n coroot coroot coroot/coroot-ce --set "clickhouse.shards=2,clickhouse.replicas=2"
```
**NOTE:** Once installed, it will take a few minutes for data to be collected and displayed in the dashboard. Be patient.


Open the Coroot dashboard by running the following command
```shell
kubectl port-forward -n coroot service/coroot-coroot 8080:8080
```
And browsing to [http://localhost:8080](http://localhost:8080)

### Upgrade

The Coroot Operator for Kubernetes automatically upgrades all components.

### Uninstall

To uninstall Coroot run the following command:

```shell
helm uninstall coroot -n coroot
helm uninstall coroot-operator -n coroot
```
