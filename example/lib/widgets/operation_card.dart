import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class OperationCard extends StatelessWidget {
  const OperationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    required this.delay,
  });

  final PhosphorIconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    if (isDestructive) {
      backgroundColor = Colors.red.shade50;
      foregroundColor = Colors.red.shade700;
      borderColor = Colors.red.shade200;
    } else if (isPrimary) {
      backgroundColor = theme.colorScheme.primary;
      foregroundColor = theme.colorScheme.onPrimary;
      borderColor = theme.colorScheme.primary;
    } else {
      backgroundColor = theme.colorScheme.surface;
      foregroundColor = theme.colorScheme.onSurface;
      borderColor = theme.colorScheme.outline.withOpacity(0.2);
    }

    return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style:
                ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                  elevation: isPrimary ? 8 : 2,
                  shadowColor: isPrimary
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : theme.colorScheme.shadow.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isPrimary
                        ? BorderSide.none
                        : BorderSide(color: borderColor),
                  ),
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(
                    isPrimary
                        ? theme.colorScheme.onPrimary.withOpacity(0.1)
                        : isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : theme.colorScheme.primary.withOpacity(0.1),
                  ),
                ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? theme.colorScheme.onPrimary.withOpacity(0.15)
                        : isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PhosphorIcon(
                    icon,
                    size: 24,
                    color: isPrimary
                        ? theme.colorScheme.onPrimary
                        : isDestructive
                        ? Colors.red.shade600
                        : theme.colorScheme.primary,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: foregroundColor,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isPrimary
                              ? theme.colorScheme.onPrimary.withOpacity(0.8)
                              : isDestructive
                              ? Colors.red.shade600.withOpacity(0.8)
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                PhosphorIcon(
                  PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                  size: 20,
                  color: isPrimary
                      ? theme.colorScheme.onPrimary.withOpacity(0.8)
                      : isDestructive
                      ? Colors.red.shade600.withOpacity(0.8)
                      : theme.colorScheme.onSurface.withOpacity(0.6),
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
