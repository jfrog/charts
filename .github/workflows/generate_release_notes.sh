#!/bin/bash
# generate_release_notes.sh
#
# Generates structured GitHub Release notes for JFrog Helm charts, using
# charts.jfrog.io as the single source of truth.
#
# All version, dependency, appVersion and changelog data is pulled from the
# published Helm repository:
#   - https://charts.jfrog.io/index.yaml          (versions, deps, appVersion)
#   - the per-version .tgz packages                (CHANGELOG.md)
# Nothing is read from git history or tags.
#
# For individual charts: emits the CHANGELOG.md entry for the released version.
# For jfrog-platform: diffs every dependency against the previous published
# platform version and collates each dependency's changelog.
#
# Usage:
#   ./generate_release_notes.sh CHART_NAME CHART_VERSION [APP_VERSION]
#
# Arguments:
#   CHART_NAME    - Name of the chart (e.g., "jfrog-platform", "artifactory")
#   CHART_VERSION - Helm chart version being released (e.g., "11.5.5")
#   APP_VERSION   - Optional app-version override; resolved from index.yaml
#                   when omitted.
#
# Requirements: yq (mikefarah v4), curl, tar, sort (-V), awk, sed
# Compatible with bash 3.2+ (macOS default) and bash 4+/5+ (Linux/CI)

set -euo pipefail

INDEX_URL="https://charts.jfrog.io/index.yaml"

capitalize() {
    echo "$1" | awk '{print toupper(substr($0,1,1)) substr($0,2)}'
}

CHART_NAME="${1:?Usage: $0 CHART_NAME CHART_VERSION [APP_VERSION]}"
CHART_VERSION="${2:?Usage: $0 CHART_NAME CHART_VERSION [APP_VERSION]}"
APP_VERSION_OVERRIDE="${3:-}"

# ---------------------------------------------------------------------------
# Working files (index + downloaded changelogs), cleaned up on exit
# ---------------------------------------------------------------------------

WORK_DIR="$(mktemp -d)"
INDEX_FILE="${WORK_DIR}/index.yaml"
trap 'rm -rf "$WORK_DIR"' EXIT

download_index() {
    if ! curl -sSL --max-time 120 "$INDEX_URL" -o "$INDEX_FILE"; then
        echo "::error::Failed to download ${INDEX_URL}" >&2
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Version comparison using sort -V
# ---------------------------------------------------------------------------

version_gt() {
    [[ "$1" != "$2" ]] && [[ "$(printf '%s\n%s' "$1" "$2" | sort -V | tail -1)" == "$1" ]]
}

version_le() {
    [[ "$(printf '%s\n%s' "$1" "$2" | sort -V | tail -1)" == "$2" ]]
}

# Convert a Helm chart version to its product app version. The chart major is
# the app major + 100: 107.133.10 -> 7.133.10, 103.137.21 -> 3.137.21.
chart_to_app_version() {
    local cv="$1"
    local major="${cv%%.*}"
    local rest="${cv#*.}"
    if [[ "$major" =~ ^[0-9]+$ ]] && (( major > 100 )); then
        echo "$(( major - 100 )).${rest}"
    else
        echo "$cv"
    fi
}

# ---------------------------------------------------------------------------
# charts.jfrog.io index.yaml lookups (single source of truth)
# ---------------------------------------------------------------------------

# All published versions of a chart, one per line.
idx_versions() {
    yq ".entries[\"$1\"][].version" "$INDEX_FILE" 2>/dev/null || true
}

# The greatest published version of CHART that is strictly less than VERSION.
idx_prev_version() {
    local chart="$1" version="$2" v best=""
    while IFS= read -r v; do
        [[ -z "$v" || "$v" == "null" ]] && continue
        if version_gt "$version" "$v"; then
            if [[ -z "$best" ]] || version_gt "$v" "$best"; then
                best="$v"
            fi
        fi
    done < <(idx_versions "$chart")
    echo "$best"
}

# appVersion of a specific chart version (empty if unknown).
idx_app_version() {
    local av
    av=$(yq ".entries[\"$1\"][] | select(.version == \"$2\") | .appVersion" "$INDEX_FILE" 2>/dev/null || true)
    [[ "$av" == "null" ]] && av=""
    echo "$av"
}

# Download URL of a specific chart version's .tgz (empty if unknown).
idx_tgz_url() {
    local url
    url=$(yq ".entries[\"$1\"][] | select(.version == \"$2\") | .urls[0]" "$INDEX_FILE" 2>/dev/null || true)
    [[ "$url" == "null" ]] && url=""
    echo "$url"
}

# Dependency names declared by a chart version, one per line.
idx_dep_names() {
    yq ".entries[\"$1\"][] | select(.version == \"$2\") | .dependencies[].name" \
        "$INDEX_FILE" 2>/dev/null || true
}

# Version of a single dependency within a chart version.
idx_dep_version() {
    local v
    v=$(yq ".entries[\"$1\"][] | select(.version == \"$2\") | .dependencies[] | select(.name == \"$3\") | .version" \
        "$INDEX_FILE" 2>/dev/null || true)
    [[ "$v" == "null" ]] && v=""
    echo "$v"
}

# Emit a "Dependency Chart Version Summary" table for CHART comparing OLD vs
# NEW versions. Prints nothing and returns 1 when the chart declares no
# dependencies; returns 0 when at least one dependency version changed and 2
# when all are unchanged (so callers can decide whether to show details).
emit_dependency_summary() {
    local chart="$1" old_version="$2" new_version="$3"
    local dep_names
    dep_names=$(idx_dep_names "$chart" "$new_version")
    [[ -z "$dep_names" ]] && return 1

    echo "## Dependency Chart Version Summary"
    echo ""
    echo "| Dependency | Previous | New | Status |"
    echo "|------------|----------|-----|--------|"

    local rc=2 dep old_v new_v
    while IFS= read -r dep; do
        [[ -z "$dep" ]] && continue
        old_v=$(idx_dep_version "$chart" "$old_version" "$dep")
        new_v=$(idx_dep_version "$chart" "$new_version" "$dep")
        if [[ "$old_v" != "$new_v" ]]; then
            printf '| **%s** | `%s` | `%s` | :arrows_counterclockwise: Updated |\n' "$dep" "${old_v:-none}" "${new_v:-none}"
            rc=0
        else
            printf '| %s | `%s` | `%s` | Unchanged |\n' "$dep" "$old_v" "$new_v"
        fi
    done <<< "$dep_names"
    echo ""
    return $rc
}

# ":arrows_counterclockwise: Updated" when the two values differ, else "Unchanged".
version_status() {
    if [[ "$1" != "$2" ]]; then
        echo ":arrows_counterclockwise: Updated"
    else
        echo "Unchanged"
    fi
}

# Chart/App version comparison table (Previous | New | Status).
emit_version_details() {
    local prev_version="$1" new_version="$2" prev_app="$3" new_app="$4"
    echo "| | Previous | New | Status |"
    echo "|---|----------|-----|--------|"
    printf '| **Chart Version** | `%s` | `%s` | %s |\n' \
        "${prev_version:-none}" "$new_version" "$(version_status "$prev_version" "$new_version")"
    printf '| **App Version** | `%s` | `%s` | %s |\n' \
        "${prev_app:-none}" "$new_app" "$(version_status "$prev_app" "$new_app")"
}

# Resolve the app version for a chart version (index first, derived fallback).
resolve_app_version() {
    local chart="$1" version="$2" av
    av=$(idx_app_version "$chart" "$version")
    [[ -z "$av" ]] && av=$(chart_to_app_version "$version")
    echo "$av"
}

# Download a chart version's .tgz and extract its CHANGELOG.md. Prints the
# path to the extracted file (cached per chart+version), or empty if there
# is no changelog available. Charts.jfrog.io is the only source consulted.
fetch_changelog() {
    local chart="$1" version="$2"
    local out="${WORK_DIR}/${chart}-${version}-CHANGELOG.md"
    [[ -f "$out" ]] && { echo "$out"; return; }

    local url; url=$(idx_tgz_url "$chart" "$version")
    [[ -z "$url" ]] && { echo ""; return; }

    local tgz="${WORK_DIR}/${chart}-${version}.tgz"
    if curl -sSL --max-time 120 "$url" -o "$tgz" 2>/dev/null; then
        if tar -xzf "$tgz" -C "$WORK_DIR" "${chart}/CHANGELOG.md" 2>/dev/null; then
            mv "${WORK_DIR}/${chart}/CHANGELOG.md" "$out"
            rmdir "${WORK_DIR}/${chart}" 2>/dev/null || true
        fi
        rm -f "$tgz"
    fi

    [[ -f "$out" ]] && echo "$out" || echo ""
}

# ---------------------------------------------------------------------------
# Container image inventory (per chart), with live registry digest lookup.
# Every image reference in a chart's values.yaml is enumerated generically
# (any map with a "repository" key), compared between the old and new chart
# version, and the new tag's digest is looked up live against its registry.
# ---------------------------------------------------------------------------

# Download a chart version's .tgz and extract its values.yaml. Prints the
# path to the extracted file (cached per chart+version), or empty if
# unavailable.
fetch_values() {
    local chart="$1" version="$2"
    local out="${WORK_DIR}/${chart}-${version}-values.yaml"
    [[ -f "$out" ]] && { echo "$out"; return; }

    local url; url=$(idx_tgz_url "$chart" "$version")
    [[ -z "$url" ]] && { echo ""; return; }

    local tgz="${WORK_DIR}/${chart}-${version}-values.tgz"
    if curl -sSL --max-time 120 "$url" -o "$tgz" 2>/dev/null; then
        if tar -xzf "$tgz" -C "$WORK_DIR" "${chart}/values.yaml" 2>/dev/null; then
            mv "${WORK_DIR}/${chart}/values.yaml" "$out"
            rmdir "${WORK_DIR}/${chart}" 2>/dev/null || true
        fi
        rm -f "$tgz"
    fi

    [[ -f "$out" ]] && echo "$out" || echo ""
}

# List every image block in a values.yaml file as "path|registry|repository|tag"
# lines. Any map with a "repository" key counts as an image block (registry
# may be absent when repository already embeds the host, e.g.
# "docker.elastic.co/beats/filebeat"; tag falls back to "version" when a
# chart uses that key name instead). Tag is empty when neither is set —
# callers resolve that against the chart's appVersion. Lines whose
# registry/repository are unresolved Helm template expressions (e.g.
# "{{ .Values.global.imageRegistry }}", seen in jfrog-platform's own
# umbrella values.yaml) are skipped.
list_chart_images() {
    local values_file="$1"
    [[ -n "$values_file" && -f "$values_file" ]] || return 0
    yq eval '.. | select(tag == "!!map") | select(has("repository")) |
        (path | join(".")) + "|" + (.registry // "") + "|" + .repository + "|" + ((.tag // .version) // "")' \
        "$values_file" 2>/dev/null | grep -vE '\{\{' || true
}

# Human-readable label for an image row: strip a trailing ".image" segment;
# a bare "image" path (the chart's own top-level image) is labelled with the
# chart name itself.
image_display_name() {
    local chart="$1" path="$2"
    if [[ "$path" == "image" ]]; then
        capitalize "$chart"
    else
        capitalize "${path%.image}"
    fi
}

# Split a combined "host/path" repository (when no separate registry field
# exists) into registry + repository. Heuristic: the first path segment is
# a registry host only if it contains a dot (matches Docker's own rule for
# distinguishing a registry host from a Docker-Hub-style org/repo).
resolve_registry_repository() {
    local registry="$1" repository="$2"
    if [[ -z "$registry" && "$repository" == *.*/* ]]; then
        registry="${repository%%/*}"
        repository="${repository#*/}"
    fi
    printf '%s|%s' "$registry" "$repository"
}

# SHA256 digest for registry/repository:tag via the anonymous Docker
# Registry HTTP API v2 token flow. Only queried for JFrog-hosted registries
# (*.jfrog.io) — other registries (e.g. docker.elastic.co) use a different
# auth realm we don't support, so their digest is left unavailable rather
# than attempting a doomed request. Cached on disk per registry+repository+
# tag for this run. Empty on any failure (auth, network, missing manifest) —
# a lookup failure never aborts the report, that row just shows no digest.
registry_digest() {
    local registry="$1" repository="$2" tag="$3"
    [[ -z "$registry" || -z "$repository" || -z "$tag" ]] && { echo ""; return; }
    [[ "$registry" == *.jfrog.io ]] || { echo ""; return; }

    local cache_key cache_file
    cache_key=$(printf '%s_%s_%s' "$registry" "$repository" "$tag" | tr -c 'A-Za-z0-9' '_')
    cache_file="${WORK_DIR}/digest-${cache_key}"
    [[ -f "$cache_file" ]] && { cat "$cache_file"; return; }

    local token
    token=$(curl -sS --max-time 30 \
        "https://${registry}/artifactory/api/docker/docker/v2/token?service=${registry}&scope=repository:${repository}:pull" \
        2>/dev/null | yq -p json '.token' 2>/dev/null || true)

    local digest=""
    if [[ -n "$token" && "$token" != "null" ]]; then
        digest=$(curl -sSI --max-time 30 \
            -H "Authorization: Bearer ${token}" \
            -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
            -H "Accept: application/vnd.docker.distribution.manifest.list.v2+json" \
            -H "Accept: application/vnd.oci.image.manifest.v1+json" \
            -H "Accept: application/vnd.oci.image.index.v1+json" \
            "https://${registry}/v2/${repository}/manifests/${tag}" 2>/dev/null \
            | grep -i '^docker-content-digest:' | awk '{print $2}' | tr -d '\r\n')
    fi

    printf '%s' "$digest" > "$cache_file"
    echo "$digest"
}

# Emit an "Image | Previous Tag | Current Tag | Status | Digest" table
# comparing a chart's old and new values.yaml. Digest is looked up live for
# the current tag only.
emit_images_table() {
    local chart="$1" old_version="$2" new_version="$3"
    local old_values new_values
    old_values=$(fetch_values "$chart" "$old_version")
    new_values=$(fetch_values "$chart" "$new_version")

    local new_images
    new_images=$(list_chart_images "$new_values")
    if [[ -z "$new_images" ]]; then
        echo "_No image references found for \`$chart\` \`$new_version\`._"
        return
    fi

    local old_images old_app_version new_app_version
    old_images=$(list_chart_images "$old_values")
    old_app_version=$(resolve_app_version "$chart" "$old_version")
    new_app_version=$(resolve_app_version "$chart" "$new_version")

    echo "<div style=\"font-size: 85%;\">"
    echo ""
    echo "| Image (repository) | Previous Tag | Current Tag | Status | Digest |"
    echo "|---------------------|--------------|--------------|--------|--------|"

    local path registry repository new_tag
    while IFS='|' read -r path registry repository new_tag; do
        [[ -z "$path" ]] && continue
        [[ -z "$new_tag" ]] && new_tag="$new_app_version"

        local old_line old_tag
        old_line=$(printf '%s\n' "$old_images" | awk -F'|' -v p="$path" '$1 == p {print; exit}')
        if [[ -n "$old_line" ]]; then
            old_tag=$(printf '%s' "$old_line" | awk -F'|' '{print $4}')
            [[ -z "$old_tag" ]] && old_tag="$old_app_version"
        else
            old_tag="none"
        fi

        local status="Unchanged"
        [[ "$old_tag" != "$new_tag" ]] && status=":arrows_counterclockwise: Updated"

        local split reg repo digest digest_display
        split=$(resolve_registry_repository "$registry" "$repository")
        reg="${split%%|*}" repo="${split#*|}"
        digest=$(registry_digest "$reg" "$repo" "$new_tag")
        digest_display="_unavailable_"
        [[ -n "$digest" ]] && digest_display="\`${digest}\`"

        printf '| **%s** (`%s`) | `%s` | `%s` | %s | %s |\n' \
            "$(image_display_name "$chart" "$path")" "$repo" "$old_tag" "$new_tag" "$status" "$digest_display"
    done <<< "$new_images"
    echo ""
    echo "</div>"
}

# ---------------------------------------------------------------------------
# CHANGELOG parsing
# Handles both "## [version]" (most charts) and "[version]" (catalog) formats
# ---------------------------------------------------------------------------

# Extract the bullet-point body of a single version's CHANGELOG section.
extract_changelog_section() {
    local file="$1" version="$2"
    [[ -n "$file" && -f "$file" ]] || return 0

    awk -v ver="$version" '
    /^(## )?\[/ {
        s = index($0, "[") + 1
        e = index($0, "]")
        v = substr($0, s, e - s)
        if (v == ver) { p = 1; next }
        else if (p) { exit }
    }
    p { print }
    ' "$file"
}

# Print the changelog lines added between OLD and NEW versions of a chart —
# the lines present in NEW's CHANGELOG.md but absent from OLD's. This yields
# the true delta even when a release appends bullets to an existing version
# section instead of cutting a new one. Both .tgz packages are pulled from
# charts.jfrog.io. Version headers in the result are bolded.
changelog_delta() {
    local chart="$1" old_version="$2" new_version="$3"

    local new_file
    new_file=$(fetch_changelog "$chart" "$new_version")
    if [[ -z "$new_file" ]]; then
        echo "_No changelog found for \`$new_version\`._"
        return
    fi

    local old_file
    old_file=$(fetch_changelog "$chart" "$old_version")
    if [[ -z "$old_file" ]]; then
        # No baseline to diff against — fall back to this version's section.
        local section
        section=$(extract_changelog_section "$new_file" "$new_version")
        [[ -n "$section" ]] && echo "$section" || echo "_No changelog entry for \`$new_version\`._"
        return
    fi

    # Lines in NEW not present anywhere in OLD (blanks dropped). grep exits 1
    # when there is no difference (identical changelogs) — that is a normal
    # "no delta" outcome, not an error, so guard it from set -e/pipefail.
    local raw content
    raw=$({ grep -vxF -f "$old_file" "$new_file" || true; } | sed '/^[[:space:]]*$/d')
    # Real entries = delta lines that aren't just version headers. When the
    # only difference is the version header itself, treat it as no entries.
    content=$(printf '%s\n' "$raw" | grep -vE '^#*[[:space:]]*\[[^]]*\]' || true)
    if [[ -z "$raw" || -z "$content" ]]; then
        # No new content lines — only version headers differ (or nothing at
        # all). This can mean the upstream changelog only bumped its header
        # without adding entries (nothing to report), OR that genuinely new
        # bullets exist but happen to also appear verbatim elsewhere in OLD's
        # full history, hiding them from the whole-file grep above. Tell
        # these apart by comparing NEW's own section against OLD's own
        # section: only surface it as new when it actually differs from what
        # was already published as of old_version.
        local new_section old_section
        new_section=$(extract_changelog_section "$new_file" "$new_version")
        old_section=$(extract_changelog_section "$old_file" "$old_version")
        if [[ -n "$new_section" && "$new_section" != "$old_section" ]]; then
            echo "**[$new_version]**"
            printf '%s\n' "$new_section" | sed '/^[[:space:]]*$/d'
        else
            echo "_No changelog entries in range \`$new_version\` .. \`$old_version\`._"
        fi
        return
    fi
    printf '%s\n' "$raw" | sed 's/^#\{1,\}[[:space:]]*\(\[.*\)/**\1**/' | drop_orphan_headers
}

# Post-process a changelog delta: drop any bolded version header
# ("**[X.Y.Z]**"-style) that ends up with no non-blank content line before
# the next header or end of input, and insert a blank line after each
# surviving header (for consistent spacing before its bullets) and before
# each header that isn't the first line (spacing from the previous section).
#
# An orphaned header happens when an older, already-published section gets
# duplicated verbatim under a renumbered version later: its header text
# differs from history so the line diff in changelog_delta picks it up, but
# every one of its bullets gets filtered out as already-known content,
# leaving a contentless header behind.
drop_orphan_headers() {
    local pending="" has_content=false first=true line
    while IFS= read -r line; do
        if [[ "$line" =~ ^\*\*\[ ]]; then
            pending="$line"
            has_content=false
        else
            if [[ -n "$pending" ]]; then
                [[ "$first" == false ]] && echo ""
                printf '%s\n' "$pending"
                pending=""
                first=false
            fi
            has_content=true
            printf '%s\n' "$line"
        fi
    done
}

# ---------------------------------------------------------------------------
# Official JFrog docs release-notes links
# Maps a chart + its application version to the public release-notes page,
# deep-linked to the specific version where the anchor format is known.
# Returns an empty string for charts with no public versioned release page
# (e.g. catalog, infrastructure deps).
# ---------------------------------------------------------------------------

docs_release_url() {
    local chart="$1" app_version="$2"
    local compact="${app_version//./}"
    local base="https://docs.jfrog.com/releases/docs"
    case "$chart" in
        artifactory|artifactory-ha|artifactory-jcr|artifactory-oss|artifactory-cpp-ce)
            echo "${base}/artifactory-self-managed-releases#artifactory-${compact}-self-managed" ;;
        xray)
            echo "${base}/security-self-managed-releases#${compact}" ;;
        distribution)
            echo "${base}/distribution-release-notes#distribution-${compact}" ;;
        worker)
            # workers anchors use major.minor only (no patch): 1.179.0 -> #jfrog-workers-1179
            local mm="${app_version%.*}"
            echo "${base}/jfrog-workers-release-information#jfrog-workers-${mm//./}" ;;
        *)
            # catalog, postgresql, rabbitmq, bridge: no public versioned page
            echo "" ;;
    esac
}

# The product name to display in the "official release notes" link text.
# artifactory-ha/jcr/oss/cpp-ce all share Artifactory's own release-notes
# page (see docs_release_url above) rather than having their own, so the
# link should read "artifactory X.Y.Z", not e.g. "artifactory-ha X.Y.Z".
docs_release_display_name() {
    local chart="$1"
    case "$chart" in
        artifactory-ha|artifactory-jcr|artifactory-oss|artifactory-cpp-ce)
            echo "artifactory" ;;
        *)
            echo "$chart" ;;
    esac
}

# Inline "official release notes" suffix appended to a heading line, rendered
# in a smaller font via <sub>. Returns an empty string when the chart has no
# public release-notes page. Shared by individual-chart and platform notes so
# both render the link identically.
release_notes_suffix() {
    local chart="$1" app_version="$2" url display_chart
    url=$(docs_release_url "$chart" "$app_version")
    [[ -z "$url" ]] && { echo ""; return; }
    display_chart=$(docs_release_display_name "$chart")
    printf '%s<sub>📖 Official release notes: [%s %s](%s)</sub>' \
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" \
        "$display_chart" "$app_version" "$url"
}

# ---------------------------------------------------------------------------
# Individual chart release notes
# ---------------------------------------------------------------------------

build_simple_notes() {
    local app_version="$1"
    local prev_version
    prev_version=$(idx_prev_version "$CHART_NAME" "$CHART_VERSION")

    echo "## $(capitalize "$CHART_NAME") \`$CHART_VERSION\`$(release_notes_suffix "$CHART_NAME" "$app_version")"
    echo ""

    if [[ -n "$prev_version" ]]; then
        local prev_app
        prev_app=$(resolve_app_version "$CHART_NAME" "$prev_version")
        emit_version_details "$prev_version" "$CHART_VERSION" "$prev_app" "$app_version"
    else
        cat <<EOF
| | |
|---|---|
| **Chart** | \`$CHART_NAME\` |
| **Chart Version** | \`$CHART_VERSION\` |
| **App Version** | \`$app_version\` |
EOF
    fi
    echo ""
    if [[ -n "$prev_version" ]]; then
        echo "## Changelog (\`$prev_version\` → \`$CHART_VERSION\`)"
    else
        echo "## Changelog"
    fi
    echo ""

    if [[ -n "$prev_version" ]]; then
        changelog_delta "$CHART_NAME" "$prev_version" "$CHART_VERSION"
    else
        local file section
        file=$(fetch_changelog "$CHART_NAME" "$CHART_VERSION")
        section=$(extract_changelog_section "$file" "$CHART_VERSION")
        [[ -n "$section" ]] && echo "$section" || echo "_No changelog entry for \`$CHART_VERSION\`._"
    fi
    echo ""

    # Dependency version summary (same table as the platform chart).
    if [[ -n "$prev_version" ]]; then
        emit_dependency_summary "$CHART_NAME" "$prev_version" "$CHART_VERSION" || true
    fi

    # Container image inventory: every image reference in values.yaml,
    # previous vs current tag, with a live registry digest lookup.
    if [[ -n "$prev_version" ]]; then
        echo ""
        echo "## Images"
        echo ""
        emit_images_table "$CHART_NAME" "$prev_version" "$CHART_VERSION"
    fi
}

# ---------------------------------------------------------------------------
# jfrog-platform release notes (with collated dependency changelogs)
# ---------------------------------------------------------------------------

build_platform_notes() {
    local app_version="$1"
    local prev_version
    prev_version=$(idx_prev_version "jfrog-platform" "$CHART_VERSION")

    echo "## Platform Chart Details"
    echo ""
    if [[ -n "$prev_version" ]]; then
        local prev_app
        prev_app=$(resolve_app_version "jfrog-platform" "$prev_version")
        emit_version_details "$prev_version" "$CHART_VERSION" "$prev_app" "$app_version"
    else
        cat <<EOF
| | |
|---|---|
| **Chart Version** | \`$CHART_VERSION\` |
| **App Version** | \`$app_version\` |
EOF
    fi
    echo ""
    if [[ -n "$prev_version" ]]; then
        echo "## Changelog (\`$prev_version\` → \`$CHART_VERSION\`)"
    else
        echo "## Changelog"
    fi
    echo ""

    local file section
    file=$(fetch_changelog "jfrog-platform" "$CHART_VERSION")
    section=$(extract_changelog_section "$file" "$CHART_VERSION")
    if [[ -n "$section" ]]; then
        echo "$section"
    else
        echo "_No changelog entry for platform version \`$CHART_VERSION\`._"
    fi
    echo ""

    if [[ -z "$prev_version" ]]; then
        echo "## Dependency Changes"
        echo ""
        echo "_No previous published platform version found — unable to compute dependency diffs._"
        return
    fi

    local dep_names
    dep_names=$(idx_dep_names "jfrog-platform" "$CHART_VERSION")
    if [[ -z "$dep_names" ]]; then
        echo "## Dependency Changes"
        echo ""
        echo "_Unable to read dependencies from charts.jfrog.io for \`$CHART_VERSION\`._"
        return
    fi

    # ---- version summary table ----
    local has_changes=true rc=0
    emit_dependency_summary "jfrog-platform" "$prev_version" "$CHART_VERSION" && rc=0 || rc=$?
    [[ "$rc" -eq 2 ]] && has_changes=false

    if [[ "$has_changes" == false ]]; then
        echo "## Dependency Changes"
        echo ""
        echo "_No dependency version changes detected._"
        return
    fi

    # ---- detailed dependency changelogs ----
    echo "## Dependency Changes"
    echo ""

    while IFS= read -r dep; do
        [[ -z "$dep" ]] && continue
        local old_v new_v
        old_v=$(idx_dep_version "jfrog-platform" "$prev_version" "$dep")
        new_v=$(idx_dep_version "jfrog-platform" "$CHART_VERSION" "$dep")
        [[ "$old_v" == "$new_v" ]] && continue

        if [[ "$dep" == "postgresql" || "$dep" == "rabbitmq" ]]; then
            echo "### $(capitalize "$dep") (\`${old_v:-none}\` → \`$new_v\`)"
            echo ""
            echo "_Infrastructure dependency updated._"
            echo ""
            continue
        fi

        echo "---"
        echo ""

        local dep_app_v
        dep_app_v=$(resolve_app_version "$dep" "$new_v")
        echo "### $(capitalize "$dep") (\`${old_v:-none}\` → \`$new_v\`)$(release_notes_suffix "$dep" "$dep_app_v")"
        echo ""

        echo "<details open>"
        echo "<summary><b>Changelog</b></summary>"
        echo ""
        changelog_delta "$dep" "$old_v" "$new_v"
        echo ""
        echo "</details>"
        echo ""
    done <<< "$dep_names"

    # ---- image version summary ----
    echo "## Image Version Summary"
    echo ""

    while IFS= read -r dep; do
        [[ -z "$dep" ]] && continue
        local old_v new_v
        old_v=$(idx_dep_version "jfrog-platform" "$prev_version" "$dep")
        new_v=$(idx_dep_version "jfrog-platform" "$CHART_VERSION" "$dep")
        [[ "$old_v" == "$new_v" ]] && continue
        [[ "$dep" == "postgresql" || "$dep" == "rabbitmq" ]] && continue

        echo "---"
        echo ""

        echo "### $(capitalize "$dep") (\`${old_v:-none}\` → \`$new_v\`)"
        echo ""

        echo "<details>"
        echo "<summary><b>Images</b></summary>"
        echo ""
        emit_images_table "$dep" "$old_v" "$new_v"
        echo ""
        echo "</details>"
        echo ""
    done <<< "$dep_names"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

download_index

if [[ -n "$APP_VERSION_OVERRIDE" ]]; then
    APP_VERSION="$APP_VERSION_OVERRIDE"
else
    APP_VERSION=$(resolve_app_version "$CHART_NAME" "$CHART_VERSION")
fi

if [[ "$CHART_NAME" == "jfrog-platform" ]]; then
    build_platform_notes "$APP_VERSION"
else
    build_simple_notes "$APP_VERSION"
fi
