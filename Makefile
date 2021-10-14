# Lint charts locally
MAC_ARGS ?=
CHARTS_REPO ?= https://github.com/jfrog/charts
CHART_TESTING_IMAGE ?= releases-docker.jfrog.io/charts-ci
CHART_TESTING_TAG ?= v0.0.26
HELM_VERSION ?= v3.7.1

# If the first argument is "lint" or "mac" or "gke" or "kind"
ifneq ( $(filter wordlist 1,lint mac gke kind), $(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "lint" "mac" or "gke" or "kind"
  MAC_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(MAC_ARGS):;@:)
endif

# check for binaries
HELM_CMD := $(shell command -v helm 2> /dev/null)
KUBECTL_CMD := $(shell command -v kubectl 2> /dev/null)
KUBEVAL_CMD := $(shell command -v kubeval 2> /dev/null)
GCLOUD_CMD := $(shell command -v gcloud 2> /dev/null)

.PHONY: check-cli
check-cli: check-helm check-kubectl check-kubeval

.PHONY: check-helm
check-helm:
ifndef HELM_CMD
	$(error "$n$nNo helm command found! $n$nPlease download required helm binary.$n$n")
endif

.PHONY: check-kubectl
check-kubectl:
ifndef KUBECTL_CMD
	$(error "$n$nNo kubectl command found! $n$nPlease download required kubectl binary.$n$n")
endif

.PHONY: check-kubeval
check-kubeval:
ifndef KUBEVAL_CMD
	$(error "$n$nNo kubeval command found! $n$nPlease install: brew tap instrumenta/instrumenta && brew install kubeval $n$n")
endif

.PHONY: check-gcloud
check-gcloud:
ifndef GCLOUD_CMD
	$(error "$n$nNo gcloud command found! $n$nPlease download required gcloud SDK.$n$n")
endif

.PHONY: lint
lint: check-cli
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	$(eval export CHART_TESTING_ARGS=${MAC_ARGS})
	$(eval export HELM_VERSION)
	$(eval export LOCAL_RUN=true)
	test/lint-charts.sh

.PHONY: mac
mac:
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	$(eval export CHART_TESTING_ARGS=${MAC_ARGS})
	$(eval export LOCAL_RUN=true)
	test/e2e-docker4mac.sh

.PHONY: gke
gke: check-gcloud
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	$(eval export CHART_TESTING_ARGS=${MAC_ARGS})
	$(eval export LOCAL_RUN=true)
	test/e2e-local-gke.sh
