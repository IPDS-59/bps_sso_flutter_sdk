import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AuthenticatedImage extends StatelessWidget {
  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    required this.accessToken,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.loadingWidget,
  });

  final String? imageUrl;
  final String accessToken;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(theme);
    }

    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      headers: {'Authorization': 'Bearer $accessToken'},
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildPlaceholder(theme);
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: PhosphorIcon(
          PhosphorIcons.user(PhosphorIconsStyle.duotone),
          size: (width ?? 100) * 0.5,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
