import 'dart:async';

import 'package:bps_sso_sdk/src/core/constants.dart';

/// Simple in-memory token validation cache to reduce network calls
///
/// This cache helps avoid redundant token validation requests by storing
/// validation results for a short period (default: 5 minutes).
class TokenValidationCache {
  TokenValidationCache._();
  static final TokenValidationCache _instance = TokenValidationCache._();
  static TokenValidationCache get instance => _instance;

  final Map<String, _CacheEntry> _cache = {};
  Timer? _cleanupTimer;

  /// Cache a token validation result
  void cacheValidation({
    required String userId,
    required String tokenHash,
    required bool isValid,
  }) {
    final key = _generateKey(userId, tokenHash);
    final expiry = DateTime.now().add(SecurityConstants.tokenCacheTTL);

    _cache[key] = _CacheEntry(
      isValid: isValid,
      expiresAt: expiry,
    );

    _scheduleCleanup();
  }

  /// Get cached validation result if available and not expired
  bool? getCachedValidation({
    required String userId,
    required String tokenHash,
  }) {
    final key = _generateKey(userId, tokenHash);
    final entry = _cache[key];

    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    return entry.isValid;
  }

  /// Clear cached validation for a specific user
  void clearUserCache(String userId) {
    _cache.removeWhere((key, _) => key.startsWith('$userId:'));
  }

  /// Clear all cached validations
  void clearAll() {
    _cache.clear();
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Generate cache key from user ID and token hash
  String _generateKey(String userId, String tokenHash) {
    // Take first 16 characters of token hash for key
    final shortHash = tokenHash.length > 16
        ? tokenHash.substring(0, 16)
        : tokenHash;
    return '$userId:$shortHash';
  }

  /// Schedule periodic cleanup of expired entries
  void _scheduleCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _cleanupExpired(),
    );
  }

  /// Remove expired entries from cache
  void _cleanupExpired() {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => now.isAfter(entry.expiresAt));

    // Cancel timer if cache is empty
    if (_cache.isEmpty) {
      _cleanupTimer?.cancel();
      _cleanupTimer = null;
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final validEntries = _cache.values
        .where((entry) => now.isBefore(entry.expiresAt))
        .length;

    return {
      'totalEntries': _cache.length,
      'validEntries': validEntries,
      'expiredEntries': _cache.length - validEntries,
      'isTimerActive': _cleanupTimer?.isActive ?? false,
    };
  }
}

/// Internal cache entry structure
class _CacheEntry {
  const _CacheEntry({
    required this.isValid,
    required this.expiresAt,
  });

  final bool isValid;
  final DateTime expiresAt;
}
