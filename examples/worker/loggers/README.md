# Worker Loggers

This example shows how to expose specific Worker/Router log files as sidecar containers using the `loggers` value, so they can be viewed with `kubectl logs` or picked up by a log collector without exec'ing into the pod.

See the [loggers-values.yaml](loggers-values.yaml) for the configuration example.

## How it works

- For each log file name listed in `loggers`, the chart adds an extra sidecar container to the Worker Deployment (named after the log file, e.g. `worker-service.log` becomes the `worker-service-log` container) that tails that log file.
- The available logger names are:
  - `router-request.log`
  - `router-service.log`
  - `router-traefik.log`
  - `worker-service.log`
  - `worker-request.log`
- Resource requests/limits for these sidecars can be set with `loggersResources`.

## Deploy

Install Worker with the following command:

```shell
helm upgrade --install worker jfrog/worker -f loggers-values.yaml
```

## Notes

- Once deployed, view a given logger's output with `kubectl logs <worker-pod> -c <logger-container>` (for example `kubectl logs <worker-pod> -c worker-service-log`).
- Any log collector that scrapes container stdout in the cluster will automatically pick up these sidecars' output as well.
