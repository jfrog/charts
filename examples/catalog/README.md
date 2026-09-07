# JFrog Catalog

JFrog Catalog indexes and enriches metadata for packages and repositories across the platform, and can be deployed standalone or as the `catalog` subchart of `jfrog-platform`.

## Examples

| Example | Description |
|---|---|
| [custom-volumes](custom-volumes) | Mount extra volumes into the Catalog container via `extraVolumes`/`extraVolumeMounts` |
| [extra-system-yaml](extra-system-yaml) | Override/extend `system.yaml` entries via `extraSystemYaml` |
| [external-database](external-database) | Point Catalog at an external PostgreSQL database |
| [custom-trust-store](custom-trust-store) | Trust a custom CA certificate via `customCertificates` |

## Deploy

```shell
helm upgrade --install catalog jfrog/catalog \
  --set jfrogUrl=https://<your-jpd>
```

See the chart's [values.yaml](../../stable/catalog/values.yaml) for the full set of configuration options.