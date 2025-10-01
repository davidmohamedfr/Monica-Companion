# Commit Guidelines

## Critical Rule: AIDD vs Public Commits Separation

### Absolute Prohibition
**NEVER mix AIDD documentation files with public code changes in the same commit.**

AIDD files include:
- `aidd-docs/**/*` (all files under aidd-docs directory)
- Any planning, documentation, or task tracking files

Public files include:
- `lib/**/*` (application code)
- `test/**/*` (test code)
- `integration_test/**/*` (integration tests)
- Configuration files (pubspec.yaml, analysis_options.yaml, etc.)
- CI/CD files (.github/workflows/*)

### Correct Workflow

#### Task Implementation Sequence
1. **FIRST**: Create and commit the plan
   ```bash
   git add aidd-docs/tasks/YYYY_MM_DD-task_name.md
   git commit -m "docs: [aidd] task planning for X"
   ```

2. **THEN**: Implement the changes
   ```bash
   git add lib/ test/
   git commit -m "feat: implement X"
   ```

#### Example: Feature Implementation
```bash
# Step 1: Plan committed BEFORE implementation
git add aidd-docs/tasks/2025_10_01-contacts_feature.md
git commit -m "docs: [aidd] plan contacts feature implementation"

# Step 2: Implementation committed separately
git add lib/features/contacts/
git commit -m "feat: add contacts list with search and filters"

# Step 3: Tests committed separately
git add test/features/contacts/
git commit -m "test: add comprehensive contacts feature tests"
```

### Commit Prefixes

#### AIDD Commits (always with [aidd] tag)
- `docs: [aidd] <description>` - Planning, task docs, memory bank updates
- Must only contain files in `aidd-docs/` directory
- Examples:
  - `docs: [aidd] plan user authentication flow`
  - `docs: [aidd] document testing best practices`
  - `docs: [aidd] update architecture decisions`

#### Public Commits (never with [aidd] tag)
- `feat:` - New features
- `fix:` - Bug fixes
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `docs:` - Documentation changes (without [aidd])
- `style:` - Code formatting
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements

### Anti-Patterns to Avoid

❌ **WRONG**: Mixing AIDD and public files
```bash
git add -A  # DANGEROUS: stages everything
git commit -m "fix: remove obsolete code"
# Contains: lib/, test/, AND aidd-docs/
```

❌ **WRONG**: Implementing before committing plan
```bash
# Implement changes first
git add lib/features/new_feature/
# Then create plan
git add aidd-docs/tasks/plan.md
git commit -m "feat: new feature"  # Mixed!
```

✅ **CORRECT**: Separate commits with explicit paths
```bash
# Commit plan first
git add aidd-docs/tasks/2025_10_01-plan.md
git commit -m "docs: [aidd] plan for new feature"

# Then implement
git add lib/features/new_feature/
git commit -m "feat: add new feature"
```

### Git Commands Best Practices

#### Safe Staging Commands
```bash
# Add specific directories
git add lib/
git add test/
git add aidd-docs/tasks/specific_file.md

# Add by pattern (public files only)
git add 'lib/**/*.dart'
git add 'test/**/*.dart'

# Add by pattern (AIDD files only)
git add 'aidd-docs/**/*.md'
```

#### Dangerous Commands (Use with Caution)
```bash
# AVOID: stages everything including mixed files
git add -A
git add .

# Instead, always be explicit
git add lib/ test/  # For implementation commits
git add aidd-docs/  # For AIDD commits
```

### Verification Checklist

Before committing, verify:
- [ ] Check staged files: `git status --short`
- [ ] Ensure only AIDD files OR only public files are staged
- [ ] Plan committed before implementation starts
- [ ] Correct commit prefix used
- [ ] No mixed file types in single commit

### Recovery from Mixed Commits

If a mixed commit occurs:
```bash
# Reset the mixed commit
git reset --soft HEAD~1

# Stage AIDD files separately
git add aidd-docs/
git commit -m "docs: [aidd] <description>"

# Stage public files separately
git add lib/ test/
git commit -m "feat/fix: <description>"
```

### Rationale

This separation ensures:
1. **Clear history**: AIDD planning vs implementation clearly separated
2. **Proper sequencing**: Plans committed before implementation starts
3. **Clean reviews**: Reviewers see planning and code changes separately
4. **Audit trail**: Track when planning happened vs when implementation occurred
5. **Rollback safety**: Can revert implementation without losing planning docs
