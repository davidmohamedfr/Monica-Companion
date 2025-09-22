#!/bin/bash

# AIDD/Public Branch Verification Script
# Verifies that a branch has zero AIDD traces

set -e

# Configuration
AIDD_PATTERNS=(
    ".opencode"
    "aidd-docs"
    "AGENTS.md"
    "CLAUDE.md"
    "opencode.jsonc"
)

AIDD_KEYWORDS=(
    "AIDD"
    "aidd"
    "AI-Driven Development"
    "opencode"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check for AIDD files
check_aidd_files() {
    echo "🔍 Checking for AIDD files..."

    local found_files=()

    for pattern in "${AIDD_PATTERNS[@]}"; do
        if [[ -e "$pattern" ]]; then
            found_files+=("$pattern")
        fi
    done

    # Also check for any files with aidd in the name
    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find . -name "*aidd*" -o -name "*opencode*" -print0 2>/dev/null | grep -z -v "/.git/" || true)

    if [[ ${#found_files[@]} -eq 0 ]]; then
        print_success "No AIDD files found"
        return 0
    else
        print_error "Found AIDD files:"
        printf '  %s\n' "${found_files[@]}"
        return 1
    fi
}

# Function to check commit messages
check_commit_messages() {
    echo "🔍 Checking commit messages for AIDD references..."

    local found_commits=()

    for keyword in "${AIDD_KEYWORDS[@]}"; do
        local commits=$(git log --all --grep="$keyword" --oneline 2>/dev/null || true)
        if [[ -n "$commits" ]]; then
            found_commits+=("$commits")
        fi
    done

    if [[ ${#found_commits[@]} -eq 0 ]]; then
        print_success "No AIDD references in commit messages"
        return 0
    else
        print_error "Found AIDD references in commit messages:"
        printf '%s\n' "${found_commits[@]}"
        return 1
    fi
}

# Function to check file contents
check_file_contents() {
    echo "🔍 Checking file contents for AIDD references..."

    local found_files=()

    # Get all tracked files except this script and git files
    local files_to_check=$(git ls-files | grep -v "verify-public-branch.sh" | grep -v "^\.git/" || true)

    if [[ -z "$files_to_check" ]]; then
        print_info "No files to check"
        return 0
    fi

    # Check each file for AIDD keywords
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            for keyword in "${AIDD_KEYWORDS[@]}"; do
                if grep -q "$keyword" "$file" 2>/dev/null; then
                    found_files+=("$file (contains: $keyword)")
                    break
                fi
            done
        fi
    done <<< "$files_to_check"

    if [[ ${#found_files[@]} -eq 0 ]]; then
        print_success "No AIDD references in file contents"
        return 0
    else
        print_error "Found AIDD references in files:"
        printf '  %s\n' "${found_files[@]}"
        return 1
    fi
}

# Function to check .gitignore for AIDD entries
check_gitignore() {
    echo "🔍 Checking .gitignore for AIDD entries..."

    if [[ ! -f .gitignore ]]; then
        print_info "No .gitignore file found"
        return 0
    fi

    local found_entries=()

    for keyword in "${AIDD_KEYWORDS[@]}"; do
        local entries=$(grep -i "$keyword" .gitignore 2>/dev/null || true)
        if [[ -n "$entries" ]]; then
            found_entries+=("$entries")
        fi
    done

    if [[ ${#found_entries[@]} -eq 0 ]]; then
        print_success "No AIDD references in .gitignore"
        return 0
    else
        print_error "Found AIDD references in .gitignore:"
        printf '  %s\n' "${found_entries[@]}"
        return 1
    fi
}

# Function to check remote URLs
check_remote_urls() {
    echo "🔍 Checking git remote URLs..."

    local remotes=$(git remote -v 2>/dev/null || true)

    if [[ -z "$remotes" ]]; then
        print_info "No git remotes configured"
        return 0
    fi

    print_info "Git remotes:"
    echo "$remotes" | sed 's/^/  /'

    # Check if any remote URLs contain AIDD references
    for keyword in "${AIDD_KEYWORDS[@]}"; do
        if echo "$remotes" | grep -qi "$keyword"; then
            print_warning "Remote URL contains AIDD reference: $keyword"
            return 1
        fi
    done

    print_success "Remote URLs are clean"
    return 0
}

# Function to check project metadata
check_project_metadata() {
    echo "🔍 Checking project metadata files..."

    local metadata_files=(
        "pubspec.yaml"
        "package.json"
        "README.md"
        "CHANGELOG.md"
    )

    local issues_found=false

    for file in "${metadata_files[@]}"; do
        if [[ -f "$file" ]]; then
            for keyword in "${AIDD_KEYWORDS[@]}"; do
                if grep -q "$keyword" "$file" 2>/dev/null; then
                    print_error "Found AIDD reference in $file: $keyword"
                    issues_found=true
                fi
            done
        fi
    done

    if [[ "$issues_found" == false ]]; then
        print_success "Project metadata is clean"
        return 0
    else
        return 1
    fi
}

# Function to run comprehensive verification
verify_branch() {
    local branch_name="$1"
    local exit_code=0

    echo "🛡️  AIDD/Public Branch Verification"
    echo "==================================="
    echo "Branch: $branch_name"
    echo ""

    # Run all checks
    if ! check_aidd_files; then
        exit_code=1
    fi
    echo ""

    if ! check_commit_messages; then
        exit_code=1
    fi
    echo ""

    if ! check_file_contents; then
        exit_code=1
    fi
    echo ""

    if ! check_gitignore; then
        exit_code=1
    fi
    echo ""

    if ! check_remote_urls; then
        exit_code=1
    fi
    echo ""

    if ! check_project_metadata; then
        exit_code=1
    fi
    echo ""

    # Summary
    if [[ $exit_code -eq 0 ]]; then
        print_success "🎉 Branch verification passed!"
        print_success "Branch '$branch_name' is safe for public release"
    else
        print_error "❌ Branch verification failed!"
        print_error "Branch '$branch_name' contains AIDD traces"
        echo ""
        echo "Actions needed:"
        echo "1. Review the issues above"
        echo "2. Run cleanup scripts if needed"
        echo "3. Re-run verification"
    fi

    return $exit_code
}

# Function to show detailed help
show_help() {
    echo "AIDD/Public Branch Verification Script"
    echo "====================================="
    echo ""
    echo "Verifies that a git branch contains no AIDD traces and is safe for public release."
    echo ""
    echo "Usage:"
    echo "  $0 [branch-name]           # Verify specific branch"
    echo "  $0                         # Verify current branch"
    echo "  $0 --help                  # Show this help"
    echo ""
    echo "Checks performed:"
    echo "  ✓ AIDD files (.opencode/, aidd-docs/, etc.)"
    echo "  ✓ Commit messages for AIDD references"
    echo "  ✓ File contents for AIDD keywords"
    echo "  ✓ .gitignore for AIDD entries"
    echo "  ✓ Git remotes for AIDD references"
    echo "  ✓ Project metadata files"
    echo ""
    echo "Exit codes:"
    echo "  0  - Branch is clean (safe for public)"
    echo "  1  - Branch contains AIDD traces"
    echo "  2  - Script error or invalid usage"
    echo ""
    echo "Examples:"
    echo "  $0 dev-public              # Verify dev-public branch"
    echo "  $0 main                    # Verify main branch"
    echo ""
}

# Main execution
main() {
    local target_branch=""

    # Parse arguments
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
        exit 0
    elif [[ -n "$1" ]]; then
        target_branch="$1"
    else
        target_branch=$(git branch --show-current 2>/dev/null || echo "")
    fi

    # Validate we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 2
    fi

    # If target branch specified, check out to it
    if [[ -n "$target_branch" ]] && [[ "$target_branch" != $(git branch --show-current) ]]; then
        if git show-ref --verify --quiet refs/heads/"$target_branch"; then
            print_info "Switching to branch: $target_branch"
            git checkout "$target_branch"
        else
            print_error "Branch '$target_branch' does not exist"
            exit 2
        fi
    fi

    # Get current branch name
    local current_branch=$(git branch --show-current 2>/dev/null || echo "detached")

    if [[ -z "$current_branch" || "$current_branch" == "detached" ]]; then
        print_error "Cannot determine current branch or in detached HEAD state"
        exit 2
    fi

    # Run verification
    verify_branch "$current_branch"
}

# Run main function
main "$@"