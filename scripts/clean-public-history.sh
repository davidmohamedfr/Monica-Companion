#!/bin/bash

# AIDD/Public History Cleanup Script
# Creates a clean dev-public branch with zero AIDD traces

set -e

echo "🧹 AIDD/Public History Cleanup Script"
echo "======================================"

# Configuration
PRIVATE_BRANCH="dev"
PUBLIC_BRANCH="dev-public"
BACKUP_SUFFIX=$(date +%Y%m%d-%H%M%S)

# AIDD file patterns to remove
AIDD_PATTERNS=(
    ".opencode"
    "aidd-docs"
    "AGENTS.md"
    "CLAUDE.md"
    "opencode.jsonc"
)

# Function to check if git is clean
check_git_clean() {
    if [[ -n $(git status --porcelain) ]]; then
        echo "❌ Working directory is not clean. Please commit or stash changes."
        exit 1
    fi
}

# Function to create backup
create_backup() {
    local backup_branch="backup-cleanup-${BACKUP_SUFFIX}"
    echo "📋 Creating backup branch: $backup_branch"
    git branch "$backup_branch"
    echo "✅ Backup created: $backup_branch"
}

# Function to remove AIDD files from history
filter_aidd_files() {
    echo "🔍 Filtering AIDD files from history..."

    # Build filter-branch command for removing AIDD files
    local filter_command="git rm -rf --cached --ignore-unmatch"
    for pattern in "${AIDD_PATTERNS[@]}"; do
        filter_command="$filter_command $pattern"
    done

    # Create new branch from current branch
    git checkout -b "$PUBLIC_BRANCH-temp" "$PRIVATE_BRANCH"

    # Filter out AIDD files from all commits
    git filter-branch --force --index-filter "$filter_command" --prune-empty HEAD

    echo "✅ AIDD files filtered from history"
}

# Function to remove AIDD commits entirely
filter_aidd_commits() {
    echo "🔍 Filtering AIDD-only commits..."

    # Remove commits that only contain AIDD changes or have [AIDD] in message
    git filter-branch --force --commit-filter '
        if echo "$GIT_COMMIT_MESSAGE" | grep -q "\[AIDD\]"; then
            skip_commit "$@";
        else
            git commit-tree "$@";
        fi' HEAD

    echo "✅ AIDD commits filtered"
}

# Function to clean .gitignore of AIDD entries
clean_gitignore() {
    echo "🧹 Cleaning .gitignore of AIDD entries..."

    if [[ -f .gitignore ]]; then
        # Remove AIDD-related entries from .gitignore
        sed -i.bak '/# AIDD/,/^$/d' .gitignore
        sed -i.bak '/opencode/d' .gitignore
        sed -i.bak '/aidd-docs/d' .gitignore
        rm -f .gitignore.bak

        # Commit if changes were made
        if ! git diff --quiet .gitignore; then
            git add .gitignore
            git commit -m "chore: clean AIDD entries from gitignore"
        fi
    fi

    echo "✅ .gitignore cleaned"
}

# Function to verify no AIDD traces remain
verify_clean() {
    echo "🔍 Verifying no AIDD traces remain..."

    local found_issues=0

    # Check for AIDD files
    for pattern in "${AIDD_PATTERNS[@]}"; do
        if [[ -e "$pattern" ]]; then
            echo "❌ Found AIDD file: $pattern"
            found_issues=1
        fi
    done

    # Check commit messages for AIDD references
    if git log --all --grep="AIDD" --grep="aidd" -i --oneline | grep -q .; then
        echo "❌ Found AIDD references in commit messages:"
        git log --all --grep="AIDD" --grep="aidd" -i --oneline
        found_issues=1
    fi

    # Check file contents for AIDD references (excluding this script)
    if git ls-files | grep -v "clean-public-history.sh" | xargs grep -l "AIDD\|aidd" 2>/dev/null | grep -q .; then
        echo "❌ Found AIDD references in files:"
        git ls-files | grep -v "clean-public-history.sh" | xargs grep -l "AIDD\|aidd" 2>/dev/null || true
        found_issues=1
    fi

    if [[ $found_issues -eq 0 ]]; then
        echo "✅ No AIDD traces found - branch is clean!"
        return 0
    else
        echo "❌ AIDD traces still present - manual cleanup required"
        return 1
    fi
}

# Function to finalize public branch
finalize_public_branch() {
    echo "🎯 Finalizing public branch..."

    # Delete old public branch if it exists
    if git show-ref --verify --quiet refs/heads/"$PUBLIC_BRANCH"; then
        git branch -D "$PUBLIC_BRANCH"
    fi

    # Rename temp branch to final public branch
    git branch -m "$PUBLIC_BRANCH-temp" "$PUBLIC_BRANCH"

    echo "✅ Public branch created: $PUBLIC_BRANCH"
}

# Main execution
main() {
    echo "Starting cleanup process..."
    echo "Private branch: $PRIVATE_BRANCH"
    echo "Public branch: $PUBLIC_BRANCH"
    echo ""

    # Pre-flight checks
    check_git_clean

    # Ensure we're on the private branch
    git checkout "$PRIVATE_BRANCH"

    # Create backup
    create_backup

    # Filter history
    filter_aidd_files
    filter_aidd_commits

    # Clean remaining files
    clean_gitignore

    # Verify cleanliness
    if verify_clean; then
        finalize_public_branch

        echo ""
        echo "🎉 Success! Clean public branch created."
        echo ""
        echo "Next steps:"
        echo "1. Review the $PUBLIC_BRANCH branch"
        echo "2. Test that the project builds correctly"
        echo "3. Push $PUBLIC_BRANCH to remote when ready"
        echo ""
        echo "⚠️  Note: This script modified Git history."
        echo "   Backup branch: backup-cleanup-${BACKUP_SUFFIX}"
    else
        echo ""
        echo "❌ Cleanup incomplete. Manual intervention required."
        echo "   Temp branch: $PUBLIC_BRANCH-temp (not renamed)"
        echo "   Backup branch: backup-cleanup-${BACKUP_SUFFIX}"
        exit 1
    fi
}

# Run main function
main "$@"