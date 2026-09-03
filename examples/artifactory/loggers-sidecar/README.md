# Stream Log Files with Logger Sidecars

This example shows how to stream specific Artifactory log files to container stdout using `artifactory.loggers`, so `kubectl logs` can read them without exec'ing into the pod.

See the [loggers-sidecar-values.yaml](loggers-sidecar-values.yaml) for the configuration example.

## How it works
- `artifactory.loggers` takes a list of log file names. Each one gets its own lightweight sidecar container that tails that file — the container is named after the log file, e.g. `artifactory-service.log` becomes the `artifactory-service-log` container.
- Read a specific log via its sidecar: `kubectl logs <pod> -c artifactory-service-log`. List every logger container on a pod with `kubectl get pod <pod> -o jsonpath='{.spec.containers[*].name}'`.
- Each named logger adds a container to every Artifactory pod, so list only the logs you actually watch — a long list makes pods noticeably heavier.
- Nginx has the same mechanism under a separate key, `nginx.loggers`, for its own log files.
- This is meant for `kubectl logs`-style ad hoc viewing. To ship logs to an external system instead, use Filebeat (see [monitoring-and-logging](../monitoring-and-logging)) rather than a sidecar per file.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f loggers-sidecar-values.yaml
```

## Related
- [loggers-sidecar](../../artifactory-ha/loggers-sidecar) — the same mechanism on Artifactory HA.
- [loggers-sidecar](../../jfrog-platform/loggers-sidecar) — the double-nested form under `jfrog-platform`.
- [plugins](../plugins) — the other half of this chart's "extensions" mechanism (`userPluginSecrets`), a related but distinct feature.
- [monitoring-and-logging](../monitoring-and-logging) — shipping logs to Filebeat/an external system instead of per-file sidecars.
