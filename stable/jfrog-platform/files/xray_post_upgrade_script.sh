#!/bin/bash
# This script is used to grow the quorum queues across all the replicas of RabbitMQ. In case the replica
# count is scaled up, the quorum queues need to be manually "grown" to the new nodes.

# A retry mechanism has been added to all the places where executing on the zeroth pod to account for
# scenarios where it is not running for any reason. This ensures that the job can complete successfully
# in the first attempt.

rabbitMqZeroPodName="{{ .Release.Name }}-{{ template "rabbitmq.name" . }}-0"

# Sleep for 30 seconds to ensure that all pods are scheduled by the k8s controller so that they don't get
# missed out while checking the pod status.
echo "Sleeping for 30 seconds to ensure all pods are scheduled"
sleep 30

# Getting the replica count from statefulset
replicaCount=$(kubectl get statefulset {{ .Release.Name }}-{{ template "rabbitmq.name" . }} -o jsonpath='{.spec.replicas}')

maxRetries=5

# Waiting for all pods to be in a running state
for (( retryCount=0; retryCount<maxRetries; retryCount++ )); do
podStatuses=$(kubectl get pods -l 'app.kubernetes.io/name={{ template "rabbitmq.name" . }},app.kubernetes.io/instance={{ .Release.Name }}' -o json | jq '[.items[].status.phase]')
podStatuses=($(echo "$podStatuses" | jq -r '.[]'))

numPods=${#podStatuses[@]}
if [ "$numPods" -ne "$replicaCount" ]; then
    echo "Not all pods are scheduled. Retrying in 30 seconds..."
    sleep 30
    continue
fi

allRunning=true
for status in "${podStatuses[@]}"; do
    if [[ "$status" != "Running" ]]; then
    allRunning=false
    break
    fi
done

if $allRunning; then
    echo "All pods are running. Exiting loop."
    break
fi

echo "Not all pods are 'Running'. Retrying in 30 seconds..."
sleep 30
done

if [[ $retryCount -eq $maxRetries ]]; then
    echo "Max retries reached while waiting for all pods to run."
    exit 1
fi

# Waiting for the RabbitMQ server in the zeroth pod to start as we want to execute all rabbitmqctl commands on it
for (( retryCount=0; retryCount<maxRetries; retryCount++ )); do
pingStatus=$(kubectl exec -i $rabbitMqZeroPodName -n {{ .Release.Namespace }} -c rabbitmq -- bash -c "rabbitmqctl ping" | grep "Ping succeeded")

if [ -n "$pingStatus" ]; then
    echo "Received ping from rabbitmq"
    break
fi

echo "RabbitMQ server not running in zeroth pod. Retrying in 30 seconds..."
sleep 30
done

if [[ $retryCount -eq $maxRetries ]]; then
echo "Max retries reached while waiting for RabbitMQ server to run in the zeroth pod"
exit 1
fi

# Waiting for RabbitMQ server to start running in all expected replicas and be a part of the cluster.
for (( retryCount=0; retryCount<maxRetries; retryCount++ )); do
runningNodeCount=$(kubectl exec -i $rabbitMqZeroPodName -n {{ .Release.Namespace }} -c rabbitmq -- bash -c "rabbitmqctl cluster_status --formatter=json" | jq .running_nodes | jq '. | length')

if [ "$replicaCount" -eq "$runningNodeCount" ]; then
    echo "RabbitMQ server running on expected number of replicas"
    break
fi

echo "RabbitMQ server not running in expected number of replicas. Retrying in 30 seconds..."
sleep 30
done

if [[ $retryCount -eq $maxRetries ]]; then
echo "Max retries reached while waiting for RabbitMQ server to run in all replicas"
exit 1
fi

# Getting the queues which are not replicated across all nodes
for (( retryCount=0; retryCount<maxRetries; retryCount++ )); do
queuesInfo=$(kubectl exec -i $rabbitMqZeroPodName -n {{ .Release.Namespace }} -c rabbitmq -- bash -c "rabbitmqctl list_queues name,members --vhost={{ .Values.global.xray.rabbitmq.haQuorum.vhost }} --formatter=json")
if [ $? -ne 0 ]; then
    echo "Failed to exec rabbitmqctl command to get minimum member count for queues. Retrying in 30 seconds..."
    sleep 30
    continue
fi

minMemberCount=$(echo $queuesInfo | jq '[.[] | select(.name != "aliveness-test") | .members | length] | min')
# queuesInfo can return an empty array if rabbitmq is not started yet
# In that case minMemberCount will be null. This handles that scenario
if [[ "$minMemberCount" -eq "null" ]]; then
    echo "Failed to get minimum member count for queues. Retrying in 30 seconds..."
    sleep 30
    continue
fi

echo "Minimum member count for queues is $minMemberCount, expected is $replicaCount"
break
done

if [[ $retryCount -eq $maxRetries ]]; then
echo "Max retries reached while waiting for minimum member count for queues"
exit 1
fi

if [ "$minMemberCount" -eq "$replicaCount" ]; then
echo "All queues are running with the expected number of replicas. No queues to grow. Exiting."
exit 0
fi

echo "Need to grow the queues as minimum replica count for queues is $minMemberCount"

for ((i = $minMemberCount + 1; i <= runningNodeCount && i <= 3; i++)); do
echo "Growing node rabbit@{{ .Release.Name }}-{{ template "rabbitmq.name" . }}-$(($i-1))"

for ((j = 0; j < 5; j++)); do
    kubectl exec -i $rabbitMqZeroPodName -n {{ .Release.Namespace }} -c rabbitmq -- bash -c "rabbitmq-queues grow rabbit@{{ .Release.Name }}-{{ template "rabbitmq.name" . }}-$(($i-1)).{{ .Release.Name }}-{{ template "rabbitmq.name" . }}-headless.{{ .Release.Namespace }}.svc.cluster.local all --vhost-pattern={{ .Values.global.xray.rabbitmq.haQuorum.vhost }} --queue-pattern \"(.*)\""
    if [ $? -ne 0 ]; then
    echo "Error growing queues on node rabbit@{{ .Release.Name }}-{{ template "rabbitmq.name" . }}-$(($i-1)), retrying in 30 seconds"
    sleep 30
    else
    echo "Queues grown successfully on node rabbit@{{ .Release.Name }}-{{ template "rabbitmq.name" . }}-$(($i-1))"
    break
    fi
done
done