# Create a Custom Secret from Inline Values

This example shows how to create a chart-managed Kubernetes Secret directly from data in `values.yaml` using `artifactory.customSecrets`, instead of creating the Secret out-of-band with `kubectl`.

See the [custom-secrets-values.yaml](custom-secrets-values.yaml) for the configuration example.

## How it works
- `artifactory.customSecrets` has the same shape and key path as the standalone `artifactory` chart — a list of `name`/`key`/`data` entries, each becoming a chart-managed Secret with one data key.
- The Secret isn't mounted automatically — pair it with an `artifactory.customVolumes` entry of type `secret` (referencing the Secret by name) and a matching `customVolumeMounts` entry to actually consume it in the container.
- This applies at the `artifactory` block level, not per HA node — it's not scoped under `artifactory.primary`.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f custom-secrets-values.yaml
```

## Related
- [custom-secrets](../../artifactory/custom-secrets), [custom-secrets](../../jfrog-platform/custom-secrets) — the same mechanism on standalone Artifactory and JFrog Platform.
- [custom-init-containers](../custom-init-containers), [custom-sidecars](../custom-sidecars) — where a custom secret's mounted volume typically gets consumed.
