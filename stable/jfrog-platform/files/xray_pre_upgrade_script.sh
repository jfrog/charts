#!/bin/bash
rabbitMqZeroPodName="{{ .Release.Name }}-{{ template "rabbitmq.name" . }}-0"
rabbitMqZeroPodStatus=$(kubectl get pods $rabbitMqZeroPodName -n {{ .Release.Namespace }} -o jsonpath='{..status.conditions[?(@.type=="Ready")].status}')

rabbitMqStatefulSetsName=$(kubectl get statefulsets -n {{ .Release.Namespace }} -l "app.kubernetes.io/name={{ template "rabbitmq.name" . }},app.kubernetes.io/instance={{ .Release.Name }}" -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
if [ $? -ne 0 ]; then
    echo "Failed to get rabbitmq statefulset name"
    exit 1
fi
rabbitMqStatefulSetName=$(echo $rabbitMqStatefulSetsName | head -n 1)
if [ -z "$rabbitMqStatefulSetName" ]; then
    echo "Rabbitmq statefulset does not exist"
    exit 1
fi
currentImage=$(kubectl get statefulset $rabbitMqStatefulSetName -n {{ .Release.Namespace }} -o jsonpath='{.spec.template.spec.containers[?(@.name=="rabbitmq")].image}')
if [ $? -ne 0 ]; then
  echo "Failed to get current RabbitMQ image from StatefulSet"
  exit 1
fi
currentImageTag="${currentImage##*:}"
newImageTag="{{ .Values.rabbitmq.image.tag }}"

{{- if not .Values.rabbitmq.disableRabbitmqchecks }}
  {{- if hasPrefix "4." .Values.rabbitmq.image.tag }}
      {{- if not .Values.global.xray.rabbitmq.haQuorum.enabled }}
        echo -e "ERROR: Upgrade to RabbitMQ 4.x requires haQuorum to be enabled.\nPlease refer the official documentation to enable quorum queues and retry."
        exit 1
      {{- end }}
      if [[ "$currentImageTag" == 3.* ]]; then
        for i in {1..12}; do
          queue_list=$(kubectl exec -i "$rabbitMqZeroPodName" -n {{ .Release.Namespace }} -- bash -c 'rabbitmqctl list_queues -p {{ .Values.global.xray.rabbitmq.vhost }} --quiet 2>/dev/null')
          [ $? -ne 0 ] && echo "ERROR: Failed to list queues (kubectl or rabbitmqctl failed)." && exit 1
          queue_count=$(printf '%s\n' "$queue_list" | awk 'NF{c++} END{print c+0}')
          [ "${queue_count:-0}" -eq 0 ] && echo "No queues on vhost \"/\". Migration check passed." && break
          echo "Waiting 10s before next check (attempt $i/12) for quorum migration to complete"
          [ $i -eq 12 ] && echo -e "ERROR: Migration not complete ($queue_count queues on \"{{ .Values.global.xray.rabbitmq.vhost }}\").\nSee: https://jfrog.com/help/r/jfrog-installation-setup-documentation/quorum-queue-enablement-for-xray-and-platform-helm-charts" && exit 1
          sleep 10
        done
      fi
  {{- end }}
{{- else }}
  echo "Rabbitmq 4 checks are disabled."
{{- end }}

{{- if not .Values.rabbitmq.disableRabbitmqchecks }}
  {{- if not .Values.global.xray.rabbitmq.haQuorum.enabled }}
  echo "Checking for quorum queues in vhost {{ .Values.global.xray.rabbitmq.haQuorum.vhost }}..."
  count=$(kubectl exec -i "$rabbitMqZeroPodName" -n {{ .Release.Namespace }} -- bash -c "rabbitmqctl list_queues -p {{ .Values.global.xray.rabbitmq.haQuorum.vhost }} name type | awk '\$2 == \"quorum\" { c++ } END { print c+0 }'" 2>/dev/null) || { echo "ERROR: Failed to count quorum queues in vhost '{{ .Values.global.xray.rabbitmq.haQuorum.vhost }}' (kubectl or rabbitmqctl failed)"; exit 1; }
  echo "Quorum queue count: $count"
  if [[ "$count" -gt 0 ]]; then
    echo -e "ERROR: Existing quorum queues found in vhost '{{ .Values.global.xray.rabbitmq.haQuorum.vhost }}'.\n'.Values.global.xray.rabbitmq.haQuorum.enabled' is not set to true.\nPlease enable it to continue. Rollback to classic queues is not allowed."
    exit 1
  else
    echo "No quorum queues found in vhost '{{ .Values.global.xray.rabbitmq.haQuorum.vhost }}'. Proceeding with  the upgrade."
  fi
  {{- end }}
{{- else }}
  echo "Roll back to classic queues checks are disabled."
{{- end }}

{{- if and .Values.global.xray.rabbitmq.haQuorum.enabled .Values.rabbitmq.migration.removeHaPolicyOnMigrationToHaQuorum.enabled }}
for (( i=1; i<=6; i++ ))
do 
    if [ "$rabbitMqZeroPodStatus" = "True" ]; then
    break
    fi
    echo "Waiting for Rabbitmq zero pod $rabbitMqZeroPodName to be in Ready state - iteration $i"
    sleep 5
    rabbitMqZeroPodStatus=$(kubectl get pods $rabbitMqZeroPodName -n {{ .Release.Namespace }} -o jsonpath='{..status.conditions[?(@.type=="Ready")].status}')
done
if [ "$rabbitMqZeroPodStatus" != "True" ]; then
    echo "Rabbitmq zero pod $rabbitMqZeroPodName is not in Ready state. Failed to remove mirroring policy 'ha-all'"
    exit 1
fi
policyExists=$(kubectl exec -i $rabbitMqZeroPodName -n {{ .Release.Namespace }} -- bash -c "rabbitmqctl -p {{ .Values.global.xray.rabbitmq.vhost }} list_policies --formatter json | grep -o '\"name\":\"ha-all\"' | wc -l | tr -d '[:space:]'")
if [ "$?" -ne 0 ]; then
    echo "Failed to check if policy ha-all exists on {{ .Values.global.xray.rabbitmq.vhost }} vhost" 
    exit 1
fi
echo "Policy ha-all exists: $policyExists"
if [ $policyExists -gt 0 ]; then
    kubectl exec -i $rabbitMqZeroPodName -n {{ .Release.Namespace }} -- rabbitmqctl -p {{ .Values.global.xray.rabbitmq.vhost }} clear_policy ha-all
    if [ "$?" -ne 0 ]; then
    echo "Failed to delete policy ha-all on {{ .Values.global.xray.rabbitmq.vhost }} vhost"
    exit 1
    else
    echo "Deleted ha-all policy successfully on {{ .Values.global.xray.rabbitmq.vhost }} vhost"
    fi
fi
{{- end }}

{{- if .Values.rabbitmq.migration.enabled }}
if [ "$rabbitMqZeroPodStatus" = "True" ]; then
    kubectl exec -i $rabbitMqZeroPodName -n {{ .Release.Namespace }} -- rabbitmqctl enable_feature_flag all
    if [ "$?" -ne 0 ]; then
        echo "Failed to perform the migration. Please make sure to enable the feature flag in rabbitmq manually [rabbitmqctl enable_feature_flag all] " 
        exit 1
    else
        echo Feature flags executed successfully!
    fi
else
    echo "Rabbitmq zero pod is not in running state. Ignoring feature flag migration for rabbitmq"
fi
{{- end }}

{{- if .Values.rabbitmq.migration.deleteStatefulSetToAllowFieldUpdate.enabled }}
# Checking whether RMQ sts exist as we delete it with --cascade=orphan during upgrade
# If it exists proceed with the deletion and update the podManagementPolicy field
# else do nothing as the sts will be automatically created with updated podManagementPolicy during upgrade
if [ -n "$rabbitMqStatefulSetName" ] && [ -n "{{ .Values.rabbitmq.podManagementPolicy }}" ]; then
    currPodManagementPolicy=$(kubectl get statefulset $rabbitMqStatefulSetName -n {{ .Release.Namespace }} -o=jsonpath='{.spec.podManagementPolicy}')
    if [ $? -ne 0 ]; then
    echo "Failed to get current pod management policy definition"
    exit 1
    fi
    if [ "$currPodManagementPolicy" != "{{ .Values.rabbitmq.podManagementPolicy }}" ]; then
    kubectl delete statefulset $rabbitMqStatefulSetName --cascade=orphan -n {{ .Release.Namespace }}
    if [ $? -ne 0 ]; then
        echo "Failed to delete statefulset $rabbitMqStatefulSetName to allow update of podManagementDefinition field: [kubectl delete statefulset STATEFULSET_NAME --cascade=orphan]"
        exit 1
    fi
    echo "Deleted statefulset $rabbitMqStatefulSetName successfully"
    else
    echo "Field podManagementPolicy of statefulset $rabbitMqStatefulSetName has not changed"
    fi
else
    echo "rabbitmq.podManagementPolicy is not set"
fi
{{- end }}