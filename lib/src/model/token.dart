class Token {
  final int _expireOffSet = 5;

  String? accessToken;
  String? tokenType;
  String? refreshToken;
  DateTime? issueTimeStamp;
  DateTime? expireTimeStamp;
  int? expiresIn;

  Token();

  factory Token.fromJson(Map<String, dynamic> json) => Token.fromMap(json);

  Map toMap() => Token.toJsonMap(this);

  @override
  String toString() => Token.toJsonMap(this).toString();

  static Map toJsonMap(Token? model) {
    final ret = <String, dynamic>{};
    if (model == null) return ret;
    if (model.accessToken != null) ret['access_token'] = model.accessToken;
    if (model.tokenType != null) ret['token_type'] = model.tokenType;
    if (model.refreshToken != null) ret['refresh_token'] = model.refreshToken;
    if (model.expiresIn != null) ret['expires_in'] = model.expiresIn;
    if (model.expireTimeStamp != null) {
      ret['expire_timestamp'] = model.expireTimeStamp!.millisecondsSinceEpoch;
    }
    return ret;
  }

  static Token fromMap(Map map) {
    if (map['error'] != null) {
      throw Exception(
          'Error during token request: ${map["error"]}: ${map["error_description"]}');
    }

    final model = Token();
    model.accessToken = map['access_token'];
    model.tokenType = map['token_type'];
    model.expiresIn = map['expires_in'] is int
        ? map['expires_in']
        : int.tryParse(map['expires_in'].toString()) ?? 60;
    model.refreshToken = map['refresh_token'];
    model.issueTimeStamp = DateTime.now().toUtc();
    model.expireTimeStamp = map.containsKey('expire_timestamp')
        ? DateTime.fromMillisecondsSinceEpoch(map['expire_timestamp'])
        : model.issueTimeStamp!
            .add(Duration(seconds: model.expiresIn! - model._expireOffSet));
    return model;
  }

  static bool isExpired(Token token) =>
      token.expireTimeStamp!.isBefore(DateTime.now().toUtc());

  static bool tokenIsValid(Token? token) =>
      token != null && !Token.isExpired(token) && token.accessToken != null;
}
