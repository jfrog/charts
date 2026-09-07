# Enable Advanced Security (JAS)

This example shows how to enable JFrog Advanced Security (JAS) on the Xray subchart.

See the [enable-advanced-security-jas-values.yaml](enable-advanced-security-jas-values.yaml) for the configuration example.

## How it works

- `xray.serviceAccount.create` and `xray.rbac.create` grant the Xray pod the ServiceAccount and RBAC permissions JAS needs to run its analysis workloads. Both default to `false`.
- `xray.jas.healthcheck.enabled` turns on the JAS health check endpoint used to verify the JAS services are running correctly.
- All three keys are chart-root keys on the `xray` subchart, so they carry the `xray.` prefix under `jfrog-platform` the same way they would on the standalone `xray` chart.

## Deploy

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f enable-advanced-security-jas-values.yaml
```

## References

- [Install JFrog Advanced Security on your self-hosted environment with Helm](https://jfrog.com/help/r/jfrog-installation-setup-documentation/install-jfrog-advanced-security-on-your-self-hosted-environment-with-helm)