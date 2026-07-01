## 1.0.2

* Relaxed `flutter_secure_storage` constraint to `>=9.0.0` to allow any version from 9.0.0 onwards without conflicts.

## 1.0.1

* Bumped `webview_flutter` to `^4.14.0`.
* Bumped `flutter_secure_storage` to `^10.3.1`.
* Bumped `shared_preferences` to `^2.5.5`.

## 1.0.0

* Initial release.
* WebView-based OAuth2 authorization code flow with automatic token refresh.
* `MicrosoftLoginButton` — pre-styled Azure AD login button.
* `GoogleLoginButton` — pre-styled Google login button.
* `OAuthLoginButton` — generic button for any OAuth2 provider.
* `AadOAuth` — programmatic API (`login`, `getAccessToken`, `tokenIsValid`, `logout`).
* Secure token caching via `flutter_secure_storage`.
