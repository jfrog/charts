# Enable Quorum Queues for RabbitMQ

This example shows how to enable RabbitMQ quorum queues for an Xray deployment.

See the [values-enable-quorum-queues-for-rabbitmq.yaml](values-enable-quorum-queues-for-rabbitmq.yaml) for the configuration example.

## Notes

* For a demo or lower environment, you can use quorum mode with `replicaCount: 1`.
* Downgrading RabbitMQ replicas from 3 to 1 is not supported. You can scale from 1 to 3; the Xray pre-upgrade hooks will grow the queues.

For more details, see the [Xray RabbitMQ Quorum Upgrade](https://docs.jfrog.com/installation/docs/xray-rabbitmq-quorum-upgrade) documentation.

## Deploy

Always apply a sizing file to provide the correct resources to the containers. Download a sizing configuration (for example, `xray-xsmall`):

```shell
curl -fsSL https://raw.githubusercontent.com/jfrog/charts/master/stable/xray/sizing/xray-xsmall.yaml \
  -o xray-xsmall.yaml
```

Install Xray with the following command:

```shell
helm upgrade --install xray jfrog/xray -f values-enable-quorum-queues-for-rabbitmq.yaml -f xray-xsmall.yaml
```
