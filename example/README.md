# BPS SSO SDK Example App

A comprehensive Flutter example application showcasing the **BPS SSO SDK** for authentication integration with BPS (Badan Pusat Statistik) systems.

## Features

🔐 **Complete SSO Authentication Flow**
- Login with both Internal and External BPS realms
- Token refresh and validation
- Secure logout functionality
- Real-time authentication status

🎨 **Beautiful Modern UI**
- Material 3 design system
- Smooth animations and transitions
- Dark/Light theme support
- Responsive layout for all screen sizes

🧭 **Multi-Page Navigation**
- AutoRoute-based navigation
- Deep link support for OAuth callbacks
- Type-safe routing

📱 **Platform Support**
- Android with proper deep link intent filters
- iOS with custom URL schemes
- Web support (configure accordingly)

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode for platform-specific development

### Installation

1. **Clone the repository and navigate to the example**
   ```bash
   cd bps_sso_sdk/example
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate route files**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### 1. SDK Configuration

When you first launch the app, you'll need to configure the BPS SSO SDK with your application's credentials:

#### General Configuration
- **Base URL**: The BPS SSO server URL (default: `https://sso.bps.go.id`)

#### Internal BPS Realm Configuration
- **Client ID**: Your registered client ID for internal BPS users
- **Redirect URI**: OAuth callback URI (default: `com.yourapp.internal://callback`)
- **Realm Name**: The Keycloak realm name (default: `bps`)

#### Advanced Internal OAuth Configuration
- **Response Types**: OAuth2 response types (default: `code`)
- **Scopes**: OAuth2 scopes (default: `openid profile email`)
- **Code Challenge Method**: PKCE method (default: `S256`)

#### External BPS Realm Configuration
- **Client ID**: Your registered client ID for external users
- **Redirect URI**: OAuth callback URI (default: `com.yourapp.external://callback`)
- **Realm Name**: The external realm name (default: `eksternal`)

#### Advanced External OAuth Configuration
- **Response Types**: OAuth2 response types (default: `code`)
- **Scopes**: OAuth2 scopes (default: `openid profile email`)
- **Code Challenge Method**: PKCE method (default: `S256`)

### 2. Deep Link Configuration

The app includes pre-configured deep link handling for OAuth callbacks.

#### Android Configuration

Deep links are configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Example deep link schemes -->
<data android:scheme="com.example.bpssso" android:host="callback" />
<data android:scheme="com.yourapp.internal" />
<data android:scheme="com.yourapp.external" />
```

**Important**: Update these schemes to match your actual application:

1. Replace `com.example.bpssso` with your app's package name
2. Replace `com.yourapp.internal` and `com.yourapp.external` with your configured redirect URIs

#### iOS Configuration

URL schemes are configured in `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.example.bpssso</string>
    <string>com.yourapp.internal</string>
    <string>com.yourapp.external</string>
</array>
```

**Important**: Update these schemes to match your redirect URIs.

### 3. BPS SSO Server Configuration

When registering your application with the BPS SSO server, configure these redirect URIs:

- **Internal Realm**: `com.yourapp.internal://callback`
- **External Realm**: `com.yourapp.external://callback`
- **Development**: `com.example.bpssso://callback`

## Usage Guide

### 1. Initial Setup

1. Launch the app
2. Tap **"Configure SDK"** on the home screen
3. Fill in your BPS SSO configuration details
4. Tap **"Initialize SDK"**

### 2. Authentication Flow

1. Navigate to **"SSO Operations"**
2. Select your target realm (Internal BPS or External)
3. Tap **"Login"** to start the authentication flow
4. Complete authentication in the opened browser/webview
5. You'll be redirected back to the app upon success

### 3. Available Operations

- **Login**: Authenticate with selected BPS realm
- **Refresh Token**: Renew your access token
- **Validate Token**: Check if your current token is valid
- **Show User Info**: View detailed user profile information
- **Logout**: Sign out and revoke tokens

## App Architecture

### Navigation Structure

```
Home Screen
├── Configuration Screen
└── Operations Screen
    └── User Info Screen
```

### Deep Link Routes

- `/` - Home screen
- `/config` - Configuration screen
- `/operations` - SSO operations screen
- `/user-info` - User information screen
- `/callback` - OAuth callback handler (redirects to operations)

### Key Components

- **StatusCard**: Real-time authentication status display
- **OperationCard**: Actionable SSO operation buttons
- **Beautiful Forms**: Validation-enabled configuration forms

## Dependencies

### Core Dependencies
- `bps_sso_sdk` - The main BPS SSO authentication SDK
- `auto_route` - Type-safe navigation and routing
- `flutter_animate` - Smooth animations and transitions

### UI Enhancement
- `google_fonts` - Professional typography (Inter font)
- `phosphor_flutter` - Beautiful iconography
- `gap` - Consistent spacing

## Development

### Adding New Features

1. Create new screens in `lib/screens/`
2. Add routes to `lib/routes/app_router.dart`
3. Run `dart run build_runner build` to generate route files
4. Create reusable widgets in `lib/widgets/`

### Testing Deep Links

#### Android
```bash
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "com.example.bpssso://callback?code=test" \
  com.example.bpssso
```

#### iOS Simulator
```bash
xcrun simctl openurl booted "com.example.bpssso://callback?code=test"
```

## Troubleshooting

### Common Issues

1. **Deep links not working**
   - Verify URL schemes match your BPS SSO server configuration
   - Check Android intent filters and iOS URL schemes
   - Ensure app is properly installed and not just run via IDE

2. **SDK initialization fails**
   - Verify all required configuration fields are filled
   - Check network connectivity
   - Confirm BPS SSO server URL is accessible

3. **Authentication fails**
   - Verify client IDs and redirect URIs match server configuration
   - Check realm names are correct
   - Ensure deep link configuration matches redirect URIs

### Debug Mode

The app includes comprehensive error handling and user feedback:
- SnackBar notifications for all operations
- Detailed error messages
- Real-time status updates

## Production Deployment

Before deploying to production:

1. **Update deep link schemes** to your production URLs
2. **Configure proper client IDs** for production BPS SSO server
3. **Test authentication flow** thoroughly on physical devices
4. **Update app signing** and bundle identifiers as needed

## License

This example app is provided as part of the BPS SSO SDK package for demonstration purposes.

## Support

For issues related to:
- **BPS SSO SDK**: Check the main SDK documentation
- **This example app**: Create an issue in the repository
- **BPS SSO Server**: Contact your BPS administrator

---

**Note**: This example app is designed to showcase all features of the BPS SSO SDK. In a production app, you may want to simplify the UI and remove configuration screens, instead hardcoding your production SSO settings.