# Privacy Policy

**Last Updated**: September 2025  
**Effective Date**: Upon V1 Release

Monica Mobile App is committed to protecting your privacy. This policy explains how we handle your personal information.

## Our Privacy Principles

1. **Local-First**: Your data stays on your device and your MonicaHQ instance
2. **Minimal Collection**: We only access data necessary for core functionality
3. **No Tracking**: No analytics, advertising, or behavioral tracking
4. **User Control**: You control what data is synchronized and when
5. **Transparency**: Open source code allows full privacy verification

## Data We Access

### Contact Information
- **What**: Names, phone numbers, email addresses from your Android contacts
- **Why**: To synchronize with your MonicaHQ instance
- **Where**: Stored locally in encrypted database, synchronized to your MonicaHQ
- **Control**: You can exclude specific contacts from synchronization

### Call Logs
- **What**: Phone numbers, call duration, call timestamps, call direction
- **Why**: To automatically log interactions with your contacts
- **Where**: Processed locally, interaction records sent to your MonicaHQ
- **Control**: Auto-logging can be disabled; you control which numbers are logged

### App Usage Data
- **What**: Operation logs (anonymized), sync timestamps, error logs
- **Why**: For troubleshooting and ensuring reliable synchronization
- **Where**: Stored locally only, never transmitted
- **Control**: Logs can be manually cleared from app settings

## Data We Do NOT Collect

- **Call Content**: We never access call recordings or conversation content
- **Location Data**: No location tracking or GPS access
- **Personal Files**: No access to photos, documents, or other files
- **Browsing History**: No web browsing or app usage tracking
- **Advertising Data**: No advertising IDs or marketing profiles
- **Analytics**: No usage analytics or performance metrics (F-Droid builds)

## How Data is Protected

### Local Storage
- **Encryption**: All local data encrypted with SQLCipher using device-specific keys
- **Key Management**: Encryption keys stored in Android Keystore (hardware-backed when available)
- **Access Control**: App-specific storage, not accessible to other apps
- **Backup Protection**: Encrypted data remains encrypted in device backups

### Data Transmission
- **TLS Encryption**: All communication with MonicaHQ uses strict TLS 1.2+
- **API Security**: Bearer token authentication with secure storage
- **No Third Parties**: Direct communication only with your MonicaHQ instance
- **Certificate Validation**: Strict certificate validation prevents man-in-the-middle attacks

### Anonymization
- **Log Sanitization**: Phone numbers and emails masked in application logs
- **Error Reporting**: No personal information included in error reports
- **Debug Information**: Personal data excluded from debug outputs

## Your MonicaHQ Instance

Monica Mobile App synchronizes with your self-hosted or cloud MonicaHQ instance:

- **Data Destination**: Your data is sent only to the MonicaHQ instance you configure
- **MonicaHQ Privacy**: Your MonicaHQ instance's privacy policy applies to synchronized data
- **Third-Party Responsibility**: We are not responsible for how your MonicaHQ instance handles data
- **Control**: You can stop synchronization and delete local data at any time

## Permissions Explained

Monica Mobile App requests minimal Android permissions:

### Required Permissions

**Contacts (`READ_CONTACTS`, `WRITE_CONTACTS`)**
- **Purpose**: Read and update your contact list for synchronization
- **Scope**: Only contacts, no access to other personal data
- **Control**: Required for core functionality

**Phone (`READ_PHONE_STATE`, `READ_CALL_LOG`)**
- **Purpose**: Detect calls and log interactions automatically
- **Scope**: Call metadata only, no access to call content
- **Control**: Can be disabled; app will work in reduced mode

**Internet (`INTERNET`, `ACCESS_NETWORK_STATE`)**
- **Purpose**: Communicate with your MonicaHQ instance
- **Scope**: Only communicates with configured MonicaHQ API
- **Control**: Required for synchronization

### Optional Permissions

**Storage (`WRITE_EXTERNAL_STORAGE`)**
- **Purpose**: Export anonymized logs for troubleshooting
- **Scope**: Only for user-initiated log exports
- **Control**: Completely optional

## Build Variants and Privacy

### F-Droid Build (`foss`)
- **Crash Reporting**: Disabled
- **Analytics**: None
- **Network**: Only MonicaHQ API communication
- **Tracking**: Zero third-party tracking

### Standard Build (`std`)
- **Crash Reporting**: Optional, disabled by default
- **Analytics**: None
- **Network**: Only MonicaHQ API communication
- **Tracking**: Zero third-party tracking

## Data Control and Rights

### Your Control Options
- **Sync Control**: Enable/disable synchronization per data type
- **Exclusion Lists**: Exclude specific contacts or phone numbers
- **Data Deletion**: Clear all local data from app settings
- **Export Logs**: Export anonymized logs for troubleshooting

### Data Portability
- **Standard Formats**: Contact data uses standard vCard format
- **API Access**: Full access to your data through MonicaHQ API
- **Export Features**: Export functionality through MonicaHQ interface

### Data Deletion
- **Local Deletion**: Clear all app data through Android settings or app interface
- **Remote Deletion**: Delete synchronized data through your MonicaHQ instance
- **Automatic Cleanup**: Old logs automatically purged (1000 operations or 2 months)

## Third-Party Services

### MonicaHQ Integration
- **Service**: Your self-hosted or cloud MonicaHQ instance
- **Data Shared**: Contacts, interactions, notes (as configured)
- **Privacy Policy**: Subject to your MonicaHQ instance's privacy policy
- **Control**: You choose what data to synchronize

### No Other Third Parties
- Monica Mobile App does not integrate with any other third-party services
- No advertising networks, analytics services, or tracking companies
- No data shared with app stores beyond download metadata

## Updates and Changes

### Privacy Policy Updates
- **Notification**: Major changes will be announced via GitHub and in-app notification
- **Granular Changes**: Minor clarifications may be updated without notification
- **Version Control**: All changes tracked in Git history
- **User Choice**: Continued use implies acceptance of updated policy

### Feature Updates
- **Privacy Impact**: New features that affect privacy will be opt-in by default
- **Transparency**: Privacy implications clearly documented for each release
- **User Control**: Additional privacy controls added when new features are introduced

## Compliance and Legal

### Data Protection Regulations
- **GDPR**: Designed with GDPR principles (data minimization, user control, transparency)
- **Local Laws**: Users responsible for compliance with local data protection laws
- **Cross-Border**: Data only flows between your device and your MonicaHQ instance

### Age Restrictions
- **13+**: App intended for users 13 years and older
- **Parental Consent**: Users under 18 should obtain parental consent
- **Child Data**: No specific provisions for children's data

## Incident Response

In case of a privacy-related incident:

1. **Immediate Assessment**: Evaluate scope and impact
2. **User Notification**: Notify affected users within 72 hours
3. **Mitigation**: Implement immediate protective measures
4. **Investigation**: Conduct thorough investigation
5. **Prevention**: Update systems and policies to prevent recurrence

## Contact and Questions

### Privacy Questions
- **GitHub Issues**: For all privacy questions and concerns
- **GitHub Discussions**: For privacy policy discussions
- **Security Issues**: Follow [SECURITY.md](SECURITY.md) for security-related privacy concerns

### Data Subject Requests
Since Monica Mobile App is local-first:
- **Local Data**: Manage through app settings
- **Synchronized Data**: Contact your MonicaHQ instance administrator
- **App Questions**: Create a GitHub Issue for app-specific data questions

## Open Source Transparency

### Code Verification
- **Source Code**: Full source code available for privacy verification
- **Build Process**: Reproducible builds for transparency
- **Community Review**: Privacy practices subject to community scrutiny
- **Issue Tracking**: Privacy concerns tracked publicly on GitHub

### Trust Through Transparency
- **No Hidden Behavior**: All data handling visible in source code
- **Community Oversight**: Open source community provides additional privacy protection
- **Regular Audits**: Code changes reviewed for privacy implications

---

**This privacy policy is part of our commitment to user privacy and data protection. Our local-first, open source approach ensures you maintain control over your personal information.**

For the most current version of this policy, please check our GitHub repository.