#!/usr/bin/env bash
# Wrapper script to run flutter commands with proper environment
# Usage: ./scripts/flutter_with_env.sh <flutter-command-and-args>

# Try common Flutter installation paths (order by likelihood)
FLUTTER_PATHS=(
  "$HOME/dev/src/flutter/bin"
  "$HOME/flutter/bin"
  "$HOME/.flutter/bin"
  "$HOME/fvm/default/bin"
  "/usr/local/flutter/bin"
  "/opt/flutter/bin"
  "$HOME/Library/Flutter/bin"
)

# Find and add Flutter to PATH
FLUTTER_FOUND=false
for flutter_path in "${FLUTTER_PATHS[@]}"; do
  if [ -d "$flutter_path" ] && [ -x "$flutter_path/flutter" ]; then
    export PATH="$flutter_path:$PATH"
    FLUTTER_FOUND=true
    break
  fi
done

# If not found in common paths, search for flutter in PATH
if [ "$FLUTTER_FOUND" = false ]; then
  # Check if flutter is already in PATH
  if command -v flutter >/dev/null 2>&1; then
    FLUTTER_FOUND=true
  else
    # Try to extract PATH from shell profiles
    for profile in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
      if [ -f "$profile" ]; then
        # Extract PATH assignments and evaluate them
        while IFS= read -r line; do
          if echo "$line" | grep -q '^export PATH='; then
            eval "$line"
          fi
        done < "$profile"
      fi
    done
  fi
fi

# Prevent git hooks from interfering with Flutter's git operations
export GIT_OPTIONAL_LOCKS=0

# When run from git hooks, git environment variables can interfere with Flutter's
# own git operations (Flutter SDK is itself a git repo). Unset them temporarily.
unset GIT_DIR
unset GIT_WORK_TREE
unset GIT_INDEX_FILE

# Run flutter with all passed arguments
exec flutter "$@"
