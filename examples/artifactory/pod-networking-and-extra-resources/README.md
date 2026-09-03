# Add Host Entries and Extra Manifests

Two unrelated escape hatches, both used when the cluster cannot give Artifactory something it needs. `hostAliases` adds entries to the pod's `/etc/hosts` when DNS cannot resolve a host; `additionalResources` deploys Kubernetes manifests of your own alongside the release.

See the [pod-networking-and-extra-resources-values.yaml](pod-networking-and-extra-resources-values.yaml) for the configuration example.

## How it works
- `hostAliases` writes entries straight into the pod's `/etc/hosts` — the usual fix in air-gapped clusters where an internal registry, LDAP server, or license service has no cluster DNS record. One IP can carry several hostnames, and the list can hold several entries.
- These are static records: when the target host moves to a new address, the pod keeps resolving the old one until the value is changed and the pods restart. This affects the Artifactory pod only, not the cluster's DNS — other workloads still cannot resolve those names.
- `additionalResources` takes raw Kubernetes YAML rendered through Helm's `tpl`, so template expressions (e.g. `{{ include "artifactory.fullname" . }}`) resolve against the release. Anything defined here is created and deleted with the release. The chart does not validate the content — a malformed manifest surfaces as a rejection from the Kubernetes API, not a Helm error, so render before deploying.
- Both settings sit at chart root with no defaults, and neither is validated by the chart — a value placed at the wrong nesting level is silently accepted by Helm and never applied.

## Deploy
```shell
helm upgrade --install artifactory jfrog/artifactory -f pod-networking-and-extra-resources-values.yaml
```

## Verify
```shell
kubectl exec <pod-name> -c artifactory -- cat /etc/hosts
kubectl exec <pod-name> -c artifactory -- getent hosts internal-registry.local
helm template artifactory jfrog/artifactory -f pod-networking-and-extra-resources-values.yaml | grep -A6 "kind: ConfigMap"
```

## Related
- [pod-networking-and-extra-resources](../../artifactory-ha/pod-networking-and-extra-resources) — the artifactory-ha version (every node receives the same host entries).
- [pod-networking-and-extra-resources](../../jfrog-platform/pod-networking-and-extra-resources) — the jfrog-platform umbrella-chart version.
