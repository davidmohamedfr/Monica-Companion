# Instruction: Rebase contacts UI branch onto dev

## Feature

- **Summary**: Rebase branch 19-ui-contacts-liste-recherche onto dev branch to integrate latest changes, automatically resolve conflicts using project context, and verify integrity through tests and linting
- **Stack**: `Git 2.x`, `Flutter >=3.35.0`, `Dart >=3.8.0`

## Existing files

- @.git/config
- @aidd-docs/memory-bank/mobile/TESTING.md
- @aidd-docs/memory-bank/mobile/CODING_ASSERTIONS.md
- @analysis_options.yaml
- @lib/features/contacts/**
- @test/features/contacts/**
- @integration_test/contacts_**

### New file to create

None

## Implementation phases

### Phase 1: Pre-rebase preparation

> Verify current state and gather information for conflict resolution

1. Check current branch status and confirm clean working tree
2. Fetch latest dev branch changes
3. Identify potential conflict areas by analyzing diff between branches
4. Document current HEAD for rollback reference

### Phase 2: Execute rebase with conflict resolution

> Rebase onto dev and automatically resolve conflicts using project documentation

1. Start interactive rebase onto dev branch
2. For each conflict, analyze using project documentation context
3. Apply conflict resolution following project coding standards
4. Continue rebase until completion
5. Verify all 5 commits are cleanly applied

### Phase 3: Post-rebase verification

> Run comprehensive tests and linting to ensure integrity

1. Run dart format check on all modified files
2. Run flutter analyze to verify no analysis issues
3. Execute unit tests for contacts feature
4. Execute integration tests for contacts feature
5. Verify all tests pass and no regressions introduced

## Reviewed implementation

- [ ] Phase 1
- [ ] Phase 2
- [ ] Phase 3

## Validation flow

1. Verify branch rebased successfully with all 5 commits preserved
2. Confirm no git conflicts remain
3. Check all tests pass without failures
4. Verify linting produces no errors
5. Confirm branch history is clean and linear

## Estimations

- Confidence: 8/10
  - ✅ Clean branch with well-documented changes
  - ✅ Comprehensive test coverage to catch regressions
  - ✅ Project documentation available for conflict resolution
  - ❌ Potential conflicts in documentation files (TESTING.md, CODING_ASSERTIONS.md)
  - ❌ Dev branch has significant changes that may conflict
- Time to implement: 10-15 minutes
