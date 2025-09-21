import 'package:auto_route/auto_route.dart';
import 'package:bps_sso_sdk/bps_sso_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../cubits/authentication_cubit.dart';
import '../cubits/configuration_cubit.dart';
import '../routes/app_router.dart';
import '../widgets/status_row.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 
                                  0.2,
                                ),
                                width: 2,
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/BPS_LOGO_VECTOR.svg',
                              height: 64,
                              width: 64,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.8, 0.8))
                          .then()
                          .shimmer(duration: 2000.ms),
                      const Gap(24),
                      Text(
                            'BPS SSO SDK',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                      const Gap(8),
                      Text(
                            'Example Application',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                      const Gap(16),
                      Text(
                            'Showcase application for BPS (Badan Pusat Statistik)\nSSO authentication integration',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha:
                                0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SDK v${BPSSsoSdkInfo.version}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                    ],
                  ),

                const Gap(32),

                // Status Card
                Center(
                    child: BlocBuilder<ConfigurationCubit, ConfigurationState>(
                      builder: (context, configState) {
                        return BlocBuilder<
                          AuthenticationCubit,
                          AuthenticationState
                        >(
                          builder: (context, authState) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(alpha: 
                                    0.1,
                                  ),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Application Status',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const Gap(16),

                                    // SDK Configuration Status
                                    StatusRow(
                                      icon: configState.isValidConfig
                                          ? PhosphorIcons.checkCircle(
                                              PhosphorIconsStyle.duotone,
                                            )
                                          : PhosphorIcons.warning(
                                              PhosphorIconsStyle.duotone,
                                            ),
                                      title: 'SDK Configuration',
                                      subtitle: configState.isValidConfig
                                          ? 'Configuration Valid'
                                          : 'Configuration Required',
                                      isSuccess: configState.isValidConfig,
                                    ),

                                    const Gap(12),

                                    // SDK Initialization Status
                                    StatusRow(
                                      icon:
                                          configState.initializationError !=
                                              null
                                          ? PhosphorIcons.xCircle(
                                              PhosphorIconsStyle.duotone,
                                            )
                                          : configState.isInitialized
                                          ? PhosphorIcons.shieldCheck(
                                              PhosphorIconsStyle.duotone,
                                            )
                                          : configState.isValidConfig
                                          ? PhosphorIcons.play(
                                              PhosphorIconsStyle.duotone,
                                            )
                                          : PhosphorIcons.prohibit(
                                              PhosphorIconsStyle.duotone,
                                            ),
                                      title: 'SDK Initialization',
                                      subtitle:
                                          configState.initializationError !=
                                              null
                                          ? 'Initialization Failed'
                                          : configState.isInitialized
                                          ? 'SDK Ready for Operations'
                                          : configState.isValidConfig
                                          ? 'Ready to Initialize'
                                          : 'Configure First',
                                      isSuccess:
                                          configState.isInitialized &&
                                          configState.initializationError ==
                                              null,
                                    ),

                                    // Show error details if initialization failed
                                    if (configState.initializationError !=
                                        null) ...[
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.red.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            PhosphorIcon(
                                              PhosphorIcons.warning(
                                                PhosphorIconsStyle.fill,
                                              ),
                                              size: 16,
                                              color: Colors.red.shade600,
                                            ),
                                            const Gap(8),
                                            Expanded(
                                              child: Text(
                                                'Error: ${configState.initializationError}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.red.shade700,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    const Gap(12),

                                    // Authentication Status
                                    StatusRow(
                                      icon: authState.currentUser != null
                                          ? PhosphorIcons.userCheck(
                                              PhosphorIconsStyle.duotone,
                                            )
                                          : PhosphorIcons.user(
                                              PhosphorIconsStyle.duotone,
                                            ),
                                      title: 'Authentication',
                                      subtitle: authState.currentUser != null
                                          ? 'Logged in as ${authState.currentUser!.username}'
                                          : 'Not authenticated',
                                      isSuccess: authState.currentUser != null,
                                    ),

                                    // Show loading indicator if any operation is in progress
                                    if (configState.isLoading ||
                                        authState.isLoading) ...[
                                      const Gap(12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    theme.colorScheme.primary,
                                                  ),
                                            ),
                                          ),
                                          const Gap(8),
                                          Text(
                                            configState.isLoading
                                                ? 'Configuring SDK...'
                                                : 'Processing...',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                  ),

                const Gap(32),

                // Action Buttons
                BlocBuilder<ConfigurationCubit, ConfigurationState>(
                  builder: (context, configState) {
                    return BlocBuilder<
                      AuthenticationCubit,
                      AuthenticationState
                    >(
                      builder: (context, authState) {
                        return Column(
                          children: [
                              _buildActionButton(
                                context: context,
                                onPressed: () {
                                  context.router.push(
                                    const ConfigurationRoute(),
                                  );
                                },
                                icon: PhosphorIcons.gear(
                                  PhosphorIconsStyle.duotone,
                                ),
                                label: configState.initializationError != null
                                    ? 'Fix Configuration'
                                    : configState.isValidConfig &&
                                          !configState.isInitialized
                                    ? 'Initialize SDK'
                                    : 'Configure SDK',
                                subtitle:
                                    configState.initializationError != null
                                    ? 'Resolve initialization error'
                                    : configState.isValidConfig &&
                                          !configState.isInitialized
                                    ? 'Initialize with current settings'
                                    : 'Set up authentication parameters',
                                isPrimary:
                                    !configState.isInitialized ||
                                    configState.initializationError != null,
                                delay: 1000.ms,
                              ),
                              const Gap(16),
                              _buildActionButton(
                                context: context,
                                onPressed:
                                    configState.isInitialized &&
                                        configState.initializationError == null
                                    ? () {
                                        context.router.push(
                                          const OperationsRoute(),
                                        );
                                      }
                                    : null,
                                icon: PhosphorIcons.signIn(
                                  PhosphorIconsStyle.duotone,
                                ),
                                label: 'SSO Operations',
                                subtitle:
                                    configState.initializationError != null
                                    ? 'Fix initialization error first'
                                    : !configState.isInitialized
                                    ? 'Initialize SDK first'
                                    : authState.currentUser != null
                                    ? 'Manage your session'
                                    : 'Login, logout, and user management',
                                isPrimary:
                                    configState.isInitialized &&
                                    configState.initializationError == null &&
                                    authState.currentUser == null,
                                delay: 1200.ms,
                              ),
                              const Gap(16),
                              _buildActionButton(
                                context: context,
                                onPressed: () {
                                  final configCubit = context.read<ConfigurationCubit>();
                                  configCubit.alice.showInspector();
                                },
                                icon: PhosphorIcons.monitor(
                                  PhosphorIconsStyle.duotone,
                                ),
                                label: 'HTTP Inspector',
                                subtitle: 'View network requests and responses',
                                isPrimary: false,
                                delay: 1400.ms,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                const Gap(24), // Bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required PhosphorIconData icon,
    required String label,
    required String subtitle,
    required bool isPrimary,
    required Duration delay,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style:
                ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  backgroundColor: isPrimary
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  foregroundColor: isPrimary
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  elevation: isPrimary ? 8 : 2,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isPrimary
                        ? BorderSide.none
                        : BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                  ),
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(
                    isPrimary
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.15)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PhosphorIcon(
                    icon,
                    size: 14,
                    color: isPrimary
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isPrimary
                              ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PhosphorIcon(
                  PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                  size: 14,
                  color: isPrimary
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: delay, duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }
}
