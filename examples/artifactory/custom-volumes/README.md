# Mount a Custom Volume into the Artifactory Container

This example shows how to mount an extra volume — here, a custom CA certificate from a ConfigMap — into the Artifactory container using `artifactory.customVolumes` and `artifactory.customVolumeMounts`.

See the [custom-volumes-values.yaml](custom-volumes-values.yaml) for the configuration example.

## How it works
- `artifactory.customVolumes` and `artifactory.customVolumeMounts` are rendered with Helm's `tpl` function, so each is a YAML **string** (block scalar), not a native YAML list — you can reference template values like `{{ .Release.Name }}` inside them.
- The ConfigMap (or Secret) referenced must exist in the same namespace before the pod starts; create it separately, e.g. `kubectl create configmap custom-truststore --from-file=custom-ca.pem`.
- Both blocks are appended to the pod's existing `volumes`/`volumeMounts` list — they don't replace anything the chart already mounts.

## Deploy
```shell
kubectl create configmap custom-truststore --from-file=custom-ca.pem
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f custom-volumes-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic. The values file also sets `nginx.https.enabled: false` to skip the mandatory TLS-secret gate for this example; use a real `nginx.tlsSecretName` in production.