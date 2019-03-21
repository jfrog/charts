# JFrog KubeXray scanner on Kubernetes Helm Chart

[KubeXray](https://github.com/jfrog/kubexray) is an open source software project that monitors pods in a Kubernetes cluster to help you detect security & license violations in containers running inside the pod. 

KubeXray listens to events from Kubernetes API server, and leverages the metadata from JFrog Xray (commercial product) to ensure that only the pods that comply with your current policy can run on Kubernetes.

## Prerequisites Details

* Kubernetes 1.10+

## Chart Details

This chart will do the following:

* Deploy JFrog KubeXray

## Requirements

- A running Kubernetes cluster
- Running Artifactory and Xray
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and setup to use the cluster
- [Helm](https://helm.sh/) installed and setup to use the cluster (helm init)
- Configuration file `xray_config.yaml` with Xray server connection settings:

```
url: https://xray.mydomain.com
user: admin
password: password
slackWebhookUrl: ""
xrayWebhookToken: ""
```

**Note:** Configuration file `xray_config.yaml` must be provided.

## Configuration

### Slack notifications

Notification by Slack can be enabled by providing `slackWebhookUrl`:

```
url: https://xray.mydomain.com
user: admin
password: password
slackWebhookUrl: https://hooks.slack.com/services/your_slack_webhook_url 
xrayWebhookToken: ""
```

### Enable KubeXray WebHook

If you want KubeXray to react on Xray policy changes generate `xrayWebhooToken` with `openssl rand -base64 64 | tr -dc A-Za-z0-9`:

```
url: https://xray.mydomain.com
user: admin
password: password
slackWebhookUrl: https://hooks.slack.com/services/your_slack_webhook_url 
xrayWebhookToken: replace_with_generated_token
```

**Note:** Also you need to add `kubexray_url` your generated `xrayWebhooToken` to your Xray server under `Admin/Webhooks`.

## Install JFrog KubeXray

### Add JFrog Helm repository

Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io/) to your helm client

```
helm repo add jfrog https://charts.jfrog.io
```

### Install Chart

#### Install JFrog KubeXray

```
helm upgrade --install kubexray --namespace kubexray jfrog/kubexray \
    --set xrayConfig="$(cat path_to_your/xray_config.yaml | base64)"
```

#### Installing with existing secret

You can deploy the KubeXray configuration file `xray_config.yaml` as a [Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/).


Create the Kubernetes secret

```
kubectl create secret generic kubexray --from-file=path_to_your/xray_config.yaml
```

Pass the configuration file to helm

```
 helm upgrade --install kubexray --namespace kubexray jfrog/kubexray \
    --set existingSecret="kubexray"
```

**NOTE:** You have to keep passing the configuration file secret parameter as `--set existingSecret="kubexray"` on all future calls to `helm install` and `helm upgrade` or set it in `values.yaml` file `existingSecret: kubexray`!

## Status

See the status of your deployed **helm** release

```
helm status kubexray
```

## Upgrade

E.g you have changed scan policy rules and to need upgrade an existing kubexray release

```
helm upgrade --install kubexray --namespace kubexray jfrog/kubexray \
    --set xrayConfig="$(cat path_to_your/xray_config.yaml | base64)"
```

Upgrading with existing secret

```
helm upgrade --install kubexray --namespace kubexray jfrog/kubexray \
    --set existingSecret="kubexray"
```

## Remove

Removing a **helm** release is done with

```
# Remove the Xray services and data tools
helm delete --purge kubexray
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the xray chart and their default values.

|         Parameter            |                    Description                   |           Default                  |
|------------------------------|--------------------------------------------------|------------------------------------|
| `image.PullPolicy`           | Container pull policy                            | `IfNotPresent`                     |
| `xrayConfig`                 | base64 encoded `xray_config.yaml` file           | ``                                 |
| `existingSecret`             | Specifies an existing secret holding the Xray config | ``                             |
| `scanPolicy.unscanned.whitelistNamespaces` | Specifies unscanned violations whitelist Namespaces list | `kube-system,kubexray` |
| `scanPolicy.unscanned.deployments`         | Specifies unscanned Deployments policy     | `ignore`                   |
| `scanPolicy.unscanned.statefulSets`        | Specifies unscanned StatefulSets policy    | `ignore`                   |
| `scanPolicy.security.whitelistNamespaces`  | Specifies security violations whitelist Namespaces list | `kube-system,kubexray` |
| `scanPolicy.security.deployments`          | Specifies Deployments with security issues policy   | `ignore`          |
| `scanPolicy.security.statefulSets`         | Specifies Deployments with security issues policy   | `ignore`          |
| `scanPolicy.license.whitelistNamespaces`   | Specifies license violations whitelist Namespaces list | `kube-system,kubexray` |
| `scanPolicy.license.deployments`           | Specifies Deployments with license issues policy   | `ignore`           |
| `scanPolicy.license.statefulSets`          | Specifies StatefulSets with license issues policy  | `ignore`           |
| `securityContext.enabled`                  | Enables Security Context  | `true`                                      |
| `securityContext.kubeXrayUserId`           | Security UserId           | `1000`                                      |
| `securityContext.kubeXrayGroupId`          | Security GroupId          | `1000`                                      |
| `service.port`                             |  Service port             | `80`                                        |
| `service.type`                             |  Service type             | `ClusterIP`                                 |
| `service.loadBalancerIP`                   |  Loadbalancer IP          | ``                                          |
| `service.externalTrafficPolicy`            | External traffic policy   | `Cluster`                                   |
| `ingress.enabled`           | If true, Webhook REST API Ingress will be created | `false`                            |
| `ingress.annotations`       | Webhook REST API Ingress annotations     | `{}`                                        |
| `ingress.hosts`             | Webhook REST API Ingress hostnames       | `[]`                                        |
| `ingress.tls`               | Webhook REST API Ingress TLS configuration (YAML) | `[]`                               |
| `ingress.defaultBackend.enabled` | If true, the default `backend` will be added using serviceName and servicePort | `true` |
| `ingress.annotations`       | Ingress annotations, which are written out if annotations section exists in values. Everything inside of the annotations section will appear verbatim inside the resulting manifest. See `Ingress annotations` section below for examples of how to leverage the annotations, specifically for how to enable docker authentication. | `` |
| `ingress.labels`              | KubeXray Ingress labels                  `{}`                                        |
| `env.logLevel`              | Logs level                               | `INFO`                                      |
| `resources.limits.cpu`      | Specifies CPU limit                      | `256m`                                      |
| `resources.limits.memory`   | Specifies memory limit                   | `128Mi`                                     |
| `resources.requests.cpu`    | Specifies CPU request                    | `100m`                                      |
| `resources.requests.memory` | Specifies memory request                 | `128Mi`                                     |
| `rbac.enabled`              | Specifies whether RBAC resources should be created | `true`                            |
| `nodeSelector`              | kubexray micro-service node selector     | `{}`                                        |
| `tolerations`               | kubexray micro-service node tolerations  | `[]`                                        |
| `affinity`                  | kubexray micro-service node affinity     | `{}`                                        |
| `podDisruptionBudget.enabled`        | Enables Pod Disruption Budget   | `false`                                     |
| `podDisruptionBudget.maxUnavailable` | Max unavailable Pods            | `1`                                         |
| `podDisruptionBudget.minAvailable`   | min unavailable Pods            | ``                                          |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install/upgrade`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example

```
helm upgrade --install kubexray --namespace kubexray jfrog/kubexray \
    --set existingSecret="kubexray",existingSecretKey="xray_config.yaml" -f override-values.yaml 
```

## Testing external access to KubeXray Webhook REST API

**Note:** Use this approach only for testing purposes, do not run it in production.

```
helm upgrade --install kubexray --namespace kubexray jfrog/kubexray \
    --set xrayConfig="$(cat path_to_your/xray_config.yaml | base64)" \
    --set service.type=LoadBalancer
```

Or you can set it up in a section `Webhook REST API Service` of your custom `override-values.yaml` file:

```
# Webhook REST API Service
service:
  type: LoadBalancer
```

Then run:

```
helm upgrade --install kubexray --namespace kubexray jfrog/kubexray \
    --set xrayConfig="$(cat path_to_your/xray_config.yaml | base64)" -f override-values.yaml 
```

It may take a few minutes for the LoadBalancer IP to be available.
Get Loadbalancer external IP:

```
kubectl -n kubexray get service kubexray

NAME       TYPE           CLUSTER-IP     EXTERNAL-IP  PORT(S)          AGE
kubexray   LoadBalancer   10.48.15.135   35.29.1.22   80:30925/TCP     2m
```

And the add IP `35.29.1.22` to your Xray server under `Admin/Webhooks` section.

## Ingress

This chart also provides support for [ingress resources](https://kubernetes.io/docs/concepts/services-networking/ingress/#what-is-ingress) which can be used to serve KubeXray Webhook REST API.
The examples below will show you how to setup [ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-controllers) and use TLS certificates from the [Let's Encrypt](https://letsencrypt.org/getting-started/).

### Ingress Controller

We are going to install [nginx-ingress](https://kubeapps.com/charts/stable/nginx-ingress) as our ingress controller:

```
helm upgrade --install nginx-ingress --namespace nginx-ingress stable/nginx-ingress
```

It may take a few minutes for the LoadBalancer IP to be available.
Get Loadbalancer external IP:

```
kubectl -n nginx-ingress get service nginx-ingress-controller

NAME                       TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)     bbbb             AGE
nginx-ingress-controller   LoadBalancer   10.48.14.142   14.97.14.15   80:30971/TCP,443:30358/TCP   2m
```

Update your domain DNS A record `kubexray.mydomain.com` with the external IP `14.97.14.15`.

And then add `kubexray.mydomain.com` to your Xray server under `Admin/Webhooks` section.

### TLS certificates from the Let's Encrypt

To retrieve TLS cert from the Let's Encrypt we are going to use [JetStack's cert-manager](https://github.com/helm/charts/tree/master/stable/cert-manager):

```
helm install --name cert-manager --namespace cert-manager stable/cert-manager
```

Then deploy the cert-manager [cluster issuer](http://docs.cert-manager.io/en/latest/reference/clusterissuers.html):

```
cat <<EOF | kubectl create -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: YOUR@EMAIL.ADDRESS
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    http01: {}
EOF
```

This will allow automatic creation/retrieval/renewal of TLS certificates from Let's Encrypt.

### Enabling Ingress

To enable `ingress` create a file `override-values.yaml` with the content below:

```
# Override values for KubeXray.

# Set kubexray scanning policy
scanPolicy:
  unscanned:
    # Whitelist namespaces
    whitelistNamespaces: "kube-system,kubexray,cert-manager,nginx-ingress"

# Webhook REST API ingress
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true" 
    ingress.kubernetes.io/force-ssl-redirect: "true"
    certmanager.k8s.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      set $x_auth_token 0;
      more_set_headers "X-Auth-Token: $x_auth_token";
    nginx.ingress.kubernetes.io/whitelist-source-range: "whitelisted IP list"

  path: /
  hosts:
    - kubexray.example.com
  tls:
    - secretName: kubexray.example.com
      hosts:
        - kubexray.example.com
```

Then run:

```
helm upgrade --install kubexray --namespace kubexray jfrog/kubexray \
    --set xrayConfig="$(cat path_to_your/xray_config.yaml | base64)" -f override-values.yaml 
```

In a few minutes you should have TLS certificate from the the Let's Encrypt, then all the traffic to `kubexray.example.com` will be served
with TLS.
