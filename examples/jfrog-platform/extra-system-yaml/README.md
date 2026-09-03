# Override system.yaml via extraSystemYaml

This example shows how to reach a `system.yaml` setting that `values.yaml` doesn't expose directly, using `extraSystemYaml`, across Artifactory, Xray, and Distribution when they're deployed together through the `jfrog-platform` chart.

See the [extra-system-yaml-values.yaml](extra-system-yaml-values.yaml) for the configuration example.

## How it works

- Each product's Helm chart generates its own `system.yaml` from `values.yaml` plus a base template. `extraSystemYaml` merges arbitrary keys into that generated file; `extraEnvironmentVariables` (`JF_`-prefixed env vars) and `systemYamlOverride` (an external Secret, not recommended) are the fallback methods, in that order of preference.
- **Correction to earlier guidance in this repo:** Artifactory, Xray, and Distribution all wrap their own `extraSystemYaml` inside a root-level block named after themselves in their *standalone* charts (`artifactory.extraSystemYaml`, `xray.extraSystemYaml`, `distribution.extraSystemYaml`) — so under `jfrog-platform` this setting is **double-nested** for all three: `artifactory.artifactory.extraSystemYaml`, `xray.xray.extraSystemYaml`, `distribution.distribution.extraSystemYaml`. This was verified empirically (single-nesting silently has no effect; double-nesting is what actually renders into each product's ConfigMap). It also matches `jfrog-platform`'s own `values.yaml`, which pre-sets `artifactory.artifactory.unifiedSecretInstallation`, `xray.xray.unifiedSecretInstallation`, and `distribution.distribution.unifiedSecretInstallation` the same way.
- This means the general "some subcharts avoid the double-nesting quirk" note in [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) is too broad if read as a blanket rule — it's true for `common.customVolumes` specifically (which sits in a separate `common:` root block, not inside `xray:`/`distribution:`), but not a general rule for every Xray/Distribution setting. Always verify a path you're unsure about by rendering rather than assuming from one example:
  ```bash
  helm show values jfrog/jfrog-platform > platform-defaults.yaml
  helm template myplatform jfrog/jfrog-platform --values values.yaml \
    --show-only charts/xray/templates/xray-configmap.yaml
  ```
- The chart silently ignores typos under `extraSystemYaml` — there's no validation error, so double-check key paths against the real `system.yaml` schema.

## Deploy

```console
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f extra-system-yaml-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related

- [extra-system-yaml](../../artifactory/extra-system-yaml) and [extra-system-yaml](../../artifactory-ha/extra-system-yaml) — the single-nested, standalone-chart form of this same key.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general umbrella-chart nesting rule, with the correction above.
