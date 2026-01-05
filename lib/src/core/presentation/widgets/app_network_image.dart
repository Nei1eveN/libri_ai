import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    required this.title,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  final String title;

  @override
  Widget build(BuildContext context) {
    // 2. On Mobile: Keep your existing CachedNetworkImage logic
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(context),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.primaryContainer,
      child: Icon(Icons.book, color: theme.primaryColor),
    );
  }
}
