# Platform Chart vs. Standalone Chart Values

`jfrog-platform` deploys each product as a subchart. The general translation rule: **the umbrella path is always the subchart name, followed by the exact same path used in that product's standalone chart.** This example is a worked reference for that rule, not a single feature.

See the [platform-vs-standalone-nesting-values.yaml](platform-vs-standalone-nesting-values.yaml) for a complete, deployable platform-chart-form example.

## How it works

| Setting | Standalone chart | Under `jfrog-platform` |
|---|---|---|
| Artifactory custom volumes | `artifactory.customVolumes` | `artifactory.artifactory.customVolumes` |
| Artifactory JVM heap | `artifactory.javaOpts` | `artifactory.artifactory.javaOpts` |
| Nginx TLS secret | `nginx.tlsSecretName` | `artifactory.nginx.tlsSecretName` |
| Xray custom volumes | `common.customVolumes` | `xray.common.customVolumes` |
| Distribution custom volumes | `common.customVolumes` | `distribution.common.customVolumes` |
| Catalog extra volumes | `extraVolumes` | `catalog.extraVolumes` |

Artifactory HA follows the same subchart-name-prefix rule, with one twist: `javaOpts` (and other primary-node settings) nest one level deeper again, under `artifactory.primary`, since HA distinguishes primary-node settings from other components. `nginx.tlsSecretName` stays at the same depth as standalone Artifactory. See [resource-and-jvm-sizing](../resource-and-jvm-sizing) and [ha-resource-sizing](../../artifactory-ha/ha-resource-sizing).

- The double-nesting for Artifactory (`artifactory.artifactory.*`) looks redundant but is correct: the outer `artifactory` selects the subchart within `jfrog-platform`'s values, and the inner `artifactory` is the standalone chart's own top-level `artifactory:` block (which most of its settings — `customVolumes`, `javaOpts`, `replicaCount`, `license`, `persistence` — live under). Settings that sit at the standalone chart's true root, like `nginx.*` or `access.*`, only get the single subchart-name prefix.
- Xray, Distribution, and Worker don't have this double-nesting quirk for settings like `common.customVolumes` — their standalone charts don't wrap that particular setting in a block named after themselves, so `common.customVolumes` becomes `xray.common.customVolumes`/`distribution.common.customVolumes` under the platform chart with no repetition. **This is setting-specific, not chart-wide** — don't assume Xray/Distribution avoid double-nesting for everything. Settings that *do* sit under a self-named root block on those charts still double-nest exactly like Artifactory: `extraSystemYaml` and `unifiedSecretInstallation` become `xray.xray.extraSystemYaml`/`distribution.distribution.extraSystemYaml` and `xray.xray.unifiedSecretInstallation`/`distribution.distribution.unifiedSecretInstallation` under `jfrog-platform` — confirmed both empirically (rendering both nesting depths) and from `stable/jfrog-platform/values.yaml`'s own shipped defaults, which pre-populate exactly these double-nested paths. See [extra-system-yaml](../extra-system-yaml). The rule is: check whether the *specific* standalone-chart setting lives inside a block named after the chart itself, not whether the chart as a whole has "the quirk."
- Always verify a path you're unsure about by rendering, rather than guessing from the pattern:
  ```bash
  helm show values jfrog/jfrog-platform > platform-defaults.yaml
  helm template myplatform jfrog/jfrog-platform --values values.yaml \
    --show-only charts/artifactory/templates/artifactory-statefulset.yaml
  ```

## Deploy

```console
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f platform-vs-standalone-nesting-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related examples

- [ha-via-platform-chart](../ha-via-platform-chart) and [tls-end-to-end](../tls-end-to-end) apply this rule to specific features.
- [resource-and-jvm-sizing](../resource-and-jvm-sizing), [extra-system-yaml](../extra-system-yaml) — this rule applied to specific settings, including the double-nesting correction above.
- The standalone [artifactory](../../artifactory) and [artifactory-ha](../../artifactory-ha) examples show the same settings in their un-nested, standalone-chart form.
