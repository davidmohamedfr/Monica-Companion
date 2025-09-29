#!/bin/bash

# AIDD/Public Commit Validation Script
# Validates commits to prevent AIDD/public content mixing

set -e

# Configuration
AIDD_PATTERNS=(
    ".opencode"
    "aidd-docs"
    "AGENTS.md"
    "CLAUDE.md"
    "opencode.jsonc"
)

PUBLIC_PATTERNS=(
    "lib/"
    "test/"
    "android/"
    "ios/"
    "pubspec.yaml"
    "README.md"
    "LICENSE"
    "docs/"
    "analysis_options.yaml"
    "scripts/"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Function to check if file is AIDD-related
is_aidd_file() {
    local file="$1"
    for pattern in "${AIDD_PATTERNS[@]}"; do
        if [[ "$file" == $pattern* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if file is public-related
is_public_file() {
    local file="$1"
    for pattern in "${PUBLIC_PATTERNS[@]}"; do
        if [[ "$file" == $pattern* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to get staged files
get_staged_files() {
    git diff --cached --name-only
}

# Function to validate commit message
validate_commit_message() {
    local commit_msg="$1"

    echo "🔍 Validating commit message..."

    # Check for AIDD prefix consistency
    if echo "$commit_msg" | grep -qi "aidd"; then
        if ! echo "$commit_msg" | grep -q "^aidd:"; then
            print_error "Commit message contains 'aidd' but doesn't use 'aidd:' prefix"
            print_error "Use: aidd: your message here"
            return 1
        fi
    fi

    # Check for proper conventional commit format
    if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|test|chore|aidd):"; then
        print_warning "Commit message doesn't follow conventional commit format"
        print_warning "Expected: type: description"
        print_warning "Types: feat, fix, docs, style, refactor, test, chore, aidd"
    fi

    print_success "Commit message validation passed"
    return 0
}

# Function to validate file changes
validate_file_changes() {
    local staged_files="$1"

    echo "🔍 Validating file changes..."

    if [[ -z "$staged_files" ]]; then
        print_warning "No files staged for commit"
        return 0
    fi

    local aidd_files=()
    local public_files=()
    local unknown_files=()

    # Categorize files
    while IFS= read -r file; do
        if [[ -z "$file" ]]; then
            continue
        fi

        if is_aidd_file "$file"; then
            aidd_files+=("$file")
        elif is_public_file "$file"; then
            public_files+=("$file")
        else
            unknown_files+=("$file")
        fi
    done <<< "$staged_files"

    # Check for mixed changes
    local has_aidd=$( [[ ${#aidd_files[@]} -gt 0 ]] && echo true || echo false )
    local has_public=$( [[ ${#public_files[@]} -gt 0 ]] && echo true || echo false )

    if [[ "$has_aidd" == true && "$has_public" == true ]]; then
        print_error "Mixed AIDD and public files in same commit!"
        echo ""
        echo "AIDD files:"
        printf '  %s\n' "${aidd_files[@]}"
        echo ""
        echo "Public files:"
        printf '  %s\n' "${public_files[@]}"
        echo ""
        print_error "Split into separate commits:"
        echo "  1. Commit AIDD files with: git commit -m 'aidd: your message'"
        echo "  2. Commit public files with: git commit -m 'feat: your message'"
        return 1
    fi

    # AIDD commit message format validation
    # AIDD files require [aidd] tag in commit message: "type: [aidd] description"
    if [[ "$has_aidd" == true ]]; then
        # During pre-commit, we can't access the commit message yet
        # This validation will be enforced through the commit-msg hook
        print_success "AIDD files detected - ensure commit message includes [aidd] tag"
        echo "  Required format: type: [aidd] description"
        echo "  Example: docs: [aidd] update memory bank with new patterns"
    fi

    if [[ "$has_public" == true ]] && [[ "$has_aidd" == false ]]; then
        print_success "Public-only commit detected - use conventional commit format"
        echo "  Example: feat: add new feature"
    fi

    # Report unknown files
    if [[ ${#unknown_files[@]} -gt 0 ]]; then
        print_warning "Unknown file categories (review classification):"
        printf '  %s\n' "${unknown_files[@]}"
    fi

    # Success message
    if [[ "$has_aidd" == true ]]; then
        print_success "AIDD-only commit validated (${#aidd_files[@]} files)"
    elif [[ "$has_public" == true ]]; then
        print_success "Public-only commit validated (${#public_files[@]} files)"
    fi

    return 0
}

# Function to check current branch
validate_branch() {
    local current_branch=$(git branch --show-current)

    echo "🔍 Validating current branch: $current_branch"

    if [[ "$current_branch" == "dev-public" ]]; then
        print_error "Direct commits to dev-public are not allowed!"
        print_error "Use the sync script to update dev-public from dev"
        return 1
    fi

    if [[ "$current_branch" == "main" ]]; then
        print_error "Direct commits to main are not allowed!"
        print_error "Use releases from dev-public branch"
        return 1
    fi

    print_success "Branch validation passed"
    return 0
}

# Function to validate current environment
validate_environment() {
    echo "🔍 Validating git environment..."

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        return 1
    fi

    # Check if there are staged changes
    if ! git diff --cached --quiet; then
        print_success "Staged changes detected"
    else
        print_warning "No staged changes found"
    fi

    return 0
}

# AIDD commit message validation with [aidd] tag format
commit_msg_hook() {
    local commit_msg_file="$1"

    echo "🛡️  AIDD Commit Message Validation"
    echo "================================="

    if [[ ! -f "$commit_msg_file" ]]; then
        print_error "Commit message file not found: $commit_msg_file"
        return 1
    fi

    local commit_msg=$(head -n1 "$commit_msg_file")

    # Get staged files to determine if AIDD files are involved
    local staged_files=$(get_staged_files)
    local aidd_files=()
    local public_files=()

    # Categorize files
    while IFS= read -r file; do
        if [[ -z "$file" ]]; then
            continue
        fi

        if is_aidd_file "$file"; then
            aidd_files+=("$file")
        elif is_public_file "$file"; then
            public_files+=("$file")
        fi
    done <<< "$staged_files"

    local has_aidd=$( [[ ${#aidd_files[@]} -gt 0 ]] && echo true || echo false )
    local has_public=$( [[ ${#public_files[@]} -gt 0 ]] && echo true || echo false )

    # Validate AIDD tag requirement: "type: [aidd] description"
    if [[ "$has_aidd" == true ]] && ! echo "$commit_msg" | grep -q "\[aidd\]"; then
        print_error "AIDD files require [aidd] tag in commit message"
        print_error "Current message: $commit_msg"
        print_error "Required format: type: [aidd] description"
        print_error "Example: docs: [aidd] update memory bank patterns"
        print_error "AIDD files in commit:"
        printf '  %s\n' "${aidd_files[@]}"
        return 1
    fi

    # Validate public files don't use [aidd] tag
    if [[ "$has_public" == true ]] && echo "$commit_msg" | grep -q "\[aidd\]"; then
        print_error "Public files cannot use [aidd] tag in commit message"
        print_error "Current message: $commit_msg"
        print_error "Use conventional commit format without [aidd] tag"
        print_error "Public files in commit:"
        printf '  %s\n' "${public_files[@]}"
        return 1
    fi

    print_success "AIDD commit message validation passed"
    return 0
}

# Main pre-commit validation
pre_commit_hook() {
    echo "🛡️  AIDD/Public Commit Validation"
    echo "=================================="

    local exit_code=0

    # Validate environment
    if ! validate_environment; then
        exit_code=1
    fi

    # Validate branch
    if ! validate_branch; then
        exit_code=1
    fi

    # Get staged files
    local staged_files=$(get_staged_files)

    # Validate file changes
    if ! validate_file_changes "$staged_files"; then
        exit_code=1
    fi

    # Summary
    echo ""
    if [[ $exit_code -eq 0 ]]; then
        print_success "All validations passed - commit allowed"
    else
        print_error "Validation failed - commit blocked"
        echo ""
        echo "Fix the issues above and try again."
    fi

    return $exit_code
}

# Main execution based on script name or argument
case "${0##*/}" in
    "pre-commit")
        pre_commit_hook
        ;;
    "validate-commit.sh")
        if [[ "$1" == "--install" ]]; then
            echo "📦 Installing git hooks..."

            # Ensure hooks directory exists
            mkdir -p .git/hooks

            # Install pre-commit hook
            cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
./scripts/validate-commit.sh --pre-commit
EOF
            chmod +x .git/hooks/pre-commit

            print_success "Git hooks installed successfully"
            echo "Pre-commit validation is now active"

        elif [[ "$1" == "--pre-commit" ]]; then
            pre_commit_hook

        elif [[ "$1" == "--commit-msg" ]]; then
            if [[ -z "$2" ]]; then
                print_error "Commit message file path required for --commit-msg"
                exit 1
            fi
            commit_msg_hook "$2"

        elif [[ "$1" == "--help" || "$1" == "-h" ]]; then
            echo "Usage: $0 [options]"
            echo ""
            echo "AIDD/Public commit validation script"
            echo ""
            echo "Options:"
            echo "  --install       Install as git pre-commit hook"
            echo "  --pre-commit    Run pre-commit validation"
            echo "  --commit-msg    Run AIDD commit message validation"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Manual validation:"
            echo "  $0                        # Run validation on staged files"
            echo ""

        else
            # Manual validation mode
            pre_commit_hook
        fi
        ;;
    *)
        print_error "Unknown execution mode"
        exit 1
        ;;
esac
