# Setting up a logging sidecar
Due to the nature of Xray running with many services, each writing multiple logs to the file system, it's hard to collect them all in a Kubernetes based deployment.<br>
The example in this directory has an example of using a [fluent-bit](https://fluentbit.io/) sidecar that collects all logs from Xray's `log/` directory and writes them to STDOUT in a nice json formatted way

See the [values-logging-fluent-bit.yaml](values-logging-fluent-bit.yaml) for the configuration example

## Deploy
Install Xray with the following command
```shell
helm upgrade --install xray jfrog/xray -f values-logging-fluent-bit.yaml
```

## Fluent-bit STDOUT
Once running, the `fluent-bit` sidecar tails the logs in the configured directories and outputs them to the container's STDOUT in a json format.<br>
Each line had a `"file"` key that lists the source file, which later can be used to separate the sources.<br>
The actual log line is in the `"log"` key.
```json
{"date":1700135001.943258,"file":"/var/opt/jfrog/xray/log/xray-server-service.log","log":"2023-11-16T11:43:21.942Z \u001b[33m[jfxr ]\u001b[0m \u001b[34m[INFO ]\u001b[0m [0e860ce4f1fd6552] [migrate:36                    ] [MainServer                      ] Data migration that should run always: starting for name V1_Update_Features_table"}
```

## Cluster log collector
Once this is setup, you need to configure your cluster log collector (probably running as a DaemonSet) to collect logs from this container only.