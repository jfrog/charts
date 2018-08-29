# Lint charts locally
CHART_TESTING_TAG ?= v1.0.3
CHARTS_REPO ?= https://github.com/jfrog/charts

.PHONY: lint
lint:
	helm lint stable/*
	@echo "--------------------------------------------------------------------------------"
	@echo
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	test/lint-charts.sh

.PHONY: test
test:
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	test/e2e-docker4mac.sh
