#!/bin/bash
set -e

# Script to cleanup old GitHub releases, keeping only the last 2
#
# Usage: ./cleanup_old_releases.sh
# Environment: Requires GITHUB_TOKEN and GITHUB_REPOSITORY

KEEP_COUNT=2

echo "🧹 Cleaning up old GitHub releases (keeping last ${KEEP_COUNT})..."

# Verify required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
  echo "❌ Error: GITHUB_TOKEN environment variable not set"
  exit 1
fi

if [ -z "$GITHUB_REPOSITORY" ]; then
  echo "❌ Error: GITHUB_REPOSITORY environment variable not set"
  exit 1
fi

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
  echo "❌ Error: gh CLI not found. Install from: https://cli.github.com/"
  exit 1
fi

# Authenticate gh CLI with token
echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null || true

# List all releases sorted by creation date (newest first)
echo "📋 Fetching all releases..."
RELEASES=$(gh release list --repo "$GITHUB_REPOSITORY" --limit 1000 --json tagName,createdAt | jq -r '.[] | "\(.createdAt)\t\(.tagName)"' | sort -r)

if [ -z "$RELEASES" ]; then
  echo "ℹ️  No releases found"
  exit 0
fi

TOTAL_COUNT=$(echo "$RELEASES" | wc -l | tr -d ' ')
echo "📊 Found ${TOTAL_COUNT} release(s)"

if [ "$TOTAL_COUNT" -le "$KEEP_COUNT" ]; then
  echo "✅ Only ${TOTAL_COUNT} release(s) exist, no cleanup needed"
  exit 0
fi

# Calculate how many to delete
DELETE_COUNT=$((TOTAL_COUNT - KEEP_COUNT))
echo "🗑️  Will delete ${DELETE_COUNT} old release(s)"

# Get releases to delete (skip first KEEP_COUNT, delete the rest)
RELEASES_TO_DELETE=$(echo "$RELEASES" | tail -n "+$((KEEP_COUNT + 1))" | cut -f2)

if [ -z "$RELEASES_TO_DELETE" ]; then
  echo "ℹ️  No releases to delete"
  exit 0
fi

# Delete old releases
DELETED=0
FAILED=0

while IFS= read -r TAG_NAME; do
  echo "🗑️  Deleting release: $TAG_NAME"

  if gh release delete "$TAG_NAME" --repo "$GITHUB_REPOSITORY" --yes 2>/dev/null; then
    echo "   ✅ Deleted release: $TAG_NAME"
    DELETED=$((DELETED + 1))
  else
    echo "   ⚠️  Failed to delete release: $TAG_NAME (may already be deleted)"
    FAILED=$((FAILED + 1))
  fi
done <<< "$RELEASES_TO_DELETE"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Cleanup Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total releases: ${TOTAL_COUNT}"
echo "Kept: ${KEEP_COUNT}"
echo "Deleted: ${DELETED}"
if [ "$FAILED" -gt 0 ]; then
  echo "Failed: ${FAILED}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$DELETED" -gt 0 ]; then
  echo "✅ Cleanup completed successfully"
  exit 0
else
  echo "ℹ️  No releases were deleted"
  exit 0
fi
