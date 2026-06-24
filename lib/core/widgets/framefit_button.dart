import 'package:flutter/material.dart';

import 'premium_widgets.dart';

class FrameFitButton extends StatelessWidget {
  const FrameFitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = FrameFitButtonVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final FrameFitButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == FrameFitButtonVariant.secondary) {
      return SecondaryButton(label: label, onPressed: onPressed, icon: icon);
    }
    return PrimaryButton(label: label, onPressed: onPressed, icon: icon);
  }
}

enum FrameFitButtonVariant { primary, ai, secondary }
