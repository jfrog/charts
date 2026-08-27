# JFrog Worker

JFrog Worker lets you run custom serverless code (Workers) that react to events in the JFrog Platform — for example, before/after a repository upload or download, or on a schedule — without deploying and managing your own service.

Workers are written in JavaScript/TypeScript, run in an isolated sandbox, and are triggered by the JFrog Platform based on the events and permissions you configure for them. This chart deploys the Worker service, which hosts and executes those Workers.

See the [JFrog Workers documentation](https://docs.jfrog.com/administration/docs/workers-overview) for the full list of supported event types, quotas, and configuration options.

## Examples

| Example | Description |
| --- | --- |
| [global-values](global-values) | Configure Worker via the shared `global` values block (for example when deployed alongside Artifactory via `jfrog-platform`) |
| [extra-system-yaml](extra-system-yaml) | Override/extend `system.yaml` entries via `extraSystemYaml` |
| [container-security-context](container-security-context) | Configure `containerSecurityContext` on the worker/router containers (replaces the deprecated `securityContext` key) |
| [loggers](loggers) | Expose specific log files as sidecar containers via `loggers` for `kubectl logs`/log-collector visibility |

## Deploy

```shell
helm upgrade --install worker jfrog/worker \
  --set jfrogUrl=https://<your-jpd> \
  --set joinKey=<join-key> \
  --set masterKey=<master-key>
```

See the chart's [values.yaml](../../stable/worker/values.yaml) for the full set of configuration options.
