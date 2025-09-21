import 'package:app_links/app_links.dart';
import 'package:bps_sso_sdk/bps_sso_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'configuration_state.dart';

class ConfigurationCubit extends HydratedCubit<ConfigurationState> {
  ConfigurationCubit() : super(const ConfigurationState()) {
    _appLinks = AppLinks();
    _setupDeepLinkListener();
    _checkSDKInitializationStatus();
  }

  late final AppLinks _appLinks;

  void _setupDeepLinkListener() {
    // Set up persistent deep link listener
    _appLinks.stringLinkStream.listen((String link) {
      // Deep link received - SDK will handle it
    });
  }

  void _checkSDKInitializationStatus() {
    // Check if the SDK is actually initialized on app launch
    final actuallyInitialized = BPSSsoClient.instance.isInitialized;

    if (state.isInitialized && !actuallyInitialized) {
      // State says initialized but SDK is not - reset the state
      emit(state.copyWith(
        isInitialized: false,
        initializationError: 'SDK was not initialized - please reinitialize',
      ));
    } else if (!state.isInitialized && actuallyInitialized) {
      // SDK is initialized but state doesn't reflect it - update state
      emit(state.copyWith(
        isInitialized: true,
        initializationError: null,
      ));
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

  void updateInternalRedirectUri(String redirectUri) {
    emit(state.copyWith(internalRedirectUri: redirectUri));
  }

  void updateInternalRealm(String realm) {
    emit(state.copyWith(internalRealm: realm));
  }

  void updateInternalResponseTypes(List<String> responseTypes) {
    emit(state.copyWith(internalResponseTypes: responseTypes));
  }

  void updateInternalScopes(List<String> scopes) {
    emit(state.copyWith(internalScopes: scopes));
  }

  void updateInternalCodeChallengeMethod(String method) {
    emit(state.copyWith(internalCodeChallengeMethod: method));
  }

  void updateExternalClientId(String clientId) {
    emit(state.copyWith(externalClientId: clientId));
  }

  void updateExternalRedirectUri(String redirectUri) {
    emit(state.copyWith(externalRedirectUri: redirectUri));
  }

  void updateExternalRealm(String realm) {
    emit(state.copyWith(externalRealm: realm));
  }

  void updateExternalResponseTypes(List<String> responseTypes) {
    emit(state.copyWith(externalResponseTypes: responseTypes));
  }

  void updateExternalScopes(List<String> scopes) {
    emit(state.copyWith(externalScopes: scopes));
  }

  void updateExternalCodeChallengeMethod(String method) {
    emit(state.copyWith(externalCodeChallengeMethod: method));
  }

  void updateInitializationStatus({
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    emit(state.copyWith(
      isLoading: isLoading ?? state.isLoading,
      initializationError: error,
      isInitialized: isInitialized ?? state.isInitialized,
    ));
  }

  BPSSsoConfig toBPSConfig() {
    return BPSSsoConfig(
      baseUrl: state.baseUrl,
      internal: BPSRealmConfig(
        clientId: state.internalClientId,
        redirectUri: state.internalRedirectUri,
        realmType: BPSRealmType.internal,
        baseUrl: state.baseUrl,
        responseTypes: state.internalResponseTypes,
        scopes: state.internalScopes,
        codeChallengeMethod: state.internalCodeChallengeMethod,
      ),
      external: BPSRealmConfig(
        clientId: state.externalClientId,
        redirectUri: state.externalRedirectUri,
        realmType: BPSRealmType.external,
        baseUrl: state.baseUrl,
        responseTypes: state.externalResponseTypes,
        scopes: state.externalScopes,
        codeChallengeMethod: state.externalCodeChallengeMethod,
      ),
      securityConfig: BPSSsoSecurityConfig.development,
    );
  }

  BPSSsoConfig toBPSConfigWithCallbacks() {
    return BPSSsoConfig(
      baseUrl: state.baseUrl,
      internal: BPSRealmConfig(
        clientId: state.internalClientId,
        redirectUri: state.internalRedirectUri,
        realmType: BPSRealmType.internal,
        baseUrl: state.baseUrl,
        responseTypes: state.internalResponseTypes,
        scopes: state.internalScopes,
        codeChallengeMethod: state.internalCodeChallengeMethod,
      ),
      external: BPSRealmConfig(
        clientId: state.externalClientId,
        redirectUri: state.externalRedirectUri,
        realmType: BPSRealmType.external,
        baseUrl: state.baseUrl,
        responseTypes: state.externalResponseTypes,
        scopes: state.externalScopes,
        codeChallengeMethod: state.externalCodeChallengeMethod,
      ),
      securityConfig: BPSSsoSecurityConfig.development,
      authCallbacks: BPSSsoAuthCallback(
        onLoginSuccess: (user, realmType) {
          // Login successful callback
        },
        onLoginFailed: (error, realmType) {
          // Login failed callback
        },
        onLoginCancelled: (realmType) {
          // Login cancelled callback
        },
        onLogoutSuccess: (user) {
          // Logout successful callback
        },
        onLogoutFailed: (error, user) {
          // Logout failed callback
        },
        onTokenRefreshSuccess: (user) {
          // Token refresh successful callback
        },
        onTokenRefreshFailed: (error, user) {
          // Token refresh failed callback
        },
        onAuthenticationFailure: (error, user) {
          // Authentication failure callback
        },
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
      );

      updateInitializationStatus(
        isLoading: false,
        isInitialized: true,
      );
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