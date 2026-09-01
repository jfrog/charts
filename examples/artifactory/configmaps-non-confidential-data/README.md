# Store Non-Confidential Data in ConfigMaps

This example shows how to mount a non-confidential config file (a custom `logback.xml`) into Artifactory using `artifactory.configMaps`, then copy it into place on every startup with `artifactory.copyOnEveryStartup`.

See the [configmaps-non-confidential-data-values.yaml](configmaps-non-confidential-data-values.yaml) for the configuration example.

## How it works
- `artifactory.configMaps` is a block-scalar string of `filename: | <content>` entries; the chart turns it into a single ConfigMap and mounts it via `artifactory.customVolumeMounts` (here, at `/tmp/my-config-map`).
- `artifactory.copyOnEveryStartup` then copies specific files out of that mount into their real target location (`etc/artifactory` here) every time the pod starts — the mounted ConfigMap itself is read-only, so files that Artifactory needs to be able to see at a normal writable path have to be copied out first.
- The same mechanism works for any non-confidential file — an init shell script, `mimetypes.xml`, etc. — not just `logback.xml`.
- For a custom `nginx.conf` specifically, create the ConfigMap yourself with `kubectl create configmap nginx-config --from-file=nginx.conf` and point the chart at it with `nginx.customConfigMap: nginx-config`, rather than using `artifactory.configMaps`.
- For **confidential** data (credentials, keys), use a Kubernetes Secret instead — see [custom-secrets-across-products](../../advanced-helm-chart-customizations/custom-secrets-across-products) once available, or `artifactory.userPluginSecrets`/`database.secrets` for existing narrower examples.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f configmaps-non-confidential-data-values.yaml
```

> The values file also includes placeholder `global.masterKey`/`global.joinKey` and `nginx.tlsSecretName` — every fresh Artifactory install requires these regardless of this example's topic. Replace them with your own generated keys and a real TLS secret before deploying to a real cluster.