import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../data/mock/mock_templates.dart';
import '../../data/models/edit_session.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final result = switch (routeArgs) {
      ResultArgs() => routeArgs,
      _ => ResultArgs(template: mockTemplates.first, previewStyle: '자연스럽게'),
    };

    return AppScaffold(
      appBar: MinimalTopBar(
        title: '완성됐어요',
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
                label: 'final',
                baseColor: Color(0xFFEFE3CA),
                accentColor: Color(0xFF2B2B2B),
              ),
            ),
          ),
          const SizedBox(height: 18),
          PremiumCard(
            radius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('적용 템플릿', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  result.template.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: 22),
                Text('선택한 시안', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  result.previewStyle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: '저장하기',
                  icon: Icons.download,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryButton(
                  label: '공유하기',
                  icon: Icons.ios_share,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            key: const Key('resultTryAnotherTemplateCta'),
            label: '다른 템플릿 적용',
            icon: Icons.auto_awesome_outlined,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.templates),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '원본과 비교',
            icon: Icons.compare,
            onPressed: () {},
          ),
          const SizedBox(height: 20),
          Text('결과가 마음에 드나요?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            children: [
              MetaChip(label: '좋아요'),
              MetaChip(label: '보통'),
              MetaChip(label: '별로'),
            ],
          ),
        ],
      ),
    );
  }
}
