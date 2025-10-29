# Deploying JFrog Xray

To deploy Xray, you can create a new custom-values.yaml file with the following content and then pass it during installation with the Helm upgrade command.

```yaml
xray:
  enabled: true
```

## Configuring JFrog Xray

You can configure JFrog Xray with the following steps:

1. View the main `values.yaml` file and copy the configurations that you wish to update into a `custom-values.yaml` file.
2. Update the product configuration with custom values in the `custom-values.yaml` file. For the values not specified in the `custom-values.yaml` file, the default values from the main `values.yaml` of the chart will be used.
3. Run the upgrade command.

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform  -f custom-values.yaml
```


## Deployment Models for Xray

### Monolith ( Xray Version 3.118.x and below )

- Architecture:

<img src="./images/non-split-architecture.png" alt="Non Split Architecture" width="400">

- All Xray services are running as separate containers in a single pod
- Please find the example custom values file here: [values-artifactory-xray.yaml](../../jfrog-platform/values/values-artifactory-xray.yaml)

### Pod Split ( Xray Version 3.124.x and above )

- Architecture:

<img src="./images/split-architecture.png" alt="Split Architecture" width="400">

- All Xray services are running as separate containers in dedicated pods.

#### Fresh Installation

1.  Set the below parameters to true

```bash
xray:
  enabled: true
  splitXraytoSeparateDeployments:
    fullSplit: true
```
2. Run the upgrade command.

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform  -f custom-values.yaml
```

3. Please find the example custom values file here: [values-artifactory-xray.yaml](./values-artifactory-xray.yaml)


#### Upgrading from Monolith to Pod Split

1. Set the below parameters to true. To prevent downtime, both the statefulset pod and deployment pods are kept together initially controlled by the `splitXraytoSeparateDeployments.gradualUpgrade` flag.

```bash
xray:
  enabled: true
  splitXraytoSeparateDeployments:
    fullSplit: true
    gradualUpgrade: true
```
2. Run the upgrade command.

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform  -f custom-values.yaml
```

3. Set the `splitXraytoSeparateDeployments.gradualUpgrade` to false which will remove statefulset pod and only keep the deployment pods

```bash
xray:
  enabled: true
  splitXraytoSeparateDeployments:
    fullSplit: true
    gradualUpgrade: false
```

4. Run the upgrade command.

```console
helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform  -f custom-values.yaml
```

5. Please find the example custom values file here: [values-artifactory-xray.yaml](./values-artifactory-xray.yaml)


## Autoscaling for Xray ( Pod Split )

1. By default, autoscaling is disabled for Xray services. 
2. To enable autoscaling, set the below values to true per service:

```bash
xray:
  enabled: true
# Enable autoscaling for all the individual microservices
  server:
    autoscaling:
      enabled: true

  analysis:
    autoscaling:
      enabled: true

  sbom:
    autoscaling:
      enabled: true

  policyenforcer:
    autoscaling:
      enabled: true

  indexer:
    autoscaling:
      enabled: true

  persist:
    autoscaling:
      enabled: true
```

3. Default autoscaling replica counts per service:

| Service | Min Replicas | Max Replicas |
|---------|--------------|--------------|
| server | 2 | 3 |
| analysis | 1 | 3 |
| sbom | 1 | 3 |
| policyenforcer | 1 | 3 |
| indexer | 1 | 3 |
| persist | 1 | 3 |

   > **Note:** These values are customizable. You can override `xray.<service>.autoscaling.minReplicas` and `xray.<service>.autoscaling.maxReplicas` for each service in your custom values file.

## Optional: KEDA for Queue-Based Autoscaling ( Pod Split )

1. You can optionally install KEDA for queue-based autoscaling.
2. Install KEDA in your cluster. For detailed instructions and maintenance, refer to the KEDA documentation: https://keda.sh/docs/2.18/deploy/
3. After installing KEDA, enable it in the Xray charts under the autoscaling section:

```bash
xray:
  enabled: true
# Enable keda for all the individual microservices
  server:
    autoscaling:
      enabled: true
      keda:
        enabled: true

  analysis:
    autoscaling:
      enabled: true
      keda:
        enabled: true

  sbom:
    autoscaling:
      enabled: true
      keda:
        enabled: true

  policyenforcer:
    autoscaling:
      enabled: true
      keda:
        enabled: true

  indexer:
    autoscaling:
      enabled: true
      keda:
        enabled: true

  persist:
    autoscaling:
      enabled: true
      keda:
        enabled: true
```