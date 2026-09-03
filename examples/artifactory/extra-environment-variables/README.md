# Set Environment Variables via extraEnvironmentVariables

This example shows how to inject an environment variable into the Artifactory container using `artifactory.extraEnvironmentVariables`, the fastest way to set a single `system.yaml` value without editing `extraSystemYaml`.

See the [extra-environment-variables-values.yaml](extra-environment-variables-values.yaml) for the configuration example.

## How it works
- `artifactory.extraEnvironmentVariables` is a native YAML **list** of `name`/`value` pairs, rendered with `tpl (toYaml .)`. Quote every value, even numeric or boolean ones — Kubernetes environment variable values must be strings.
- To reach a `system.yaml` setting, prefix its dotted path with `JF_`, uppercase every segment, and join with underscores — e.g. `shared.security.bootstrapKeysReadTimeoutSecs` becomes `JF_SHARED_SECURITY_BOOTSTRAPKEYSREADTIMEOUTSECS`. An unrecognized variable name is accepted and silently ignored, so check the real `system.yaml` schema first.
- Not every variable needs the `JF_` prefix — the chart also reads some tuning values directly (for example `SERVER_XML_ARTIFACTORY_MAX_THREADS`) without going through `system.yaml`.
- This value only reaches the main Artifactory container. The `router` sidecar reads its own `router.extraEnvironmentVariables` instead, and `frontend`/`access` each have their own key too.
- Verify a variable landed by exec'ing into the pod: `kubectl exec <pod> -c artifactory -- env | grep JF_`.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f extra-environment-variables-values.yaml
```

## Related
- [extra-environment-variables](../../artifactory-ha/extra-environment-variables) — the same key on Artifactory HA.
- [extra-environment-variables](../../jfrog-platform/extra-environment-variables) — the double-nested form under `jfrog-platform`, plus Xray's differently-named, differently-shaped `extraEnvVars`.
- [extra-system-yaml](../extra-system-yaml) — the alternative, more powerful method for settings that don't fit a single environment variable.
