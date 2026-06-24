import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../data/mock/mock_templates.dart';
import '../../data/models/edit_session.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  String selected = '자연스럽게';

  static const options = [
    (label: '자연스럽게', description: '얼굴 밝기와 피부톤만 부드럽게 정리해요.'),
    (label: '밝게', description: '어두운 부분을 살리고 SNS용으로 환하게 맞춰요.'),
    (label: '무드있게', description: '색온도와 대비를 조절해 분위기를 더해요.'),
  ];

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final template = switch (routeArgs) {
      PreviewArgs(:final template) => template,
      _ => mockTemplates.first,
    };

    return AppScaffold(
      appBar: MinimalTopBar(
        title: '시안 미리보기',
        subtitle: template.name,
        leading: IconButton(
          tooltip: '뒤로',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
        ),
      ),
      child: ListView(
        children: [
          const Column(
            key: Key('previewComparisonStage'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PhotoTile(
                      data: PhotoTileData(
                        label: 'original',
                        baseColor: Color(0xFFC7B7A6),
                        accentColor: Color(0xFF8EA0A8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: PhotoTile(
                      data: PhotoTileData(
                        label: 'preview',
                        baseColor: Color(0xFFEFE3CA),
                        accentColor: Color(0xFFB8C9D4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          PremiumCard(
            radius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  template.recommendationReason,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('편집 방향', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Column(
            key: const Key('previewDirectionList'),
            children: [
              for (final option in options) ...[
                PreviewOptionCard(
                  key: Key('previewOption-${option.label}'),
                  label: option.label,
                  description: option.description,
                  selected: selected == option.label,
                  onTap: () => setState(() => selected = option.label),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            key: const Key('previewApplyCta'),
            label: '고화질로 적용하기',
            icon: Icons.check,
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.result,
              arguments: ResultArgs(template: template, previewStyle: selected),
            ),
          ),
        ],
      ),
    );
  }
}
