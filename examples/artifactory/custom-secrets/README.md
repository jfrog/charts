# Create a Custom Secret from Inline Values

This example shows how to create a chart-managed Kubernetes Secret directly from data in `values.yaml` using `artifactory.customSecrets`, instead of creating the Secret out-of-band with `kubectl`.

See the [custom-secrets-values.yaml](custom-secrets-values.yaml) for the configuration example.

## How it works
- `artifactory.customSecrets` is a list of `name`/`key`/`data` entries. For each entry, the chart creates a Kubernetes Secret named `name` with a single data key `key` whose value is `data`.
- The Secret isn't mounted automatically — pair it with an `artifactory.customVolumes` entry of type `secret` (referencing the Secret by name) and a matching `customVolumeMounts` entry to actually consume it in the container.
- This is meant for small, non-sensitive-at-rest values you're comfortable keeping in your `values.yaml`/Helm release history — for real secret material, prefer creating the Secret separately and referencing it, so it never passes through Helm's values.

## Deploy
```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f custom-secrets-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [custom-secrets](../../artifactory-ha/custom-secrets), [custom-secrets](../../jfrog-platform/custom-secrets) — the same mechanism on Artifactory HA and JFrog Platform.
- [custom-init-containers](../custom-init-containers), [custom-sidecars](../custom-sidecars) — where a custom secret's mounted volume typically gets consumed.
