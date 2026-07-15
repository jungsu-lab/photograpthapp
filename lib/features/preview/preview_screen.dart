import 'package:flutter/material.dart';

import '../../core/widgets/premium_widgets.dart';
import '../../data/models/edit_session.dart';
import '../../data/repositories/template_repository.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  String selected = '자연스럽게';
  static const repository = TemplateRepository();

  static const options = [
    (label: '자연스럽게', description: '얼굴 밝기만 살짝 정리해요.'),
    (label: '밝게', description: '어두운 부분을 올려 산뜻하게 보여줘요.'),
    (label: '차분하게', description: '색과 대비를 눌러 분위기를 남겨요.'),
  ];

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final template = switch (routeArgs) {
      PreviewArgs(:final template) => template,
      _ => repository.all().first,
    };

    return AppScaffold(
      appBar: MinimalTopBar(
        title: '저장 전에 비교해보세요',
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
          Text('어떤 느낌이 좋나요?', style: Theme.of(context).textTheme.titleLarge),
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
            label: '이 느낌으로 보기',
            icon: Icons.check,
            // Kept only so the legacy, unreachable prototype remains
            // compilable while the real editor owns the active flow.
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
    );
  }
}
