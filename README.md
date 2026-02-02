# Money Saving Groups Mobile App

A cross-platform mobile application for managing money-saving groups with friends and family. Built with Flutter for iOS and Android.

## Features

### Admin Features
- Create and manage multiple saving groups
- Set flexible durations (weekly, monthly, or custom)
- Assign or automatically decide collection rotation
- No limit on group members
- Generate and share invite codes

### User Features
- Local signup and login with PIN + biometric authentication
- Join groups using invite codes
- View personal contribution amounts (privacy-focused)
- See collection schedule and rotation
- **Fair Collection System**: Each member collects exactly their contribution amount × number of members
- Dashboard with upcoming collections and group overview

### Technical Features
- Cross-platform (iOS & Android)
- Local SQLite database storage
- Secure PIN-based authentication with biometric support
- Privacy-focused design (users only see their own contribution amounts)
- Future-ready architecture for backend integration

## Fair Collection System

This app implements a **proportional collection system** that ensures fairness for all members:

### How It Works
- Each member contributes their chosen amount per cycle
- When it's your turn to collect, you receive: **Your Contribution × Number of Members**
- Everyone gets back exactly what they put in over the full cycle

### Example
**Group with 4 members:**
- Alice contributes $200/month → Collects $200 × 4 = $800
- Bob contributes $150/month → Collects $150 × 4 = $600  
- Carol contributes $100/month → Collects $100 × 4 = $400
- Dave contributes $50/month → Collects $50 × 4 = $200

**Result:** Everyone gets back exactly what they contributed over 4 months, but as a lump sum when it's their turn.

### Benefits
- **Fair**: No one loses money to subsidize others
- **Flexible**: Members can contribute different amounts based on their capacity
- **Transparent**: Clear calculation shown in the app
- **Motivating**: Higher contributors get proportionally higher returns

## Screenshots

[Add screenshots here when available]

## Installation

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode for platform-specific development
- A physical device or emulator for testing

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd money_saving_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS (macOS only)
   flutter run -d ios
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK version: 21
- Target SDK version: 33
- Biometric authentication requires Android 6.0+

#### iOS
- Minimum iOS version: 11.0
- Face ID/Touch ID support requires iOS 11.0+

## App Architecture

### Project Structure
```
lib/
├── core/
│   ├── constants/     # App constants and configuration
│   ├── utils/         # Utility functions and helpers
│   └── theme/         # App theme and styling
├── data/
│   ├── database/      # SQLite database helper
│   ├── models/        # Data models
│   └── repositories/  # Data access layer
├── presentation/
│   ├── screens/       # UI screens
│   ├── widgets/       # Reusable UI components
│   └── providers/     # State management (Provider pattern)
└── services/          # Business logic services
```

### Database Schema
- **Users**: Store user accounts with encrypted PINs
- **Groups**: Saving group information and settings
- **Group Members**: Member relationships and contribution amounts
- **Collection Schedule**: Automated collection rotation
- **Contributions**: Track payment status and history

## Usage Guide

### Getting Started
1. **First Launch**: Create your account with username, full name, and secure PIN
2. **Enable Biometric**: Optionally enable fingerprint/face recognition for quick access
3. **Create or Join**: Either create a new group or join existing one with invite code

### Creating a Group
1. Tap "Create Group" from dashboard
2. Enter group name and optional description
3. Choose saving cycle (weekly, monthly, or custom)
4. Set your contribution amount
5. Select start date and optional end date
6. Share the generated invite code with others

### Joining a Group
1. Get invite code from group admin
2. Tap "Join Group" from dashboard
3. Enter the 6-character invite code
4. Set your contribution amount
5. Confirm to join the group

### Managing Groups
- **View Details**: Tap any group to see members, schedule, and statistics
- **Collection Schedule**: See when you or others will collect contributions
- **Invite Members**: Share the invite code from group details
- **Admin Controls**: Group creators can manage members and deactivate groups

## Security Features

### Data Protection
- All sensitive data encrypted using Flutter Secure Storage
- PIN hashing with SHA-256
- Local database with secure storage
- No sensitive data transmitted over network

### Authentication
- 4-8 digit PIN requirement
- Biometric authentication support (fingerprint/face recognition)
- Automatic session management
- Secure logout functionality

## Development

### Running Tests
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Building for Release

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Comment complex business logic
- Maintain consistent file structure

## Future Enhancements

### Planned Features
- Push notifications for collection reminders
- Data export functionality
- Advanced reporting and analytics
- Multi-currency support
- Group chat functionality

### Backend Integration
The app is designed with a repository pattern that can easily integrate with a backend API:
- RESTful API integration
- Real-time synchronization
- Conflict resolution
- Offline-first architecture

## Troubleshooting

### Common Issues

**Database Errors**
- Clear app data and restart
- Check device storage space
- Ensure proper permissions

**Authentication Issues**
- Verify biometric settings in device
- Reset PIN if forgotten (requires app reinstall)
- Check device compatibility

**Performance Issues**
- Close other apps to free memory
- Restart the application
- Update to latest version

### Support
For technical support or bug reports, please create an issue in the repository with:
- Device information (OS version, device model)
- App version
- Steps to reproduce the issue
- Screenshots if applicable

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the excellent framework
- Community packages used in this project
- Contributors and testers

---

**Version**: 1.0.0  
**Last Updated**: January 2026  
**Minimum Flutter Version**: 3.0.0