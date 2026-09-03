# JMX Monitoring and Filebeat Log Shipping

This example shows two independent monitoring mechanisms: enabling JMX access via `artifactory.javaOpts.jmx.enabled` to expose Artifactory's MBeans, and shipping logs to a central ELK-style collector via the bundled `filebeat` sidecar.

See the [monitoring-and-logging-values.yaml](monitoring-and-logging-values.yaml) for the configuration example.

## How it works
- `artifactory.javaOpts.jmx.enabled` turns on JMX on port `artifactory.javaOpts.jmx.port` (default `9010`), exposing MBeans under the `org.jfrog.artifactory` domain (repositories, executor pools, storage, HTTP connection pools). On `artifactory-ha`, the same keys nest one level deeper under `artifactory.primary.javaOpts.jmx.*`.
- To connect with `jconsole` or a similar tool from outside the cluster, also set `artifactory.service.type: LoadBalancer` and use `artifactory.javaOpts.jmx.host` to control the hostname JMX advertises.
- `filebeat.enabled` deploys a Filebeat sidecar that tails Artifactory's logs and forwards them to `filebeat.logstashUrl`. This is a **different** log-shipping mechanism from the [logging](../logging) example's fluent-bit sidecar — Filebeat integrates with an existing ELK/Logstash pipeline, while fluent-bit in the other example just reformats logs to the container's own STDOUT. Pick one, not both.
- `filebeat.filebeatYml` (not shown here) lets you replace the entire generated Filebeat config with your own, for outputs other than Logstash.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f monitoring-and-logging-values.yaml
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic.

## Related
See [logging](../logging) for the fluent-bit-based alternative to Filebeat.