import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ScoreRow extends StatelessWidget {
  const ScoreRow({super.key, required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? AppColors.textPrimary
        : score >= 60
        ? AppColors.warningAccent
        : AppColors.lowScoreAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 94,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 7,
                backgroundColor: AppColors.surfacePressed,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 34,
            child: Text(
              '$score',
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
