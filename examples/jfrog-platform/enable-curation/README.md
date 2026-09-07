# Enable Curation

Curation depends on several other components being deployed together: Xray running in pod-split mode with a separate Curation route, Catalog with caching, and Bridge.

See the [enable-curation-values.yaml](enable-curation-values.yaml) for the configuration example.

## How it works

- `xray.splitXraytoSeparateDeployments.fullSplit: true` deploys each Xray service as its own dedicated deployment instead of one combined pod — Curation requires this pod-split mode.
- `xray.curation.separateRoute: true` gives the Curation service its own routable endpoint instead of sharing Xray's default route.
- `catalog.enabled` + `catalog.cache.enabled` (backed by `xray.valkey.enabled`) provide the package metadata and caching layer Curation reads from.
- `bridge.enabled: true` deploys the Bridge component Curation uses to communicate with upstream sources.
- This Helm configuration only **deploys** the Curation pod and its dependencies. Curation itself is **activated** afterward from the Artifactory UI, under Administration > Curation.

## Notes

Enabling `catalog` and `bridge` together on `jfrog-platform` (chart 11.6.3) breaks Helm's cross-subchart global value merge: `bridge`'s image-name helper (`stable/jfrog-platform/charts/bridge/templates/_helpers.tpl`) reads `.Values.global.digests.router`, and with both components enabled the merged `global.digests` value it receives isn't a map, so the template aborts with `nil pointer evaluating interface {}.router`. Setting `global.digests: {}` explicitly at the root of your values file (as done in `enable-curation-values.yaml`) works around it.

## Deploy

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-curation-values.yaml
```