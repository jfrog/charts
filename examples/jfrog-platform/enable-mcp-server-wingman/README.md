# Enable the MCP Server (Wingman)

This example shows how to enable JFrog's MCP Server, which ships as the `wingman` subchart on the self-hosted install path.

See the [enable-mcp-server-wingman-values.yaml](enable-mcp-server-wingman-values.yaml) for the configuration example.

## How it works

- `wingman.enabled: true` turns on the `wingman` subchart (disabled by default).
- Wingman currently ships as a beta feature. `wingman.consentToJfrogOnlineBetaAgreement: true` records that you've read and accepted the JFrog Online Beta Agreement, and must be a literal YAML boolean — the strings `"true"`/`"false"` or numbers `1`/`0` are not accepted.
- Wingman uses its own database credentials (`wingman.database.user`/`password`, both `wingman` by default) and does not deploy a dedicated PostgreSQL instance (`wingman.postgresql.enabled: false`) — it shares the platform's bundled PostgreSQL by default.

## Deploy

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-mcp-server-wingman-values.yaml
```