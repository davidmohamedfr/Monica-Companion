# Security Policy

## Supported Versions

Monica Mobile App follows a rolling release model. Security updates are provided for:

| Version | Supported          |
| ------- | ------------------ |
| Latest Release | ✅ |
| Previous Release | ✅ (30 days) |
| Older Versions | ❌ |

Currently in development - V1 has not been released yet.

## Security Features

Monica Mobile App implements multiple security layers:

### Data Protection
- **Local Encryption**: All local data encrypted using SQLCipher
- **Secure Storage**: API tokens stored in Android Keystore (hardware-backed when available)
- **Key Derivation**: Encryption keys derived from device-specific, non-exportable sources
- **Database Security**: No plaintext personal data stored locally

### Network Security
- **TLS Enforcement**: All API communication requires valid TLS certificates
- **Certificate Pinning**: Planned for production releases
- **API Token Security**: Bearer tokens with secure generation and storage
- **No Fallback**: HTTP connections explicitly rejected

### Privacy Protection
- **Anonymized Logging**: Personal information (phone numbers, emails) masked in logs
- **Minimal Permissions**: Only requests essential Android permissions
- **Local-First**: Data synchronized only with user-configured MonicaHQ instance
- **No Telemetry**: No usage analytics or tracking in F-Droid builds

### Application Security
- **Code Obfuscation**: Release builds use Flutter's obfuscation
- **Root Detection**: Planned for sensitive operations
- **Debug Protection**: Debug features disabled in release builds
- **Integrity Checks**: APK signature verification

## Reporting a Vulnerability

**Note: Public security vulnerability reporting is not currently supported as this project is in early development phase.**

For security concerns during development:

### How to Report

1. **GitHub Issues**: Use GitHub issues for all security discussions
2. **Development Focus**: Security reporting will be formalized upon V1 release

### What to Include

Please provide as much information as possible:

- **Vulnerability Type**: What kind of security issue
- **Impact Assessment**: How the vulnerability could be exploited
- **Reproduction Steps**: Detailed steps to reproduce the issue
- **Affected Versions**: Which versions are vulnerable
- **Environment**: Device, Android version, MonicaHQ version
- **Proof of Concept**: If available (be responsible)

### Response Timeline

**Development Phase**: Response times will be established upon V1 release. Currently, security discussions are handled on a best-effort basis through GitHub issues.

### Severity Guidelines

**Critical**
- Remote code execution
- Authentication bypass
- Data exfiltration vulnerabilities
- Privilege escalation to root/system

**High**
- Local privilege escalation
- Sensitive data exposure
- Authentication weaknesses
- Cryptographic failures

**Medium**
- Information disclosure
- Denial of service
- Input validation issues
- Configuration vulnerabilities

**Low**
- UI/UX security improvements
- Documentation issues
- Minor information leakage

## Security Process

### Development Phase Approach
**Current Status**: Formal security processes will be established upon V1 release.

**Development Phase**:
- Security discussions handled through GitHub issues
- Code review includes security considerations
- Community feedback welcomed on security design
- Security best practices implemented from the start

### Future Security Process (Post-V1)
- Formal vulnerability assessment procedures
- Coordinated disclosure timeline
- Security patch release process
- Community security researcher recognition

## Security Best Practices for Users

### Installation Security
- **Official Sources**: Only install from GitHub Releases or F-Droid
- **Verify Signatures**: Check APK signatures match official releases
- **Avoid Sideloading**: Don't install from unknown third-party sources

### Usage Security
- **Keep Updated**: Install security updates promptly
- **Strong Passwords**: Use strong MonicaHQ passwords
- **Network Security**: Use trusted networks for initial setup
- **Device Security**: Keep Android system updated

### Data Protection
- **Backup Strategy**: Understand local vs. cloud data backup
- **Device Locking**: Use device lock screen protection
- **App Permissions**: Review and understand granted permissions
- **MonicaHQ Security**: Secure your MonicaHQ instance properly

## Security Configuration

### Recommended MonicaHQ Setup
```
# Enable in MonicaHQ .env
APP_ENV=production
APP_DEBUG=false
HTTPS_ONLY=true
SESSION_SECURE_COOKIE=true
```

### App Security Settings
- Enable automatic security updates
- Use strong device authentication
- Configure app-specific password if available
- Regular security review of connected devices in MonicaHQ

## Incident Response

**Development Phase**: Formal incident response procedures will be established upon V1 release.

**Current Approach**:
- Security issues discussed openly through GitHub issues
- Community-driven security review and feedback
- Fixes implemented through standard development process

## Security Resources

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security-testing-guide/)
- [Android Security Guidelines](https://developer.android.com/topic/security)
- [Flutter Security](https://docs.flutter.dev/security)
- [MonicaHQ Security Docs](https://docs.monicahq.com/installation/security)

## Contact

For security-related questions or concerns:
- **GitHub Issues**: Use GitHub Issues for all security discussions
- **GitHub Discussions**: For security best practices and general questions

**Note**: Formal security contact procedures will be established upon V1 release.

---

**Last Updated**: September 2025  
**Version**: 0.0.1