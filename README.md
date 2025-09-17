# Monica Mobile App

A mobile companion application for [Monica](https://github.com/monicahq/monica), the open-source Personal Relationship Manager (PRM) that helps you document your life and organize your interactions with family, friends, and personal relationships.

## 🎯 Project Status

**Currently in Development** - V1 targeting Android platform

This project is in active development phase with AIDD (AI-Driven Development) tooling setup complete. The Flutter mobile application is planned but not yet implemented.

## 🚀 Features (Planned V1)

- **Bidirectional Contact Sync** - Seamless synchronization between Android contacts and MonicaHQ
- **Automatic Call Logging** - Capture phone interactions with known and unknown contacts
- **Offline-First Design** - Local SQLite storage with background synchronization
- **Privacy-Focused** - Encrypted local storage, anonymized logging, minimal permissions
- **Conflict Resolution** - Smart handling of sync conflicts with manual review options
- **Undo System** - Reverse actions with comprehensive activity journal
- **Exclusion Lists** - Fine-grained control over what gets synchronized

## 📱 Platform Support

- **Android**: Primary target for V1
- **iOS**: Planned for post-V1 release

## 🔧 Installation

### For Users

**Option 1: GitHub Releases (Recommended)**
1. Go to [Releases](https://github.com/yourusername/monica-mobile-app/releases)
2. Download the latest APK
3. Enable "Install from Unknown Sources" in Android settings
4. Install the APK

**Option 2: F-Droid**
- Available on F-Droid store (coming soon)
- Automatically built from source for maximum transparency

**Note**: Google Play Store distribution is not planned for V1 due to permission requirements.

### For Developers

#### Prerequisites
- Flutter 3.x
- Android SDK 33+
- Android Studio or VS Code
- Git

#### Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/monica-mobile-app.git
cd monica-mobile-app

# Install Flutter dependencies
flutter pub get

# Run on Android device/emulator
flutter run
```

#### Development Environment
```bash
# Setup linting after git pull
make setup-linting

# Run tests
flutter test
flutter test integration_test

# Code analysis
make analyze
# or
dart analyze
```

## 🔐 Security & Privacy

Monica Mobile App prioritizes your privacy:

- **Local Encryption**: All local data encrypted with SQLCipher
- **Secure Storage**: API tokens stored in Android Keystore
- **TLS Only**: All network communication uses strict TLS
- **Anonymized Logging**: Personal information never logged
- **Minimal Permissions**: Only requests essential Android permissions

See [SECURITY.md](SECURITY.md) for security policy and [PRIVACY.md](PRIVACY.md) for detailed privacy practices.

## 🎛️ Configuration

### MonicaHQ Setup
1. Self-host Monica or use Monica Cloud
2. Generate API token in Monica settings
3. Configure in mobile app during first setup

### Sync Settings
- Sync frequency (default: every 4 hours)
- Auto-log calls (on/off)
- Conflict resolution preference
- Excluded contacts/numbers

## 🏗️ Architecture

- **Frontend**: Flutter with Material Design 3
- **State Management**: Riverpod 2
- **Local Database**: SQLite with SQLCipher encryption
- **Background Tasks**: WorkManager for reliable sync
- **Architecture Pattern**: MVVM with DDD principles

## 📚 Documentation

- [Security Policy](SECURITY.md)
- [Privacy Policy](PRIVACY.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## 🤝 Contributing

We welcome contributions! Please read our [Code of Conduct](CODE_OF_CONDUCT.md) first.

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Follow Flutter best practices and coding standards
4. Ensure tests pass and build succeeds
5. Submit a pull request

### Reporting Issues
- **Bugs**: Use GitHub Issues with bug report template
- **Feature Requests**: Use GitHub Issues with feature request template
- **Security Issues**: Follow [SECURITY.md](SECURITY.md) reporting process

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Code analysis
dart analyze

# Performance tests
flutter test --coverage
```

## 📦 Building

### Development Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

### F-Droid Compatible Build
```bash
flutter build apk --release --flavor foss
```

## 🗂️ Project Structure

```
/
├── android/                 # Android-specific configuration
├── lib/                     # Flutter application code
│   ├── core/                # Shared utilities and configuration
│   ├── features/            # Feature-based modules
│   └── services/            # External service integrations
├── test/                    # Unit tests
├── integration_test/        # Integration tests
└── docs/                    # Additional documentation
```

## 📄 License

This project is licensed under the GNU Affero General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Monica PRM](https://github.com/monicahq/monica) - The main Monica project
- [Monica Documentation](https://docs.monicahq.com/) - Official Monica docs
- [F-Droid](https://f-droid.org/) - Open source Android app repository

## 🙏 Acknowledgments

- AIDD Community for method, tooling and all the exchange
- Monica team for creating an amazing PRM platform
- Flutter team for the excellent mobile framework
- Open source community for tools and libraries

---

**Monica Mobile App** - Nurture your relationships, everywhere you go.