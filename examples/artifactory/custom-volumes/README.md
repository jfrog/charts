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
helm upgrade --install artifactory jfrog/artifactory -f custom-volumes-values.yaml
```

> The values file also includes placeholder `global.masterKey`/`global.joinKey` and `nginx.tlsSecretName` — every fresh Artifactory install requires these regardless of this example's topic. Replace them with your own generated keys and a real TLS secret before deploying to a real cluster.