import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:app_links/app_links.dart';
import 'package:bps_sso_sdk/bps_sso_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../core/di/injection.dart';
import '../routes/app_router.dart';

part 'configuration_state.dart';

class ConfigurationCubit extends HydratedCubit<ConfigurationState> {
  ConfigurationCubit() : super(const ConfigurationState()) {
    _appLinks = AppLinks();
    _alice = getIt<Alice>();
    _aliceDioAdapter = getIt<AliceDioAdapter>();
    _setupDeepLinkListener();
    _checkSDKInitializationStatus();
    _setupAliceNavigatorKey();
  }

  late final AppLinks _appLinks;
  late final Alice _alice;
  late final AliceDioAdapter _aliceDioAdapter;

  /// Get Alice instance for HTTP inspection
  Alice get alice => _alice;

  void _setupAliceNavigatorKey() {
    // Set navigator key for Alice after AppRouter is available
    final appRouter = getIt<AppRouter>();
    _alice.addAdapter(_aliceDioAdapter);
    _alice.setNavigatorKey(appRouter.navigatorKey);
  }

  void _setupDeepLinkListener() {
    // Set up persistent deep link listener
    _appLinks.stringLinkStream.listen((String link) {
      // Deep link received - navigate to operations to handle the callback
      final appRouter = getIt<AppRouter>();
      if (appRouter.navigatorKey.currentContext != null) {
        // Navigate to operations screen when deep link is received
        appRouter.navigate(const OperationsRoute());
      }
    });
  }

  void _checkSDKInitializationStatus() {
    // Check if the SDK is actually initialized on app launch
    final actuallyInitialized = BPSSsoClient.instance.isInitialized;

    if (state.isInitialized && !actuallyInitialized) {
      // State says initialized but SDK is not - reset the state
      emit(
        state.copyWith(
          isInitialized: false,
          initializationError: 'SDK was not initialized - please reinitialize',
        ),
      );
    } else if (!state.isInitialized && actuallyInitialized) {
      // SDK is initialized but state doesn't reflect it - update state
      emit(state.copyWith(isInitialized: true, initializationError: null));
    }
  }

  /// Manually refresh the SDK initialization status
  void refreshInitializationStatus() {
    _checkSDKInitializationStatus();
  }

  /// Toggle privacy mode to obscure sensitive information
  void togglePrivacyMode() {
    emit(state.copyWith(privacyMode: !state.privacyMode));
  }

  void updateBaseUrl(String baseUrl) {
    emit(state.copyWith(baseUrl: baseUrl));
  }

  void updateInternalClientId(String clientId) {
    emit(state.copyWith(internalClientId: clientId));
  }

  void updateInternalRedirectScheme(String scheme) {
    emit(state.copyWith(internalRedirectScheme: scheme));
  }

  void updateInternalRedirectHost(String host) {
    emit(state.copyWith(internalRedirectHost: host));
  }

  void updateInternalRealm(String realm) {
    emit(state.copyWith(internalRealm: realm));
  }

  void updateInternalResponseTypes(List<BPSOAuthResponseType> responseTypes) {
    emit(state.copyWith(internalResponseTypes: responseTypes));
  }

  void updateInternalScopes(List<BPSOAuthScope> scopes) {
    emit(state.copyWith(internalScopes: scopes));
  }

  void updateInternalCodeChallengeMethod(BPSCodeChallengeMethod method) {
    emit(state.copyWith(internalCodeChallengeMethod: method));
  }

  void updateExternalClientId(String clientId) {
    emit(state.copyWith(externalClientId: clientId));
  }

  void updateExternalRedirectScheme(String scheme) {
    emit(state.copyWith(externalRedirectScheme: scheme));
  }

  void updateExternalRedirectHost(String host) {
    emit(state.copyWith(externalRedirectHost: host));
  }

  void updateExternalRealm(String realm) {
    emit(state.copyWith(externalRealm: realm));
  }

  void updateExternalResponseTypes(List<BPSOAuthResponseType> responseTypes) {
    emit(state.copyWith(externalResponseTypes: responseTypes));
  }

  void updateExternalScopes(List<BPSOAuthScope> scopes) {
    emit(state.copyWith(externalScopes: scopes));
  }

  void updateExternalCodeChallengeMethod(BPSCodeChallengeMethod method) {
    emit(state.copyWith(externalCodeChallengeMethod: method));
  }

  void updateInitializationStatus({
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    emit(
      state.copyWith(
        isLoading: isLoading ?? state.isLoading,
        initializationError: error,
        isInitialized: isInitialized ?? state.isInitialized,
      ),
    );
  }

  BPSRealmConfig _internalRealmConfig() => BPSRealmConfig(
    clientId: state.internalClientId,
    redirectUri: state.internalRedirectUri,
    realmType: BPSRealmType.internal,
    baseUrl: state.baseUrl,
    responseTypes: state.internalResponseTypes,
    scopes: state.internalScopes,
    codeChallengeMethod: state.internalCodeChallengeMethod,
    realmName:
        state.internalRealm == 'pegawai-bps' ? null : state.internalRealm,
  );

  BPSRealmConfig _externalRealmConfig() => BPSRealmConfig(
    clientId: state.externalClientId,
    redirectUri: state.externalRedirectUri,
    realmType: BPSRealmType.external,
    baseUrl: state.baseUrl,
    responseTypes: state.externalResponseTypes,
    scopes: state.externalScopes,
    codeChallengeMethod: state.externalCodeChallengeMethod,
    realmName:
        state.externalRealm == 'eksternal' ? null : state.externalRealm,
  );

  BPSSsoConfig toBPSConfig() {
    return BPSSsoConfig(
      baseUrl: state.baseUrl,
      internal: _internalRealmConfig(),
      external: _externalRealmConfig(),
      securityConfig: BPSSsoSecurityConfig.development,
      interceptors: [_aliceDioAdapter],
    );
  }

  BPSSsoConfig toBPSConfigWithCallbacks() {
    return BPSSsoConfig(
      baseUrl: state.baseUrl,
      internal: _internalRealmConfig(),
      external: _externalRealmConfig(),
      securityConfig: BPSSsoSecurityConfig.development,
      interceptors: [_aliceDioAdapter],
      authCallbacks: BPSSsoAuthCallback(
        onLoginSuccess: (user, realmType) {},
        onLoginFailed: (error, realmType) {},
        onLoginCancelled: (realmType) {},
        onLogoutSuccess: (user) {},
        onLogoutFailed: (error, user) {},
        onTokenRefreshSuccess: (user) {},
        onTokenRefreshFailed: (error, user) {},
        onAuthenticationFailure: (error, user) {},
      ),
    );
  }

  Future<void> initializeSDK() async {
    try {
      updateInitializationStatus(isLoading: true, error: null);

      final config = toBPSConfigWithCallbacks();

      // Initialize the SDK with proper callback handling
      // Deep link listener is already set up in constructor
      BPSSsoClient.instance.initialize(
        config: config,
        linkStream: _appLinks.stringLinkStream,
        forceReinitialize: true,
      );

      updateInitializationStatus(isLoading: false, isInitialized: true);
    } catch (e) {
      updateInitializationStatus(
        isLoading: false,
        error: e.toString(),
        isInitialized: false,
      );
      rethrow;
    }
  }

  @override
  ConfigurationState? fromJson(Map<String, dynamic> json) {
    try {
      return ConfigurationState.fromJson(json);
    } catch (e) {
      return const ConfigurationState();
    }
  }

  @override
  Map<String, dynamic>? toJson(ConfigurationState state) {
    return state.toJson();
  }
}
