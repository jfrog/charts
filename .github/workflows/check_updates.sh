#!/bin/bash

set -euo pipefail
set -x

CHART_NAME="${CHART_NAME:-}"
FORCE_UPDATE="${FORCE_UPDATE:-false}"
UPDATES_AVAILABLE="false"
UPDATED_CHARTS=""
UPDATED_CHART_VERSIONS=""
UPDATED_APP_VERSIONS=""

# List of all charts
CHARTS=("artifactory-cpp-ce" "artifactory-ha" "artifactory-jcr" "artifactory-oss" "artifactory" "catalog" "distribution" "jfrog-platform" "worker" "xray")

if [ -n "$CHART_NAME" ]; then
  IFS=',' read -r -a CHARTS <<< "$CHART_NAME"
fi

# Function to get latest chart version from JFrog repo
get_latest_version() {
  local chart_name=$1
  helm search repo jfrog/$chart_name --output json | jq -r '.[0].version' 2>/dev/null || echo ""
}

# Function to get latest app version from JFrog repo
get_latest_app_version() {
  local chart_name=$1
  helm search repo jfrog/$chart_name --output json | jq -r '.[0].app_version' 2>/dev/null || echo ""
}

# Function to get current chart version from Chart.yaml
get_current_version() {
  local chart_path=$1
  yq '.version' "$chart_path/Chart.yaml" 2>/dev/null || echo ""
}

# Function to get current app version from Chart.yaml
get_current_app_version() {
  local chart_path=$1
  yq '.appVersion' "$chart_path/Chart.yaml" 2>/dev/null || echo ""
}

SKIPPED_CHARTS=""
SKIPPED_REASONS=""

for chart in "${CHARTS[@]}"; do
  chart_path="stable/$chart"
  if [ ! -d "$chart_path" ]; then
    echo "Chart path $chart_path does not exist, skipping."
    SKIPPED_CHARTS="${SKIPPED_CHARTS}${chart},"
    SKIPPED_REASONS="${SKIPPED_REASONS}${chart}: Directory not found in stable/\n"
    continue
  fi

  current_version=$(get_current_version "$chart_path")
  latest_version=$(get_latest_version "$chart")
  current_app_version=$(get_current_app_version "$chart_path")
  latest_app_version=$(get_latest_app_version "$chart")

  if [ -z "$latest_version" ]; then
    echo "No latest version found for $chart, skipping."
    SKIPPED_CHARTS="${SKIPPED_CHARTS}${chart},"
    SKIPPED_REASONS="${SKIPPED_REASONS}${chart}: No version found in JFrog repo\n"
    continue
  fi

  if [[ "$latest_version" != "$current_version" ]] || [[ "$latest_app_version" != "$current_app_version" ]] || [[ "$FORCE_UPDATE" == "true" ]]; then
    # Check if tag already exists
    RAW_TAG="$chart/$latest_version"
    FORMATTED_TAG="${RAW_TAG//\//-}"
    
    if git tag -l | grep -q "^$FORMATTED_TAG$" && [[ "$FORCE_UPDATE" != "true" ]]; then
      SKIPPED_CHARTS="${SKIPPED_CHARTS}${chart},"
      SKIPPED_REASONS="${SKIPPED_REASONS}${chart}: Tag $FORMATTED_TAG already exists\n"
    else
      UPDATES_AVAILABLE="true"
      UPDATED_CHARTS="${UPDATED_CHARTS}${chart},"
      UPDATED_CHART_VERSIONS="${UPDATED_CHART_VERSIONS}${latest_version},"
      UPDATED_APP_VERSIONS="${UPDATED_APP_VERSIONS}${latest_app_version},"
    fi
  else
    SKIPPED_CHARTS="${SKIPPED_CHARTS}${chart},"
    SKIPPED_REASONS="${SKIPPED_REASONS}${chart}: Already up to date (chart: $current_version, app: $current_app_version)\n"
  fi
done

# Set GitHub outputs
echo "updates-available=$UPDATES_AVAILABLE" >> "$GITHUB_OUTPUT"

# Prepare arrays for updated charts
IFS=',' read -r -a UPDATED_CHART_ARRAY <<< "${UPDATED_CHARTS%,}"
IFS=',' read -r -a UPDATED_VERSION_ARRAY <<< "${UPDATED_CHART_VERSIONS%,}"
IFS=',' read -r -a UPDATED_APP_VERSION_ARRAY <<< "${UPDATED_APP_VERSIONS%,}"

# Prepare arrays for skipped charts (unique charts only)
IFS=',' read -r -a SKIPPED_CHART_ARRAY <<< "${SKIPPED_CHARTS%,}"

# Output the markdown summary using here-doc

{
  echo "## Charts being updated"
  echo ""

  if [ "${#UPDATED_CHART_ARRAY[@]}" -gt 0 ]; then
    echo "| Chart             | Current Version | New Version | App Current Version | App New Version |"
    echo "|-------------------|-----------------|-------------|---------------------|-----------------|"
    for i in "${!UPDATED_CHART_ARRAY[@]}"; do
      chart="${UPDATED_CHART_ARRAY[$i]}"
      current_version=$(get_current_version "stable/$chart")
      latest_version="${UPDATED_VERSION_ARRAY[$i]}"
      current_app_version=$(get_current_app_version "stable/$chart")
      latest_app_version="${UPDATED_APP_VERSION_ARRAY[$i]}"
      printf '| %-17s | %-15s | %-11s | %-19s | %-15s |\n' \
        "$chart" "$current_version" "$latest_version" "$current_app_version" "$latest_app_version"
    done
  else
    echo "_No charts updated._"
  fi

  echo ""
  echo "## Skipped Charts"
  echo ""

  if [ "${#SKIPPED_CHART_ARRAY[@]}" -gt 0 ]; then
    echo "| Chart          | Status                                        | Current Version | App Version |"
    echo "|----------------|-----------------------------------------------|-----------------|-------------|"
    # Loop over skipped charts with reason lines
    # Use the SKIPPED_REASONS variable to get reason per chart
    while IFS= read -r line; do
      if [[ "$line" =~ ([^:]+):[[:space:]]*(.*) ]]; then
        chart="${BASH_REMATCH[1]}"
        reason="${BASH_REMATCH[2]}"
        if [ -d "stable/$chart" ]; then
          current_version=$(get_current_version "stable/$chart")
          current_app_version=$(get_current_app_version "stable/$chart")
          printf '| %-14s | %-45s | %-15s | %-11s |\n' "$chart" "$reason" "$current_version" "$current_app_version"
        else
          printf '| %-14s | %-45s | %-15s | %-11s |\n' "$chart" "$reason" "-" "-"
        fi
      fi
    done < <(printf '%b' "$SKIPPED_REASONS")
  else
    echo "_No charts skipped._"
  fi
} > summary.md

# Write the summary to GitHub output (using here-doc)
echo "update-summary<<EOF" >> "$GITHUB_OUTPUT"
cat summary.md >> "$GITHUB_OUTPUT"
echo "EOF" >> "$GITHUB_OUTPUT"

# Output skipped and updated charts lists (trim trailing commas)
SKIPPED_CHARTS=${SKIPPED_CHARTS%,}
UPDATED_CHARTS=${UPDATED_CHARTS%,}
UPDATED_CHART_VERSIONS=${UPDATED_CHART_VERSIONS%,}
UPDATED_APP_VERSIONS=${UPDATED_APP_VERSIONS%,}

echo "skipped-charts=$SKIPPED_CHARTS" >> "$GITHUB_OUTPUT"
echo "updated-charts=$UPDATED_CHARTS" >> "$GITHUB_OUTPUT"
echo "updated-chart-versions=$UPDATED_CHART_VERSIONS" >> "$GITHUB_OUTPUT"
echo "updated-app-versions=$UPDATED_APP_VERSIONS" >> "$GITHUB_OUTPUT"
