# Create a Custom Secret from Inline Values

This example shows how to create a chart-managed Kubernetes Secret directly from data in `values.yaml` using `customSecrets`, worked through for both Artifactory and Xray under the `jfrog-platform` umbrella chart.

See the [custom-secrets-values.yaml](custom-secrets-values.yaml) for the configuration example.

## How it works
- Artifactory's `customSecrets` is double-nested under the platform chart — `artifactory.artifactory.customSecrets` — the same as `extraSystemYaml` and `unifiedSecretInstallation`, because the standalone Artifactory chart wraps its own settings in a self-named `artifactory:` block.
- Xray is different: its `customSecrets` lives under a separate `common:` root block in the standalone chart (not inside a self-named `xray:` block), so under the platform chart it's single-nested as `xray.common.customSecrets`.
- Distribution follows Artifactory's pattern too — `distribution.distribution.customSecrets` — since its standalone chart also self-wraps.
- Each list entry (`name`/`key`/`data`) becomes a chart-managed Secret with one data key. It isn't mounted automatically — pair it with a `customVolumes` entry of type `secret` and a matching mount to actually consume it.

## Deploy
```console
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f custom-secrets-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related
- [custom-secrets](../../artifactory/custom-secrets), [custom-secrets](../../artifactory-ha/custom-secrets) — the same mechanism on standalone Artifactory and Artifactory HA.
- [extra-system-yaml](../extra-system-yaml) — the same self-wrapped-block double-nesting quirk, verified there too.
- [custom-init-containers](../custom-init-containers), [custom-sidecars](../custom-sidecars) — where a custom secret's mounted volume typically gets consumed.
