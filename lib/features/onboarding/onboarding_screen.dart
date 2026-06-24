import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/premium_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  static const pages = [
    (
      title: '사진 찍기 전에 알려드릴게요',
      body: '구도, 조명, 거리, 초점을 촬영 전에 먼저 확인해요.',
      type: _VisualType.camera,
    ),
    (
      title: '템플릿만 고르면 끝',
      body: '어려운 프롬프트 없이 원하는 분위기를 고르면 돼요.',
      type: _VisualType.presets,
    ),
    (
      title: '적용 전 시안을 먼저 확인',
      body: '결과를 먼저 보고 마음에 드는 방향만 고화질로 완성해요.',
      type: _VisualType.preview,
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OnboardingTopBar(),
          Expanded(
            child: PageView.builder(
              controller: controller,
              onPageChanged: (value) => setState(() => page = value),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final item = pages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: _StoryVisual(
                          type: item.type,
                          active: index == page,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Text(
                        item.body,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Text(
                  '${page + 1} / 3',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: List.generate(pages.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 1,
                          margin: EdgeInsets.only(
                            right: index == pages.length - 1 ? 0 : 6,
                          ),
                          color: page == index
                              ? AppColors.textPrimary
                              : AppColors.lineStrong,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: PrimaryButton(
              key: const Key('onboardingPrimaryCta'),
              label: page == pages.length - 1 ? '시작하기' : '다음',
              onPressed: () {
                if (page < pages.length - 1) {
                  controller.nextPage(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  );
                  return;
                }
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.appBackground,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 5,
            backgroundColor: AppColors.profileAccent,
          ),
          const SizedBox(width: 8),
          Text('FrameFit', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text('PHOTO GUIDE', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _StoryVisual extends StatelessWidget {
  const _StoryVisual({required this.type, required this.active});

  final _VisualType type;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: active ? const Key('onboardingEditorialFrame') : null,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.line),
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          children: [
            _ReferenceStrip(type: type, active: active),
            const SizedBox(height: 12),
            Expanded(
              child: switch (type) {
                _VisualType.camera => const _CameraStory(),
                _VisualType.presets => const _PresetStory(),
                _VisualType.preview => const _PreviewStory(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceStrip extends StatelessWidget {
  const _ReferenceStrip({required this.type, required this.active});

  final _VisualType type;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      _VisualType.camera => 'COMPOSITION',
      _VisualType.presets => 'PRESET LIBRARY',
      _VisualType.preview => 'BEFORE / AFTER',
    };

    return Container(
      key: active ? const Key('onboardingReferenceStrip') : null,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const Spacer(),
          const Icon(Icons.more_horiz, size: 18),
        ],
      ),
    );
  }
}

class _CameraStory extends StatelessWidget {
  const _CameraStory();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppMetrics.thumbnailRadius),
      child: Stack(
        children: [
          const Positioned.fill(
            child: PhotoTile(
              data: PhotoTileData(
                label: 'profile',
                baseColor: Color(0xFFB8AAA0),
                accentColor: Color(0xFF2A2A2A),
              ),
            ),
          ),
          const Positioned.fill(child: CameraGuideOverlay(mode: '프로필')),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white.withValues(alpha: 0.9),
              child: Text(
                '얼굴을 살짝 오른쪽으로 옮기면 여백이 더 자연스러워요.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetStory extends StatelessWidget {
  const _PresetStory();

  @override
  Widget build(BuildContext context) {
    const tiles = [
      PhotoTileData(
        label: 'profile',
        baseColor: Color(0xFFD3B7A5),
        accentColor: Color(0xFF111111),
      ),
      PhotoTileData(
        label: 'film',
        baseColor: Color(0xFF7FA9C8),
        accentColor: Color(0xFFE0A45B),
      ),
      PhotoTileData(
        label: 'food',
        baseColor: Color(0xFFC9824A),
        accentColor: Color(0xFF6C3E20),
      ),
      PhotoTileData(
        label: 'mood',
        baseColor: Color(0xFF9A768C),
        accentColor: Color(0xFF352A35),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: PhotoGrid(items: tiles, columns: 2, aspectRatio: 0.82)),
      ],
    );
  }
}

class _PreviewStory extends StatelessWidget {
  const _PreviewStory();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Row(
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
        ),
        const SizedBox(height: 10),
        const PreviewOptionCard(
          label: '밝게',
          description: 'SNS용으로 환하게 맞춰요.',
          selected: true,
          onTap: _noop,
        ),
      ],
    );
  }
}

void _noop() {}

enum _VisualType { camera, presets, preview }
