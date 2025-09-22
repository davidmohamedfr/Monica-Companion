# AIDD/Public Git Separation Workflow

## Overview

This document outlines the strategy for maintaining complete separation between AIDD (AI-Driven Development) tooling and public project code, ensuring that AIDD never appears in public Git history.

## Branch Strategy

### Primary Branches

- **`dev`**: Private development branch containing AIDD tooling and project code
- **`dev-public`**: Public-facing branch with zero AIDD traces, clean history
- **`main`**: Production releases (synced from `dev-public`)

### Branch Relationships

```
dev (private) ──filter──> dev-public (public) ──release──> main
     │                           │
     │ AIDD tooling              │ Clean project code only
     │ All commits               │ Filtered commits
```

## File Classification

### AIDD Files (Private Only)
- `.opencode/` directory and contents
- `aidd-docs/` directory and contents
- `AGENTS.md`
- `CLAUDE.md`
- `opencode.jsonc`
- Any files with AIDD-specific content

### Public Files
- `lib/` - Flutter application code
- `test/` - Test files
- `android/`, `ios/` - Platform-specific code
- `pubspec.yaml` - Flutter dependencies
- `README.md`, `LICENSE` - Documentation
- `docs/` - Public documentation
- CI/CD configuration files
- `analysis_options.yaml`

### Mixed Files (Content Filtering Required)
- `.gitignore` - May contain AIDD-specific excludes
- Build scripts that might reference AIDD paths

## Commit Conventions

### On `dev` Branch (Private)
- Use clear prefixes to identify commit types:
  - `aidd:` - AIDD tooling changes only
  - `feat:`, `fix:`, `chore:` etc. - Public project changes only
- **Never mix AIDD and public changes in single commit**

### On `dev-public` Branch
- Only contains filtered commits from `dev`
- No manual commits allowed
- All changes come through sync process

## Workflow Scripts

### 1. History Cleanup (`scripts/clean-public-history.sh`)
One-time script to create clean `dev-public` branch:
- Removes all AIDD commits from history
- Filters out AIDD files from remaining commits
- Creates new clean branch

### 2. Branch Sync (`scripts/sync-to-public.sh`)
Ongoing maintenance script:
- Syncs new commits from `dev` to `dev-public`
- Automatically filters out AIDD content
- Maintains clean public history

### 3. Pre-commit Validation (`scripts/validate-commit.sh`)
Enforcement through git hooks:
- Prevents mixing AIDD and public files in commits
- Validates commit message prefixes
- Blocks commits that would expose AIDD

## Usage Guidelines

### Daily Development
1. Work on `dev` branch normally
2. Commit AIDD changes with `aidd:` prefix
3. Commit project changes with standard prefixes
4. Run sync script periodically to update `dev-public`

### Pre-release Process
1. Ensure all changes are committed to `dev`
2. Run sync script to update `dev-public`
3. Verify `dev-public` has no AIDD traces
4. Create release from `dev-public`

### Emergency AIDD Exposure
If AIDD content accidentally appears in public history:
1. Stop all work immediately
2. Run history cleanup script
3. Force-push cleaned `dev-public` branch
4. Notify team of history rewrite

## Validation Commands

### Check for AIDD traces in public branch:
```bash
# Switch to public branch
git checkout dev-public

# Search for AIDD references
git log --all --grep="aidd" --grep="AIDD" -i
git log --all --name-only | grep -E "(opencode|aidd-docs|AGENTS|CLAUDE)"

# Verify file structure
find . -name "*aidd*" -o -name "*opencode*" -o -name "AGENTS.md" -o -name "CLAUDE.md"
```

### Verify commit separation:
```bash
# Check recent commits for mixed content
git log --name-only -10 | grep -E "(aidd|opencode)" && echo "AIDD FOUND!" || echo "Clean"
```

## Security Notes

- **Never push `dev` branch to public remotes**
- **Always verify `dev-public` before sharing**
- **Backup before running history cleanup scripts**
- **Double-check automation scripts before execution**

## Recovery Procedures

### If AIDD leaked to public:
1. Immediate containment: Make repository private
2. Run emergency cleanup scripts
3. Rewrite public history
4. Verify complete AIDD removal
5. Restore public access only after verification

### If history corruption occurs:
1. Restore from backup branch (`backup-dev-YYYYMMDD-HHMMSS`)
2. Re-run separation process
3. Validate before proceeding

## Automation Status

- ✅ History cleanup script
- ✅ Branch sync automation
- ✅ Pre-commit validation hooks
- ✅ Public branch verification
- ✅ Emergency cleanup procedures