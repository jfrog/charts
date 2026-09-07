# Apply a Resource Sizing Profile

Every chart ships with `resources: {}` by default — no requests or limits, so Kubernetes gives the pods no scheduling guarantees. Rather than deriving values yourself, the `artifactory-ha` chart ships ready-made sizing profiles under its own `sizing/` directory that set resource requests/limits, replica counts, and JVM options across every service at once. This example layers one on top of your own values instead of tuning `resources`/`javaOpts` by hand.

See the [resource-sizing-profiles-values.yaml](resource-sizing-profiles-values.yaml) for the configuration example — it's your own custom values, not a copy of the shipped profile.

## How it works
- The `artifactory-ha` chart ships the same six tiers as standalone `artifactory`, in its own `sizing/` directory: `artifactory-xsmall.yaml` through `artifactory-2xlarge.yaml`.
- Fetch the chart to get the profile files, then pass the profile alongside your own values: `helm pull jfrog/artifactory-ha --untar`.
- Helm applies `--values`/`-f` files left to right, with later files winning on conflicting keys. Pass the sizing profile **first** and your own values **after** it, so your overrides take precedence over the profile.
- The profiles set some values (JVM options, database connection pools) by writing into the generated `system.yaml`. Using `systemYamlOverride` (see [extra-system-yaml](../extra-system-yaml)) replaces that generated file entirely, discarding those parts of the profile even though the resource requests/limits still apply.
- The shipped profiles set memory limits but leave CPU limits commented out — set CPU *requests* for scheduling and leave CPU limits unset unless a policy requires them, since a CPU limit throttles rather than errors.
- Primary-node settings (`artifactory.primary.resources`/`javaOpts`) are still nested under `artifactory.primary` even when a profile sets them — see [ha-resource-sizing](../ha-resource-sizing).

## Deploy
```shell
helm pull jfrog/artifactory-ha --untar
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha \
  -f artifactory-ha/sizing/artifactory-small.yaml \
  -f resource-sizing-profiles-values.yaml
```

## Related
- [resource-sizing-profiles](../../artifactory/resource-sizing-profiles), [resource-sizing-profiles](../../jfrog-platform/resource-sizing-profiles) — the standalone and platform-chart versions of this example.
- [ha-resource-sizing](../ha-resource-sizing) — setting `artifactory.primary.resources`/`javaOpts` by hand instead of using a shipped profile.
