# Enable the Workers Addon

This example shows how to enable Artifactory's Workers addon — which lets you run custom JavaScript code in response to Artifactory events — via `artifactory.worker.enabled`.

See the [worker-enablement-values.yaml](worker-enablement-values.yaml) for the configuration example.

## How it works
- `artifactory.worker.enabled` is `false` by default; setting it to `true` turns on the Workers addon inside the Artifactory process.
- This is a single, standalone-chart-only flag. It's unrelated to the separate `worker` **subchart** shipped with the `jfrog-platform` umbrella chart, which runs Workers as its own pod — the two are configured independently.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f worker-enablement-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic.