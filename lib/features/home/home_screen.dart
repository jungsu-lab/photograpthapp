import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../data/models/edit_session.dart';
import '../../data/models/template.dart';
import '../../data/repositories/template_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const repository = TemplateRepository();

  @override
  Widget build(BuildContext context) {
    final templates = repository.recommended();
    final categories = repository.categories.where((item) => item != '전체');

    return AppScaffold(
      padding: EdgeInsets.zero,
      bottomNavigation: const _HomeBottomNav(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 92),
        children: [
          const _HomeTopBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              '오늘 찍을 사진, 먼저 맞춰볼까요?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              '사진 종류를 고르면 화면에서 위치와 여백을 잡아볼 수 있어요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _LeadGallery(),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _QuickActions(
              onCamera: () => Navigator.pushNamed(context, AppRoutes.camera),
              onTemplates: () =>
                  Navigator.pushNamed(context, AppRoutes.templates),
            ),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: '카테고리',
              subtitle: '상황에 맞게 빠르게 고르기',
              actionLabel: '전체',
              onAction: () => Navigator.pushNamed(context, AppRoutes.templates),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _CategoryEntryRail(categories: categories.toList()),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: '추천 템플릿',
              subtitle: '처음 찍어도 덜 헤매는 기준',
              actionLabel: '전체',
              onAction: () => Navigator.pushNamed(context, AppRoutes.templates),
            ),
          ),
          const SizedBox(height: 10),
          _TemplateRail(templates: templates),
          const SizedBox(height: 26),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: '최근 사진', subtitle: '작업한 사진을 한곳에 모아요.'),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: PhotoGrid(
              items: [
                PhotoTileData(
                  label: 'portrait',
                  baseColor: Color(0xFFB8AAA0),
                  accentColor: Color(0xFF2B2B2B),
                ),
                PhotoTileData(
                  label: 'sunset',
                  baseColor: Color(0xFFE0A45B),
                  accentColor: Color(0xFF6F6570),
                ),
                PhotoTileData(
                  label: 'food',
                  baseColor: Color(0xFFC9824A),
                  accentColor: Color(0xFF6C3E20),
                ),
                PhotoTileData(
                  label: 'product',
                  baseColor: Color(0xFFE8E5DE),
                  accentColor: Color(0xFFB8B8B2),
                ),
              ],
              columns: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('homeEditorialHeader'),
      decoration: const BoxDecoration(
        color: AppColors.appBackground,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 5,
            backgroundColor: AppColors.profileAccent,
          ),
          const SizedBox(width: 8),
          Text('FrameFit', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          const StatusPill(label: '촬영 전 체크', icon: Icons.grid_3x3),
        ],
      ),
    );
  }
}

class _LeadGallery extends StatelessWidget {
  const _LeadGallery();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('homeLeadGallery'),
      children: [
        const Row(
          children: [
            Expanded(
              flex: 3,
              child: AspectRatio(
                aspectRatio: 1,
                child: PhotoTile(
                  data: PhotoTileData(
                    label: 'composition',
                    baseColor: Color(0xFFB8AAA0),
                    accentColor: Color(0xFF2B2B2B),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.18,
                    child: PhotoTile(
                      data: PhotoTileData(
                        label: 'preset',
                        baseColor: Color(0xFFEFE3CA),
                        accentColor: Color(0xFFB8C9D4),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  AspectRatio(
                    aspectRatio: 1.18,
                    child: PhotoTile(
                      data: PhotoTileData(
                        label: 'gallery',
                        baseColor: Color(0xFFE8E5DE),
                        accentColor: Color(0xFFB8B8B2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.line),
              bottom: BorderSide(color: AppColors.line),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text('구도 82', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '얼굴을 조금만 오른쪽으로 옮기면 여백이 편해져요.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onCamera, required this.onTemplates});

  final VoidCallback onCamera;
  final VoidCallback onTemplates;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('homeQuickActions'),
      children: [
        Expanded(
          child: PrimaryButton(
            key: const Key('homePrimaryCta'),
            label: '찍기 전에 맞추기',
            icon: Icons.photo_camera_outlined,
            onPressed: onCamera,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SecondaryButton(
            key: const Key('homeSecondaryCta'),
            label: '스타일 고르기',
            icon: Icons.tune,
            onPressed: onTemplates,
          ),
        ),
      ],
    );
  }
}

class _TemplateRail extends StatelessWidget {
  const _TemplateRail({required this.templates});

  final List<EditTemplate> templates;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('homeTemplateRail'),
      height: 206,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final template = templates[index];
          return MotionIn(
            delay: Duration(milliseconds: 35 * index),
            offset: const Offset(0.04, 0),
            child: SizedBox(
              width: 176,
              child: PresetCard(
                key: Key('homeTemplateCard-${template.id}'),
                template: template,
                compact: true,
                recommended: index == 0,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.templateDetail,
                  arguments: TemplateDetailArgs(template: template),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryEntryRail extends StatelessWidget {
  const _CategoryEntryRail({required this.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('homeCategoryEntryRail'),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.line),
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.indexed
              .map(
                (entry) => MotionIn(
                  delay: Duration(milliseconds: 24 * entry.$1),
                  child: CategoryChip(
                    label: entry.$2,
                    selected: false,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.templates,
                      arguments: TemplateLibraryArgs(initialCategory: entry.$2),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav();

  @override
  Widget build(BuildContext context) {
    return EditorActionBar(
      selectedIndex: 0,
      onTap: (index) {
        if (index == 1) Navigator.pushNamed(context, AppRoutes.camera);
        if (index == 2) Navigator.pushNamed(context, AppRoutes.templates);
      },
      actions: const [
        EditorActionItem(icon: Icons.home_outlined, label: '홈'),
        EditorActionItem(icon: Icons.camera_alt_outlined, label: '촬영'),
        EditorActionItem(icon: Icons.auto_awesome_outlined, label: '템플릿'),
        EditorActionItem(icon: Icons.person_outline, label: '내 사진'),
      ],
    );
  }
}
