# Beta Agreement Consent

Wingman currently ships as a beta feature on the self-hosted install path, and the chart refuses to render any resources until you explicitly acknowledge the JFrog Online Beta Agreement via `consentToJfrogOnlineBetaAgreement`. This example also shows `jfrogUrl` and `waitForArtifactory`, the two values that control whether Wingman waits for the platform router to be reachable before starting.

See the [enable-beta-agreement-values.yaml](enable-beta-agreement-values.yaml) for the configuration example.

## How it works

- `consentToJfrogOnlineBetaAgreement` must be the literal YAML boolean `true` — a missing key, `false`, the string `"true"`, or any other truthy value all fail the install at template time with the agreement URL in the error message. This gate only applies to self-hosted installs; SaaS deployments bypass it entirely.
- `jfrogUrl` is mandatory whenever `waitForArtifactory` is `true` (the default) — Wingman polls `<jfrogUrl>/router/api/v1/system/readiness` from an init container before starting, and an empty URL would otherwise hang forever.
- Set `waitForArtifactory: false` only for a standalone install that isn't fronted by a JFrog Platform.

## Deploy

```shell
helm upgrade --install wingman jfrog/wingman -f enable-beta-agreement-values.yaml
```

See the chart's [values.yaml](../../../stable/wingman/values.yaml) for the full set of configuration options.