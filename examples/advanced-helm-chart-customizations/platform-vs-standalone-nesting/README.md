# Platform Chart vs. Standalone Chart Values

`jfrog-platform` deploys each product as a subchart, so most standalone-chart values move one level deeper, nested under the subchart's name. This is the canonical, cross-chart version of that translation rule — worked through for Artifactory, Artifactory HA, and JFrog Platform side by side, using the same representative settings (JVM heap and the Nginx TLS secret) in each.

**The general rule: the umbrella path is always the subchart name, followed by the exact same path used in that product's standalone chart.**

<details>
  <summary>Artifactory</summary>

At chart root: `javaOpts` for JVM heap, `nginx.tlsSecretName` for the TLS secret.

See [platform-vs-standalone-nesting-artifactory-values.yaml](platform-vs-standalone-nesting-artifactory-values.yaml).

```yaml
artifactory:
  javaOpts:
    xms: "1g"
    xmx: "4g"
nginx:
  tlsSecretName: nginx-tls-secret
```

Deploy:
```shell
helm upgrade --install artifactory jfrog/artifactory -f platform-vs-standalone-nesting-artifactory-values.yaml
```
</details>

<details>
  <summary>Artifactory HA</summary>

`javaOpts` nests one level deeper under `artifactory.primary`, since HA distinguishes primary-node settings from other components. `nginx.tlsSecretName` stays the same as the standalone chart.

See [platform-vs-standalone-nesting-artifactory-ha-values.yaml](platform-vs-standalone-nesting-artifactory-ha-values.yaml).

```yaml
artifactory:
  primary:
    javaOpts:
      xms: "1g"
      xmx: "4g"
nginx:
  tlsSecretName: nginx-tls-secret
```

Deploy:
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f platform-vs-standalone-nesting-artifactory-ha-values.yaml
```
</details>

<details>
  <summary>JFrog Platform</summary>

| Setting | Standalone chart | Under `jfrog-platform` |
|---|---|---|
| Artifactory JVM heap | `artifactory.javaOpts` | `artifactory.artifactory.javaOpts` |
| Nginx TLS secret | `nginx.tlsSecretName` | `artifactory.nginx.tlsSecretName` |
| Artifactory custom volumes | `artifactory.customVolumes` | `artifactory.artifactory.customVolumes` |
| Xray custom volumes | `common.customVolumes` | `xray.common.customVolumes` |
| Distribution custom volumes | `common.customVolumes` | `distribution.common.customVolumes` |
| Catalog extra volumes | `extraVolumes` | `catalog.extraVolumes` |

- The double-nesting for Artifactory (`artifactory.artifactory.*`) looks redundant but is correct: the outer `artifactory` selects the subchart within `jfrog-platform`'s values, and the inner `artifactory` is the standalone chart's own top-level `artifactory:` block, which most of its settings (`javaOpts`, `customVolumes`, `replicaCount`, `license`, `persistence`) live under. Settings that sit at the standalone chart's true root, like `nginx.*` or `access.*`, only get the single subchart-name prefix.
- This is **setting-specific, not chart-wide** — don't assume Xray/Distribution avoid double-nesting for everything. `common.customVolumes` genuinely avoids it (`common:` isn't a self-named block, so it becomes `xray.common.customVolumes`/`distribution.common.customVolumes` with no repetition). But settings that *do* sit under a self-named root block on those charts still double-nest exactly like Artifactory: `extraSystemYaml` and `unifiedSecretInstallation` become `xray.xray.extraSystemYaml`/`distribution.distribution.extraSystemYaml` and `xray.xray.unifiedSecretInstallation`/`distribution.distribution.unifiedSecretInstallation` under `jfrog-platform` — confirmed both empirically (rendering both nesting depths) and from `stable/jfrog-platform/values.yaml`'s own shipped defaults, which pre-populate exactly these double-nested paths. See [extra-system-yaml-across-products](../extra-system-yaml-across-products) for the worked example. The rule is: check whether the *specific* standalone-chart setting lives inside a block named after the chart itself, not whether the chart as a whole has "the quirk."
- Always verify a path you're unsure about by rendering, rather than guessing from the pattern:
  ```bash
  helm show values jfrog/jfrog-platform > platform-defaults.yaml
  helm template myplatform jfrog/jfrog-platform --values values.yaml \
    --show-only charts/artifactory/templates/artifactory-statefulset.yaml
  ```

See [platform-vs-standalone-nesting-jfrog-platform-values.yaml](platform-vs-standalone-nesting-jfrog-platform-values.yaml).

Deploy:
```shell
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f platform-vs-standalone-nesting-jfrog-platform-values.yaml
```
</details>

## Related
- [platform-vs-standalone-nesting](../../jfrog-platform/platform-vs-standalone-nesting) — the original, jfrog-platform-only version of this example.
- [custom-volumes-across-products](../custom-volumes-across-products) and [resource-and-jvm-sizing-across-products](../resource-and-jvm-sizing-across-products) apply this rule to specific features across more products.
- The standalone [artifactory](../../artifactory) and [artifactory-ha](../../artifactory-ha) examples show these settings in their own, narrower context.