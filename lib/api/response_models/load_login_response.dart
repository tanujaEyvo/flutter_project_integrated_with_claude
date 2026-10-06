import 'dart:convert';

class LoadLoginResponse {
  final String code;
  final List<String> message;
  final dynamic data;
  final int totalrecords;

  LoadLoginResponse({
    required this.code,
    required this.message,
    this.data,
    required this.totalrecords,
  });

  factory LoadLoginResponse.fromJson(Map<String, dynamic> json) {
    return LoadLoginResponse(
      code: json['code'] as String,
      message: List<String>.from(json['message']),
      data: json['data'] != null
          ? Data.fromJson(
              jsonDecode(json['data'] as String)) // Make sure it's a string
          : null,
      totalrecords: json['totalrecords'] as int,
    );
  }

  @override
  String toString() {
    return 'LoadLoginResponse(code: $code, message: $message, data: $data, totalrecords: $totalrecords)';
  }
}

class Data {
  final bool isLoginWithScan;
  final bool isAzureAdLogin;
  final bool isSSOlogin;
  final String clientId;
  final String tenantId;
  final String authority;
  final String redirectUri;
  final String clientCode;
  final String accessKey;
  final String connectionString;
  final String ssoButtonText;
  final String? ssoSession;
  final String? appType;
  final int mobileSessionTimeOut;
  final bool? versionChanged;
  final String? versionChangedMessage;

  Data(
      {required this.isLoginWithScan,
      required this.isAzureAdLogin,
      required this.isSSOlogin,
      required this.clientId,
      required this.tenantId,
      required this.authority,
      required this.redirectUri,
      required this.clientCode,
      required this.accessKey,
      required this.connectionString,
      required this.ssoButtonText,
      this.ssoSession,
      this.appType,
      required this.mobileSessionTimeOut,
      this.versionChangedMessage,
      this.versionChanged});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      isLoginWithScan: json['scanlogin'] as bool? ?? false,
      isAzureAdLogin: json['azuread'] as bool? ?? false,
      isSSOlogin: json['ssologin'] as bool? ?? false,
      clientId: json['clientid'] as String? ?? '',
      tenantId: json['tanentid'] as String? ?? '',
      authority: json['authority'] as String? ?? '',
      redirectUri: json['redirecturi'] as String? ?? '',
      clientCode: json['clientcode'] as String? ?? '',
      accessKey: json['accesskey'] as String? ?? '',
      connectionString: json['connectionstring'] as String? ?? '',
      ssoButtonText: json['ssobtntext'] as String? ?? '',
      ssoSession: json['ssosession'] as String?,
      appType: json['apptype'] as String?,
      mobileSessionTimeOut: json['mobileSessionTimeOut'] as int? ?? 120,
      versionChangedMessage: json['versionChangedMessage'] as String? ?? "",
      versionChanged: json['versionChanged'] as bool? ?? false,
    );
  }
  @override
  String toString() {
    return '''
Data(
  isLoginWithScan: $isLoginWithScan,
  isAzureAdLogin: $isAzureAdLogin,
  isSSOlogin: $isSSOlogin,
  clientId: $clientId,
  tenantId: $tenantId,
  authority: $authority,
  redirectUri: $redirectUri,
  clientCode: $clientCode,
  accessKey: $accessKey,
  connectionString: $connectionString,
  ssoButtonText: $ssoButtonText,
  ssoSession: $ssoSession,
  appType: $appType,
  mobileSessionTimeOut: $mobileSessionTimeOut,
  versionChanged:$versionChanged,
  versionChangedMessage:$versionChangedMessage   

)
''';
  }
}
