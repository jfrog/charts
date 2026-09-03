# Set Environment Variables via extraEnvironmentVariables

This example shows how to inject an environment variable into the Artifactory HA containers using `artifactory.extraEnvironmentVariables`, the fastest way to set a single `system.yaml` value without editing `extraSystemYaml`.

See the [extra-environment-variables-values.yaml](extra-environment-variables-values.yaml) for the configuration example.

## How it works
- `artifactory.extraEnvironmentVariables` uses the same key and the same flat nesting as the standalone chart — it is **not** scoped under `artifactory.primary`, unlike `resources`/`javaOpts` (see [ha-resource-sizing](../ha-resource-sizing)).
- It's a native YAML **list** of `name`/`value` pairs, rendered with `tpl (toYaml .)`. Quote every value, even numeric or boolean ones.
- To reach a `system.yaml` setting, prefix its dotted path with `JF_`, uppercase every segment, and join with underscores — e.g. `shared.security.bootstrapKeysReadTimeoutSecs` becomes `JF_SHARED_SECURITY_BOOTSTRAPKEYSREADTIMEOUTSECS`. Every node in the HA cluster picks up the same variable.
- Verify a variable landed by exec'ing into a pod: `kubectl exec <pod> --namespace artifactory-ha -c artifactory -- env | grep JF_`.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f extra-environment-variables-values.yaml
```

## Related
- [extra-environment-variables](../../artifactory/extra-environment-variables) — the standalone-chart version.
- [extra-environment-variables](../../jfrog-platform/extra-environment-variables) — the double-nested form under `jfrog-platform`.
