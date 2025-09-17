#!/bin/bash

# Setup script for Monica Mobile App linting configuration
# Run this script after git pull to ensure all linting tools are properly configured

set -e

echo "🔧 Setting up linting configuration..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Install lefthook if not present
if ! command -v lefthook &> /dev/null; then
    echo "📦 Installing lefthook..."
    
    # Try different package managers
    if command -v brew &> /dev/null; then
        brew install lefthook
    elif command -v npm &> /dev/null; then
        npm install -g @arkweid/lefthook
    elif command -v go &> /dev/null; then
        go install github.com/evilmartians/lefthook@latest
    else
        echo "❌ Please install lefthook manually: https://github.com/evilmartians/lefthook"
        exit 1
    fi
fi

# Install git hooks
echo "🔗 Installing git hooks..."
lefthook install

# Verify Flutter installation (if available)
if command -v flutter &> /dev/null; then
    echo "✅ Flutter detected: $(flutter --version | head -1)"
    
    # Get dependencies if pubspec.yaml exists
    if [ -f "pubspec.yaml" ]; then
        echo "📦 Getting Flutter dependencies..."
        flutter pub get
    fi
    
    # Verify linting configuration
    echo "🔍 Verifying linting configuration..."
    if [ -f "analysis_options.yaml" ]; then
        echo "✅ analysis_options.yaml found"
    else
        echo "❌ analysis_options.yaml missing"
        exit 1
    fi
    
else
    echo "⚠️  Flutter not installed or not in PATH"
    echo "   Install Flutter: https://docs.flutter.dev/get-started/install"
fi

# Deploy IDE configurations
echo "🏗️  Deploying IDE configurations..."

# VS Code configuration
if [ -d ".vscode" ] || [ "$1" = "--force-vscode" ]; then
    mkdir -p .vscode
    if [ -f "templates/ide/vscode-settings.json" ]; then
        cp templates/ide/vscode-settings.json .vscode/settings.json
        echo "✅ VS Code settings deployed"
    else
        echo "⚠️  VS Code template not found"
    fi
else
    echo "📝 VS Code not detected (run with --force-vscode to deploy anyway)"
fi

# Android Studio configuration
if [ -d ".idea" ] || [ "$1" = "--force-idea" ]; then
    mkdir -p .idea/codeStyles .idea/inspectionProfiles
    
    if [ -f "templates/ide/android-studio-project.xml" ]; then
        cp templates/ide/android-studio-project.xml .idea/codeStyles/Project.xml
        echo '<?xml version="1.0" encoding="UTF-8"?>' > .idea/codeStyles/codeStyleConfig.xml
        echo '<component name="ProjectCodeStyleConfiguration">' >> .idea/codeStyles/codeStyleConfig.xml
        echo '  <state>' >> .idea/codeStyles/codeStyleConfig.xml
        echo '    <option name="USE_PER_PROJECT_SETTINGS" value="true" />' >> .idea/codeStyles/codeStyleConfig.xml
        echo '  </state>' >> .idea/codeStyles/codeStyleConfig.xml
        echo '</component>' >> .idea/codeStyles/codeStyleConfig.xml
        echo "✅ Android Studio code styles deployed"
    fi
    
    if [ -f "templates/ide/android-studio-inspections.xml" ]; then
        cp templates/ide/android-studio-inspections.xml .idea/inspectionProfiles/Project_Default.xml
        echo '<?xml version="1.0" encoding="UTF-8"?>' > .idea/inspectionProfiles/profiles_settings.xml
        echo '<component name="InspectionProjectProfileManager">' >> .idea/inspectionProfiles/profiles_settings.xml
        echo '  <settings>' >> .idea/inspectionProfiles/profiles_settings.xml
        echo '    <option name="USE_PROJECT_PROFILE" value="true" />' >> .idea/inspectionProfiles/profiles_settings.xml
        echo '    <version value="1.0" />' >> .idea/inspectionProfiles/profiles_settings.xml
        echo '  </settings>' >> .idea/inspectionProfiles/profiles_settings.xml
        echo '</component>' >> .idea/inspectionProfiles/profiles_settings.xml
        echo "✅ Android Studio inspection profiles deployed"
    fi
else
    echo "📝 Android Studio not detected (run with --force-idea to deploy anyway)"
fi

# Check if dart is available for local linting
if command -v dart &> /dev/null; then
    echo "✅ Dart SDK available for linting"
    
    # Run a quick analysis if there are Dart files
    if find . -name "*.dart" -not -path "./.dart_tool/*" -not -path "./build/*" | grep -q .; then
        echo "🔍 Running quick lint check..."
        dart analyze --fatal-warnings || echo "⚠️  Linting issues found - will be enforced on commit"
    fi
else
    echo "⚠️  Dart SDK not available - install Flutter to enable local linting"
fi

echo ""
echo "🎉 Linting configuration setup complete!"
echo ""
echo "📚 Documentation: docs/LINTING.md"
echo "🔧 Configuration: analysis_options.yaml"
echo "🚀 CI/CD: .github/workflows/lint.yml"
echo "🔗 Git hooks: lefthook.yml"
echo ""
echo "💡 Tips:"
echo "   • Linting runs automatically on commit"
echo "   • Use 'dart analyze' to check manually"
echo "   • Use 'dart format .' to format code"
echo "   • Use 'dart fix --apply' for auto-fixes"
echo "   • Copy lefthook-local.yml.template for personal hooks"