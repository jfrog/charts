# Lint charts locally
CHART_TESTING_TAG ?= v1.0.3
CHARTS_REPO ?= https://github.com/rimusz/charts-testing-travisci

.PHONY: lint
lint:
	helm lint stable/*
	@echo "--------------------------------------------------------------------------------"
	@echo
	$(eval export CHART_TESTING_TAG)
	$(eval export CHARTS_REPO)
	test/lint-charts.sh
