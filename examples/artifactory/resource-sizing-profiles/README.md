# Apply a Resource Sizing Profile

Every chart ships with `resources: {}` by default — no requests or limits, so Kubernetes gives the pods no scheduling guarantees. Rather than deriving values yourself, the chart ships ready-made sizing profiles under its own `sizing/` directory that set resource requests/limits, replica counts, and JVM options across every service at once. This example layers one on top of your own values instead of tuning `resources`/`javaOpts` by hand.

See the [resource-sizing-profiles-values.yaml](resource-sizing-profiles-values.yaml) for the configuration example — it's your own custom values, not a copy of the shipped profile.

## How it works
- The `artifactory` chart ships six tiers in its `sizing/` directory: `artifactory-xsmall.yaml` through `artifactory-2xlarge.yaml` (confirmed present in this repo's `stable/artifactory/sizing/`).
- Fetch the chart to get the profile files, then pass the profile alongside your own values: `helm pull jfrog/artifactory --untar`.
- Helm applies `--values`/`-f` files left to right, with later files winning on conflicting keys. Pass the sizing profile **first** and your own values **after** it, so your overrides take precedence over the profile — not the other way around.
- The profiles set some values (JVM options, database connection pools) by writing into the generated `system.yaml`. Using `systemYamlOverride` (see [extra-system-yaml](../extra-system-yaml)) replaces that generated file entirely, discarding those parts of the profile even though the resource requests/limits still apply. Reproduce them yourself, or use `extraSystemYaml` instead.
- The shipped profiles set memory limits but deliberately leave the CPU limit commented out — a CPU limit throttles the container once reached (slow requests, not an error), so set CPU *requests* for scheduling and leave CPU limits unset unless a policy requires them.

## Deploy
```shell
helm pull jfrog/artifactory --untar
helm upgrade --install artifactory jfrog/artifactory \
  -f artifactory/sizing/artifactory-small.yaml \
  -f resource-sizing-profiles-values.yaml
```

## Verify
```bash
kubectl get pod <pod-name> --namespace <namespace> \
  -o jsonpath='{range .spec.containers[*]}{.name}{"\t"}{.resources}{"\n"}{end}'
```

## Related
- [resource-sizing-profiles](../../artifactory-ha/resource-sizing-profiles), [resource-sizing-profiles](../../jfrog-platform/resource-sizing-profiles) — the same shipped-profile mechanism on the HA and platform charts.
- [resource-jvm-sizing](../resource-jvm-sizing) — setting `resources`/`javaOpts` by hand instead of using a shipped profile.
