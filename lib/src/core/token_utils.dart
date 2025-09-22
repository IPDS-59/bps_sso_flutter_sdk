import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Utility functions for token management
class TokenUtils {
  TokenUtils._();

  /// Generate a hash of the access token for caching purposes
  ///
  /// Uses SHA256 to create a consistent hash that can be used as a cache key
  /// without storing the actual token value.
  static String hashToken(String token) {
    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if a token is close to expiring
  ///
  /// Returns true if the token expires within the configured buffer time.
  /// This helps trigger preemptive token refresh.
  static bool isTokenNearExpiry(DateTime? expiresAt, Duration buffer) {
    if (expiresAt == null) return false;

    final now = DateTime.now();
    final bufferTime = expiresAt.subtract(buffer);

    return now.isAfter(bufferTime);
  }

  /// Extract token expiry from JWT payload (if available)
  ///
  /// This is a simple implementation that extracts the 'exp' claim
  /// from a JWT token without full JWT validation.
  static DateTime? extractTokenExpiry(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (second part)
      final payload = parts[1];
      final normalizedPayload = _normalizeBase64(payload);
      final payloadBytes = base64Decode(normalizedPayload);
      final payloadString = utf8.decode(payloadBytes);
      final payloadJson = jsonDecode(payloadString) as Map<String, dynamic>;

      final exp = payloadJson['exp'] as int?;
      if (exp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } on Exception {
      // Token parsing failed, return null
      return null;
    }
  }

  /// Normalize base64 string for decoding
  ///
  /// JWT base64 encoding may not have proper padding, so we add it if needed.
  static String _normalizeBase64(String str) {
    switch (str.length % 4) {
      case 0:
        return str;
      case 2:
        return '$str==';
      case 3:
        return '$str=';
      default:
        throw Exception('Invalid base64 string');
    }
  }
}
