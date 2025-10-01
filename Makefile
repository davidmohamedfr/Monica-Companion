# Monica Mobile App - Development Commands

.PHONY: setup-linting lint format analyze deps clean help test-integration

# Setup linting configuration (run after git pull)
setup-linting:
	@echo "🔧 Setting up linting configuration..."
	@chmod +x scripts/setup-linting.sh
	@./scripts/setup-linting.sh

# Install git hooks
install-hooks:
	@echo "🔗 Installing git hooks..."
	@lefthook install

# Run linting checks
lint: analyze

# Format all Dart code
format:
	@echo "🎨 Formatting Dart code..."
	@dart format .

# Analyze code for issues
analyze:
	@echo "🔍 Analyzing code..."
	@dart analyze --fatal-warnings

# Get Flutter dependencies
deps:
	@echo "📦 Getting dependencies..."
	@flutter pub get

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@flutter clean
	@rm -rf build/

# Run tests
test:
	@echo "🧪 Running tests..."
	@flutter test

# Run integration tests with permissions granted
test-integration:
	@echo "🧪 Running integration tests..."
	@echo "📱 Building debug APK..."
	@flutter build apk --debug
	@echo "📲 Installing APK with permissions granted (-g flag)..."
	@adb install -r -g build/app/outputs/flutter-apk/app-debug.apk
	@echo "🚀 Running integration tests..."
	@flutter test integration_test/

# Build debug APK
build-debug:
	@echo "🔨 Building debug APK..."
	@flutter build apk --debug

# Build release APK
build-release:
	@echo "🚀 Building release APK..."
	@flutter build apk --release

# Show help
help:
	@echo "📚 Available commands:"
	@echo "  setup-linting     - Setup linting configuration after git pull"
	@echo "  install-hooks     - Install git hooks"
	@echo "  format            - Format all Dart code"
	@echo "  analyze           - Analyze code for issues"
	@echo "  lint              - Alias for analyze"
	@echo "  deps              - Get Flutter dependencies"
	@echo "  test              - Run unit tests"
	@echo "  test-integration  - Run integration tests with permissions granted (-g)"
	@echo "  clean             - Clean build artifacts"
	@echo "  build-debug       - Build debug APK"
	@echo "  build-release     - Build release APK"
	@echo "  help              - Show this help message"