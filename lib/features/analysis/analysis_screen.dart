import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/premium_widgets.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: MinimalTopBar(
        title: '사진 분석 완료',
        subtitle: '촬영 상태를 확인하고 어울리는 템플릿을 추천했어요.',
        leading: IconButton(
          tooltip: '뒤로',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
        ),
      ),
      child: ListView(
        children: [
          const AspectRatio(
            aspectRatio: 4 / 5,
            child: PhotoTile(
              data: PhotoTileData(
                label: 'captured',
                baseColor: Color(0xFFB8AAA0),
                accentColor: Color(0xFF2B2B2B),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _MetricRow(label: '초점', score: 86),
          const _MetricRow(label: '구도', score: 78),
          const _MetricRow(label: '조명', score: 82),
          const _MetricRow(label: '배경', score: 63),
          const _MetricRow(label: '안정감', score: 91),
          const SizedBox(height: 18),
          PremiumCard(
            radius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('추천 이유', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '배경이 살짝 복잡해서 배경 흐림 인물 템플릿을 추천해요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            key: const Key('analysisTemplatesCta'),
            label: '추천 템플릿 보기',
            icon: Icons.auto_awesome_outlined,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.templates),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 2,
              color: AppColors.textPrimary,
              backgroundColor: AppColors.line,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text(
              '$score',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
