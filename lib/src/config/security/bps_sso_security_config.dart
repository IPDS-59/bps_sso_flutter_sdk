import 'package:bps_sso_sdk/src/config/config.dart';

/// Security configuration for the BPS SSO SDK
class BPSSsoSecurityConfig {
  const BPSSsoSecurityConfig({
    this.enableCertificatePinning = true,
    this.enableJwtSignatureVerification = true,
    this.enableTokenEncryption = true,
    this.enableRuntimeSecurityChecks = true,
    this.enableMemoryProtection = true,
    this.tokenTimeoutDuration = const Duration(minutes: 30),
    this.maxSessionDuration = const Duration(hours: 8),
    this.enableAuditLogging = true,
    this.auditLogLevel = AuditLogLevel.info,
    this.pinnedCertificates = const [],
    this.allowedHosts = const ['sso.bps.go.id'],
    this.enableDebugDetection = true,
    this.enableRootDetection = true,
  });

  /// Whether to enable SSL certificate pinning
  final bool enableCertificatePinning;

  /// Whether to verify JWT signatures
  final bool enableJwtSignatureVerification;

  /// Whether to encrypt tokens in storage
  final bool enableTokenEncryption;

  /// Whether to perform runtime security checks
  final bool enableRuntimeSecurityChecks;

  /// Whether to enable memory protection mechanisms
  final bool enableMemoryProtection;

  /// Timeout duration for individual requests
  final Duration tokenTimeoutDuration;

  /// Maximum session duration before re-authentication required
  final Duration maxSessionDuration;

  /// Whether to enable audit logging
  final bool enableAuditLogging;

  /// Level of audit logging
  final AuditLogLevel auditLogLevel;

  /// List of pinned certificate fingerprints
  final List<String> pinnedCertificates;

  /// List of allowed hostnames for SSO communication
  final List<String> allowedHosts;

  /// Whether to detect debugging attempts
  final bool enableDebugDetection;

  /// Whether to detect rooted/jailbroken devices
  final bool enableRootDetection;

  /// ISO 27001 compliant security configuration
  static const BPSSsoSecurityConfig iso27001 = BPSSsoSecurityConfig(
    tokenTimeoutDuration: Duration(minutes: 15), // Shorter timeout for security
    maxSessionDuration: Duration(hours: 4), // Shorter session for security
    auditLogLevel: AuditLogLevel.detailed,
  );

  static const BPSSsoSecurityConfig development = BPSSsoSecurityConfig(
    enableCertificatePinning: false,
    enableTokenEncryption: false,
    enableRuntimeSecurityChecks: false,
    enableMemoryProtection: false,
    tokenTimeoutDuration: Duration(hours: 1),
    maxSessionDuration: Duration(hours: 24),
    auditLogLevel: AuditLogLevel.debug,
    enableDebugDetection: false,
    enableRootDetection: false,
  );
}
