import 'package:flutter/material.dart';

/// Returns a widget that tries to load an image from asset path.
/// Shows a placeholder or error widget on error.
Widget loadImageWithFallback(String assetPath,
    {double radius = 40,
      Widget? errorWidget,
      BoxFit fit = BoxFit.cover}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.grey[200],
    backgroundImage: AssetImage(assetPath),
    onBackgroundImageError: (_, __) {},
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        assetPath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Icon(Icons.person, size: radius, color: Colors.grey);
        },
      ),
    ),
  );
}
