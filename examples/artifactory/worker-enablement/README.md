# Enable the Workers Addon

This example shows how to enable Artifactory's Workers addon — which lets you run custom JavaScript code in response to Artifactory events — via `artifactory.worker.enabled`.

See the [worker-enablement-values.yaml](worker-enablement-values.yaml) for the configuration example.

## How it works
- `artifactory.worker.enabled` is `false` by default; setting it to `true` turns on the Workers addon inside the Artifactory process.
- This is a single, standalone-chart-only flag. It's unrelated to the separate `worker` **subchart** shipped with the `jfrog-platform` umbrella chart, which runs Workers as its own pod — the two are configured independently.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f worker-enablement-values.yaml
```

> The values file also includes placeholder `global.masterKey`/`global.joinKey` and `nginx.tlsSecretName` — every fresh Artifactory install requires these regardless of this example's topic. Replace them with your own generated keys and a real TLS secret before deploying to a real cluster.