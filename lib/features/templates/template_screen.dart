import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../data/models/edit_session.dart';
import '../../data/models/template.dart';
import '../../data/repositories/template_repository.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  static const repository = TemplateRepository();
  static const categories = ['전체', '프로필', '셀카', '음식', '여행', '상품', '감성'];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = categories[selectedIndex];
    final templates = repository.byCategory(selectedCategory);
    final recommended = templates.first;

    return AppScaffold(
      appBar: MinimalTopBar(
        title: '템플릿',
        subtitle: '사진에 맞는 편집 방향을 골라보세요.',
        leading: IconButton(
          tooltip: '뒤로',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
        ),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: _CuratedHeader(category: selectedCategory),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: DecoratedBox(
              key: const Key('templateCategoryTabs'),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.line),
                  bottom: BorderSide(color: AppColors.line),
                ),
              ),
              child: ThinTabRow(
                labels: categories,
                selectedIndex: selectedIndex,
                onTap: (index) => setState(() => selectedIndex = index),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              key: const Key('templatePresetList'),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              itemCount: templates.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EditorialSectionHeader(title: '이 사진에 추천'),
                      const SizedBox(height: 10),
                      PresetCard(
                        key: Key('recommendedTemplateCard-${recommended.id}'),
                        template: recommended,
                        recommended: true,
                        onTap: () => _openPreview(recommended),
                      ),
                    ],
                  );
                }
                final template = templates[index - 1];
                return PresetCard(
                  key: Key('templateCard-${template.id}'),
                  template: template,
                  onTap: () => _openPreview(template),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openPreview(EditTemplate template) {
    Navigator.pushNamed(
      context,
      AppRoutes.preview,
      arguments: PreviewArgs(template: template),
    );
  }
}

class _CuratedHeader extends StatelessWidget {
  const _CuratedHeader({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('templateCuratedHeader'),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.line),
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text('PRESET STORE', style: Theme.of(context).textTheme.labelSmall),
          const Spacer(),
          Text(category, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
