# Instruction: Fix AIDD Commit Message Validation False Positive

## Feature

- **Summary**: Fix git pre-commit validation script that incorrectly rejects valid AIDD commits due to reading previous commit message instead of current commit message during validation
- **Stack**: `Bash scripting`, `Git hooks`, `Lefthook`

## Existing files

- @scripts/validate-commit.sh

### New file to create

No new files required

## Implementation phases

### Phase 1: Fix commit message retrieval logic

> Replace incorrect git log command with proper current commit message reading mechanism

1. Analyze current pre-commit hook execution context to determine available commit message sources
2. Replace line 152 `git log --format=%s -1` with proper commit message retrieval for pre-commit phase
3. Handle cases where commit message might not be available yet in pre-commit context
4. Update validation logic to work with current commit message instead of previous one

### Phase 2: Testing and validation

> Ensure fix works correctly and doesn't break existing functionality

1. Test script with sample AIDD commits that previously failed
2. Verify public file validation still works correctly
3. Test mixed commit detection still functions
4. Validate branch protection rules remain intact

## Reviewed implementation

- [ ] Phase 1
- [ ] Phase 2

## Validation flow

1. Stage some AIDD files for commit
2. Create commit with proper aidd: prefix message
3. Verify pre-commit hook passes validation
4. Test with public files and non-aidd prefix to ensure proper rejection
5. Test mixed AIDD/public files to ensure proper blocking

## Estimations

- **Confidence**: 9/10 - Clear root cause identified, straightforward bash scripting fix required
- **Time to implement**: 30 minutes - Simple logic change with minimal testing neededtest change
test local config
test local config 2
