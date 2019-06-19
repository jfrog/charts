# Lint charts locally
MAC_ARGS ?=
CHARTS_REPO ?= https://github.com/jfrog/charts
CHART_TESTING_IMAGE ?= quay.io/helmpack/chart-testing
CHART_TESTING_TAG ?= v2.3.3
TEST_IMAGE_TAG ?= v3.3.2
K8S_VERSION ?= v1.14.2
KIND_VERSION ?= v0.3.0

# If the first argument is "lint" or "mac" or "gke" or "kind"
ifneq ( $(filter wordlist 1,lint mac gke kind), $(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "lint" "mac" or "gke" or "kind"
  MAC_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(MAC_ARGS):;@:)
endif

.PHONY: lint
lint:
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	$(eval export CHART_TESTING_ARGS=${MAC_ARGS})
	test/lint-charts.sh

.PHONY: mac
mac:
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	$(eval export CHART_TESTING_ARGS=${MAC_ARGS})
	test/e2e-docker4mac.sh

.PHONY: gke
gke:
	$(eval export TEST_IMAGE_TAG)
	$(eval export CHARTS_REPO)
	$(eval export CHART_TESTING_ARGS=${MAC_ARGS})
	test/e2e-local-gke.sh

.PHONY: kind
kind:
	$(eval export CHART_TESTING_IMAGE)
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	$(eval export K8S_VERSION)
	$(eval export KIND_VERSION)
	$(eval export CHART_TESTING_ARGS=${MAC_ARGS})
	$(eval export LOCAL_RUN=true)
	test/e2e-kind.sh
