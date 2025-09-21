/// Audit logging levels for security compliance
enum AuditLogLevel {
  /// No audit logging
  none,

  /// Basic audit logging (authentication events only)
  basic,

  /// Standard audit logging (authentication + authorization)
  info,

  /// Detailed audit logging (all security events)
  detailed,

  /// Debug level logging (development only)
  debug,
}
