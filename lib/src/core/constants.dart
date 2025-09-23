/// Security and configuration constants for BPS SSO SDK
class SecurityConstants {
  SecurityConstants._();

  // Authentication timeouts
  static const Duration authTimeout = Duration(minutes: 5);
  static const Duration tokenRefreshTimeout = Duration(seconds: 30);
  static const Duration customTabCloseDelay = Duration(milliseconds: 500);

  // Security parameters
  static const int stateParameterLength = 32;
  static const int codeVerifierLength = 128;
  static const int minCodeVerifierLength = 43;
  static const int maxCodeVerifierLength = 128;

  // Entropy validation
  static const double minEntropyRatio = 0.1;
  static const double maxEntropyThreshold = 4;

  // Token validation
  static const Duration tokenCacheTTL = Duration(minutes: 5);
  static const Duration tokenExpiryBuffer = Duration(minutes: 5);

  // Network retry configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 10);

  // Custom tabs configuration
  static const Duration iOSTabCloseDelay = Duration(milliseconds: 300);
  static const int maxCustomTabAttempts = 3;

  // Cache keys
  static const String tokenCacheKeyPrefix = 'token_validation_';
  static const String userCacheKeyPrefix = 'user_data_';

  // SSL Pinning - Production certificates
  static const List<String> productionCertificates = [
    // Add your production SSL certificates here
    // Format: SHA256 fingerprint of the certificate
    // Example: 'SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
  ];

  // Allowed domains for OAuth redirects
  static const List<String> allowedRedirectDomains = [
    'sso.bps.go.id',
    'sso-staging.bps.go.id',
    'localhost', // For development only
  ];
}

/// Network configuration constants
class NetworkConstants {
  NetworkConstants._();

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String userAgentHeader = 'User-Agent';

  // Content types
  static const String jsonContentType = 'application/json';
  static const String formUrlEncodedContentType =
      'application/x-www-form-urlencoded';

  // User agent
  static const String sdkUserAgent = 'BPS-SSO-SDK/1.2.0 (Flutter)';
}

/// HTTP status code constants
class HttpStatusCodes {
  HttpStatusCodes._();

  // Success codes
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;

  // Client error codes
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;

  // Server error codes
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}

/// Token and authentication constants
class TokenConstants {
  TokenConstants._();

  // Default token expiry (1 hour in seconds)
  static const int defaultTokenExpirySeconds = 3600;

  // Token multipliers
  static const int millisecondsPerSecond = 1000;

  // Character sets for random generation
  static const String alphanumericChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static const String pkceAllowedChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  // Entropy validation
  static const int entropyTestDataSize = 100;
  static const int randomCharRange = 256;
  static const int minUniqueEntropyValues = 50;
}

/// OAuth2 and OIDC constants
class OAuth2Constants {
  OAuth2Constants._();

  // OAuth2 parameters
  static const String responseTypeParam = 'response_type';
  static const String clientIdParam = 'client_id';
  static const String redirectUriParam = 'redirect_uri';
  static const String scopeParam = 'scope';
  static const String stateParam = 'state';
  static const String codeParam = 'code';
  static const String grantTypeParam = 'grant_type';
  static const String refreshTokenParam = 'refresh_token';

  // PKCE parameters
  static const String codeChallengeParam = 'code_challenge';
  static const String codeChallengeMethodParam = 'code_challenge_method';
  static const String codeVerifierParam = 'code_verifier';

  // Grant types
  static const String authorizationCodeGrant = 'authorization_code';
  static const String refreshTokenGrant = 'refresh_token';

  // Default scopes
  static const List<String> defaultScopes = ['openid', 'profile', 'email'];
  static const List<String> internalDefaultScopes = [
    'openid',
    'profile-pegawai',
  ];

  // Token types
  static const String bearerTokenType = 'Bearer';
}

/// Error message constants
class ErrorMessages {
  ErrorMessages._();

  static const String authenticationCancelled =
      'Authentication was cancelled by the user';
  static const String tokenExchangeFailed =
      'Failed to exchange authorization code for tokens';
  static const String networkError =
      'Network error occurred during authentication';
  static const String missingUserData =
      'Required user data is missing from the response';
  static const String invalidState =
      'Invalid state parameter in OAuth callback';
  static const String tokenExpired = 'Access token has expired';
  static const String refreshFailed = 'Failed to refresh access token';
  static const String logoutFailed = 'Failed to logout user';
  static const String configurationError = 'Invalid SDK configuration';
  static const String deepLinkTimeout =
      'Authentication timeout - no response received';
  static const String invalidRedirectUri = 'Invalid or insecure redirect URI';
  static const String securityViolation = 'Security validation failed';
  static const String rootDetected = 'Device appears to be rooted/jailbroken';
  static const String debuggerDetected =
      'Debugger detected - authentication blocked';
}
