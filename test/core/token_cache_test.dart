import 'package:bps_sso_sdk/src/core/token_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenValidationCache', () {
    late TokenValidationCache cache;

    setUp(() {
      cache = TokenValidationCache.instance;
      cache.clearAll(); // Start with clean cache
    });

    tearDown(() {
      cache.clearAll(); // Clean up after each test
    });

    test('should cache and retrieve validation results', () {
      const userId = 'user123';
      const tokenHash = 'token_hash_123';

      // Initially no cached result
      expect(
        cache.getCachedValidation(userId: userId, tokenHash: tokenHash),
        isNull,
      );

      // Cache a valid result
      cache.cacheValidation(
        userId: userId,
        tokenHash: tokenHash,
        isValid: true,
      );

      // Should retrieve cached result
      expect(
        cache.getCachedValidation(userId: userId, tokenHash: tokenHash),
        isTrue,
      );
    });

    test('should cache invalid validation results', () {
      const userId = 'user123';
      const tokenHash = 'token_hash_123';

      // Cache an invalid result
      cache.cacheValidation(
        userId: userId,
        tokenHash: tokenHash,
        isValid: false,
      );

      // Should retrieve cached invalid result
      expect(
        cache.getCachedValidation(userId: userId, tokenHash: tokenHash),
        isFalse,
      );
    });

    test('should clear cache for specific user', () {
      const user1Id = 'user1';
      const user2Id = 'user2';
      const tokenHash = 'token_hash_123';

      // Cache results for both users
      cache
        ..cacheValidation(
          userId: user1Id,
          tokenHash: tokenHash,
          isValid: true,
        )
        ..cacheValidation(
          userId: user2Id,
          tokenHash: tokenHash,
          isValid: true,
        )
        // Clear cache for user1
        ..clearUserCache(user1Id);

      // User1 cache should be cleared, user2 should remain
      expect(
        cache.getCachedValidation(userId: user1Id, tokenHash: tokenHash),
        isNull,
      );
      expect(
        cache.getCachedValidation(userId: user2Id, tokenHash: tokenHash),
        isTrue,
      );
    });

    test('should clear all cache', () {
      const userId = 'user123';
      const tokenHash = 'token_hash_123';

      // Cache a result
      cache.cacheValidation(
        userId: userId,
        tokenHash: tokenHash,
        isValid: true,
      );

      // Clear all cache
      cache.clearAll();

      // Should have no cached result
      expect(
        cache.getCachedValidation(userId: userId, tokenHash: tokenHash),
        isNull,
      );
    });

    test('should provide cache statistics', () {
      const userId = 'user123';
      const tokenHash = 'token_hash_123';

      // Initial stats
      var stats = cache.getStats();
      expect(stats['totalEntries'], equals(0));
      expect(stats['validEntries'], equals(0));

      // Cache a result
      cache.cacheValidation(
        userId: userId,
        tokenHash: tokenHash,
        isValid: true,
      );

      // Updated stats
      stats = cache.getStats();
      expect(stats['totalEntries'], equals(1));
      expect(stats['validEntries'], equals(1));
    });

    test('should handle different token hashes for same user', () {
      const userId = 'user123';
      const tokenHash1 = 'token_hash_1';
      const tokenHash2 = 'token_hash_2';

      // Cache different results for different tokens
      cache
        ..cacheValidation(
          userId: userId,
          tokenHash: tokenHash1,
          isValid: true,
        )
        ..cacheValidation(
          userId: userId,
          tokenHash: tokenHash2,
          isValid: false,
        );

      // Should retrieve correct results for each token
      expect(
        cache.getCachedValidation(userId: userId, tokenHash: tokenHash1),
        isTrue,
      );
      expect(
        cache.getCachedValidation(userId: userId, tokenHash: tokenHash2),
        isFalse,
      );
    });
  });
}
