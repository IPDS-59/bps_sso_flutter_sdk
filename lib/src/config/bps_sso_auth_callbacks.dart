// need to ignore it
// ignore_for_file: comment_references, lines_longer_than_80_chars

import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:bps_sso_sdk/src/models/models.dart';

/// Callback configuration for authentication events
class BPSSsoAuthCallback {
  const BPSSsoAuthCallback({
    this.onLoginSuccess,
    this.onLoginFailed,
    this.onLoginCancelled,
    this.onLogoutSuccess,
    this.onLogoutFailed,
    this.onTokenRefreshSuccess,
    this.onTokenRefreshFailed,
    this.onAuthenticationFailure,
  });

  /// Called when user successfully logs in
  /// [user] - The authenticated user data
  /// [realmType] - The realm type used for authentication
  final void Function(BPSUser user, BPSRealmType realmType)? onLoginSuccess;

  /// Called when login fails
  /// [error] - The error that occurred during login
  /// [realmType] - The realm type that was attempted
  final void Function(Exception error, BPSRealmType realmType)? onLoginFailed;

  /// Called when user cancels the login process
  /// [realmType] - The realm type that was attempted
  final void Function(BPSRealmType realmType)? onLoginCancelled;

  /// Called when user successfully logs out
  /// [user] - The user that was logged out
  final void Function(BPSUser user)? onLogoutSuccess;

  /// Called when logout fails (but local storage is still cleared)
  /// [error] - The error that occurred during logout
  /// [user] - The user that was being logged out
  final void Function(Exception error, BPSUser user)? onLogoutFailed;

  /// Called when token refresh is successful
  /// [user] - The user with updated tokens
  final void Function(BPSUser user)? onTokenRefreshSuccess;

  /// Called when token refresh fails
  /// [error] - The error that occurred during token refresh
  /// [user] - The user whose tokens failed to refresh
  final void Function(Exception error, BPSUser user)? onTokenRefreshFailed;

  /// Called when authentication fails due to expired/invalid session
  /// This includes cases where:
  /// - Access token is expired and refresh token is also expired/invalid
  /// - User session is invalidated on the server
  /// - Authentication state becomes inconsistent
  ///
  /// This callback should typically trigger a force logout and redirect to login
  /// [error] - The authentication failure reason
  /// [user] - The user whose authentication failed (may be null if no valid user data)
  final void Function(Exception error, BPSUser? user)? onAuthenticationFailure;

  /// Default empty callbacks configuration
  static const BPSSsoAuthCallback none = BPSSsoAuthCallback();
}
