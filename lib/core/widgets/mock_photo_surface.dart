import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MockPhotoSurface extends StatelessWidget {
  const MockPhotoSurface({
    super.key,
    required this.icon,
    this.accentColor = AppColors.textPrimary,
    this.borderColor = AppColors.line,
  });

  final IconData icon;
  final Color accentColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.photoPlaceholder,
              AppColors.surfaceSoft,
            ],
          ),
          borderRadius: BorderRadius.circular(AppMetrics.thumbnailRadius),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 90,
            color: accentColor.withValues(alpha: 0.78),
          ),
        ),
      ),
    );
  }
}
