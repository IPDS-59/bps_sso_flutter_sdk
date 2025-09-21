import 'package:bps_sso_sdk/bps_sso_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../cubits/configuration_cubit.dart';
import 'authenticated_image.dart';
import 'obscured_text.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    this.user,
    this.isLoading = false,
    this.lastOperation,
    this.lastResult,
  });

  final BPSUser? user;
  final bool isLoading;
  final String? lastOperation;
  final String? lastResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final privacyMode = context.watch<ConfigurationCubit>().state.privacyMode;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Show user avatar if available, otherwise show status icon
              if (user != null && user!.photo != null)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.shade600,
                      width: 2,
                    ),
                  ),
                  child: AuthenticatedImage(
                    imageUrl: user!.photo,
                    accessToken: user!.accessToken,
                    width: 48,
                    height: 48,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: user != null
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PhosphorIcon(
                    user != null
                        ? PhosphorIcons.userCheck(PhosphorIconsStyle.duotone)
                        : PhosphorIcons.userMinus(PhosphorIconsStyle.duotone),
                    size: 24,
                    color: user != null
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                  ),
                ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authentication Status',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      user != null
                          ? 'Logged in as ${user!.displayName}'
                          : 'Not logged in',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (user != null) ...[
            const Gap(20),
            const Divider(),
            const Gap(16),

            // Primary user information
            _buildInfoRow(
              icon: PhosphorIcons.user(PhosphorIconsStyle.duotone),
              label: 'Full Name',
              value: user!.fullName,
              theme: theme,
              isPrivacyMode: privacyMode,
              shouldObscure: false, // Don't obscure name
            ),
            const Gap(12),
            _buildInfoRow(
              icon: PhosphorIcons.at(PhosphorIconsStyle.duotone),
              label: 'Username',
              value: user!.username,
              theme: theme,
              isPrivacyMode: privacyMode,
            ),
            const Gap(12),
            if (user!.email.isNotEmpty) ...[
              _buildInfoRow(
                icon: PhosphorIcons.envelope(PhosphorIconsStyle.duotone),
                label: 'Email',
                value: user!.email,
                theme: theme,
                isPrivacyMode: privacyMode,
              ),
              const Gap(12),
            ],
            // Only show NIP for internal users
            if (user!.isInternal) ...[
              _buildInfoRow(
                icon: PhosphorIcons.identificationCard(
                  PhosphorIconsStyle.duotone,
                ),
                label: 'NIP',
                value: user!.nip,
                theme: theme,
                isPrivacyMode: privacyMode,
              ),
              const Gap(12),
            ],

            // Organization and position information (only for internal users)
            if (user!.isInternal) ...[
              _buildInfoRow(
                icon: PhosphorIcons.building(PhosphorIconsStyle.duotone),
                label: 'Organization',
                value: user!.organization,
                theme: theme,
              ),
              const Gap(12),
            ],
            if (user!.position != null && user!.position!.isNotEmpty) ...[
              _buildInfoRow(
                icon: PhosphorIcons.briefcase(PhosphorIconsStyle.duotone),
                label: 'Position',
                value: user!.position!,
                theme: theme,
              ),
              const Gap(12),
            ],
            if (user!.rank != null && user!.rank!.isNotEmpty) ...[
              _buildInfoRow(
                icon: PhosphorIcons.star(PhosphorIconsStyle.duotone),
                label: 'Rank',
                value: user!.rank!,
                theme: theme,
              ),
              const Gap(12),
            ],

            // Location information
            if (user!.region != null && user!.region!.isNotEmpty) ...[
              _buildInfoRow(
                icon: PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
                label: 'Region',
                value: user!.region!,
                theme: theme,
              ),
              const Gap(12),
            ],
            if (user!.province != null && user!.province!.isNotEmpty) ...[
              _buildInfoRow(
                icon: PhosphorIcons.globe(PhosphorIconsStyle.duotone),
                label: 'Province',
                value: user!.province!,
                theme: theme,
              ),
              const Gap(12),
            ],
            if (user!.address != null && user!.address!.isNotEmpty) ...[
              _buildInfoRow(
                icon: PhosphorIcons.house(PhosphorIconsStyle.duotone),
                label: 'Office Address',
                value: user!.address!,
                theme: theme,
              ),
              const Gap(12),
            ],

            // Realm and authentication information
            _buildInfoRow(
              icon: PhosphorIcons.globeHemisphereWest(
                PhosphorIconsStyle.duotone,
              ),
              label: 'Realm',
              value: user!.realmDisplayName,
              theme: theme,
              isPrivacyMode: privacyMode,
            ),
            const Gap(12),
            _buildInfoRow(
              icon: PhosphorIcons.fingerprint(PhosphorIconsStyle.duotone),
              label: 'User ID',
              value: user!.id,
              theme: theme,
              isPrivacyMode: privacyMode,
            ),
            const Gap(12),
            if (user!.oldNip != null && user!.oldNip!.isNotEmpty) ...[
              _buildInfoRow(
                icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.duotone),
                label: 'Old NIP',
                value: user!.oldNip!,
                theme: theme,
              ),
              const Gap(12),
            ],

            // Token information
            _buildInfoRow(
              icon: PhosphorIcons.clock(PhosphorIconsStyle.duotone),
              label: 'Token expires',
              value: _formatDateTime(user!.tokenExpiry),
              theme: theme,
              isPrivacyMode: privacyMode,
            ),
            const Gap(12),
            _buildInfoRow(
              icon: user!.isTokenExpired
                  ? PhosphorIcons.warning(PhosphorIconsStyle.duotone)
                  : PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone),
              label: 'Token status',
              value: user!.isTokenExpired ? 'Expired' : 'Valid',
              theme: theme,
              valueColor: user!.isTokenExpired ? Colors.red : Colors.green,
              isPrivacyMode: privacyMode,
            ),

            // Additional user properties
            const Gap(12),
            _buildInfoRow(
              icon: PhosphorIcons.textAa(PhosphorIconsStyle.duotone),
              label: 'Initials',
              value: user!.initials,
              theme: theme,
              isPrivacyMode: privacyMode,
            ),
            if (user!.firstName != null && user!.firstName!.isNotEmpty) ...[
              const Gap(12),
              _buildInfoRow(
                icon: PhosphorIcons.userCircle(PhosphorIconsStyle.duotone),
                label: 'First Name',
                value: user!.firstName!,
                theme: theme,
              ),
            ],
            if (user!.lastName != null && user!.lastName!.isNotEmpty) ...[
              const Gap(12),
              _buildInfoRow(
                icon: PhosphorIcons.userCircle(PhosphorIconsStyle.duotone),
                label: 'Last Name',
                value: user!.lastName!,
                theme: theme,
              ),
            ],
            if (user!.hasPhoto) ...[
              const Gap(12),
              _buildInfoRow(
                icon: PhosphorIcons.image(PhosphorIconsStyle.duotone),
                label: 'Has Photo',
                value: 'Yes',
                theme: theme,
                valueColor: Colors.green.shade600,
                isPrivacyMode: privacyMode,
              ),
            ],
          ],
          if (lastOperation != null && lastResult != null) ...[
            const Gap(20),
            const Divider(),
            const Gap(16),
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.pulse(PhosphorIconsStyle.duotone),
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const Gap(8),
                Text(
                  'Last Operation: $lastOperation',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(
              lastResult!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color:
                    lastResult!.contains('failed') ||
                        lastResult!.contains('invalid')
                    ? Colors.red.shade600
                    : Colors.green.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required PhosphorIconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    Color? valueColor,
    bool isPrivacyMode = false,
    bool shouldObscure = true,
  }) {
    return Row(
      children: [
        PhosphorIcon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const Gap(8),
        Text(
          '$label:',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const Gap(8),
        Expanded(
          child: ObscuredText(
            text: value,
            isObscured: isPrivacyMode && shouldObscure,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();

    if (localDateTime.isBefore(now)) {
      return 'Expired ${_timeAgo(now.difference(localDateTime))}';
    } else {
      return 'In ${_timeAgo(localDateTime.difference(now))}';
    }
  }

  String _timeAgo(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
