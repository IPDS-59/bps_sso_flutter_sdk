/// Error handling configuration for the authentication flow
class BPSSsoErrorConfig {
  const BPSSsoErrorConfig({
    this.enableDetailedErrorMessages = false,
    this.enableErrorLogging = true,
    this.enableUserFriendlyMessages = true,
    this.customErrorMessages = const {},
    this.onError,
    this.enableErrorReporting = false,
    this.errorReportingEndpoint,
    this.maxRetryAttempts = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  /// Whether to show detailed technical error messages
  /// Should be false in production for security
  final bool enableDetailedErrorMessages;

  /// Whether to enable secure error logging
  final bool enableErrorLogging;

  /// Whether to show user-friendly error messages
  final bool enableUserFriendlyMessages;

  /// Custom error messages for specific error types
  final Map<Type, String> customErrorMessages;

  /// Custom error handler callback
  final void Function(Exception error, StackTrace? stackTrace)? onError;

  /// Whether to enable error reporting to remote service
  final bool enableErrorReporting;

  /// Endpoint for error reporting (if enabled)
  final String? errorReportingEndpoint;

  /// Maximum number of retry attempts for failed operations
  final int maxRetryAttempts;

  /// Delay between retry attempts
  final Duration retryDelay;

  /// Create a copy with modified values
  BPSSsoErrorConfig copyWith({
    bool? enableDetailedErrorMessages,
    bool? enableErrorLogging,
    bool? enableUserFriendlyMessages,
    Map<Type, String>? customErrorMessages,
    void Function(Exception error, StackTrace? stackTrace)? onError,
    bool? enableErrorReporting,
    String? errorReportingEndpoint,
    int? maxRetryAttempts,
    Duration? retryDelay,
  }) => BPSSsoErrorConfig(
    enableDetailedErrorMessages:
        enableDetailedErrorMessages ?? this.enableDetailedErrorMessages,
    enableErrorLogging: enableErrorLogging ?? this.enableErrorLogging,
    enableUserFriendlyMessages:
        enableUserFriendlyMessages ?? this.enableUserFriendlyMessages,
    customErrorMessages: customErrorMessages ?? this.customErrorMessages,
    onError: onError ?? this.onError,
    enableErrorReporting: enableErrorReporting ?? this.enableErrorReporting,
    errorReportingEndpoint:
        errorReportingEndpoint ?? this.errorReportingEndpoint,
    maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
    retryDelay: retryDelay ?? this.retryDelay,
  );
}
