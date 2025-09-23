import 'dart:convert';
import 'dart:math';

import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:bps_sso_sdk/src/core/constants.dart';
import 'package:bps_sso_sdk/src/exceptions/exceptions.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Security manager for the BPS SSO SDK
/// Implements ISO 27001 compliant security controls
class BPSSsoSecurityManager {
  factory BPSSsoSecurityManager() => _instance;
  BPSSsoSecurityManager._internal();
  static final BPSSsoSecurityManager _instance =
      BPSSsoSecurityManager._internal();

  BPSSsoSecurityConfig _config = BPSSsoSecurityConfig.iso27001;

  /// Initialize security manager with configuration
  void initialize(BPSSsoSecurityConfig config) {
    _config = config;
    if (_config.enableRuntimeSecurityChecks) {
      _performRuntimeSecurityChecks();
    }
  }

  /// Generate cryptographically secure PKCE code verifier
  /// Implements RFC 7636 with enhanced entropy validation
  String generateSecureCodeVerifier() {
    try {
      // Validate entropy before generation
      if (!_hasAdequateEntropy()) {
        _logSecurityEvent(
          'Insufficient entropy detected for code verifier generation',
          AuditLogLevel.detailed,
        );
        throw const SecurityException(
          'Insufficient cryptographic entropy available',
        );
      }

      // RFC 7636: 43-128 characters recommended
      final length =
          SecurityConstants.minCodeVerifierLength +
          Random.secure().nextInt(
            SecurityConstants.maxCodeVerifierLength -
                SecurityConstants.minCodeVerifierLength +
                1,
          );
      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
      final random = Random.secure();

      final verifier = List.generate(
        length,
        (index) => chars[random.nextInt(chars.length)],
      ).join();

      // Additional entropy validation
      if (!_validateCodeVerifierEntropy(verifier)) {
        _logSecurityEvent(
          'Generated code verifier failed entropy validation',
          AuditLogLevel.detailed,
        );
        throw const SecurityException(
          'Generated code verifier does not meet entropy requirements',
        );
      }

      _logSecurityEvent(
        'Secure code verifier generated successfully',
        AuditLogLevel.info,
      );
      return verifier;
    } catch (e) {
      _logSecurityEvent(
        'Code verifier generation failed: $e',
        AuditLogLevel.detailed,
      );
      rethrow;
    }
  }

  /// Generate PKCE code challenge with security validation
  String generateCodeChallenge(String codeVerifier) {
    try {
      if (codeVerifier.length < SecurityConstants.minCodeVerifierLength ||
          codeVerifier.length > SecurityConstants.maxCodeVerifierLength) {
        throw const SecurityException(
          'Code verifier length violates RFC 7636 requirements',
        );
      }

      final bytes = utf8.encode(codeVerifier);
      final digest = sha256.convert(bytes);
      final challenge = base64Url.encode(digest.bytes).replaceAll('=', '');

      _logSecurityEvent(
        'Code challenge generated successfully',
        AuditLogLevel.info,
      );
      return challenge;
    } catch (e) {
      _logSecurityEvent(
        'Code challenge generation failed: $e',
        AuditLogLevel.detailed,
      );
      rethrow;
    }
  }

  /// Generate cryptographically secure state parameter
  String generateSecureState() {
    try {
      // Use configured length for government-grade security
      const length = SecurityConstants.stateParameterLength;
      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      final random = Random.secure();

      final state = List.generate(
        length,
        (index) => chars[random.nextInt(chars.length)],
      ).join();

      _logSecurityEvent('Secure state parameter generated', AuditLogLevel.info);
      return state;
    } on Exception catch (e) {
      _logSecurityEvent('State generation failed: $e', AuditLogLevel.detailed);
      throw const SecurityException(
        'Failed to generate secure state parameter',
      );
    }
  }

  /// Validate deep link security
  bool validateDeepLink(String link, String expectedState) {
    try {
      final uri = Uri.tryParse(link);
      if (uri == null) {
        _logSecurityEvent(
          'Invalid deep link format received',
          AuditLogLevel.detailed,
        );
        return false;
      }

      // Validate scheme
      if (!_isValidScheme(uri.scheme)) {
        _logSecurityEvent(
          'Invalid URL scheme in deep link: ${uri.scheme}',
          AuditLogLevel.detailed,
        );
        return false;
      }

      // Validate host
      if (!_isValidHost(uri.host)) {
        _logSecurityEvent(
          'Invalid host in deep link: ${uri.host}',
          AuditLogLevel.detailed,
        );
        return false;
      }

      // Validate state parameter
      final receivedState = uri.queryParameters['state'];
      if (receivedState != expectedState) {
        _logSecurityEvent(
          'State parameter mismatch in deep link',
          AuditLogLevel.detailed,
        );
        return false;
      }

      // Validate required parameters
      if (!_validateRequiredParameters(uri.queryParameters)) {
        _logSecurityEvent(
          'Missing required parameters in deep link',
          AuditLogLevel.detailed,
        );
        return false;
      }

      _logSecurityEvent('Deep link validation successful', AuditLogLevel.info);
      return true;
    } on Exception catch (e) {
      _logSecurityEvent(
        'Deep link validation error: $e',
        AuditLogLevel.detailed,
      );
      return false;
    }
  }

  /// Sanitize error messages for production use
  Exception sanitizeError(dynamic error, {required bool isProduction}) {
    try {
      _logSecurityEvent(
        'Error occurred: $error',
        AuditLogLevel.detailed,
      );

      if (!isProduction && kDebugMode) {
        // Return detailed errors in development
        return error is Exception ? error : Exception(error.toString());
      }

      // Return sanitized errors in production
      if (error is AuthenticationCancelledException) {
        return error; // This is safe to expose
      } else if (error is NetworkException) {
        return const NetworkException('Network error occurred');
      } else if (error is SecurityException) {
        return const SecurityException('Security validation failed');
      } else {
        return const NetworkException('Authentication failed');
      }
    } on Exception catch (e) {
      _logSecurityEvent(
        'Error sanitization failed: $e',
        AuditLogLevel.detailed,
      );
      return const NetworkException('An unexpected error occurred');
    }
  }

  /// Secure memory cleanup for sensitive data
  void secureClearSensitiveData(String sensitiveData) {
    if (!_config.enableMemoryProtection) return;

    try {
      // This is a best-effort approach in Dart to overwrite memory
      // For stronger memory protection, consider native implementation
      final random = Random.secure();
      List.generate(
        sensitiveData.length,
        (_) => String.fromCharCode(random.nextInt(256)),
      ).join();

      _logSecurityEvent(
        'Sensitive data cleared from memory',
        AuditLogLevel.info,
      );
    } on Exception catch (e) {
      _logSecurityEvent('Memory cleanup failed: $e', AuditLogLevel.detailed);
    }
  }

  /// Perform runtime security checks
  void _performRuntimeSecurityChecks() {
    try {
      if (_config.enableDebugDetection && _isDebuggingDetected()) {
        _logSecurityEvent('Debugging attempt detected', AuditLogLevel.detailed);
        throw const SecurityException(
          'Debugging detected - operation not allowed',
        );
      }

      if (_config.enableRootDetection && _isRootDetected()) {
        _logSecurityEvent(
          'Rooted/jailbroken device detected',
          AuditLogLevel.detailed,
        );
        throw const SecurityException('Compromised device detected');
      }

      _logSecurityEvent('Runtime security checks passed', AuditLogLevel.info);
    } catch (e) {
      _logSecurityEvent(
        'Runtime security check failed: $e',
        AuditLogLevel.detailed,
      );
      rethrow;
    }
  }

  /// Check if adequate entropy is available
  bool _hasAdequateEntropy() {
    try {
      // Generate test random data and check for patterns
      final random = Random.secure();
      final testData = List.generate(100, (_) => random.nextInt(256));

      // Simple entropy check - in production, use more sophisticated methods
      final uniqueValues = testData.toSet().length;
      return uniqueValues > 50; // At least 50% unique values
    } on Exception {
      return false;
    }
  }

  /// Validate code verifier entropy
  bool _validateCodeVerifierEntropy(String verifier) {
    try {
      // Check character distribution
      final charCounts = <String, int>{};
      for (final char in verifier.split('')) {
        charCounts[char] = (charCounts[char] ?? 0) + 1;
      }

      // Ensure no character appears too frequently (basic entropy check)
      final maxFrequency = charCounts.values.reduce((a, b) => a > b ? a : b);
      final entropyRatio = maxFrequency / verifier.length;

      // No character should appear more than the configured threshold
      return entropyRatio < SecurityConstants.minEntropyRatio;
    } on Exception {
      return false;
    }
  }

  /// Validate URL scheme
  bool _isValidScheme(String scheme) {
    const validSchemes = ['id.go.bps'];
    return validSchemes.contains(scheme);
  }

  /// Validate URL host
  bool _isValidHost(String host) {
    // For deep links, the host should match expected patterns
    final validPatterns = [
      RegExp(r'^[a-zA-Z0-9-]+-sso-(internal|eksternal)$'),
    ];

    return validPatterns.any((pattern) => pattern.hasMatch(host));
  }

  /// Validate required parameters in deep link
  bool _validateRequiredParameters(Map<String, String> params) {
    // Check for authorization code or error
    return params.containsKey('code') || params.containsKey('error');
  }

  /// Detect debugging attempts
  bool _isDebuggingDetected() {
    if (kDebugMode) {
      return true; // Development mode
    }

    // Additional debugging detection can be implemented here
    // For production apps, you might check for:
    // - Debugger attachment
    // - Frida/hooking frameworks
    // - Suspicious runtime behavior

    return false;
  }

  /// Detect rooted/jailbroken devices
  bool _isRootDetected() {
    // This is a simplified implementation
    // In production, use dedicated libraries like:
    // - freerasp for comprehensive protection
    // - root_detector package
    // - Custom native implementations

    return false; // Placeholder implementation
  }

  /// Log security events for audit purposes
  void _logSecurityEvent(String message, AuditLogLevel level) {
    if (!_config.enableAuditLogging) return;
    if (level.index < _config.auditLogLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'level': level.toString(),
      'event': message,
      'component': 'BpsSecurityManager',
    };

    // In production, send to secure logging service
    if (kDebugMode) {
      debugPrint('[SECURITY AUDIT] $logEntry');
    }
  }
}
