#!/bin/bash
# Setup Flutter environment for git hooks
# This script sources the user's shell profile to ensure Flutter is in PATH

# Try to source common shell profiles
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc" 2>/dev/null
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" 2>/dev/null
[ -f "$HOME/.bash_profile" ] && source "$HOME/.bash_profile" 2>/dev/null

# Export PATH to make it available to subsequent commands
export PATH
