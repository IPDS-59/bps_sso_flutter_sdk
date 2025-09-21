/// Base exception for BPS SSO operations
abstract class BPSSsoException implements Exception {
  const BPSSsoException(this.message);

  final String message;

  @override
  String toString() => 'BPSSsoException: $message';
}

/// Exception thrown when authentication is cancelled by user
class AuthenticationCancelledException extends BPSSsoException {
  const AuthenticationCancelledException()
    : super('Authentication was cancelled by user');
}

/// Exception thrown when token exchange fails
class TokenExchangeException extends BPSSsoException {
  const TokenExchangeException(super.message);

  factory TokenExchangeException.fromStatusCode(int statusCode) {
    return TokenExchangeException(
      'Token exchange failed with status code: $statusCode',
    );
  }
}

/// Exception thrown when access token is invalid or expired
class InvalidTokenException extends BPSSsoException {
  const InvalidTokenException() : super('Access token is invalid or expired');
}

/// Exception thrown when required user data is missing
class MissingUserDataException extends BPSSsoException {
  const MissingUserDataException(String field)
    : super('Required user data field is missing: $field');
}

/// Exception thrown when network request fails
class NetworkException extends BPSSsoException {
  const NetworkException(super.message);
}

/// Exception thrown when user info cannot be retrieved
class UserInfoException extends BPSSsoException {
  const UserInfoException(super.message);
}

/// Exception thrown when logout operation fails
class LogoutException extends BPSSsoException {
  const LogoutException(super.message);
}

/// Exception thrown when security validation fails
class SecurityException extends BPSSsoException {
  const SecurityException(super.message);
}

/// Exception thrown when certificate validation fails
class CertificateValidationException extends BPSSsoException {
  const CertificateValidationException(super.message);
}

/// Exception thrown when state parameter validation fails
class InvalidStateException extends BPSSsoException {
  const InvalidStateException()
    : super('OAuth state parameter validation failed');
}
