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

  int selectedIndex = 0;
  bool _appliedRouteArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedRouteArgs) {
      return;
    }

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final initialCategory = switch (routeArgs) {
      TemplateLibraryArgs(:final initialCategory) => initialCategory,
      String() => routeArgs,
      _ => null,
    };

    if (initialCategory != null) {
      final index = repository.categories.indexOf(initialCategory);
      if (index >= 0) {
        selectedIndex = index;
      }
    }
    _appliedRouteArgs = true;
  }

  @override
  Widget build(BuildContext context) {
    final categories = repository.categories;
    final selectedCategory = categories[selectedIndex];
    final templates = repository.byCategory(selectedCategory);
    final recommended = templates.isEmpty ? null : templates.first;

    return AppScaffold(
      appBar: MinimalTopBar(
        title: '스타일 고르기',
        subtitle: '오늘 찍을 사진에 맞는 기준을 골라보세요.',
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
              child: _CategoryRail(
                categories: categories,
                selectedIndex: selectedIndex,
                onTap: (index) => setState(() => selectedIndex = index),
              ),
            ),
          ),
          Expanded(
            child: recommended == null
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: EmptyState(
                      icon: Icons.auto_awesome_outlined,
                      title: '여기는 아직 비어 있어요',
                      description: '다른 카테고리에서 먼저 골라보세요.',
                    ),
                  )
                : ListView.separated(
                    key: const Key('templatePresetList'),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    itemCount: templates.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return MotionIn(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: '먼저 보기 좋은 스타일'),
                              const SizedBox(height: 10),
                              TemplateCard(
                                key: Key(
                                  'recommendedTemplateCard-${recommended.id}',
                                ),
                                template: recommended,
                                recommended: true,
                                onTap: () => _openDetail(recommended),
                              ),
                            ],
                          ),
                        );
                      }
                      final template = templates[index - 1];
                      return MotionIn(
                        delay: Duration(milliseconds: 32 * index),
                        child: TemplateCard(
                          key: Key('templateCard-${template.id}'),
                          template: template,
                          onTap: () => _openDetail(template),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openDetail(EditTemplate template) {
    Navigator.pushNamed(
      context,
      AppRoutes.templateDetail,
      arguments: TemplateDetailArgs(template: template),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.categories,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 7),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          return CategoryChip(
            label: categories[index],
            selected: index == selectedIndex,
            onTap: () => onTap(index),
          );
        },
      ),
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
          Text('보고 있는 기준', style: Theme.of(context).textTheme.labelSmall),
          const Spacer(),
          Text(category, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
