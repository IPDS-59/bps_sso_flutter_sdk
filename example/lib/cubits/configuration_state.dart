part of 'configuration_cubit.dart';

class ConfigurationState extends Equatable {
  final String baseUrl;
  final String internalClientId;
  final String internalRedirectUri;
  final String internalRealm;
  final List<String> internalResponseTypes;
  final List<String> internalScopes;
  final String internalCodeChallengeMethod;
  final String externalClientId;
  final String externalRedirectUri;
  final String externalRealm;
  final List<String> externalResponseTypes;
  final List<String> externalScopes;
  final String externalCodeChallengeMethod;
  final bool isLoading;
  final String? initializationError;
  final bool isInitialized;
  final bool privacyMode;

  const ConfigurationState({
    this.baseUrl = 'https://sso.bps.go.id',
    this.internalClientId = '***REMOVED***',
    this.internalRedirectUri = 'id.go.bps://***REMOVED***',
    this.internalRealm = 'bps',
    this.internalResponseTypes = const ['code'],
    this.internalScopes = const ['openid', 'profile-pegawai'],
    this.internalCodeChallengeMethod = 'S256',
    this.externalClientId = '***REMOVED***',
    this.externalRedirectUri = 'id.go.bps://***REMOVED***',
    this.externalRealm = 'eksternal',
    this.externalResponseTypes = const ['code'],
    this.externalScopes = const ['openid', 'email', 'profile'],
    this.externalCodeChallengeMethod = 'S256',
    this.isLoading = false,
    this.initializationError,
    this.isInitialized = false,
    this.privacyMode = false,
  });

  ConfigurationState copyWith({
    String? baseUrl,
    String? internalClientId,
    String? internalRedirectUri,
    String? internalRealm,
    List<String>? internalResponseTypes,
    List<String>? internalScopes,
    String? internalCodeChallengeMethod,
    String? externalClientId,
    String? externalRedirectUri,
    String? externalRealm,
    List<String>? externalResponseTypes,
    List<String>? externalScopes,
    String? externalCodeChallengeMethod,
    bool? isLoading,
    String? initializationError,
    bool? isInitialized,
    bool? privacyMode,
    bool clearInitializationError = false,
  }) {
    return ConfigurationState(
      baseUrl: baseUrl ?? this.baseUrl,
      internalClientId: internalClientId ?? this.internalClientId,
      internalRedirectUri: internalRedirectUri ?? this.internalRedirectUri,
      internalRealm: internalRealm ?? this.internalRealm,
      internalResponseTypes:
          internalResponseTypes ?? this.internalResponseTypes,
      internalScopes: internalScopes ?? this.internalScopes,
      internalCodeChallengeMethod:
          internalCodeChallengeMethod ?? this.internalCodeChallengeMethod,
      externalClientId: externalClientId ?? this.externalClientId,
      externalRedirectUri: externalRedirectUri ?? this.externalRedirectUri,
      externalRealm: externalRealm ?? this.externalRealm,
      externalResponseTypes:
          externalResponseTypes ?? this.externalResponseTypes,
      externalScopes: externalScopes ?? this.externalScopes,
      externalCodeChallengeMethod:
          externalCodeChallengeMethod ?? this.externalCodeChallengeMethod,
      isLoading: isLoading ?? this.isLoading,
      initializationError: initializationError,
      isInitialized: isInitialized ?? this.isInitialized,
      privacyMode: privacyMode ?? this.privacyMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseUrl': baseUrl,
      'internalClientId': internalClientId,
      'internalRedirectUri': internalRedirectUri,
      'internalRealm': internalRealm,
      'internalResponseTypes': internalResponseTypes,
      'internalScopes': internalScopes,
      'internalCodeChallengeMethod': internalCodeChallengeMethod,
      'externalClientId': externalClientId,
      'externalRedirectUri': externalRedirectUri,
      'externalRealm': externalRealm,
      'externalResponseTypes': externalResponseTypes,
      'externalScopes': externalScopes,
      'externalCodeChallengeMethod': externalCodeChallengeMethod,
      'isLoading': isLoading,
      'initializationError': initializationError,
      'isInitialized': isInitialized,
      'privacyMode': privacyMode,
    };
  }

  factory ConfigurationState.fromJson(Map<String, dynamic> json) {
    return ConfigurationState(
      baseUrl: json['baseUrl'] as String? ?? 'https://sso.bps.go.id',
      internalClientId: json['internalClientId'] as String? ?? '',
      internalRedirectUri:
          json['internalRedirectUri'] as String? ??
          'id.go.bps.examplesso://sso-internal',
      internalRealm: json['internalRealm'] as String? ?? 'bps',
      internalResponseTypes:
          (json['internalResponseTypes'] as List<dynamic>?)?.cast<String>() ??
          const ['code'],
      internalScopes:
          (json['internalScopes'] as List<dynamic>?)?.cast<String>() ??
          const ['openid', 'profile', 'email'],
      internalCodeChallengeMethod:
          json['internalCodeChallengeMethod'] as String? ?? 'S256',
      externalClientId: json['externalClientId'] as String? ?? '',
      externalRedirectUri:
          json['externalRedirectUri'] as String? ??
          'id.go.bps.examplesso://sso-eksternal',
      externalRealm: json['externalRealm'] as String? ?? 'eksternal',
      externalResponseTypes:
          (json['externalResponseTypes'] as List<dynamic>?)?.cast<String>() ??
          const ['code'],
      externalScopes:
          (json['externalScopes'] as List<dynamic>?)?.cast<String>() ??
          const ['openid', 'profile', 'email'],
      externalCodeChallengeMethod:
          json['externalCodeChallengeMethod'] as String? ?? 'S256',
      isLoading: json['isLoading'] as bool? ?? false,
      initializationError: json['initializationError'] as String?,
      isInitialized: json['isInitialized'] as bool? ?? false,
      privacyMode: json['privacyMode'] as bool? ?? false,
    );
  }

  bool get isValidConfig {
    return baseUrl.isNotEmpty &&
        internalClientId.isNotEmpty &&
        internalRedirectUri.isNotEmpty &&
        internalRealm.isNotEmpty &&
        externalClientId.isNotEmpty &&
        externalRedirectUri.isNotEmpty &&
        externalRealm.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    baseUrl,
    internalClientId,
    internalRedirectUri,
    internalRealm,
    internalResponseTypes,
    internalScopes,
    internalCodeChallengeMethod,
    externalClientId,
    externalRedirectUri,
    externalRealm,
    externalResponseTypes,
    externalScopes,
    externalCodeChallengeMethod,
    isLoading,
    initializationError,
    isInitialized,
    privacyMode,
  ];
}
