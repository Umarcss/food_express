import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = path.startsWith('http')
        ? Image.network(
            path,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) =>
                _Fallback(width: width, height: height),
          )
        : Image.asset(
            path,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) =>
                _Fallback(width: width, height: height),
          );

    if (borderRadius == null) return image;
    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }
}

class _Fallback extends StatelessWidget {
  final double? width;
  final double? height;

  const _Fallback({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
