# HA Multi-Node License via Secret

This example shows how to license a multi-node Artifactory HA cluster using `artifactory.license.secret`, which mounts a Kubernetes Secret as `ARTIFACTORY_HOME/etc/artifactory.cluster.license`.

Unlike the standalone `artifactory` chart, an Artifactory HA cluster needs one Enterprise license per node — for the default `artifactory.primary.replicaCount: 3`, that means 3 concatenated license keys in the mounted file, not 1.

See the [multi-node-license-values.yaml](multi-node-license-values.yaml) for the configuration example.

## How it works

- `artifactory.license.secret` names a pre-existing Kubernetes Secret; `artifactory.license.dataKey` is the key inside that Secret whose value is the license file content.
- The mounted file must contain one Enterprise license concatenated per cluster node. If `artifactory.primary.replicaCount` is scaled up or down, the license file must be resized to match and the Secret updated.
- `artifactory.license.licenseKey` is also available to pass the license content directly in values.yaml, but a Secret is preferred so the license doesn't end up in plaintext values files or Helm release history.

## Deploy

1. Concatenate one license per node into a single file, then create the Secret:
```bash
cat license-1.lic license-2.lic license-3.lic > artifactory.cluster.license
kubectl create secret generic artifactory-cluster-license \
  --from-file=artifactory.lic=./artifactory.cluster.license \
  --namespace artifactory-ha
```
2. Install with the license values file:
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f multi-node-license-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```