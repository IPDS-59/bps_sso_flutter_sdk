part of 'configuration_cubit.dart';

class ConfigurationState extends Equatable {
  final String baseUrl;
  final String internalClientId;
  final String internalRedirectScheme;
  final String internalRedirectHost;
  final String internalRealm;
  final List<BPSOAuthResponseType> internalResponseTypes;
  final List<BPSOAuthScope> internalScopes;
  final BPSCodeChallengeMethod internalCodeChallengeMethod;
  final String externalClientId;
  final String externalRedirectScheme;
  final String externalRedirectHost;
  final String externalRealm;
  final List<BPSOAuthResponseType> externalResponseTypes;
  final List<BPSOAuthScope> externalScopes;
  final BPSCodeChallengeMethod externalCodeChallengeMethod;
  final bool isLoading;
  final String? initializationError;
  final bool isInitialized;
  final bool privacyMode;

  ConfigurationState({
    String? baseUrl,
    String? internalClientId,
    String? internalRedirectScheme,
    String? internalRedirectHost,
    String? internalRealm,
    this.internalResponseTypes = const [BPSOAuthResponseType.code],
    this.internalScopes = const [
      BPSOAuthScope.openid,
      BPSOAuthScope.profilePegawai,
    ],
    this.internalCodeChallengeMethod = BPSCodeChallengeMethod.s256,
    String? externalClientId,
    String? externalRedirectScheme,
    String? externalRedirectHost,
    String? externalRealm,
    this.externalResponseTypes = const [BPSOAuthResponseType.code],
    this.externalScopes = const [
      BPSOAuthScope.openid,
      BPSOAuthScope.email,
      BPSOAuthScope.profile,
    ],
    this.externalCodeChallengeMethod = BPSCodeChallengeMethod.s256,
    this.isLoading = false,
    this.initializationError,
    this.isInitialized = false,
    this.privacyMode = false,
  }) : baseUrl = baseUrl ?? Env.baseUrl,
       internalClientId = internalClientId ?? Env.internalClientId,
       internalRedirectScheme =
           internalRedirectScheme ?? Env.internalRedirectScheme,
       internalRedirectHost = internalRedirectHost ?? Env.internalRedirectHost,
       internalRealm = internalRealm ?? Env.internalRealm,
       externalClientId = externalClientId ?? Env.externalClientId,
       externalRedirectScheme =
           externalRedirectScheme ?? Env.externalRedirectScheme,
       externalRedirectHost = externalRedirectHost ?? Env.externalRedirectHost,
       externalRealm = externalRealm ?? Env.externalRealm;

  BPSRedirectUri get internalRedirectUri => BPSRedirectUri(
    scheme: internalRedirectScheme,
    host: internalRedirectHost,
  );

  BPSRedirectUri get externalRedirectUri => BPSRedirectUri(
    scheme: externalRedirectScheme,
    host: externalRedirectHost,
  );

  ConfigurationState copyWith({
    String? baseUrl,
    String? internalClientId,
    String? internalRedirectScheme,
    String? internalRedirectHost,
    String? internalRealm,
    List<BPSOAuthResponseType>? internalResponseTypes,
    List<BPSOAuthScope>? internalScopes,
    BPSCodeChallengeMethod? internalCodeChallengeMethod,
    String? externalClientId,
    String? externalRedirectScheme,
    String? externalRedirectHost,
    String? externalRealm,
    List<BPSOAuthResponseType>? externalResponseTypes,
    List<BPSOAuthScope>? externalScopes,
    BPSCodeChallengeMethod? externalCodeChallengeMethod,
    bool? isLoading,
    String? initializationError,
    bool? isInitialized,
    bool? privacyMode,
  }) {
    return ConfigurationState(
      baseUrl: baseUrl ?? this.baseUrl,
      internalClientId: internalClientId ?? this.internalClientId,
      internalRedirectScheme:
          internalRedirectScheme ?? this.internalRedirectScheme,
      internalRedirectHost: internalRedirectHost ?? this.internalRedirectHost,
      internalRealm: internalRealm ?? this.internalRealm,
      internalResponseTypes:
          internalResponseTypes ?? this.internalResponseTypes,
      internalScopes: internalScopes ?? this.internalScopes,
      internalCodeChallengeMethod:
          internalCodeChallengeMethod ?? this.internalCodeChallengeMethod,
      externalClientId: externalClientId ?? this.externalClientId,
      externalRedirectScheme:
          externalRedirectScheme ?? this.externalRedirectScheme,
      externalRedirectHost: externalRedirectHost ?? this.externalRedirectHost,
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
      'internalRedirectScheme': internalRedirectScheme,
      'internalRedirectHost': internalRedirectHost,
      'internalRealm': internalRealm,
      'internalResponseTypes': internalResponseTypes
          .map((e) => e.name)
          .toList(),
      'internalScopes': internalScopes.map((e) => e.name).toList(),
      'internalCodeChallengeMethod': internalCodeChallengeMethod.name,
      'externalClientId': externalClientId,
      'externalRedirectScheme': externalRedirectScheme,
      'externalRedirectHost': externalRedirectHost,
      'externalRealm': externalRealm,
      'externalResponseTypes': externalResponseTypes
          .map((e) => e.name)
          .toList(),
      'externalScopes': externalScopes.map((e) => e.name).toList(),
      'externalCodeChallengeMethod': externalCodeChallengeMethod.name,
      'isLoading': isLoading,
      'initializationError': initializationError,
      'isInitialized': isInitialized,
      'privacyMode': privacyMode,
    };
  }

  factory ConfigurationState.fromJson(Map<String, dynamic> json) {
    BPSOAuthResponseType parseResponseType(String name) =>
        BPSOAuthResponseType.values.firstWhere(
          (e) => e.name == name,
          orElse: () => BPSOAuthResponseType.code,
        );

    BPSOAuthScope parseScope(String name) => BPSOAuthScope.values.firstWhere(
      (e) => e.name == name,
      orElse: () => BPSOAuthScope.openid,
    );

    BPSCodeChallengeMethod parseChallengeMethod(String name) =>
        BPSCodeChallengeMethod.values.firstWhere(
          (e) => e.name == name,
          orElse: () => BPSCodeChallengeMethod.s256,
        );

    return ConfigurationState(
      baseUrl: json['baseUrl'] as String?,
      internalClientId: json['internalClientId'] as String?,
      internalRedirectScheme: json['internalRedirectScheme'] as String?,
      internalRedirectHost: json['internalRedirectHost'] as String?,
      internalRealm: json['internalRealm'] as String?,
      internalResponseTypes:
          (json['internalResponseTypes'] as List<dynamic>?)
              ?.map((e) => parseResponseType(e as String))
              .toList() ??
          const [BPSOAuthResponseType.code],
      internalScopes:
          (json['internalScopes'] as List<dynamic>?)
              ?.map((e) => parseScope(e as String))
              .toList() ??
          const [BPSOAuthScope.openid, BPSOAuthScope.profilePegawai],
      internalCodeChallengeMethod: parseChallengeMethod(
        json['internalCodeChallengeMethod'] as String? ?? 's256',
      ),
      externalClientId: json['externalClientId'] as String?,
      externalRedirectScheme: json['externalRedirectScheme'] as String?,
      externalRedirectHost: json['externalRedirectHost'] as String?,
      externalRealm: json['externalRealm'] as String?,
      externalResponseTypes:
          (json['externalResponseTypes'] as List<dynamic>?)
              ?.map((e) => parseResponseType(e as String))
              .toList() ??
          const [BPSOAuthResponseType.code],
      externalScopes:
          (json['externalScopes'] as List<dynamic>?)
              ?.map((e) => parseScope(e as String))
              .toList() ??
          const [
            BPSOAuthScope.openid,
            BPSOAuthScope.email,
            BPSOAuthScope.profile,
          ],
      externalCodeChallengeMethod: parseChallengeMethod(
        json['externalCodeChallengeMethod'] as String? ?? 's256',
      ),
      isLoading: json['isLoading'] as bool? ?? false,
      initializationError: json['initializationError'] as String?,
      isInitialized: json['isInitialized'] as bool? ?? false,
      privacyMode: json['privacyMode'] as bool? ?? false,
    );
  }

  bool get isValidConfig {
    return baseUrl.isNotEmpty &&
        internalClientId.isNotEmpty &&
        internalRedirectHost.isNotEmpty &&
        internalRealm.isNotEmpty &&
        externalClientId.isNotEmpty &&
        externalRedirectHost.isNotEmpty &&
        externalRealm.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    baseUrl,
    internalClientId,
    internalRedirectScheme,
    internalRedirectHost,
    internalRealm,
    internalResponseTypes,
    internalScopes,
    internalCodeChallengeMethod,
    externalClientId,
    externalRedirectScheme,
    externalRedirectHost,
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
