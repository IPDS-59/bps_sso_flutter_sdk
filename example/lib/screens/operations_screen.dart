import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bps_sso_sdk/bps_sso_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../cubits/authentication_cubit.dart';
import '../cubits/configuration_cubit.dart';
import '../routes/app_router.dart';
import '../widgets/operation_card.dart';
import '../widgets/status_card.dart';

@RoutePage()
class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  void _cancelAuthentication(BuildContext context) {
    context.read<AuthenticationCubit>().cancelAuthentication();
    _showWarning(context, 'Authentication cancelled');
  }

  Future<void> _performLogin(BuildContext context) async {
    try {
      await context.read<AuthenticationCubit>().login(context);
      if (!context.mounted) return;
      final state = context.read<AuthenticationCubit>().state;
      if (state.currentUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 20,
                ),
                const Gap(8),
                Expanded(
                  child: Text('Welcome ${state.currentUser!.displayName}!'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Authentication cancelled or timed out';
        _showWarning(context, errorMessage);
      } else {
        errorMessage = 'Login failed: $e';
        _showError(context, errorMessage);
      }
    }
  }

  Future<void> _refreshToken(BuildContext context) async {
    try {
      await context.read<AuthenticationCubit>().refreshToken();
      if (!context.mounted) return;
      _showSuccess(context, 'Token refreshed successfully');
    } catch (e) {
      if (!context.mounted) return;
      if (e.toString().contains('Please login first')) {
        _showWarning(context, 'Please login first');
      } else {
        _showError(context, 'Token refresh failed: $e');
      }
    }
  }

  Future<void> _validateToken(BuildContext context) async {
    try {
      await context.read<AuthenticationCubit>().validateToken();
      if (!context.mounted) return;
      _showSuccess(context, 'Token is valid');
    } catch (e) {
      if (!context.mounted) return;
      if (e.toString().contains('Please login first')) {
        _showWarning(context, 'Please login first');
      } else if (e.toString().contains('Token is invalid')) {
        _showWarning(context, 'Token is invalid');
      } else {
        _showError(context, 'Token validation failed: $e');
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await context.read<AuthenticationCubit>().logout();
      if (!context.mounted) return;
      _showSuccess(context, 'Logout successful');
    } catch (e) {
      if (!context.mounted) return;
      if (e.toString().contains('Please login first')) {
        _showWarning(context, 'Please login first');
      } else {
        _showError(context, 'Logout failed: $e');
      }
    }
  }

  void _showUserInfo(BuildContext context) {
    final currentUser = context.read<AuthenticationCubit>().state.currentUser;
    if (currentUser == null) {
      _showWarning(context, 'Please login first');
      return;
    }

    context.router.push(UserInfoRoute(user: currentUser));
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const Gap(8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.warning(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const Gap(8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.warning(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const Gap(8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.router.pop(),
                      icon: PhosphorIcon(
                        PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SSO Operations',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Manage authentication and user sessions',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Privacy Mode Toggle
                    BlocBuilder<ConfigurationCubit, ConfigurationState>(
                      builder: (context, configState) {
                        return IconButton(
                          onPressed: () => context
                              .read<ConfigurationCubit>()
                              .togglePrivacyMode(),
                          icon: PhosphorIcon(
                            configState.privacyMode
                                ? PhosphorIcons.eyeSlash(
                                    PhosphorIconsStyle.duotone,
                                  )
                                : PhosphorIcons.eye(PhosphorIconsStyle.duotone),
                            size: 24,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: configState.privacyMode
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surface,
                            foregroundColor: configState.privacyMode
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                    const Gap(8),
                    IconButton(
                      onPressed: () =>
                          context.router.push(const ConfigurationRoute()),
                      icon: PhosphorIcon(
                        PhosphorIcons.gear(PhosphorIconsStyle.duotone),
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Status Card
                    BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      builder: (context, state) {
                        return StatusCard(
                              user: state.currentUser,
                              isLoading: state.isLoading,
                              lastOperation: state.lastOperation,
                              lastResult: state.lastResult,
                            )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0);
                      },
                    ),

                    const Gap(24),

                    // Realm Selection
                    BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      builder: (context, state) {
                        return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(alpha: 
                                    0.1,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIcons.globeHemisphereWest(
                                          PhosphorIconsStyle.duotone,
                                        ),
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const Gap(8),
                                      Text(
                                        'Realm Selection',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(16),
                                  SegmentedButton<BPSRealmType>(
                                    segments: [
                                      ButtonSegment(
                                        value: BPSRealmType.internal,
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            PhosphorIcon(
                                              PhosphorIcons.building(
                                                PhosphorIconsStyle.duotone,
                                              ),
                                              size: 16,
                                            ),
                                            const Gap(8),
                                            Expanded(
                                              child: const Text(
                                                'Internal BPS',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ButtonSegment(
                                        value: BPSRealmType.external,
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            PhosphorIcon(
                                              PhosphorIcons.users(
                                                PhosphorIconsStyle.duotone,
                                              ),
                                              size: 16,
                                            ),
                                            const Gap(8),
                                            Expanded(
                                              child: const Text(
                                                'External',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    selected: {state.selectedRealm},
                                    onSelectionChanged: state.currentUser != null
                                        ? null
                                        : (Set<BPSRealmType> selection) {
                                            context
                                                .read<AuthenticationCubit>()
                                                .setSelectedRealm(
                                                  selection.first,
                                                );
                                          },
                                    style: SegmentedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.surface,
                                      foregroundColor:
                                          theme.colorScheme.onSurface,
                                      selectedBackgroundColor:
                                          theme.colorScheme.primary,
                                      selectedForegroundColor:
                                          theme.colorScheme.onPrimary,
                                      side: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0);
                      },
                    ),

                    const Gap(24),

                    // Operations
                    Text(
                          'Operations',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),

                    const Gap(16),

                    BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            OperationCard(
                              icon: PhosphorIcons.signIn(
                                PhosphorIconsStyle.duotone,
                              ),
                              title: 'Login',
                              subtitle:
                                  'Authenticate with BPS SSO using selected realm',
                              onPressed: state.isLoading || state.currentUser != null
                                  ? null
                                  : () => _performLogin(context),
                              isPrimary: true,
                              delay: 700.ms,
                            ),

                            // Show cancel button when authentication is in progress
                            if (state.isLoading &&
                                state.lastOperation == 'Login') ...[
                              const Gap(12),
                              Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _cancelAuthentication(context),
                                      icon: PhosphorIcon(
                                        PhosphorIcons.x(
                                          PhosphorIconsStyle.bold,
                                        ),
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Cancel Authentication',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.errorContainer,
                                        foregroundColor:
                                            theme.colorScheme.onErrorContainer,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 400.ms)
                                  .slideY(begin: 0.3, end: 0),
                            ],
                          ],
                        );
                      },
                    ),

                    const Gap(12),

                    BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            OperationCard(
                              icon: PhosphorIcons.arrowClockwise(
                                PhosphorIconsStyle.duotone,
                              ),
                              title: 'Refresh Token',
                              subtitle: 'Refresh the current access token',
                              onPressed:
                                  state.isLoading || state.currentUser == null
                                  ? null
                                  : () => _refreshToken(context),
                              delay: 800.ms,
                            ),

                            const Gap(12),

                            OperationCard(
                              icon: PhosphorIcons.shieldCheck(
                                PhosphorIconsStyle.duotone,
                              ),
                              title: 'Validate Token',
                              subtitle: 'Check if current token is still valid',
                              onPressed:
                                  state.isLoading || state.currentUser == null
                                  ? null
                                  : () => _validateToken(context),
                              delay: 900.ms,
                            ),

                            const Gap(12),

                            OperationCard(
                              icon: PhosphorIcons.user(
                                PhosphorIconsStyle.duotone,
                              ),
                              title: 'Show User Info',
                              subtitle: 'Display detailed user information',
                              onPressed: state.currentUser == null
                                  ? null
                                  : () => _showUserInfo(context),
                              delay: 1000.ms,
                            ),

                            const Gap(12),

                            OperationCard(
                              icon: PhosphorIcons.signOut(
                                PhosphorIconsStyle.duotone,
                              ),
                              title: 'Logout',
                              subtitle: 'Logout and revoke tokens',
                              onPressed:
                                  state.isLoading || state.currentUser == null
                                  ? null
                                  : () => _logout(context),
                              isDestructive: true,
                              delay: 1100.ms,
                            ),

                            const Gap(12),

                            OperationCard(
                              icon: PhosphorIcons.monitor(
                                PhosphorIconsStyle.duotone,
                              ),
                              title: 'HTTP Inspector',
                              subtitle: 'View network requests and responses',
                              onPressed: () {
                                final configCubit = context.read<ConfigurationCubit>();
                                configCubit.alice.showInspector();
                              },
                              delay: 1200.ms,
                            ),
                          ],
                        );
                      },
                    ),

                    const Gap(32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
