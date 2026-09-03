# License via Kubernetes Secret

This example shows how to supply the Artifactory license through a pre-created Kubernetes Secret instead of the UI or REST API.

See the [license-via-secret-values.yaml](license-via-secret-values.yaml) for the configuration example.

## How it works

- Create the Secret out-of-band before installing:
  ```shell
  kubectl create secret generic artifactory-license -n jfrog-platform --from-file=artifactory.lic=./artifactory.lic
  ```
- `artifactory.artifactory.license.secret` names the Secret, and `artifactory.artifactory.license.dataKey` names the key inside it holding the license text.
- On the `jfrog-platform` umbrella chart this value needs the double `artifactory.artifactory.` prefix. On the standalone `artifactory` chart, the equivalent key is one level shallower: `artifactory.license.secret` / `artifactory.license.dataKey`.

## Deploy

```console
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f license-via-secret-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```