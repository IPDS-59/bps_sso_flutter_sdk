import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:bps_sso_sdk/src/exceptions/exceptions.dart';
import 'package:bps_sso_sdk/src/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BPSUser', () {
    final now = DateTime.now();
    final tokenExpiry = now.add(const Duration(hours: 1));

    group('Internal User', () {
      test('should create internal user from valid JSON', () {
        final json = {
          'sub': 'user123',
          'preferred_username': 'john.doe',
          'email': 'john.doe@bps.go.id',
          'name': 'John Doe',
          'nip': '123456789',
          'organisasi': 'BPS Pusat',
          'jabatan': 'Kepala Bagian',
          'golongan': 'IV/a',
          'kabupaten': 'Jakarta Pusat',
          'provinsi': 'DKI Jakarta',
          'foto': 'https://example.com/photo.jpg',
          'alamat-kantor': 'Jl. Dr. Sutomo No. 6-8',
          'nip-lama': '987654321',
          'first-name': 'John',
          'last-name': 'Doe',
          'access_token': 'access123',
          'refresh_token': 'refresh123',
          'expires_in': 3600,
        };

        final user = BPSUser.fromJson(json, BPSRealmType.internal);

        expect(user.id, equals('user123'));
        expect(user.username, equals('john.doe'));
        expect(user.email, equals('john.doe@bps.go.id'));
        expect(user.fullName, equals('John Doe'));
        expect(user.nip, equals('123456789'));
        expect(user.organization, equals('BPS Pusat'));
        expect(user.position, equals('Kepala Bagian'));
        expect(user.rank, equals('IV/a'));
        expect(user.region, equals('Jakarta Pusat'));
        expect(user.province, equals('DKI Jakarta'));
        expect(user.photo, equals('https://example.com/photo.jpg'));
        expect(user.address, equals('Jl. Dr. Sutomo No. 6-8'));
        expect(user.oldNip, equals('987654321'));
        expect(user.firstName, equals('John'));
        expect(user.lastName, equals('Doe'));
        expect(user.accessToken, equals('access123'));
        expect(user.refreshToken, equals('refresh123'));
        expect(user.realm, equals(BPSRealmType.internal));
        expect(user.isInternal, isTrue);
        expect(user.isExternal, isFalse);
      });

      test(
        'should throw exception when required fields are missing '
        'for internal user',
        () {
        final json = {
          'sub': 'user123',
          'preferred_username': 'john.doe',
          'access_token': 'access123',
          'refresh_token': 'refresh123',
          // Missing 'nip' which is required for internal users
        };

        expect(
          () => BPSUser.fromJson(json, BPSRealmType.internal),
          throwsA(isA<MissingUserDataException>()),
        );
      });
    });

    group('External User', () {
      test('should create external user from valid JSON', () {
        final json = {
          'sub': 'ext123',
          'preferred_username': 'jane.smith@gmail.com',
          'email': 'jane.smith@gmail.com',
          'name': 'Jane Smith',
          'given_name': 'Jane',
          'family_name': 'Smith',
          'access_token': 'access456',
          'refresh_token': 'refresh456',
          'expires_in': 3600,
        };

        final user = BPSUser.fromJson(json, BPSRealmType.external);

        expect(user.id, equals('ext123'));
        expect(user.username, equals('jane.smith@gmail.com'));
        expect(user.email, equals('jane.smith@gmail.com'));
        expect(user.fullName, equals('Jane Smith'));
        expect(user.nip, equals('EXTERNAL'));
        expect(user.organization, equals('External User'));
        expect(user.firstName, equals('Jane'));
        expect(user.lastName, equals('Smith'));
        expect(user.accessToken, equals('access456'));
        expect(user.refreshToken, equals('refresh456'));
        expect(user.realm, equals(BPSRealmType.external));
        expect(user.isInternal, isFalse);
        expect(user.isExternal, isTrue);
      });

      test('should handle missing optional fields for external user', () {
        final json = {
          'sub': 'ext123',
          'username': 'jane.smith',
          'access_token': 'access456',
          'refresh_token': 'refresh456',
          'expires_in': 3600,
        };

        final user = BPSUser.fromJson(json, BPSRealmType.external);

        expect(user.id, equals('ext123'));
        expect(user.username, equals('jane.smith'));
        expect(user.email, equals(''));
        expect(user.fullName, equals('jane.smith')); // Falls back to username
        expect(user.nip, equals('EXTERNAL'));
        expect(user.organization, equals('External User'));
      });
    });

    group('Token Management', () {
      test('should detect expired token', () {
        final expiredUser = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: now.subtract(const Duration(hours: 1)), // Expired
        );

        expect(expiredUser.isTokenExpired, isTrue);
      });

      test('should detect valid token', () {
        final validUser = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: tokenExpiry, // Valid
        );

        expect(validUser.isTokenExpired, isFalse);
      });

      test('should update tokens using copyWithTokens', () {
        final user = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'old_access',
          refreshToken: 'old_refresh',
          tokenExpiry: now.subtract(const Duration(hours: 1)),
        );

        final newExpiry = now.add(const Duration(hours: 2));
        final updatedUser = user.copyWithTokens(
          accessToken: 'new_access',
          refreshToken: 'new_refresh',
          tokenExpiry: newExpiry,
        );

        expect(updatedUser.accessToken, equals('new_access'));
        expect(updatedUser.refreshToken, equals('new_refresh'));
        expect(updatedUser.tokenExpiry, equals(newExpiry));
        // Other fields should remain the same
        expect(updatedUser.id, equals(user.id));
        expect(updatedUser.fullName, equals(user.fullName));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final user = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: tokenExpiry,
          position: 'Manager',
          rank: 'IV/a',
        );

        final json = user.toJson();

        expect(json['id'], equals('user123'));
        expect(json['username'], equals('john.doe'));
        expect(json['email'], equals('john.doe@bps.go.id'));
        expect(json['fullName'], equals('John Doe'));
        expect(json['nip'], equals('123456789'));
        expect(json['organization'], equals('BPS'));
        expect(json['realm'], equals('internal'));
        expect(json['accessToken'], equals('access123'));
        expect(json['refreshToken'], equals('refresh123'));
        expect(json['tokenExpiry'], equals(tokenExpiry.toIso8601String()));
        expect(json['position'], equals('Manager'));
        expect(json['rank'], equals('IV/a'));
      });

      test('should deserialize from storage JSON correctly', () {
        final json = {
          'id': 'user123',
          'username': 'john.doe',
          'email': 'john.doe@bps.go.id',
          'fullName': 'John Doe',
          'nip': '123456789',
          'organization': 'BPS',
          'realm': 'internal',
          'accessToken': 'access123',
          'refreshToken': 'refresh123',
          'tokenExpiry': tokenExpiry.toIso8601String(),
          'position': 'Manager',
          'rank': 'IV/a',
        };

        final user = BPSUser.fromStorageJson(json);

        expect(user.id, equals('user123'));
        expect(user.username, equals('john.doe'));
        expect(user.realm, equals(BPSRealmType.internal));
        expect(user.tokenExpiry, equals(tokenExpiry));
      });
    });

    group('Equality and Hash', () {
      test('should be equal when id and username match', () {
        final user1 = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: tokenExpiry,
        );

        final user2 = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'different@email.com', // Different email
          fullName: 'Different Name', // Different name
          nip: '987654321', // Different NIP
          organization: 'Different Org',
          realm: BPSRealmType.external, // Different realm
          accessToken: 'different_access',
          refreshToken: 'different_refresh',
          tokenExpiry: now,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when id or username differ', () {
        final user1 = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: tokenExpiry,
        );

        final user2 = BPSUser(
          id: 'user456', // Different ID
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: tokenExpiry,
        );

        expect(user1, isNot(equals(user2)));
      });
    });

    group('Helper Methods', () {
      test('should generate correct initials', () {
        final user = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe Smith',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: tokenExpiry,
        );

        expect(user.initials, equals('JDS'));
      });

      test('should handle single name for initials', () {
        final user = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: tokenExpiry,
        );

        expect(user.initials, equals('J'));
      });

      test('should detect if user has photo', () {
        final userWithPhoto = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: tokenExpiry,
          photo: 'https://example.com/photo.jpg',
        );

        final userWithoutPhoto = BPSUser(
          id: 'user456',
          username: 'jane.doe',
          email: 'jane.doe@bps.go.id',
          fullName: 'Jane Doe',
          nip: '987654321',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access456',
          refreshToken: 'refresh456',
          tokenExpiry: tokenExpiry,
        );

        expect(userWithPhoto.hasPhoto, isTrue);
        expect(userWithoutPhoto.hasPhoto, isFalse);
      });

      test('should get realm display name', () {
        final internalUser = BPSUser(
          id: 'user123',
          username: 'john.doe',
          email: 'john.doe@bps.go.id',
          fullName: 'John Doe',
          nip: '123456789',
          organization: 'BPS',
          realm: BPSRealmType.internal,
          accessToken: 'access123',
          refreshToken: 'refresh123',
          tokenExpiry: tokenExpiry,
        );

        final externalUser = BPSUser(
          id: 'user456',
          username: 'jane.smith@gmail.com',
          email: 'jane.smith@gmail.com',
          fullName: 'Jane Smith',
          nip: 'EXTERNAL',
          organization: 'External User',
          realm: BPSRealmType.external,
          accessToken: 'access456',
          refreshToken: 'refresh456',
          tokenExpiry: tokenExpiry,
        );

        expect(internalUser.realmDisplayName, equals('BPS Internal'));
        expect(externalUser.realmDisplayName, equals('External'));
      });
    });

    group('Error Handling', () {
      test('should throw MissingUserDataException for missing sub', () {
        final json = {
          'preferred_username': 'john.doe',
          'access_token': 'access123',
          'refresh_token': 'refresh123',
          // Missing 'sub'
        };

        expect(
          () => BPSUser.fromJson(json, BPSRealmType.internal),
          throwsA(isA<MissingUserDataException>()),
        );
      });

      test('should throw MissingUserDataException for missing username', () {
        final json = {
          'sub': 'user123',
          'access_token': 'access123',
          'refresh_token': 'refresh123',
          // Missing 'preferred_username' and 'username'
        };

        expect(
          () => BPSUser.fromJson(json, BPSRealmType.internal),
          throwsA(isA<MissingUserDataException>()),
        );
      });

      test(
        'should throw MissingUserDataException for missing access_token',
        () {
        final json = {
          'sub': 'user123',
          'preferred_username': 'john.doe',
          'refresh_token': 'refresh123',
          // Missing 'access_token'
        };

        expect(
          () => BPSUser.fromJson(json, BPSRealmType.internal),
          throwsA(isA<MissingUserDataException>()),
        );
      });
    });
  });
}
