# Worker Container Security Context

This example shows how to configure a security context on the `worker` and `router` containers using the `containerSecurityContext` values block.

`containerSecurityContext` is the supported way to control container-level security settings such as `runAsNonRoot`, `allowPrivilegeEscalation`, and dropped Linux capabilities. It is enabled by default with a sensible baseline; the values below show how to further restrict it by dropping the `NET_RAW` capability.

See the [container-security-context-values.yaml](container-security-context-values.yaml) for the configuration example.

## How it works

- `containerSecurityContext` is rendered into the Kubernetes `securityContext` field of both the `worker` and `router` containers in the Worker Deployment.
- `capabilities.drop` accepts a list of Linux capabilities to remove from the containers, in addition to `runAsNonRoot` and `allowPrivilegeEscalation`.

## Deploy

Install Worker with the following command:

```shell
helm upgrade --install worker jfrog/worker -f container-security-context-values.yaml
```

## Notes

- The older top-level `securityContext` key is no longer supported. Setting it causes `helm template`/`helm install` to fail with:
  ```
  .Values.securityContext is no longer supported and should be replaced with .Values.containerSecurityContext
  ```
  If you have `securityContext` set anywhere in your values, replace it with the equivalent `containerSecurityContext` keys shown in this example.
