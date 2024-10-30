# Setting up a logging sidecar
Due to the nature of Artifactory running with many services, each writing multiple logs to the file system, it's hard to collect them all in a Kubernetes based deployment.<br>
The example in this directory has an example of using a [fluent-bit](https://fluentbit.io/) sidecar that collects all logs from Artifactory's `log/` directory and writes them to STDOUT in a nice json formatted way

See the [values-logging-fluent-bit.yaml](values-logging-fluent-bit.yaml) for the configuration example

## Deploy
Install Artifactory with the following command
```shell
helm upgrade --install artifactory jfrog/artifactory -f values-logging-fluent-bit.yaml
```

## Fluent-bit STDOUT
Once running, the `fluent-bit` sidecar tails the logs in the configured directories and outputs them to the container's STDOUT in a json format.<br>
Each line had a `"file"` key that lists the source file, which later can be used to separate the sources.<br>
The actual log line is in the `"log"` key.
```json
{"date":1683099717.440138,"file":"/var/opt/jfrog/artifactory/log/frontend-service.log","log":"2023-05-03T07:41:57.435Z [jffe ] [INFO ] [] [frontend-service.log] [main ] - pinging artifactory, attempt number 1"}
```

## Cluster log collector
Once this is setup, you need to configure your cluster log collector (probably running as a DaemonSet) to collect logs from this container only.