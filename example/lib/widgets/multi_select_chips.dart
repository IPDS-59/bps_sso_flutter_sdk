import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MultiSelectChips extends StatelessWidget {
  const MultiSelectChips({
    super.key,
    required this.title,
    required this.icon,
    required this.selectedValues,
    required this.availableValues,
    required this.onChanged,
  });

  final String title;
  final PhosphorIconData icon;
  final List<String> selectedValues;
  final List<String> availableValues;
  final Function(List<String>) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PhosphorIcon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const Gap(8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: availableValues.map((value) {
            final isSelected = selectedValues.contains(value);
            return FilterChip(
              label: Text(value),
              selected: isSelected,
              onSelected: (selected) {
                final newValues = List<String>.from(selectedValues);
                if (selected) {
                  if (!newValues.contains(value)) {
                    newValues.add(value);
                  }
                } else {
                  newValues.remove(value);
                }
                onChanged(newValues);
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
