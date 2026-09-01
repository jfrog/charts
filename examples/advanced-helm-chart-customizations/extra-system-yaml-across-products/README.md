# Overriding system.yaml Across Products

Each product's Helm chart generates its own `system.yaml` from `values.yaml` plus a base template (`files/system.yaml`). When `values.yaml` doesn't expose a setting directly, three methods let you reach it, in order of preference: `extraSystemYaml` (merged into the generated file), `extraEnvironmentVariables` (mapped via `JF_`-prefixed env vars), and `systemYamlOverride` (an external Secret — not recommended, since it bypasses the chart's own generation entirely). The product silently ignores typos under `extraSystemYaml` — there's no validation error, so double-check key paths against the real `system.yaml` schema.

<details>
  <summary>Artifactory</summary>

`artifactory.extraSystemYaml` nests inside the chart's own `artifactory:` block (same tier as `license`, `javaOpts`, `customVolumes`). `artifactory.extraEnvironmentVariables` and the chart-root `systemYamlOverride` are the two fallback methods.

See [extra-system-yaml-artifactory-values.yaml](extra-system-yaml-artifactory-values.yaml).

```shell
helm upgrade --install artifactory jfrog/artifactory -f extra-system-yaml-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

Same shape and same key path as standalone Artifactory — `artifactory.extraSystemYaml`.

See [extra-system-yaml-artifactory-ha-values.yaml](extra-system-yaml-artifactory-ha-values.yaml).

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f extra-system-yaml-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

**Correction to earlier guidance in this repo:** Artifactory, Xray, and Distribution all wrap their own `extraSystemYaml` inside a root-level block named after themselves in their *standalone* charts (`artifactory.extraSystemYaml`, `xray.extraSystemYaml`, `distribution.extraSystemYaml`) — so under `jfrog-platform` this setting is **double-nested** for all three: `artifactory.artifactory.extraSystemYaml`, `xray.xray.extraSystemYaml`, `distribution.distribution.extraSystemYaml`. This was verified empirically (single-nesting silently has no effect; double-nesting is what actually renders into each product's ConfigMap). It also matches `jfrog-platform`'s own `values.yaml`, which pre-sets `artifactory.artifactory.unifiedSecretInstallation`, `xray.xray.unifiedSecretInstallation`, and `distribution.distribution.unifiedSecretInstallation` the same way.

> This means the "Xray/Distribution don't have this double-nesting quirk" note in [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) and [custom-volumes-across-products](../custom-volumes-across-products) is too broad — it's true for `common.customVolumes` specifically (which sits in a separate `common:` root block, not inside `xray:`/`distribution:`), but not a general rule for every Xray/Distribution setting. Always verify by rendering rather than assuming from one example.

See [extra-system-yaml-jfrog-platform-values.yaml](extra-system-yaml-jfrog-platform-values.yaml).

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f extra-system-yaml-jfrog-platform-values.yaml
```
</details>

## References
- [catalog/extra-system-yaml](../../catalog/extra-system-yaml) — Catalog's separate `extraSystemYaml`/`systemYamlOverride` mechanism (Catalog isn't covered by this cross-product topic since it doesn't self-wrap the same way).
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — the general nesting rule, with the correction above.