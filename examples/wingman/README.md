# JFrog Wingman (MCP Server)

Wingman is JFrog's self-hosted MCP (Model Context Protocol) Server, exposing JFrog Platform capabilities to MCP-compatible clients over the platform's router.

## Examples

| Example | Description |
|---|---|
| [enable-beta-agreement](enable-beta-agreement) | Acknowledge the JFrog Online Beta Agreement required on the self-hosted install path |
| [external-database](external-database) | Point Wingman at an external PostgreSQL instead of the bundled one |
| [resource-sizing](resource-sizing) | Size the Wingman container's CPU and memory |

## Deploy

```shell
helm upgrade --install wingman jfrog/wingman \
  --set consentToJfrogOnlineBetaAgreement=true \
  --set jfrogUrl=https://<your-platform>
```

See the chart's [values.yaml](../../stable/wingman/values.yaml) for the full set of configuration options.