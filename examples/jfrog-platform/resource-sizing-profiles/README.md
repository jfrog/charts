# Apply a Resource Sizing Profile

Every chart ships with `resources: {}` by default — no requests or limits, so Kubernetes gives the pods no scheduling guarantees. Rather than deriving values yourself, the `jfrog-platform` chart ships ready-made sizing profiles under its own `sizing/` directory that set resource requests/limits, replica counts, and JVM options across every product at once. This example layers one on top of your own values instead of tuning `resources`/`javaOpts` by hand per subchart.

See the [resource-sizing-profiles-values.yaml](resource-sizing-profiles-values.yaml) for the configuration example — it's your own custom values, not a copy of the shipped profile.

## How it works
- `jfrog-platform` ships six tiers in its own `sizing/` directory: `platform-xsmall.yaml` through `platform-2xlarge.yaml`. A platform profile sets values for products a standalone chart doesn't contain — don't pass an `artifactory`-chart sizing file to `jfrog-platform` or vice versa.
- Fetch the chart to get the profile files, then pass the profile alongside your own values: `helm pull jfrog/jfrog-platform --untar`.
- Helm applies `--values`/`-f` files left to right, with later files winning on conflicting keys. Pass the sizing profile **first** and your own values **after** it — the same ordering rule as [openshift-overlay](../openshift-overlay).
- Resources are set per service, not per product — each product runs several containers, and setting only the product-level value leaves the sidecars unbounded. `artifactory.router.resources` (single-nested, unlike `artifactory.artifactory.resources`) is one of several independent keys, alongside `frontend`, `access`, `observability`, and `nginx` in Artifactory, and each microservice in Xray.
- The profiles set some values (JVM options, database connection pools) by writing into the generated `system.yaml`. Using `systemYamlOverride` (see [extra-system-yaml](../extra-system-yaml)) replaces that generated file entirely, discarding those parts of the profile even though the resource requests/limits still apply.
- The shipped profiles set memory limits but leave CPU limits commented out — set CPU *requests* for scheduling and leave CPU limits unset unless a policy requires them.

## Deploy
```shell
helm pull jfrog/jfrog-platform --untar
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform \
  -f jfrog-platform/sizing/platform-small.yaml \
  -f resource-sizing-profiles-values.yaml
```

## Verify
```bash
helm template myplatform jfrog/jfrog-platform \
  --values jfrog-platform/sizing/platform-small.yaml \
  | grep -A6 "resources:"
```

## Related
- [resource-sizing-profiles](../../artifactory/resource-sizing-profiles), [resource-sizing-profiles](../../artifactory-ha/resource-sizing-profiles) — the standalone and HA versions of this example.
- [resource-and-jvm-sizing](../resource-and-jvm-sizing) — setting `artifactory.artifactory.resources`/`javaOpts` by hand instead of using a shipped profile.
- [platform-vs-standalone-nesting](../platform-vs-standalone-nesting) — why `router` is single-nested while `resources`/`javaOpts` on the main Artifactory container are double-nested.
