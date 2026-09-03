# Enable JFrog Workers

This example shows how to enable the JFrog Workers service on the `jfrog-platform` umbrella chart, which deploys the standalone `worker` subchart and wires up the Artifactory-side Workers integration.

See the [enable-workers-values.yaml](enable-workers-values.yaml) for the configuration example.

## How it works

- `worker.enabled: true` turns on the `worker` subchart, which is disabled by default (`worker.enabled: false` in `stable/jfrog-platform/values.yaml`).
- Artifactory also has its own Workers toggle at `artifactory.artifactory.worker.enabled`. Its chart default is the literal, unresolved template string `'{{ .Values.worker.enabled }}'` — Helm treats any non-empty string as truthy, so this flag is effectively always "on" regardless of `worker.enabled`. Set it explicitly to the real string `'true'` (or `'false'`) so the Artifactory-side toggle actually reflects your intent.
- Both flags must be set together: enabling only `worker.enabled` deploys the Workers pod without the Artifactory integration being deterministically toggled.

## Deploy

```console
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-workers-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```