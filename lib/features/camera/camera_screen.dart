import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/premium_widgets.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String selectedMode = '프로필';

  static const guides = {
    '프로필': _Guide(
      message: '얼굴을 살짝 오른쪽으로 옮기면 여백이 더 자연스러워요.',
      hint: '배경 흐림 인물 템플릿 추천',
      score: 82,
      detail: '프로필 모드 · 여백 82 · 배경 복잡도 보통',
    ),
    '셀카': _Guide(
      message: '카메라를 조금 위로 올리면 얼굴 비율이 안정돼요.',
      hint: '자연 셀카 템플릿 추천',
      score: 80,
      detail: '셀카 모드 · 얼굴 각도 80 · 조명 안정',
    ),
    '음식': _Guide(
      message: '접시가 화면 왼쪽으로 치우쳤어요. 중앙에 조금만 맞춰보세요.',
      hint: '맛있어 보이는 음식 템플릿 추천',
      score: 78,
      detail: '음식 모드 · 정렬 78 · 색감 좋음',
    ),
    '여행': _Guide(
      message: '하늘과 피사체 비율이 좋아요. 수평만 살짝 맞춰보세요.',
      hint: '필름 여행 템플릿 추천',
      score: 86,
      detail: '여행 모드 · 수평 86 · 하늘 비율 좋음',
    ),
    '상품': _Guide(
      message: '제품 배경이 조금 복잡해요. 밝은 배경 쪽으로 옮겨보세요.',
      hint: '흰 배경 상품컷 추천',
      score: 81,
      detail: '상품 모드 · 선명도 81 · 배경 정리 필요',
    ),
    '감성': _Guide(
      message: '왼쪽 여백을 살리면 더 감성적인 구도가 돼요.',
      hint: '시네마틱 무드 템플릿 추천',
      score: 84,
      detail: '감성 모드 · 여백 84 · 무드 적합',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final guide = guides[selectedMode]!;

    return Scaffold(
      backgroundColor: AppColors.cameraBackdrop,
      body: SafeArea(
        child: Column(
          children: [
            _CameraTopBar(mode: selectedMode),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppMetrics.thumbnailRadius,
                  ),
                  child: Stack(
                    key: const Key('cameraEditorSurface'),
                    children: [
                      Positioned.fill(
                        child: _MockCameraSurface(mode: selectedMode),
                      ),
                      Positioned.fill(
                        child: CameraGuideOverlay(
                          mode: selectedMode,
                          score: guide.score,
                          message: guide.message,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 14,
                        child: _GuidePanel(guide: guide),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _CameraModeRail(
                modes: guides.keys.toList(growable: false),
                selectedMode: selectedMode,
                onChanged: (mode) => setState(() => selectedMode = mode),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 8, 26, 18),
              child: Row(
                key: const Key('cameraToolDock'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: '갤러리',
                    onPressed: () {},
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 74,
                    height: 74,
                    child: IconButton(
                      key: const Key('captureButton'),
                      tooltip: '촬영',
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.analysis),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        shape: const CircleBorder(),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined, size: 30),
                    ),
                  ),
                  IconButton(
                    tooltip: '템플릿',
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.templates),
                    icon: const Icon(
                      Icons.auto_awesome_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraTopBar extends StatelessWidget {
  const _CameraTopBar({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: '닫기',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  mode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'LIVE COMPOSITION',
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '그리드',
            onPressed: () {},
            icon: const Icon(Icons.grid_3x3, color: Colors.white, size: 18),
          ),
          IconButton(
            tooltip: '설정',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _CameraModeRail extends StatelessWidget {
  const _CameraModeRail({
    required this.modes,
    required this.selectedMode,
    required this.onChanged,
  });

  final List<String> modes;
  final String selectedMode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('cameraModeRail'),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x33FFFFFF)),
          bottom: BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final mode = modes[index];
          final selected = mode == selectedMode;
          return InkWell(
            onTap: () => onChanged(mode),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mode,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0x99FFFFFF),
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 1.5,
                    width: 22,
                    color: selected ? Colors.white : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemCount: modes.length,
      ),
    );
  }
}

class _MockCameraSurface extends StatelessWidget {
  const _MockCameraSurface({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final colors = switch (mode) {
      '음식' => [const Color(0xFFC9824A), const Color(0xFF6C3E20)],
      '여행' => [const Color(0xFF7FA9C8), const Color(0xFFE0A45B)],
      '상품' => [const Color(0xFFE8E5DE), const Color(0xFFB8B8B2)],
      '감성' => [const Color(0xFF6F6570), const Color(0xFF222222)],
      _ => [const Color(0xFFB8AAA0), const Color(0xFF2B2B2B)],
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 36,
            top: 76,
            child: Container(
              width: 96,
              height: 156,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(52),
              ),
            ),
          ),
          Positioned(
            right: 34,
            bottom: 170,
            child: Container(
              width: 160,
              height: 108,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidePanel extends StatelessWidget {
  const _GuidePanel({required this.guide});

  final _Guide guide;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.9),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text('${guide.score}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  guide.message,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(guide.hint, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  guide.detail,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Guide {
  const _Guide({
    required this.message,
    required this.hint,
    required this.score,
    required this.detail,
  });

  final String message;
  final String hint;
  final int score;
  final String detail;
}
