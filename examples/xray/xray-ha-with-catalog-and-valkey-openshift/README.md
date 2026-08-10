# Xray HA with Catalog and Valkey on OpenShift

This example shows how to deploy Xray in HA mode on OpenShift with Catalog, Valkey (with Sentinel), RabbitMQ quorum queues, and external PostgreSQL databases.

Update `global.jfrogUrl` and `global.joinKey` to match your Artifactory instance. The master key can be created separately for Xray. Update the database URLs/credentials and RabbitMQ password before using in any non-local environment.

See the [values-xray-ha-with-catalog-and-valkey-openshift.yaml](values-xray-ha-with-catalog-and-valkey-openshift.yaml) for the configuration example.

## Notes

* Security contexts are disabled and service accounts / RBAC are enabled for OpenShift restricted SCC defaults.
* For HA, apply a large sizing (or larger) where `minReplicas` is at least 2. Alternatively, turn off autoscaling and set the desired `replicaCount` for Xray.
* RabbitMQ HA should use quorum and should always have 3 replicas. For more details, see the [Xray RabbitMQ Quorum Upgrade](https://docs.jfrog.com/installation/docs/xray-rabbitmq-quorum-upgrade) documentation.
* Check the affinity settings in the sizing YAML. That is important to schedule pods on different nodes.
* Catalog uses Valkey with Sentinel for caching (`catalog.cache.enabled: true` and `valkey.enabled: true`).

## Deploy

Always apply a sizing file to provide the correct resources to the containers. For HA, download a large sizing configuration:

```shell
curl -fsSL https://raw.githubusercontent.com/jfrog/charts/master/stable/xray/sizing/xray-large.yaml \
  -o xray-large.yaml
```

Install Xray with the following command:

```shell
helm upgrade --install xray jfrog/xray -f values-xray-ha-with-catalog-and-valkey-openshift.yaml -f xray-large.yaml
```
