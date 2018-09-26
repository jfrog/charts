# Lint charts locally
CHART_TESTING_TAG ?= v1.1.0
TEST_IMAGE_TAG ?= v2.0.5
CHARTS_REPO ?= https://github.com/rimusz/jfrog-charts
MAC_ARGS ?=

# If the first argument is "mac" or "gke"...
ifneq ( $(filter wordlist 1,mac gke), $(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "mac" or "gke"
  MAC_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(MAC_ARGS):;@:)
endif

.PHONY: lint
lint:
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	test/lint-charts.sh

.PHONY: mac
mac:
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	$(eval export CHART_TESTING_ARGS=${MAC_ARGS})
	test/e2e-docker4mac.sh

.PHONY: gke
gke:
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	$(eval export CHART_TESTING_ARGS=${MAC_ARGS})
	test/e2e-local-gke.sh
