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

- The double-nesting for Artifactory (`artifactory.artifactory.*`) looks redundant but is correct: the outer `artifactory` selects the subchart within `jfrog-platform`'s values, and the inner `artifactory` is the standalone chart's own top-level `artifactory:` block (which most of its settings — `customVolumes`, `javaOpts`, `replicaCount`, `license`, `persistence` — live under). Settings that sit at the standalone chart's true root, like `nginx.*` or `access.*`, only get the single subchart-name prefix.
- Xray, Distribution, and Worker don't have this double-nesting quirk because their standalone charts don't wrap their own settings in a block named after themselves — `common.customVolumes` at the standalone-chart root becomes `xray.common.customVolumes` under the platform chart, with no repetition.
- Always verify a path you're unsure about by rendering, rather than guessing from the pattern:
  ```bash
  helm show values jfrog/jfrog-platform > platform-defaults.yaml
  helm template myplatform jfrog/jfrog-platform --values values.yaml \
    --show-only charts/artifactory/templates/artifactory-statefulset.yaml
  ```

## Deploy

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f platform-vs-standalone-nesting-values.yaml
```

## Related examples

- [ha-via-platform-chart](../ha-via-platform-chart) and [tls-end-to-end](../tls-end-to-end) apply this rule to specific features.
- The standalone [artifactory examples](../../artifactory) show the same settings in their un-nested, standalone-chart form.
- See [advanced-helm-chart-customizations/platform-vs-standalone-nesting](../../advanced-helm-chart-customizations/platform-vs-standalone-nesting) for the fuller, cross-chart version of this reference (adds Artifactory and Artifactory HA side by side with JFrog Platform).
