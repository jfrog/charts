# JFrog Distribution

JFrog Distribution lets you take a Release Bundle from Artifactory and distribute it to any number of Edge nodes, in a controlled and trackable way.

## Examples

| Example | Description |
|---|---|
| [external-postgres](external-postgres) | Point Distribution at an external PostgreSQL instance instead of the bundled subchart |
| [custom-volumes](custom-volumes) | Mount a custom volume (for example a trust store) into the Distribution pod |
| [router-tls](router-tls) | Enable TLS on the router container |
| [legacy-migration-upgrade](legacy-migration-upgrade) | The mandatory `unifiedUpgradeAllowed` flag and the 1.x/2.x data migration job |

## Deploy

```shell
helm upgrade --install distribution jfrog/distribution \
  --set distribution.jfrogUrl=http://<your-artifactory>:8082 \
  --set unifiedUpgradeAllowed=true
```

See the chart's [values.yaml](../../stable/distribution/values.yaml) for the full set of configuration options.