import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../data/mock/mock_templates.dart';
import '../../data/models/edit_session.dart';
import '../../data/models/template.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = mockTemplates.take(3).toList(growable: false);

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
              '오늘 사진, 찍기 전에 먼저 맞춰볼까요?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              '촬영 목적에 맞춰 구도와 편집 템플릿을 이어서 추천해요.',
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
            child: EditorialSectionHeader(
              title: '촬영 코치',
              subtitle: '목적별 구도 체크',
              actionLabel: '촬영',
              onAction: () => Navigator.pushNamed(context, AppRoutes.camera),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _CoachStrip(),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EditorialSectionHeader(
              title: '추천 템플릿',
              subtitle: '이 사진에 어울리는 편집 방향',
              actionLabel: '전체',
              onAction: () => Navigator.pushNamed(context, AppRoutes.templates),
            ),
          ),
          const SizedBox(height: 10),
          _TemplateRail(templates: templates),
          const SizedBox(height: 26),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: EditorialSectionHeader(
              title: '최근 작업',
              subtitle: '완성한 사진은 이곳에 모여요.',
            ),
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
          Text('STUDIO', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 6),
          IconButton(
            tooltip: '알림',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, size: 20),
          ),
          IconButton(
            tooltip: '설정',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, size: 20),
          ),
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
                  '얼굴을 살짝 오른쪽으로 옮기면 여백이 더 자연스러워요.',
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
            label: '사진 찍기',
            icon: Icons.photo_camera_outlined,
            onPressed: onCamera,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SecondaryButton(
            key: const Key('homeSecondaryCta'),
            label: '사진 편집하기',
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
          return SizedBox(
            width: 176,
            child: PresetCard(
              key: Key('homeTemplateCard-${template.id}'),
              template: template,
              compact: true,
              recommended: index == 0,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.preview,
                arguments: PreviewArgs(template: template),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CoachStrip extends StatelessWidget {
  const _CoachStrip();

  @override
  Widget build(BuildContext context) {
    const modes = ['프로필', '셀카', '음식', '여행', '상품', '감성'];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.line),
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: modes.map((mode) => MetaChip(label: mode)).toList(),
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
