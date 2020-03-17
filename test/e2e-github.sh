#!/usr/bin/env bash

set -o errexit
set -o pipefail

main() {

    if [ -n "${GCLOUD_GKE_CLUSTER:-}" ]; then
        echo "PR is from main repo, running in GKE..."
        echo
        test/e2e-gke.sh
    else
        echo "PR is from fork, there is nothing to do there..."
        exit 0
    fi
}

main
