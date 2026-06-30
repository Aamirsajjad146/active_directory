import '../model/config.dart';

class AuthorizationRequest {
  String? url;
  String? redirectUrl;
  Map<String, String>? parameters;

  AuthorizationRequest(Config config) {
    url = config.authorizationUrl;
    redirectUrl = config.redirectUri;
    parameters = {
      'client_id': config.clientId,
      'response_type': config.responseType,
      'redirect_uri': config.redirectUri,
      'scope': config.scope,
      if (config.forceConsent) 'prompt': 'consent',
    };
  }
}
