import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:bps_sso_sdk/src/exceptions/exceptions.dart';
import 'package:flutter/material.dart';

/// Represents a BPS user with authentication information
@immutable
class BPSUser {
  const BPSUser({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.nip,
    required this.organization,
    required this.realm,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiry,
    this.position,
    this.rank,
    this.region,
    this.province,
    this.photo,
    this.address,
    this.oldNip,
    this.firstName,
    this.lastName,
  });

  /// Create BPSUser from JSON response
  factory BPSUser.fromJson(Map<String, dynamic> json, BPSRealmType realm) {
    // Extract required fields with validation
    final sub = json['sub'] as String?;
    final username =
        json['preferred_username'] as String? ?? json['username'] as String?;
    final accessToken = json['access_token'] as String?;
    final refreshToken = json['refresh_token'] as String?;

    // Validate required fields
    if (sub == null || sub.isEmpty) {
      throw const MissingUserDataException('sub');
    }

    if (username == null || username.isEmpty) {
      throw const MissingUserDataException('username');
    }

    if (accessToken == null || accessToken.isEmpty) {
      throw const MissingUserDataException('access_token');
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      throw const MissingUserDataException('refresh_token');
    }

    // Calculate token expiry
    final expiresIn = json['expires_in'] as int? ?? 3600;
    final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

    // Handle different user structures for internal vs external realms
    if (realm == BPSRealmType.external) {
      // External user structure
      return BPSUser(
        id: sub,
        username: username,
        email: json['email'] as String? ?? '',
        fullName: json['name'] as String? ?? username,
        nip: 'EXTERNAL', // External users don't have NIP
        organization: 'External User',
        realm: realm,
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenExpiry: tokenExpiry,
        firstName:
            json['given_name'] as String? ?? json['first_name'] as String?,
        lastName:
            json['family_name'] as String? ?? json['last_name'] as String?,
      );
    } else {
      // Internal user structure
      final nip = json['nip'] as String?;

      // NIP is required for internal users
      if (nip == null || nip.isEmpty) {
        throw const MissingUserDataException('nip');
      }

      return BPSUser(
        id: sub,
        username: username,
        email: json['email'] as String? ?? '',
        fullName: json['name'] as String? ?? username,
        nip: nip,
        organization: json['organisasi'] as String? ?? 'BPS',
        realm: realm,
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenExpiry: tokenExpiry,
        position: json['jabatan'] as String?,
        rank: json['golongan'] as String?,
        region: json['kabupaten'] as String?,
        province: json['provinsi'] as String?,
        photo: json['foto'] as String?,
        address: json['alamat-kantor'] as String?,
        oldNip: json['nip-lama'] as String?,
        firstName: json['first-name'] as String?,
        lastName: json['last-name'] as String?,
      );
    }
  }

  /// Create BPSUser from stored JSON
  factory BPSUser.fromStorageJson(Map<String, dynamic> json) {
    final realmName = json['realm'] as String;
    final realm = realmName == 'external'
        ? BPSRealmType.external
        : BPSRealmType.internal;

    return BPSUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      nip: json['nip'] as String,
      organization: json['organization'] as String,
      realm: realm,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenExpiry: DateTime.parse(json['tokenExpiry'] as String),
      position: json['position'] as String?,
      rank: json['rank'] as String?,
      region: json['region'] as String?,
      province: json['province'] as String?,
      photo: json['photo'] as String?,
      address: json['address'] as String?,
      oldNip: json['oldNip'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }

  /// Unique user identifier (sub claim)
  final String id;

  /// Username for authentication
  final String username;

  /// User's email address
  final String email;

  /// Full name of the user
  final String fullName;

  /// NIP (Nomor Induk Pegawai) - Employee ID
  final String nip;

  /// Organization code
  final String organization;

  /// Authentication realm type
  final BPSRealmType realm;

  /// OAuth2 access token
  final String accessToken;

  /// OAuth2 refresh token
  final String refreshToken;

  /// Token expiry time
  final DateTime tokenExpiry;

  /// User's position/job title
  final String? position;

  /// User's rank/grade
  final String? rank;

  /// User's region/kabupaten
  final String? region;

  /// User's province
  final String? province;

  /// URL to user's photo
  final String? photo;

  /// Office address
  final String? address;

  /// Old NIP (legacy employee ID)
  final String? oldNip;

  /// First name
  final String? firstName;

  /// Last name
  final String? lastName;

  /// Check if access token is expired
  bool get isTokenExpired => DateTime.now().isAfter(tokenExpiry);

  /// Check if user is from external realm
  bool get isExternal => realm == BPSRealmType.external;

  /// Check if user is from internal realm
  bool get isInternal => realm == BPSRealmType.internal;

  /// Get user initials from full name
  String get initials {
    final names = fullName.split(' ');
    if (names.isEmpty) return '';
    if (names.length == 1) return names[0].substring(0, 1).toUpperCase();
    return names.map((name) => name.substring(0, 1).toUpperCase()).join();
  }

  /// Check if user has a photo
  bool get hasPhoto => photo != null && photo!.isNotEmpty;

  /// Get display name for the realm
  String get realmDisplayName => realm.displayName;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'nip': nip,
      'organization': organization,
      'realm': realm.name,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenExpiry': tokenExpiry.toIso8601String(),
      'position': position,
      'rank': rank,
      'region': region,
      'province': province,
      'photo': photo,
      'address': address,
      'oldNip': oldNip,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  /// Create a copy with updated token information
  BPSUser copyWithTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime tokenExpiry,
  }) {
    return BPSUser(
      id: id,
      username: username,
      email: email,
      fullName: fullName,
      nip: nip,
      organization: organization,
      realm: realm,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenExpiry: tokenExpiry,
      position: position,
      rank: rank,
      region: region,
      province: province,
      photo: photo,
      address: address,
      oldNip: oldNip,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  String toString() {
    return 'BPSUser{'
        'id: $id, '
        'username: $username, '
        'fullName: $fullName, '
        'nip: $nip, '
        'realm: $realm}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BPSUser && other.id == id && other.username == username;
  }

  @override
  int get hashCode => Object.hash(id, username);
}
