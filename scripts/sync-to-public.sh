#!/bin/bash

# AIDD/Public Branch Sync Script
# Syncs new commits from dev to dev-public, filtering out AIDD content

set -e

echo "🔄 AIDD/Public Branch Sync Script"
echo "================================="

# Configuration
PRIVATE_BRANCH="dev"
PUBLIC_BRANCH="dev-public"
TEMP_BRANCH="sync-temp-$(date +%Y%m%d-%H%M%S)"

# AIDD file patterns to exclude
AIDD_PATTERNS=(
    ".opencode"
    "aidd-docs"
    "AGENTS.md"
    "CLAUDE.md"
    "opencode.jsonc"
)

# Function to check if branches exist
check_branches() {
    if ! git show-ref --verify --quiet refs/heads/"$PRIVATE_BRANCH"; then
        echo "❌ Private branch '$PRIVATE_BRANCH' does not exist"
        exit 1
    fi

    if ! git show-ref --verify --quiet refs/heads/"$PUBLIC_BRANCH"; then
        echo "❌ Public branch '$PUBLIC_BRANCH' does not exist"
        echo "   Run clean-public-history.sh first to create it"
        exit 1
    fi
}

# Function to check if sync is needed
check_sync_needed() {
    echo "🔍 Checking if sync is needed..."

    # Get the latest commit hash from public branch
    local public_latest=$(git rev-parse "$PUBLIC_BRANCH")

    # Check if this commit exists in private branch history
    if git merge-base --is-ancestor "$public_latest" "$PRIVATE_BRANCH" 2>/dev/null; then
        # Find commits in private branch since last public sync
        local new_commits=$(git rev-list "$public_latest".."$PRIVATE_BRANCH" --count)

        if [[ $new_commits -eq 0 ]]; then
            echo "✅ No sync needed - public branch is up to date"
            return 1
        else
            echo "📊 Found $new_commits new commits to sync"
            return 0
        fi
    else
        echo "⚠️  Cannot determine sync point - full sync required"
        return 0
    fi
}

# Function to filter commits for public branch
filter_new_commits() {
    echo "🔄 Filtering new commits for public branch..."

    # Get the latest commit from public branch as base
    local base_commit=$(git rev-parse "$PUBLIC_BRANCH")

    # Create temp branch from public branch
    git checkout -b "$TEMP_BRANCH" "$PUBLIC_BRANCH"

    # Get list of new commits from private branch
    local commits_to_sync=$(git rev-list --reverse "$base_commit".."$PRIVATE_BRANCH")

    for commit in $commits_to_sync; do
        echo "  Processing commit: $(git log --oneline -1 $commit)"

        # Check if commit message contains AIDD markers
        local commit_msg=$(git log --format=%s -1 "$commit")
        if echo "$commit_msg" | grep -qi "aidd\|\\[aidd\\]"; then
            echo "    ⏭️  Skipping AIDD commit"
            continue
        fi

        # Check if commit only touches AIDD files
        local changed_files=$(git diff-tree --no-commit-id --name-only -r "$commit")
        local non_aidd_files=""

        for file in $changed_files; do
            local is_aidd=false
            for pattern in "${AIDD_PATTERNS[@]}"; do
                if [[ "$file" == $pattern* ]]; then
                    is_aidd=true
                    break
                fi
            done

            if [[ "$is_aidd" == false ]]; then
                non_aidd_files+="$file "
            fi
        done

        if [[ -z "$non_aidd_files" ]]; then
            echo "    ⏭️  Skipping AIDD-only commit"
            continue
        fi

        # Cherry-pick the commit, but only include non-AIDD files
        echo "    ✅ Including commit with filtered files"

        # Try to cherry-pick the commit
        if git cherry-pick --no-commit "$commit"; then
            # Remove any AIDD files that might have been included
            for pattern in "${AIDD_PATTERNS[@]}"; do
                if [[ -e "$pattern" ]]; then
                    git rm -rf --cached "$pattern" 2>/dev/null || true
                fi
            done

            # Commit the filtered changes
            git commit --reuse-message="$commit" || true
        else
            echo "    ⚠️  Cherry-pick conflict - manual resolution required"
            echo "    Commit: $commit"
            echo "    Files: $non_aidd_files"

            # Reset the failed cherry-pick
            git cherry-pick --abort 2>/dev/null || true

            # For now, skip conflicting commits
            echo "    ⏭️  Skipping conflicting commit"
        fi
    done

    echo "✅ Commit filtering complete"
}

# Function to verify no AIDD content
verify_no_aidd() {
    echo "🔍 Verifying no AIDD content in synced branch..."

    local found_issues=0

    # Check for AIDD files
    for pattern in "${AIDD_PATTERNS[@]}"; do
        if [[ -e "$pattern" ]]; then
            echo "❌ Found AIDD file: $pattern"
            found_issues=1
        fi
    done

    # Check for AIDD references in recent commits
    local recent_commits=$(git log --oneline -10)
    if echo "$recent_commits" | grep -qi "aidd"; then
        echo "❌ Found AIDD references in recent commits:"
        echo "$recent_commits" | grep -i "aidd"
        found_issues=1
    fi

    if [[ $found_issues -eq 0 ]]; then
        echo "✅ No AIDD content detected"
        return 0
    else
        echo "❌ AIDD content found - sync failed"
        return 1
    fi
}

# Function to finalize sync
finalize_sync() {
    echo "🎯 Finalizing sync..."

    # Switch to public branch and fast-forward to temp branch
    git checkout "$PUBLIC_BRANCH"
    git merge "$TEMP_BRANCH" --ff-only

    # Clean up temp branch
    git branch -d "$TEMP_BRANCH"

    echo "✅ Sync completed successfully"
}

# Function to cleanup on failure
cleanup_on_failure() {
    echo "🧹 Cleaning up after failure..."

    # Switch back to private branch
    git checkout "$PRIVATE_BRANCH" 2>/dev/null || true

    # Remove temp branch if it exists
    git branch -D "$TEMP_BRANCH" 2>/dev/null || true

    echo "❌ Sync failed - cleanup complete"
}

# Main execution
main() {
    echo "Starting sync process..."
    echo "Private branch: $PRIVATE_BRANCH"
    echo "Public branch: $PUBLIC_BRANCH"
    echo ""

    # Set up error handling
    trap cleanup_on_failure ERR

    # Pre-flight checks
    check_branches

    # Check if sync is needed
    if ! check_sync_needed; then
        exit 0
    fi

    # Ensure we start from private branch
    git checkout "$PRIVATE_BRANCH"

    # Filter and sync commits
    filter_new_commits

    # Verify result
    if verify_no_aidd; then
        finalize_sync

        echo ""
        echo "🎉 Sync completed successfully!"
        echo ""
        echo "Summary:"
        echo "- Private branch: $PRIVATE_BRANCH"
        echo "- Public branch: $PUBLIC_BRANCH (updated)"
        echo ""
        echo "Next steps:"
        echo "1. Review the updated $PUBLIC_BRANCH"
        echo "2. Push to remote if needed"
    else
        cleanup_on_failure
        exit 1
    fi
}

# Show usage if requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $0 [options]"
    echo ""
    echo "Syncs commits from dev to dev-public, filtering out AIDD content."
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  --dry-run     Show what would be synced without making changes"
    echo ""
    echo "Prerequisites:"
    echo "- Both dev and dev-public branches must exist"
    echo "- Working directory must be clean"
    echo ""
    exit 0
fi

# Dry run mode
if [[ "$1" == "--dry-run" ]]; then
    echo "🔍 DRY RUN MODE - No changes will be made"
    echo ""

    check_branches
    if check_sync_needed; then
        echo "✅ Sync would be performed"
    fi
    exit 0
fi

# Run main function
main "$@"