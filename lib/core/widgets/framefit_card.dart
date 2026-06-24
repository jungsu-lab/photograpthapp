import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'premium_widgets.dart';

class FrameFitCard extends StatelessWidget {
  const FrameFitCard({
    super.key,
    required this.child,
    this.padding = 16,
    this.borderColor = AppColors.line,
  });

  final Widget child;
  final double padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.all(padding),
      borderColor: borderColor,
      child: child,
    );
  }
}
