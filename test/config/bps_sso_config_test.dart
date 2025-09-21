import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BPSSsoConfig', () {
    group('Factory Constructor', () {
      test('should create config with default values', () {
        final config = BPSSsoConfig.create(
          appName: 'testapp',
          internalClientId: 'internal-client',
          externalClientId: 'external-client',
        );

        expect(config.baseUrl, equals('https://sso.bps.go.id'));
        expect(config.internal.clientId, equals('internal-client'));
        expect(config.external.clientId, equals('external-client'));
        expect(
          config.internal.redirectUri,
          equals('id.go.bps://testapp-sso-internal'),
        );
        expect(
          config.external.redirectUri,
          equals('id.go.bps://testapp-sso-eksternal'),
        );
        expect(config.internal.realm, equals('pegawai-bps'));
        expect(config.external.realm, equals('eksternal'));
        expect(config.internal.responseTypes, equals(['code']));
        expect(config.external.responseTypes, equals(['code']));
        expect(config.internal.scopes, equals(['openid', 'profile', 'email']));
        expect(config.external.scopes, equals(['openid', 'profile', 'email']));
        expect(config.internal.codeChallengeMethod, equals('S256'));
        expect(config.external.codeChallengeMethod, equals('S256'));
        expect(config.interceptors, isEmpty);
      });

      test('should create config with custom interceptors', () {
        final logInterceptor = LogInterceptor();
        final config = BPSSsoConfig.create(
          appName: 'testapp',
          internalClientId: 'internal-client',
          externalClientId: 'external-client',
          interceptors: [logInterceptor],
        );

        expect(config.interceptors, hasLength(1));
        expect(config.interceptors.first, equals(logInterceptor));
      });

      test('should create config with custom values', () {
        final config = BPSSsoConfig.create(
          appName: 'myapp',
          internalClientId: 'custom-internal',
          externalClientId: 'custom-external',
          baseUrl: 'https://custom.sso.example.com',
          responseTypes: ['code', 'token'],
          scopes: ['openid', 'profile', 'email', 'roles'],
          codeChallengeMethod: 'plain',
        );

        expect(config.baseUrl, equals('https://custom.sso.example.com'));
        expect(config.internal.responseTypes, equals(['code', 'token']));
        expect(config.external.responseTypes, equals(['code', 'token']));
        expect(
          config.internal.scopes,
          equals(['openid', 'profile', 'email', 'roles']),
        );
        expect(
          config.external.scopes,
          equals(['openid', 'profile', 'email', 'roles']),
        );
        expect(config.internal.codeChallengeMethod, equals('plain'));
        expect(config.external.codeChallengeMethod, equals('plain'));
      });

      test('should create config with custom realm names', () {
        final config = BPSSsoConfig.create(
          appName: 'testapp',
          internalClientId: 'internal-client',
          externalClientId: 'external-client',
          internalRealmName: 'custom-internal-realm',
          externalRealmName: 'custom-external-realm',
        );

        expect(config.internal.realm, equals('custom-internal-realm'));
        expect(config.external.realm, equals('custom-external-realm'));
        expect(config.internal.realmName, equals('custom-internal-realm'));
        expect(config.external.realmName, equals('custom-external-realm'));
      });

      test('should use default realm names when custom names are null', () {
        final config = BPSSsoConfig.create(
          appName: 'testapp',
          internalClientId: 'internal-client',
          externalClientId: 'external-client',
        );

        expect(config.internal.realm, equals('pegawai-bps'));
        expect(config.external.realm, equals('eksternal'));
        expect(config.internal.realmName, isNull);
        expect(config.external.realmName, isNull);
      });
    });

    group('Manual Constructor', () {
      test('should create config with manual realm configs', () {
        const internalConfig = BPSRealmConfig(
          clientId: 'internal-123',
          redirectUri: 'id.go.bps://myapp-internal',
          realmType: BPSRealmType.internal,
          scopes: <String>['openid', 'profile-pegawai'],
        );

        const externalConfig = BPSRealmConfig(
          clientId: 'external-456',
          redirectUri: 'id.go.bps://myapp-external',
          realmType: BPSRealmType.external,
          scopes: <String>['openid', 'email', 'profile'],
        );

        const config = BPSSsoConfig(
          internal: internalConfig,
          external: externalConfig,
        );

        expect(config.internal, equals(internalConfig));
        expect(config.external, equals(externalConfig));
        expect(config.baseUrl, equals('https://sso.bps.go.id'));
      });
    });

    group('getConfig Method', () {
      late BPSSsoConfig config;

      setUp(() {
        config = BPSSsoConfig.create(
          appName: 'testapp',
          internalClientId: 'internal-client',
          externalClientId: 'external-client',
        );
      });

      test('should return internal config for internal realm', () {
        final realmConfig = config.getConfig(BPSRealmType.internal);

        expect(realmConfig, equals(config.internal));
        expect(realmConfig.realmType, equals(BPSRealmType.internal));
        expect(realmConfig.clientId, equals('internal-client'));
      });

      test('should return external config for external realm', () {
        final realmConfig = config.getConfig(BPSRealmType.external);

        expect(realmConfig, equals(config.external));
        expect(realmConfig.realmType, equals(BPSRealmType.external));
        expect(realmConfig.clientId, equals('external-client'));
      });
    });
  });

  group('BPSRealmConfig', () {
    group('URL Generation', () {
      late BPSRealmConfig config;

      setUp(() {
        config = const BPSRealmConfig(
          clientId: 'test-client',
          redirectUri: 'id.go.bps://testapp-sso-internal',
          realmType: BPSRealmType.internal,
        );
      });

      test('should generate correct auth URL', () {
        const codeChallenge = 'test-code-challenge';
        const state = 'test-state';

        final authUrl = config.buildAuthUrl(
          codeChallenge: codeChallenge,
          state: state,
        );

        final uri = Uri.parse(authUrl);

        expect(uri.scheme, equals('https'));
        expect(uri.host, equals('sso.bps.go.id'));
        expect(
          uri.path,
          equals('/auth/realms/pegawai-bps/protocol/openid-connect/auth'),
        );

        final queryParams = uri.queryParameters;
        expect(queryParams['client_id'], equals('test-client'));
        expect(
          queryParams['redirect_uri'],
          equals('id.go.bps://testapp-sso-internal'),
        );
        expect(queryParams['response_type'], equals('code'));
        expect(queryParams['scope'], equals('openid profile email'));
        expect(queryParams['code_challenge'], equals(codeChallenge));
        expect(queryParams['code_challenge_method'], equals('S256'));
        expect(queryParams['state'], equals(state));
      });

      test('should generate correct token URL', () {
        final tokenUrl = config.tokenUrl;

        expect(
          tokenUrl,
          equals(
            'https://sso.bps.go.id/auth/realms/pegawai-bps/protocol/openid-connect/token',
          ),
        );
      });

      test('should generate correct user info URL', () {
        final userInfoUrl = config.userInfoUrl;

        expect(
          userInfoUrl,
          equals(
            'https://sso.bps.go.id/auth/realms/pegawai-bps/protocol/openid-connect/userinfo',
          ),
        );
      });

      test('should generate correct logout URL', () {
        final logoutUrl = config.logoutUrl;

        expect(
          logoutUrl,
          equals(
            'https://sso.bps.go.id/auth/realms/pegawai-bps/protocol/openid-connect/logout',
          ),
        );
      });
    });

    group('Realm Property', () {
      test('should return correct realm for internal type', () {
        const config = BPSRealmConfig(
          clientId: 'test-client',
          redirectUri: 'id.go.bps://test',
          realmType: BPSRealmType.internal,
          scopes: <String>['openid'],
        );

        expect(config.realm, equals('pegawai-bps'));
      });

      test('should return correct realm for external type', () {
        const config = BPSRealmConfig(
          clientId: 'test-client',
          redirectUri: 'id.go.bps://test',
          realmType: BPSRealmType.external,
          scopes: <String>['openid'],
        );

        expect(config.realm, equals('eksternal'));
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        const config1 = BPSRealmConfig(
          clientId: 'test-client',
          redirectUri: 'id.go.bps://test',
          realmType: BPSRealmType.internal,
          scopes: <String>['openid', 'profile'],
        );

        const config2 = BPSRealmConfig(
          clientId: 'test-client',
          redirectUri: 'id.go.bps://test',
          realmType: BPSRealmType.internal,
          scopes: <String>['openid', 'profile'],
        );

        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('should not be equal when properties differ', () {
        const config1 = BPSRealmConfig(
          clientId: 'test-client-1',
          redirectUri: 'id.go.bps://test',
          realmType: BPSRealmType.internal,
          scopes: <String>['openid'],
        );

        const config2 = BPSRealmConfig(
          clientId: 'test-client-2', // Different client ID
          redirectUri: 'id.go.bps://test',
          realmType: BPSRealmType.internal,
          scopes: <String>['openid'],
        );

        expect(config1, isNot(equals(config2)));
      });
    });

    group('Multiple Response Types and Scopes', () {
      test('should handle multiple response types', () {
        const config = BPSRealmConfig(
          clientId: 'test-client',
          redirectUri: 'id.go.bps://test',
          realmType: BPSRealmType.internal,
          responseTypes: <String>['code', 'token', 'id_token'],
          scopes: <String>['openid'],
        );

        final authUrl = config.buildAuthUrl(
          codeChallenge: 'test-challenge',
          state: 'test-state',
        );

        final uri = Uri.parse(authUrl);
        expect(
          uri.queryParameters['response_type'],
          equals('code token id_token'),
        );
      });

      test('should handle multiple scopes', () {
        const config = BPSRealmConfig(
          clientId: 'test-client',
          redirectUri: 'id.go.bps://test',
          realmType: BPSRealmType.internal,
          scopes: <String>['openid', 'profile', 'email', 'roles', 'groups'],
        );

        final authUrl = config.buildAuthUrl(
          codeChallenge: 'test-challenge',
          state: 'test-state',
        );

        final uri = Uri.parse(authUrl);
        expect(
          uri.queryParameters['scope'],
          equals('openid profile email roles groups'),
        );
      });
    });
  });

  group('BPSRealmType', () {
    test('should have correct value for internal', () {
      expect(BPSRealmType.internal.value, equals('pegawai-bps'));
    });

    test('should have correct value for external', () {
      expect(BPSRealmType.external.value, equals('eksternal'));
    });

    test('should have correct display name for internal', () {
      expect(BPSRealmType.internal.displayName, equals('BPS Internal'));
    });

    test('should have correct display name for external', () {
      expect(BPSRealmType.external.displayName, equals('External'));
    });
  });
}
