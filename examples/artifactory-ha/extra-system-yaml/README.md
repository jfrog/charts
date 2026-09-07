# Override system.yaml via extraSystemYaml

This example shows how to reach a `system.yaml` setting that `values.yaml` doesn't expose directly, using `artifactory.extraSystemYaml`, on the Artifactory HA chart.

See the [extra-system-yaml-values.yaml](extra-system-yaml-values.yaml) for the configuration example.

## How it works

- Same shape and same key path as standalone Artifactory — `artifactory.extraSystemYaml` isn't renamed or renested for the HA chart.
- The chart generates its own `system.yaml` from `values.yaml` plus a base template. `extraSystemYaml` is the preferred way to reach a setting `values.yaml` doesn't expose directly; `artifactory.extraEnvironmentVariables` (`JF_`-prefixed env vars) and the chart-root `systemYamlOverride` (an external Secret, not recommended) are the two fallback methods.
- The chart silently ignores typos under `extraSystemYaml` — there's no validation error, so double-check key paths against the real `system.yaml` schema.

## Deploy

```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f extra-system-yaml-values.yaml
```

## Related

- [extra-system-yaml](../../artifactory/extra-system-yaml) — the same mechanism and key path for standalone Artifactory.
- [extra-system-yaml](../../jfrog-platform/extra-system-yaml) — the double-nested form of this same key under the `jfrog-platform` umbrella chart.
