#!/usr/bin/env bash

readonly namespace=rt
readonly HELM="helm3"

install_helm3() {
    echo "Install Helm v${HELM_VERSION} cli"
    curl -s -O https://get.helm.sh/helm-v"${HELM_VERSION}"-linux-amd64.tar.gz
    tar -zxvf helm-v:"${HELM_VERSION}"-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm
    cp /usr/local/bin/helm /usr/local/bin/helm3
    echo
}

connect_to_cluster() {
    # shellcheck disable=SC2086
    echo $GCLOUD_SERVICE_KEY_CHARTS_CI | base64 --decode -i > $REPO_ROOT/gcloud-service-key.json
    # shellcheck disable=SC2086
    echo $GCLOUD_GKE_CLUSTER | base64 --decode -i > $REPO_ROOT/gke_cluster
    # shellcheck disable=SC1090,SC2086
    source $REPO_ROOT/gke_cluster

    gcloud auth activate-service-account --key-file "$REPO_ROOT"/gcloud-service-key.json >/dev/null 2>&1
    gcloud container clusters get-credentials "$CLUSTER_NAME" --project "$PROJECT_NAME" --zone "$CLOUDSDK_COMPUTE_ZONE"
}

deploy() {
    kubectl create ns ${namespace} || true
    # shellcheck disable=SC2086
    echo $RT_LICENSE | base64 --decode -i > "$REPO_ROOT"/artifactory.lic
    kubectl create secret generic artifactory-license -n ${namespace} --from-file="$REPO_ROOT"/artifactory.lic
    echo
    ${HELM} dep up stable/artifactory/
    ${HELM} upgrade --install artifactory --namespace ${namespace} stable/artifactory/ \
        --set nginx.enabled=false,postgresql.postgresqlPassword=password \
        --set artifactory.license.secret=artifactory-license,artifactory.license.dataKey=artifactory.lic \
        --set artifactory.joinKey=EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE,artifactory.masterKey=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    echo
    echo "Waiting for Artifactory to be ready!"
    kubectl rollout status statefulset/artifactory-postgresql -w -n ${namespace} --request-timeout="10m"
    kubectl rollout status statefulset/artifactory-artifactory -w -n ${namespace} --request-timeout="10m"
    kubectl get pods -n ${namespace}
    kubectl get svc -n ${namespace}
    echo
}

clean() {
    ${HELM} delete --namespace ${namespace} artifactory || true
    sleep 20
    kubectl delete ns ${namespace} --force --grace-period=0 || true
    sleep 10
}

main() {
    install_helm3
    connect_to_cluster
    if [[ "$(${HELM} list -n ${namespace} -f artifactory | grep -c artifactory)" -eq 1 ]]; then
        echo "Run clean up"
        clean
    fi
    deploy
}

main
