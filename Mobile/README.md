# Tedio Mobile App

A Flutter application that runs on both Android and iOS platforms.

## Prerequisites

Before you begin, ensure you have the following installed:

### General Requirements
- **Flutter SDK** (3.4.3 or higher)
  - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Git**

### For iOS Development
- **macOS** (required for iOS development)
- **Xcode** (latest stable version)
  - Install from Mac App Store
  - Agree to Xcode license: `sudo xcodebuild -license accept`
- **CocoaPods**
  ```bash
  sudo gem install cocoapods
  ```
- **iOS Simulator** or physical iOS device

### For Android Development
- **Android Studio**
  - Download from [developer.android.com](https://developer.android.com/studio)
- **Android SDK**
- **Android Emulator** or physical Android device
- **Java Development Kit (JDK) 11 or higher**

## Setup Instructions

### 1. Clone the Repository
```bash
cd /path/to/Tedio/Mobile
```

### 2. Install Flutter Dependencies
```bash
cd tedio_app
flutter pub get
```

### 3. Verify Flutter Setup
```bash
flutter doctor
```
This command will check your environment and display any missing dependencies.

## Running on iOS

### Using iOS Simulator
1. Open iOS Simulator:
   ```bash
   open -a Simulator
   ```

2. List available simulators:
   ```bash
   flutter devices
   ```

3. Run the app:
   ```bash
   flutter run
   ```
   Or specify a device:
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

### Using Physical iOS Device
1. Connect your iPhone/iPad via USB
2. Trust the computer on your device
3. Open Xcode and sign the app:
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Select your team in Signing & Capabilities
   - Ensure bundle identifier is unique

4. Run the app:
   ```bash
   flutter run -d [device-id]
   ```

### iOS-Specific Commands
```bash
# Clean iOS build
cd ios && pod cache clean --all && cd ..
flutter clean

# Update CocoaPods
cd ios && pod install && cd ..

# Build iOS app (without running)
flutter build ios
```

## Running on Android

### Using Android Emulator
1. Open Android Studio
2. Open AVD Manager (Tools → AVD Manager)
3. Create or start an emulator
4. Run the app:
   ```bash
   flutter run
   ```

### Using Physical Android Device
1. Enable Developer Options on your device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging
3. Connect device via USB
4. Run the app:
   ```bash
   flutter run -d [device-id]
   ```

### Android-Specific Commands
```bash
# Clean Android build
flutter clean
cd android && ./gradlew clean && cd ..

# Build APK
flutter build apk

# Build App Bundle (for Play Store)
flutter build appbundle

# Install APK directly
flutter install
```

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

## Common Commands

### Development
```bash
# Run in debug mode (default)
flutter run

# Run in profile mode (performance testing)
flutter run --profile

# Run in release mode (production-like)
flutter run --release

# Hot reload (while app is running)
r

# Hot restart (while app is running)
R

# List connected devices
flutter devices

# Run on all connected devices
flutter run -d all
```

### Building for Production

#### iOS
```bash
# Build for iOS (creates .app)
flutter build ios

# Build for iOS Simulator
flutter build ios --simulator

# Archive for App Store
flutter build ipa
```

#### Android
```bash
# Build APK (all ABIs)
flutter build apk

# Build APK (split by ABI)
flutter build apk --split-per-abi

# Build App Bundle
flutter build appbundle
```

## Troubleshooting

### iOS Issues

**Pod install fails:**
```bash
cd ios
pod deintegrate
pod cache clean --all
pod install
cd ..
```

**Signing issues:**
- Open `ios/Runner.xcworkspace` in Xcode
- Select Runner target
- Update Team and Bundle Identifier

### Android Issues

**Gradle build fails:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**SDK version issues:**
- Update `android/app/build.gradle`:
  - minSdkVersion
  - targetSdkVersion
  - compileSdkVersion

### General Issues

**Clean everything:**
```bash
flutter clean
flutter pub cache clean
flutter pub get
cd ios && pod install && cd ..
```

**Reset Flutter:**
```bash
flutter doctor -v
flutter upgrade
flutter pub upgrade
```

## Project Structure
```
Mobile/
└── tedio_app/
    ├── android/          # Android-specific code
    ├── ios/             # iOS-specific code
    ├── lib/             # Dart/Flutter code
    │   └── main.dart    # App entry point
    ├── test/            # Unit tests
    ├── pubspec.yaml     # Dependencies
    └── README.md        # App-specific readme
```

## Dependencies
The app uses the following key packages:
- **provider** - State management
- **http & dio** - Networking
- **shared_preferences** - Local storage
- **go_router** - Navigation
- **get_it** - Dependency injection
- **file_picker** - File selection

## Additional Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Dart Documentation](https://dart.dev/guides)
- [iOS Setup Guide](https://flutter.dev/docs/get-started/install/macos)
- [Android Setup Guide](https://flutter.dev/docs/get-started/install/windows)

## Support
For issues specific to this project, please check the project's issue tracker or contact the development team.