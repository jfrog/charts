# Stream Log Files with Logger Sidecars

This example shows how to stream specific Artifactory log files to container stdout on Artifactory HA using `artifactory.loggers`, so `kubectl logs` can read them without exec'ing into the pod.

See the [loggers-sidecar-values.yaml](loggers-sidecar-values.yaml) for the configuration example.

## How it works
- `artifactory.loggers` uses the same key and the same flat nesting as the standalone chart — it is **not** scoped under `artifactory.primary`, unlike `resources`/`javaOpts` (see [ha-resource-sizing](../ha-resource-sizing)).
- Each log file name listed gets its own sidecar container on every HA node's pod, named after the log file (e.g. `artifactory-service.log` becomes `artifactory-service-log`).
- Read a specific log via its sidecar: `kubectl logs <pod> --namespace artifactory-ha -c artifactory-service-log`.
- Each named logger adds a container to every pod, so list only the logs you actually watch.

## Deploy
```shell
helm upgrade --install artifactory-ha jfrog/artifactory-ha --namespace artifactory-ha -f loggers-sidecar-values.yaml
```

## Related
- [loggers-sidecar](../../artifactory/loggers-sidecar) — the standalone-chart version.
- [loggers-sidecar](../../jfrog-platform/loggers-sidecar) — the double-nested form under `jfrog-platform`.
