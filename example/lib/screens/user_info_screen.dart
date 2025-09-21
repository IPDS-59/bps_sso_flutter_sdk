import 'package:auto_route/auto_route.dart';
import 'package:bps_sso_sdk/bps_sso_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../cubits/configuration_cubit.dart';
import '../widgets/authenticated_image.dart';
import '../widgets/obscured_text.dart';

@RoutePage()
class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key, required this.user});

  final BPSUser user;

  void _copyUserJson(BuildContext context) {
    final json = user.toJson();
    final jsonString = json.entries
        .map((e) => '  "${e.key}": "${e.value}"')
        .join(',\n');

    Clipboard.setData(ClipboardData(text: '{\n$jsonString\n}'));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            PhosphorIcon(
              PhosphorIcons.copy(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const Gap(8),
            const Text('User data copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final privacyMode = context.watch<ConfigurationCubit>().state.privacyMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.05),
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
                            'User Information',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Detailed account information',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copyUserJson(context),
                      icon: PhosphorIcon(
                        PhosphorIcons.copy(PhosphorIconsStyle.duotone),
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
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
                    // User Avatar
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.surface,
                          ),
                          child: AuthenticatedImage(
                            imageUrl: user.photo,
                            accessToken: user.accessToken,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                    const Gap(16),

                    // User Name and Email
                    Center(
                      child: Column(
                        children: [
                          Text(
                            user.fullName,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Gap(4),
                          ObscuredText(
                            text: user.email,
                            isObscured: privacyMode,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const Gap(24),

                    // Profile Information
                    _buildSection(
                      context: context,
                      icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
                      title: 'Profile Information',
                      delay: 400.ms,
                      children: [
                        _buildInfoTile(
                          context: context,
                          icon: PhosphorIcons.identificationCard(
                            PhosphorIconsStyle.duotone,
                          ),
                          label: 'Full Name',
                          value: user.fullName,
                          shouldObscure: false, // Don't obscure name
                          isPrivacyMode: privacyMode,
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: PhosphorIcons.at(PhosphorIconsStyle.duotone),
                          label: 'Email',
                          value: user.email,
                          isPrivacyMode: privacyMode,
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: PhosphorIcons.fingerprint(
                            PhosphorIconsStyle.duotone,
                          ),
                          label: 'User ID',
                          value: user.id,
                          isPrivacyMode: privacyMode,
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
                          label: 'Username',
                          value: user.username,
                          isPrivacyMode: privacyMode,
                        ),
                      ],
                    ),

                    // Work Information (only for internal users)
                    if (user.isInternal) ...[
                      const Gap(24),
                      _buildSection(
                        context: context,
                        icon: PhosphorIcons.briefcase(PhosphorIconsStyle.duotone),
                        title: 'Work Information',
                        delay: 600.ms,
                        children: [
                          _buildInfoTile(
                            context: context,
                            icon: PhosphorIcons.identificationBadge(
                              PhosphorIconsStyle.duotone,
                            ),
                            label: 'NIP',
                            value: user.nip,
                            isPrivacyMode: privacyMode,
                          ),
                          _buildInfoTile(
                            context: context,
                            icon: PhosphorIcons.building(
                              PhosphorIconsStyle.duotone,
                            ),
                            label: 'Organization',
                            value: user.organization,
                            isPrivacyMode: privacyMode,
                          ),
                          if (user.position != null)
                            _buildInfoTile(
                              context: context,
                              icon: PhosphorIcons.crown(
                                PhosphorIconsStyle.duotone,
                              ),
                              label: 'Position',
                              value: user.position!,
                              isPrivacyMode: privacyMode,
                            ),
                          if (user.rank != null)
                            _buildInfoTile(
                              context: context,
                              icon: PhosphorIcons.medal(
                                PhosphorIconsStyle.duotone,
                              ),
                              label: 'Rank',
                              value: user.rank!,
                              isPrivacyMode: privacyMode,
                            ),
                        ],
                      ),
                    ],

                    const Gap(24),

                    // Authentication Information
                    _buildSection(
                      context: context,
                      icon: PhosphorIcons.shield(PhosphorIconsStyle.duotone),
                      title: 'Authentication Information',
                      delay: 800.ms,
                      children: [
                        _buildInfoTile(
                          context: context,
                          icon: PhosphorIcons.globeHemisphereWest(
                            PhosphorIconsStyle.duotone,
                          ),
                          label: 'Realm',
                          value: user.realmDisplayName,
                          shouldObscure: false,
                          isPrivacyMode: privacyMode,
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: PhosphorIcons.clock(PhosphorIconsStyle.duotone),
                          label: 'Token Expires',
                          value: _formatDateTime(user.tokenExpiry),
                          shouldObscure: false,
                          isPrivacyMode: privacyMode,
                        ),
                        _buildInfoTile(
                          context: context,
                          icon: user.isTokenExpired
                              ? PhosphorIcons.warning(PhosphorIconsStyle.duotone)
                              : PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone),
                          label: 'Token Status',
                          value: user.isTokenExpired ? 'Expired' : 'Valid',
                          valueColor: user.isTokenExpired ? Colors.red : Colors.green,
                          shouldObscure: false,
                          isPrivacyMode: privacyMode,
                        ),
                      ],
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

  Widget _buildSection({
    required BuildContext context,
    required PhosphorIconData icon,
    required String title,
    required Duration delay,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PhosphorIcon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Gap(12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Gap(20),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay, duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required PhosphorIconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool shouldObscure = true,
    bool isPrivacyMode = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhosphorIcon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const Gap(12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: ObscuredText(
            text: value,
            isObscured: isPrivacyMode && shouldObscure,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    return '${localDateTime.day}/${localDateTime.month}/${localDateTime.year} '
        '${localDateTime.hour.toString().padLeft(2, '0')}:'
        '${localDateTime.minute.toString().padLeft(2, '0')}';
  }
}