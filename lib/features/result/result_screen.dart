import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../data/models/edit_session.dart';
import '../../data/repositories/template_repository.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const repository = TemplateRepository();

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final result = switch (routeArgs) {
      ResultArgs() => routeArgs,
      _ => ResultArgs(template: repository.all().first, previewStyle: '자연스럽게'),
    };

    return AppScaffold(
      appBar: MinimalTopBar(
        title: '이렇게 나왔어요',
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
                Text('사용한 스타일', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  result.template.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: 22),
                Text('고른 느낌', style: Theme.of(context).textTheme.bodySmall),
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
                  onPressed: () =>
                      _showComingSoon(context, '저장은 실제 이미지가 연결되면 바로 열릴 거예요.'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryButton(
                  label: '공유하기',
                  icon: Icons.ios_share,
                  onPressed: () =>
                      _showComingSoon(context, '공유는 저장 기능 다음에 붙일 예정이에요.'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            key: const Key('resultTryAnotherTemplateCta'),
            label: '다른 스타일 보기',
            icon: Icons.auto_awesome_outlined,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.templates),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: '원본과 비교',
            icon: Icons.compare,
            onPressed: () =>
                _showComingSoon(context, '원본 비교는 실제 촬영 이미지에서 켤 수 있어요.'),
          ),
          const SizedBox(height: 20),
          Text('이 방향 괜찮나요?', style: Theme.of(context).textTheme.titleMedium),
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

void _showComingSoon(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
