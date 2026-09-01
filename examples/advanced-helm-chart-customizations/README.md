# Advanced Helm Chart Customizations

The per-chart `examples/` folders (`artifactory`, `artifactory-ha`, `jfrog-platform`, and others) cover one chart at a time. Several customizations, though, are really the *same* feature applied to multiple charts with a different key path in each — the standalone-vs-platform nesting rule, custom volumes, TLS, resource/JVM sizing, licensing, PostgreSQL passwords, in-pod service toggles, custom init containers/sidecars/secrets, and more. Each topic below lays those variants out side by side, one collapsible `<details>` section per applicable chart, each with its own complete, deployable values file — so you can see how the same concept differs by chart without cross-referencing multiple directories.

This folder is additive: every per-chart scenario these topics touch on still exists in its own `examples/<chart>/` folder too, and each side cross-links to the other.

## Topics

| Topic | Applies to | Description |
|---|---|---|
| [platform-vs-standalone-nesting](platform-vs-standalone-nesting) | Artifactory, Artifactory HA, JFrog Platform | The general translation rule for umbrella-chart nesting, worked through with JVM heap and the Nginx TLS secret |
| [custom-volumes-across-products](custom-volumes-across-products) | Artifactory, Artifactory HA, Catalog, Distribution, JFrog Platform | Per-product custom-volume key paths, value types, and mount scopes |
| [tls-across-products](tls-across-products) | Artifactory, Artifactory HA, RabbitMQ (Xray), JFrog Platform | The Access-CA + Nginx/router TLS model applied per chart |
| [resource-and-jvm-sizing-across-products](resource-and-jvm-sizing-across-products) | Artifactory, Artifactory HA, JFrog Platform | Container resources and JVM heap nesting per chart |
| [licensing-across-products](licensing-across-products) | Artifactory, Artifactory HA, JFrog Platform | License-via-Secret key nesting, plus HA's per-node license requirement |
| [postgres-password-management-across-products](postgres-password-management-across-products) | Artifactory, Artifactory HA, Catalog, Distribution, Wingman, JFrog Platform | Bundled vs. external PostgreSQL credential shape per chart |
| [enable-disable-platform-services](enable-disable-platform-services) | Artifactory, Artifactory HA, JFrog Platform | Toggling the in-pod services (`frontend`, `observability`, `platformfederation`, etc.) that run inside the Artifactory process |
| [circle-of-trust-certificates-across-products](circle-of-trust-certificates-across-products) | Artifactory, Artifactory HA, JFrog Platform | Trusting another JPD's root certificate for Access Federation via `circleOfTrustCertificatesSecret` |
| [custom-init-containers-across-products](custom-init-containers-across-products) | Artifactory, Artifactory HA, JFrog Platform | Injecting custom init containers before/after the chart's built-in ones |
| [custom-sidecars-across-products](custom-sidecars-across-products) | Artifactory, Artifactory HA, JFrog Platform | Adding a utility sidecar container via `customSidecarContainers` |
| [frontend-jfbus-jfmelt-deployment-modes](frontend-jfbus-jfmelt-deployment-modes) | Artifactory, Artifactory HA | Reverting Frontend to in-pod mode and customizing its standalone Deployment |
| [extra-system-yaml-across-products](extra-system-yaml-across-products) | Artifactory, Artifactory HA, JFrog Platform | Reaching settings `values.yaml` doesn't expose directly, via `extraSystemYaml`/`extraEnvironmentVariables`/`systemYamlOverride` |
| [custom-secrets-across-products](custom-secrets-across-products) | Artifactory, Artifactory HA, JFrog Platform | Creating a chart-managed Secret from inline `values.yaml` data via `customSecrets` |
| [unified-secret-across-products](unified-secret-across-products) | Artifactory, Artifactory HA, JFrog Platform | Consolidating chart-managed secrets into one Kubernetes Secret via `unifiedSecretInstallation` |

## Deploy

Each topic's `### <Chart>` section links its own values file and the exact `helm upgrade --install` command for that chart. See the chart's own values.yaml for the full set of options: [artifactory](../../stable/artifactory/values.yaml), [artifactory-ha](../../stable/artifactory-ha/values.yaml), [jfrog-platform](../../stable/jfrog-platform/values.yaml).