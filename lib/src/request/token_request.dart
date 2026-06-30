import '../model/config.dart';

class TokenRequestDetails {
  String? url;
  Map<String, String>? params;
  Map<String, String>? headers;

  TokenRequestDetails(Config config, String code) {
    url = config.tokenUrl;
    params = {
      'client_id': config.clientId,
      'code': code,
      'redirect_uri': config.redirectUri,
      'grant_type': 'authorization_code',
      if (config.clientSecret != null) 'client_secret': config.clientSecret!,
    };
    headers = {
      'Accept': 'application/json',
      'Content-Type': config.contentType,
    };
  }
}
