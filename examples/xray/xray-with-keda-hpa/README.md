# Xray with KEDA Autoscaling

This example shows how to deploy Xray with `fullSplit` (each microservice as its own Deployment) and override the sizing file's autoscaling to use [KEDA](https://keda.sh/) instead of the regular CPU/memory-based HPA.

See the [values-xray-with-keda-hpa.yaml](values-xray-with-keda-hpa.yaml) for the configuration example.

## Why KEDA fits Xray

* Xray scales horizontally (more pods), not vertically (bigger pods).
* Each Xray worker consumes a largely fixed/static number of messages at a time, so adding pods increases throughput roughly linearly with queue backlog.
* Queue-based KEDA autoscaling matches how Xray actually works: spin up more replicas when RabbitMQ queues grow, and scale back down when the work drains.

## How KEDA scales Xray pods

* `splitXraytoSeparateDeployments.fullSplit: true` deploys each microservice as its own Deployment (`server`, `analysis`, `indexer`, …).
* For each worker service with `autoscaling.keda.enabled: true`, the chart creates a KEDA `ScaledObject` that watches that service's RabbitMQ queues (`QueueLength` trigger; queue names/thresholds default from the chart's `values.yaml`).
* When messages in a watched queue exceed the queue threshold, KEDA adds replicas up to `maxReplicas`; when queues drain, it scales back down toward `minReplicas`.
* `server` is different: it has no RabbitMQ queue triggers, so KEDA scales it on CPU/memory instead.

## Notes

* KEDA must already be installed on the target cluster. See the [KEDA deployment docs](https://keda.sh/docs/2.10/deploy/).
* This file only sets `autoscaling`/`keda` blocks; it does not set each microservice's `enabled` flag. Whether a given microservice (e.g. `sbom`, `aiscanner`, `jascontextual`, `jasexposures`) is actually deployed is a separate decision — enable it in your base/sizing values as needed. The KEDA config here applies once that service is enabled.
* This file only overrides autoscaling; it does not set resource requests/limits. Apply it on top of a sizing file so containers still get correct resources.

## Prod sizing reference (min/max replicas)

The values below are JFrog's published prod sizing `minReplicas`/`maxReplicas` per tier, per microservice. [values-xray-with-keda-hpa.yaml](values-xray-with-keda-hpa.yaml) uses the `xlarge` row; pick a different tier's values here if that better matches your sizing file.

| Service | xsmall | small | medium | large | xlarge | 2xlarge |
|---|---|---|---|---|---|---|
| server | 2–3 | 2–3 | 2–4 | 2–4 | 2–7 | 2–7 |
| analysis | 1–3 | 1–3 | 1–4 | 1–4 | 1–7 | 1–7 |
| indexer | 1–3 | 1–3 | 1–4 | 1–4 | 1–7 | 1–7 |
| persist | 1–3 | 1–3 | 1–4 | 1–4 | 1–7 | 1–7 |
| policyenforcer | 1–3 | 1–3 | 1–4 | 1–4 | 1–7 | 1–7 |
| sbom | 1–3 | 1–3 | 1–4 | 1–4 | 1–7 | 1–7 |
| aiscanner | 1–3 | 1–3 | 1–3 | 1–3 | 1–3 | 1–3 |
| reporting | 1–3 | 1–3 | 1–4 | 1–4 | 1–7 | 1–7 |
| jascontextual | 1–10 | 1–10 | 1–10 | 1–10 | 1–10 | 1–10 |
| jasexposures | 1–10 | 1–10 | 1–10 | 1–10 | 1–10 | 1–10 |

> Autoscaling is disabled by default on `xsmall` (except `server`); the ranges above are what applies if you turn it on.

## Prod sizing reference (persistence / ephemeral storage size)

The values below are JFrog's published prod sizing storage size (`<service>.persistence.size`) per tier, per microservice. With `fullSplit`, each service runs as a Deployment whose data volume is an `emptyDir` and this value is its `sizeLimit`; no PVC is created. The data is ephemeral (lost on pod restart) and is backed by the node's disk, so each replica consumes up to this much node storage and total usage scales with `maxReplicas`. Disk IOPS and throughput come from the node, not from a storage class. In the monolith (StatefulSet) mode the same size would instead be a PVC via `common.persistence.size`.

| Service | xsmall | small | medium | large | xlarge |
|---|---|---|---|---|---|
| server | 100Gi | 100Gi | 100Gi | 100Gi | 100Gi |
| indexer | 200Gi | 200Gi | 200Gi | 200Gi | 200Gi |
| analysis | 200Gi | 200Gi | 200Gi | 200Gi | 200Gi |
| persist | 50Gi | 50Gi | 50Gi | 50Gi | 50Gi |
| policyenforcer | 50Gi | 50Gi | 50Gi | 50Gi | 50Gi |
| sbom | 200Gi | 200Gi | 200Gi | 200Gi | 200Gi |

Example override (applies on top of your sizing file):

```yaml
server:
  persistence:
    size: 100Gi
indexer:
  persistence:
    size: 200Gi
analysis:
  persistence:
    size: 200Gi
persist:
  persistence:
    size: 50Gi
policyenforcer:
  persistence:
    size: 50Gi
sbom:
  persistence:
    size: 200Gi
```

## Deploy

Always apply a sizing file to provide the correct resources to the containers:

```shell
curl -fsSL https://raw.githubusercontent.com/jfrog/charts/master/stable/xray/sizing/xray-large.yaml \
  -o xray-large.yaml
```

Install Xray with the following command:

```shell
helm upgrade --install xray jfrog/xray -f <your existing custom values> -f values-xray-with-keda-hpa.yaml -f xray-large.yaml
```
