import 'package:flutter/material.dart';

/// A widget that can obscure text when privacy mode is enabled
class ObscuredText extends StatelessWidget {
  const ObscuredText({
    super.key,
    required this.text,
    required this.isObscured,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final bool isObscured;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  String _obscureText(String input) {
    if (input.isEmpty) return input;

    // For email addresses, show first 2 chars and domain
    if (input.contains('@')) {
      final parts = input.split('@');
      if (parts[0].length > 2) {
        return '${parts[0].substring(0, 2)}${'•' * 4}@${parts[1]}';
      }
      return '${'•' * 4}@${parts[1]}';
    }

    // For short text (less than 6 characters), obscure all
    if (input.length <= 6) {
      return '•' * input.length;
    }

    // For longer text, show first 2 and last 2 characters
    final firstTwo = input.substring(0, 2);
    final lastTwo = input.substring(input.length - 2);
    final middleLength = input.length - 4;

    return '$firstTwo${'•' * middleLength}$lastTwo';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      isObscured ? _obscureText(text) : text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}