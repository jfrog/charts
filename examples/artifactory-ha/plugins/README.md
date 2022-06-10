
# Adding plugins as a secret

You can deploy the user plugins as a Kubernetes Secret. You will need to download the plugins and create a secret out of it. 

1. Download the required plugins
```bash
wget https://raw.githubusercontent.com/jfrog/artifactory-user-plugins/master/cleanup/artifactCleanup/artifactCleanup.json
wget https://raw.githubusercontent.com/jfrog/artifactory-user-plugins/master/cleanup/artifactCleanup/artifactCleanup.groovy
```
**Note:** Refer plugins repository -> https://github.com/jfrog/artifactory-user-plugins/

2. Create the Kubernetes secret.

```bash
kubectl create secret generic cleanup --from-file=artifactCleanup.groovy  --from-file=artifactCleanup.json
```

3. Create a plugin-values.yaml
```
artifactory:
  ## List of secrets for Artifactory user plugins.
  ## One Secret per plugin's files.
  userPluginSecrets:
   - cleanup
  primary:
    preStartCommand: "mkdir -p {{ .Values.artifactory.persistence.mountPath }}/etc/artifactory/plugins/ && cp -Lrf /artifactory_bootstrap/plugins/* {{ .Values.artifactory.persistence.mountPath }}/etc/artifactory/plugins/"
```

**Note:** `artifactory.primary.preStartCommand` is used to copy and overwrite the files from (`/artifactory_bootstrap/plugins folder` ) to `/opt/jfrog/artifactory/var/etc/artifactory/plugins` everytime the pod is restarted.

4. Install with the plugin-values.yaml.
```
helm upgrade --install artifactory --namespace artifactory jfrog/artifactory-ha -f plugin-values.yaml
```
