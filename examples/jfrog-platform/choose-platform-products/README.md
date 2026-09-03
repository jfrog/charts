# Choose Which Products the Platform Chart Deploys

The `jfrog-platform` chart deploys a subset of the platform by default, not all of it — Artifactory and Xray come up without being asked for, and everything else stays off until enabled. This example turns on Distribution and Workers on a running platform, and separately shows Catalog's dependency on Xray/Valkey. It's distinct from [enable-disable-platform-services](../enable-disable-platform-services): that example toggles in-pod *services* running inside the Artifactory process (`observability`, `rtfs`, etc.); this one toggles entire *products*, each its own set of pods (and for several, its own database).

See the [choose-platform-products-values.yaml](choose-platform-products-values.yaml) for the configuration example.

## How it works
- Each product has an `enabled` flag at the chart's top level — there's no standalone-chart equivalent, since standalone charts are each their own Helm release and you choose by deciding which charts to install.

  | Product | Key | Default |
  |---|---|---|
  | JFrog Artifactory | `artifactory.enabled` | `true` |
  | JFrog Xray | `xray.enabled` | `true` |
  | JFrog Distribution | `distribution.enabled` | `false` |
  | JFrog Catalog | `catalog.enabled` | `false` |
  | JFrog Workers | `worker.enabled` | `false` |
  | Bridge | `bridge.enabled` | `false` |
  | Wingman | `wingman.enabled` | `false` |
  | Bundled PostgreSQL | `postgresql.enabled` | `true` |
  | Bundled RabbitMQ | `rabbitmq.enabled` | `true` |

- Enabling a product on an existing install is a `helm upgrade` that adds pods (and, for several products, a database) — decide before the first install where possible.
- **Catalog refuses to install without Xray**: `catalog.enabled: true` while `xray.enabled: false` stops the install with `Catalog (.Values.catalog.enabled) is not currently supported as a standalone feature without Xray (.Values.xray.enabled)`. Enable both, or neither.
- **Catalog's cache switch isn't where you'd expect**: Valkey (Catalog's cache) is enabled under **Xray** — `xray.valkey.enabled` — not under `catalog`, even though Catalog is what uses it. All three keys (`xray.enabled`, `xray.valkey.enabled`, `catalog.cache.enabled`) are required together; `catalog.cache.enabled` alone points the cache at a Valkey service that was never deployed.
- Distribution and Wingman each carry their own `database` block — configure it when enabling them (see [distribution's external-postgres](../../distribution/external-postgres) or [wingman's external-database](../../wingman/external-database)).
- `insight.enabled`/`pipelines.enabled` were removed in chart version 11.x — a values file carried over from a 10.x deployment that still sets either key stops the install; remove them, or stay on chart version 10.x.

## Deploy
```console
helm upgrade --install jfrog-platform --namespace jfrog-platform \
  --set databaseUpgradeReady=true --set gaUpgradeReady=true \
  -f choose-platform-products-values.yaml
```

## Related
- [enable-disable-platform-services](../enable-disable-platform-services) — toggling in-pod *services*, not whole products.
- [enable-distribution](../enable-distribution), [enable-catalog](../enable-catalog), [enable-workers](../enable-workers) — the fuller, dedicated setup for each of these products individually.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — why these flags have no standalone-chart equivalent.
