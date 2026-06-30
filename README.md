# msl_oauth_login

A Flutter OAuth2 authentication package with a ready-to-use login button.
Supports **Microsoft Azure AD**, **Google**, and any other OAuth2 provider.

**Source code:** [github.com/Aamirsajjad146/active_directory](https://github.com/Aamirsajjad146/active_directory/tree/main)

---

## Features

- WebView-based OAuth2 authorization code flow
- Token caching with secure storage (auto-refresh on expiry)
- Pre-styled `MicrosoftLoginButton` and `GoogleLoginButton`
- Generic `OAuthLoginButton` for any other provider
- Configurable loader shown inside the WebView while pages load

---

## Installation

In your app's `pubspec.yaml`:

```yaml
dependencies:
  msl_oauth_login:
    path: ../packages/msl_oauth_login   # adjust path to your setup
```

---

## Setup

### 1. Navigator key

The package needs a `GlobalKey<NavigatorState>` to push the WebView login screen.
Create one key and pass it to **both** `MaterialApp` and `Config`.

```dart
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,   // ← same key
      home: const HomeScreen(),
    ),
  );
}
```

### 2. Android — `minSdkVersion`

In `android/app/build.gradle` set:

```gradle
minSdkVersion 20
```

### 3. iOS — `NSAppTransportSecurity` *(if needed)*

Add to `ios/Runner/Info.plist` if your redirect URI is non-HTTPS:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

---

## Usage

### Microsoft Azure AD

```dart
import 'package:msl_oauth_login/msl_oauth_login.dart';

class LoginScreen extends StatelessWidget {
  static final _config = Config(
    tenant:      'YOUR_TENANT_ID',
    clientId:    'YOUR_CLIENT_ID',
    redirectUri: 'YOUR_REDIRECT_URI',
    scope:       'YOUR_SCOPE',
    navigatorKey: navigatorKey,
    loader: const Center(child: CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MicrosoftLoginButton(
          config: _config,
          onSuccess: (token) {
            // token is the access token string
            print('Logged in: $token');
          },
          onError: (e) => print('Error: $e'),
        ),
      ),
    );
  }
}
```

### Google

```dart
static final _googleConfig = Config(
  clientId:         'your-client-id.apps.googleusercontent.com',
  redirectUri:      'com.example.app:/oauth2redirect',
  scope:            'openid email profile',
  authorizationUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenUrl:         'https://oauth2.googleapis.com/token',
  navigatorKey:     navigatorKey,
  loader: const Center(child: CircularProgressIndicator()),
);

GoogleLoginButton(
  config: _googleConfig,
  onSuccess: (token) => print('Google token: $token'),
  onError:   (e)     => print('Error: $e'),
)
```

### Custom / Any other provider

Use `OAuthLoginButton` and supply your own `child` widget for full control
over the button's appearance.

```dart
static final _oktaConfig = Config(
  clientId:         'your-okta-client-id',
  redirectUri:      'com.example.app:/callback',
  scope:            'openid offline_access',
  authorizationUrl: 'https://your-org.okta.com/oauth2/v1/authorize',
  tokenUrl:         'https://your-org.okta.com/oauth2/v1/token',
  navigatorKey:     navigatorKey,
  loader: const SizedBox(),   // no loader
);

OAuthLoginButton(
  config: _oktaConfig,
  onSuccess: (token) => print('Token: $token'),
  onError:   (e)     => print('Error: $e'),
  width:  260,
  height: 52,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF007DC1),
    shape: const StadiumBorder(),
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.lock, color: Colors.white),
      SizedBox(width: 10),
      Text('Sign in with Okta',
          style: TextStyle(color: Colors.white, fontSize: 15)),
    ],
  ),
)
```

---

## Config reference

| Parameter | Type | Required | Description |
|---|---|---|---|
| `tenant` | `String?` | ✓ for Microsoft | Azure AD tenant ID. URLs are auto-built when supplied. |
| `clientId` | `String` | ✓ | OAuth2 client / application ID. |
| `redirectUri` | `String` | ✓ | Redirect URI registered in your provider. |
| `scope` | `String` | ✓ | Space-separated OAuth2 scopes. |
| `navigatorKey` | `GlobalKey<NavigatorState>` | ✓ | Same key passed to `MaterialApp.navigatorKey`. |
| `loader` | `Widget` | | Shown as overlay while WebView page loads. Default: `CircularProgressIndicator`. |
| `authorizationUrl` | `String?` | ✓ if no `tenant` | Authorization endpoint (Google / custom providers). |
| `tokenUrl` | `String?` | ✓ if no `tenant` | Token endpoint (Google / custom providers). |
| `logoutUrl` | `String?` | | Logout endpoint (optional). |
| `clientSecret` | `String?` | | Client secret (if required by provider). |
| `forceConsent` | `bool` | | Adds `prompt=consent` to every request. Default: `true`. |
| `responseType` | `String` | | Default: `'code'`. |
| `contentType` | `String` | | Default: `'application/x-www-form-urlencoded'`. |
| `userAgent` | `String?` | | Custom WebView user-agent. |

---

## Button reference

### `MicrosoftLoginButton`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `config` | `Config` | required | Auth configuration. |
| `onSuccess` | `void Function(String)` | required | Called with access token. |
| `onError` | `void Function(Object)?` | `null` | Called on failure. |
| `text` | `String` | `'Sign in with Microsoft'` | Button label. |
| `logo` | `Widget?` | Microsoft logo | Override the logo widget. |
| `backgroundColor` | `Color` | `#0078D4` | Button fill color. |
| `textColor` | `Color` | `white` | Label color. |
| `borderRadius` | `double` | `4.0` | Corner radius. |
| `width` | `double` | `double.infinity` | Button width. |
| `height` | `double` | `48.0` | Button height. |
| `textStyle` | `TextStyle?` | `null` | Override label style. |

### `GoogleLoginButton`

Same parameters as `MicrosoftLoginButton` with Google defaults:
`backgroundColor: white`, `textColor: #3C4043`, white button with grey border.

### `OAuthLoginButton`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `config` | `Config` | required | Auth configuration. |
| `onSuccess` | `void Function(String)` | required | Called with access token. |
| `onError` | `void Function(Object)?` | `null` | Called on failure. |
| `child` | `Widget` | required | Full content of the button. |
| `style` | `ButtonStyle?` | `null` | Forwarded to `ElevatedButton`. |
| `width` | `double` | `double.infinity` | Button width. |
| `height` | `double` | `48.0` | Button height. |
| `loadingWidget` | `Widget?` | Small `CircularProgressIndicator` | Shown while auth is in progress. |

---

## Advanced — access token without button

If you need to call the auth flow programmatically (e.g. on app start):

```dart
final auth = AadOAuth(_config);

// Login (shows WebView if no cached token)
await auth.login();

// Get current access token (refreshes automatically if expired)
final token = await auth.getAccessToken();

// Check validity without network call
final isValid = auth.tokenIsValid();

// Logout (clears secure storage)
await auth.logout();
```
