import 'dart:async';

import 'package:bps_sso_sdk/bps_sso_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends HydratedCubit<AuthenticationState>
    with WidgetsBindingObserver {
  AuthenticationCubit() : super(const AuthenticationState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  Timer? _cancelTimer;

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelTimer?.cancel();
    return super.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // If app is resumed and we were in a loading state (likely authentication)
    // and it's been more than a few seconds, assume user cancelled
    if (state == AppLifecycleState.resumed &&
        this.state.isLoading &&
        this.state.authStartTime != null) {
      final timeSinceStart = DateTime.now().difference(
        this.state.authStartTime!,
      );

      // If more than 3 seconds have passed since starting auth and we're still loading,
      // it's likely the user cancelled or closed the browser
      if (timeSinceStart.inSeconds > 3) {
        emit(
          this.state.copyWith(
            isLoading: false,
            lastResult: 'Authentication cancelled by user',
            clearAuthStartTime: true,
          ),
        );
      }
    }
  }

  void setSelectedRealm(BPSRealmType realm) {
    emit(state.copyWith(selectedRealm: realm));
  }

  void cancelAuthentication() {
    emit(
      state.copyWith(
        isLoading: false,
        lastResult: 'Authentication cancelled by user',
        clearAuthStartTime: true,
      ),
    );
    _cancelTimer?.cancel();
  }

  Future<void> login(BuildContext context) async {
    emit(
      state.copyWith(
        isLoading: true,
        lastOperation: 'Login',
        lastResult: null,
        authStartTime: DateTime.now(),
      ),
    );

    try {
      // SDK is now properly initialized with callback configuration
      // The login method should complete when the deep link callback is processed
      final user = await BPSSsoClient.instance.login(
        context: context,
        realmType: state.selectedRealm,
      ).timeout(
        const Duration(minutes: 2), // Give enough time for user to complete OAuth
        onTimeout: () {
          throw TimeoutException(
            'OAuth flow timed out. The deep link callback may not have been processed correctly.',
            const Duration(minutes: 2),
          );
        },
      );

      _cancelTimer?.cancel();
      emit(
        state.copyWith(
          currentUser: user,
          lastResult: 'Login successful! Welcome ${user.fullName}',
          isLoading: false,
          clearAuthStartTime: true,
        ),
      );
    } catch (e) {
      _cancelTimer?.cancel();

      String errorMessage;
      if (e is AuthenticationCancelledException) {
        errorMessage = 'Authentication was cancelled';
      } else if (e is TimeoutException) {
        errorMessage = 'OAuth flow timed out - deep link callback issue';
      } else if (e is NetworkException) {
        errorMessage = 'Network error: ${e.message}';
      } else if (e is TokenExchangeException) {
        errorMessage = 'Token exchange failed';
      } else {
        errorMessage = 'Login failed: $e';
      }

      emit(
        state.copyWith(
          isLoading: false,
          lastResult: errorMessage,
          clearAuthStartTime: true,
        ),
      );
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    if (state.currentUser == null) {
      throw Exception('Please login first');
    }

    emit(
      state.copyWith(
        isLoading: true,
        lastOperation: 'Refresh Token',
        lastResult: null,
      ),
    );

    try {
      final updatedUser = await BPSSsoClient.instance.refreshToken(
        state.currentUser!,
      );

      emit(
        state.copyWith(
          currentUser: updatedUser,
          lastResult: 'Token refreshed successfully',
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          lastResult: 'Token refresh failed: $e',
          isLoading: false,
        ),
      );
      rethrow;
    }
  }

  Future<void> validateToken() async {
    if (state.currentUser == null) {
      throw Exception('Please login first');
    }

    emit(
      state.copyWith(
        isLoading: true,
        lastOperation: 'Validate Token',
        lastResult: null,
      ),
    );

    try {
      final isValid = await BPSSsoClient.instance.validateToken(
        state.currentUser!,
      );

      emit(
        state.copyWith(
          lastResult: 'Token is ${isValid ? 'valid' : 'invalid'}',
          isLoading: false,
        ),
      );

      if (!isValid) {
        throw Exception('Token is invalid');
      }
    } catch (e) {
      emit(
        state.copyWith(
          lastResult: 'Token validation failed: $e',
          isLoading: false,
        ),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    if (state.currentUser == null) {
      throw Exception('Please login first');
    }

    emit(
      state.copyWith(
        isLoading: true,
        lastOperation: 'Logout',
        lastResult: null,
      ),
    );

    try {
      await BPSSsoClient.instance.logout(state.currentUser!);

      // Complete reset of authentication state
      emit(
        state.copyWith(
          lastResult: 'Logout successful', // Set success message
          isLoading: false,           // Stop loading
          clearCurrentUser: true,     // Clear user data
          clearLastOperation: true,   // Clear last operation
          clearAuthStartTime: true,   // Clear auth timing
        ),
      );
    } catch (e) {
      // Even if logout fails on server, clear local data for security
      emit(
        state.copyWith(
          lastResult: 'Logout failed: $e', // Show error message
          isLoading: false,           // Stop loading
          clearCurrentUser: true,     // Clear user data anyway
          clearLastOperation: true,   // Clear last operation
          clearAuthStartTime: true,   // Clear auth timing
        ),
      );
      rethrow;
    }
  }

  void clearUser() {
    emit(
      state.copyWith(
        lastResult: 'User data cleared', // Set clear message
        clearCurrentUser: true,     // Clear user data
        clearLastOperation: true,   // Clear last operation
        clearAuthStartTime: true,   // Clear auth timing
      ),
    );
  }

  @override
  AuthenticationState? fromJson(Map<String, dynamic> json) {
    try {
      return AuthenticationState.fromJson(json);
    } catch (e) {
      return const AuthenticationState();
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthenticationState state) {
    return state.toJson();
  }
}
