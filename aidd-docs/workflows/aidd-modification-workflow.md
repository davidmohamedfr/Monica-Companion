# AIDD Modification Workflow

## Purpose

This workflow ensures proper separation between AIDD tooling and public codebase while allowing AIDD-specific configurations to be tracked and version-controlled within AIDD development context.

## Files Requiring This Workflow

- `lefthook-local.yml` - AIDD-specific git hooks configuration
- Any other AIDD configuration files that need version control but should not reach public branches

## Standard Workflow for AIDD Modifications

### 1. Prepare for AIDD Commit

```bash
# Remove AIDD file from gitignore temporarily
git checkout .gitignore
sed -i '' '/lefthook-local.yml/d' .gitignore
git add .gitignore
git commit -m "chore: temporarily remove lefthook-local.yml from gitignore for AIDD update"
```

### 2. Make AIDD Changes

```bash
# Make your AIDD modifications
vim lefthook-local.yml  # or other AIDD files

# Stage and commit AIDD changes
git add lefthook-local.yml
git commit -m "aidd: your AIDD modification description"
```

### 3. Restore Protection

```bash
# Re-add file to gitignore
echo "lefthook-local.yml" >> .gitignore
git add .gitignore
git commit -m "chore: re-add lefthook-local.yml to gitignore after AIDD update"
```

## Why This Workflow Is Necessary

### AIDD/Public Separation Requirements
- **Public branches** should not contain AIDD-specific configurations
- **AIDD development** needs version control for configurations
- **Sync scripts** filter out AIDD content when creating public branches

### Benefits
1. **Version Control**: AIDD configurations are tracked and can be reverted
2. **Team Collaboration**: AIDD team members can share configuration changes
3. **Clean Public Code**: Public branches remain free of AIDD contamination
4. **Audit Trail**: Clear history of AIDD configuration evolution

## Automated Helpers

### Quick AIDD Modification Script

Create a helper script for this workflow:

```bash
#!/bin/bash
# File: scripts/aidd-modify.sh

AIDD_FILES=("lefthook-local.yml")

echo "🔧 Starting AIDD modification workflow..."

# Step 1: Remove from gitignore
for file in "${AIDD_FILES[@]}"; do
    sed -i '' "/$file/d" .gitignore
done
git add .gitignore
git commit -m "chore: temporarily remove AIDD files from gitignore for update"

echo "✅ AIDD files ready for modification"
echo "📝 Make your changes, then run: scripts/aidd-restore.sh"
```

### Restoration Script

```bash
#!/bin/bash
# File: scripts/aidd-restore.sh

AIDD_FILES=("lefthook-local.yml")

echo "🔒 Restoring AIDD protection..."

# Re-add to gitignore
for file in "${AIDD_FILES[@]}"; do
    echo "$file" >> .gitignore
done

git add .gitignore
git commit -m "chore: restore AIDD files to gitignore after update"

echo "✅ AIDD separation restored"
```

## Integration with AIDD Validation

The `scripts/validate-commit.sh` enforces this separation by:

1. **Detecting AIDD content** in commits
2. **Requiring `aidd:` prefix** for AIDD-related changes
3. **Preventing mixed commits** that contain both AIDD and public content
4. **Validating file categorization** against known patterns

## Branch Sync Considerations

When syncing to public branches (`dev-public`):

1. **AIDD files are filtered out** by sync scripts
2. **Only public content** reaches public branches
3. **History is cleaned** of AIDD references
4. **Proper separation is maintained** automatically

This workflow ensures that AIDD development can proceed normally while maintaining clean separation for public consumption.