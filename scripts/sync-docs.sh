#!/bin/bash
# sync-docs.sh - Sync documentation from source repos to Jekyll collections

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEBSITE_ROOT="$(dirname "$SCRIPT_DIR")"
DRIFTHOUND_SOURCE="$WEBSITE_ROOT/../drifthound-source"
ACTION_SOURCE="$WEBSITE_ROOT/../drifthound-action-source"

echo "Starting documentation sync..."
echo "Website root: $WEBSITE_ROOT"
echo "DriftHound source: $DRIFTHOUND_SOURCE"
echo "Action source: $ACTION_SOURCE"

# Extract version from DriftHound source
if [ -f "$DRIFTHOUND_SOURCE/lib/drifthound/version.rb" ]; then
  echo "Extracting version from DriftHound..."
  VERSION=$(grep 'Version = ' "$DRIFTHOUND_SOURCE/lib/drifthound/version.rb" | sed 's/.*Version = "\(.*\)"/\1/')
  echo "Found version: $VERSION"

  # Update _config.yml version
  if [ -n "$VERSION" ]; then
    echo "Updating _config.yml with version $VERSION..."
    sed -i.bak "s/^version: .*/version: \"$VERSION\"/" "$WEBSITE_ROOT/_config.yml"
    rm "$WEBSITE_ROOT/_config.yml.bak"
    echo "Version updated successfully!"
  else
    echo "WARNING: Could not extract version from version.rb"
  fi
else
  echo "WARNING: version.rb not found at $DRIFTHOUND_SOURCE/lib/drifthound/version.rb"
fi

# Clean existing docs (preserve getting-started.md which is manually maintained)
if [ -f "$WEBSITE_ROOT/_docs/getting-started.md" ]; then
  mv "$WEBSITE_ROOT/_docs/getting-started.md" "$WEBSITE_ROOT/_docs_getting_started_backup.md"
fi

rm -rf "$WEBSITE_ROOT/_docs"
rm -rf "$WEBSITE_ROOT/_changelog"
mkdir -p "$WEBSITE_ROOT/_docs"
mkdir -p "$WEBSITE_ROOT/_changelog"

# Restore getting-started
if [ -f "$WEBSITE_ROOT/_docs_getting_started_backup.md" ]; then
  mv "$WEBSITE_ROOT/_docs_getting_started_backup.md" "$WEBSITE_ROOT/_docs/getting-started.md"
fi

# Function to add front matter to a markdown file
add_frontmatter() {
  local source_file=$1
  local dest_file=$2
  local title=$3
  local category=$4
  local order=$5
  local description=$6
  local source_repo=$7

  # Create destination directory if it doesn't exist
  mkdir -p "$(dirname "$dest_file")"

  cat > "$dest_file" << EOF
---
layout: docs
title: "$title"
category: "$category"
order: $order
description: "$description"
toc: true
source_repo: "$source_repo"
source_path: "$source_file"
last_synced: "$(date +%Y-%m-%d)"
---

EOF

  # Append original content, fixing image paths
  sed 's|./media/|/assets/images/docs/|g' "$source_file" >> "$dest_file"
}

# Sync DriftHound Core docs
if [ -d "$DRIFTHOUND_SOURCE/docs" ]; then
  echo "Syncing DriftHound core documentation..."
  mkdir -p "$WEBSITE_ROOT/_docs/core"

  if [ -f "$DRIFTHOUND_SOURCE/docs/configuration.md" ]; then
    add_frontmatter \
      "$DRIFTHOUND_SOURCE/docs/configuration.md" \
      "$WEBSITE_ROOT/_docs/core/configuration.md" \
      "Configuration Guide" \
      "core" \
      1 \
      "Complete configuration reference for DriftHound" \
      "DriftHound"
  fi

  if [ -f "$DRIFTHOUND_SOURCE/docs/api-usage.md" ]; then
    add_frontmatter \
      "$DRIFTHOUND_SOURCE/docs/api-usage.md" \
      "$WEBSITE_ROOT/_docs/core/api-usage.md" \
      "API Usage" \
      "core" \
      2 \
      "Learn how to interact with the DriftHound API" \
      "DriftHound"
  fi

  if [ -f "$DRIFTHOUND_SOURCE/docs/cli-usage.md" ]; then
    add_frontmatter \
      "$DRIFTHOUND_SOURCE/docs/cli-usage.md" \
      "$WEBSITE_ROOT/_docs/core/cli-usage.md" \
      "CLI Usage" \
      "core" \
      3 \
      "Using the DriftHound command-line interface" \
      "DriftHound"
  fi

  if [ -f "$DRIFTHOUND_SOURCE/docs/slack-notifications.md" ]; then
    add_frontmatter \
      "$DRIFTHOUND_SOURCE/docs/slack-notifications.md" \
      "$WEBSITE_ROOT/_docs/core/slack-notifications.md" \
      "Slack Notifications" \
      "core" \
      4 \
      "Configure Slack notifications for drift alerts" \
      "DriftHound"
  fi

  # Copy media assets
  if [ -d "$DRIFTHOUND_SOURCE/docs/media" ]; then
    echo "Copying DriftHound media assets..."
    mkdir -p "$WEBSITE_ROOT/assets/images/docs"
    cp -r "$DRIFTHOUND_SOURCE/docs/media/"* "$WEBSITE_ROOT/assets/images/docs/" 2>/dev/null || true
  fi
else
  echo "WARNING: DriftHound docs directory not found at $DRIFTHOUND_SOURCE/docs"
fi

# Sync GitHub Action docs
if [ -d "$ACTION_SOURCE/docs" ]; then
  echo "Syncing GitHub Action documentation..."
  mkdir -p "$WEBSITE_ROOT/_docs/github-action"

  if [ -f "$ACTION_SOURCE/docs/QUICKSTART.md" ]; then
    add_frontmatter \
      "$ACTION_SOURCE/docs/QUICKSTART.md" \
      "$WEBSITE_ROOT/_docs/github-action/quickstart.md" \
      "GitHub Action Quick Start" \
      "github-action" \
      1 \
      "Get started with the DriftHound GitHub Action in minutes" \
      "drifthound-action"
  fi

  if [ -f "$ACTION_SOURCE/docs/ENVIRONMENT-AUTH.md" ]; then
    add_frontmatter \
      "$ACTION_SOURCE/docs/ENVIRONMENT-AUTH.md" \
      "$WEBSITE_ROOT/_docs/github-action/environment-auth.md" \
      "Authentication & Environment Setup" \
      "github-action" \
      2 \
      "Configure authentication for cloud providers in GitHub Actions" \
      "drifthound-action"
  fi

  if [ -f "$ACTION_SOURCE/docs/TESTING.md" ]; then
    add_frontmatter \
      "$ACTION_SOURCE/docs/TESTING.md" \
      "$WEBSITE_ROOT/_docs/github-action/testing.md" \
      "Testing Guide" \
      "github-action" \
      3 \
      "Testing the DriftHound GitHub Action" \
      "drifthound-action"
  fi

  if [ -f "$ACTION_SOURCE/docs/CONTRIBUTING.md" ]; then
    add_frontmatter \
      "$ACTION_SOURCE/docs/CONTRIBUTING.md" \
      "$WEBSITE_ROOT/_docs/github-action/contributing.md" \
      "Contributing" \
      "github-action" \
      4 \
      "How to contribute to the DriftHound GitHub Action" \
      "drifthound-action"
  fi
else
  echo "WARNING: drifthound-action docs directory not found at $ACTION_SOURCE/docs"
fi

# Sync Development docs
if [ -d "$ACTION_SOURCE/docs" ]; then
  echo "Syncing development documentation..."
  mkdir -p "$WEBSITE_ROOT/_docs/development"

  if [ -f "$ACTION_SOURCE/docs/CLI-IMPROVEMENTS.md" ]; then
    add_frontmatter \
      "$ACTION_SOURCE/docs/CLI-IMPROVEMENTS.md" \
      "$WEBSITE_ROOT/_docs/development/cli-improvements.md" \
      "CLI Improvements" \
      "development" \
      1 \
      "Planned improvements for the DriftHound CLI" \
      "drifthound-action"
  fi
fi

# Sync Changelogs
echo "Syncing changelogs..."

if [ -f "$DRIFTHOUND_SOURCE/CHANGELOG.md" ]; then
  add_frontmatter \
    "$DRIFTHOUND_SOURCE/CHANGELOG.md" \
    "$WEBSITE_ROOT/_changelog/drifthound.md" \
    "DriftHound Changelog" \
    "changelog" \
    1 \
    "Release history for DriftHound" \
    "DriftHound"
fi

if [ -f "$ACTION_SOURCE/docs/CHANGELOG.md" ]; then
  add_frontmatter \
    "$ACTION_SOURCE/docs/CHANGELOG.md" \
    "$WEBSITE_ROOT/_changelog/drifthound-action.md" \
    "GitHub Action Changelog" \
    "changelog" \
    2 \
    "Release history for DriftHound GitHub Action" \
    "drifthound-action"
fi

# Validate expected docs exist
validate_docs() {
  local missing=0
  local expected_docs=(
    "_docs/core/configuration.md"
    "_docs/core/api-usage.md"
    "_docs/core/cli-usage.md"
    "_docs/core/slack-notifications.md"
    "_docs/github-action/quickstart.md"
    "_docs/github-action/environment-auth.md"
  )

  for doc in "${expected_docs[@]}"; do
    if [ ! -f "$WEBSITE_ROOT/$doc" ]; then
      echo "WARNING: Missing expected doc: $doc"
      missing=$((missing + 1))
    fi
  done

  if [ $missing -gt 0 ]; then
    echo "WARNING: $missing expected documentation files are missing"
    echo "This may be normal if source repositories are not available locally"
  else
    echo "All expected documentation files synced successfully!"
  fi
}

validate_docs

echo "Documentation sync complete!"
