# Override system.yaml via extraSystemYaml

This example shows how to reach a `system.yaml` setting that `values.yaml` doesn't expose directly, using `artifactory.extraSystemYaml`.

See the [extra-system-yaml-values.yaml](extra-system-yaml-values.yaml) for the configuration example.

## How it works

- The chart generates its own `system.yaml` from `values.yaml` plus a base template (`files/system.yaml`). When a setting isn't exposed as its own `values.yaml` key, three methods let you reach it, in order of preference: `extraSystemYaml` (merged into the generated file), `extraEnvironmentVariables` (mapped via `JF_`-prefixed env vars), and `systemYamlOverride` (an external Secret — not recommended, since it bypasses the chart's own generation entirely).
- `artifactory.extraSystemYaml` nests inside the chart's own `artifactory:` block, at the same tier as `license`, `javaOpts`, and `customVolumes`.
- The chart silently ignores typos under `extraSystemYaml` — there's no validation error, so double-check key paths against the real `system.yaml` schema before relying on a setting taking effect.

## Deploy

```shell
export MASTER_KEY=$(openssl rand -hex 32)
export JOIN_KEY=$(openssl rand -hex 32)
helm upgrade --install artifactory jfrog/artifactory -f extra-system-yaml-values.yaml \
  --set global.masterKey=$MASTER_KEY --set global.joinKey=$JOIN_KEY
```

## Related

- [extra-system-yaml](../../artifactory-ha/extra-system-yaml) — the same mechanism and key path for Artifactory HA.
- [extra-system-yaml](../../jfrog-platform/extra-system-yaml) — the double-nested form of this same key under the `jfrog-platform` umbrella chart.
- [catalog/extra-system-yaml](../../catalog/extra-system-yaml) — Catalog's separate `extraSystemYaml`/`systemYamlOverride` mechanism, which doesn't self-wrap the same way.
