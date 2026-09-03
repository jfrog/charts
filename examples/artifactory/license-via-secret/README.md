# Artifactory License via Kubernetes Secret

This example shows how to supply the Artifactory license from a pre-created Kubernetes Secret using `artifactory.license.secret` and `artifactory.license.dataKey`, instead of pasting the license key in plain text via `artifactory.license.licenseKey`.

See the [license-via-secret-values.yaml](license-via-secret-values.yaml) for the configuration example.

## How it works
- Create the Secret first: `kubectl create secret generic artifactory-license --from-file=artifactory.lic=./artifactory.lic`.
- `artifactory.license.secret` names the Secret; `artifactory.license.dataKey` names the data key inside it (must match the `--from-file=<dataKey>=...` name used above).
- The chart mounts the referenced key as `ARTIFACTORY_HOME/etc/artifactory.lic`, loaded at runtime — no rolling restart is required to rotate it, only recreating/patching the Secret and letting Artifactory pick it up.
- Use either `artifactory.license.secret` or `artifactory.license.licenseKey`, not both.

## Deploy
```shell
kubectl create secret generic artifactory-license --from-file=artifactory.lic=./artifactory.lic
helm upgrade --install artifactory jfrog/artifactory -f license-via-secret-values.yaml
```

> The Deploy command above supplies `global.masterKey`/`global.joinKey` via `--set` — every fresh Artifactory install requires them regardless of this example's topic.