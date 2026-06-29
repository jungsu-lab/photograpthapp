import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../data/models/edit_session.dart';
import '../../data/models/template.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String selectedMode = '프로필';
  bool _appliedRouteArgs = false;

  static const guides = {
    '프로필': _Guide(
      message: '얼굴을 조금만 오른쪽으로 옮겨볼까요?',
      hint: '배경을 살짝 흐리면 인물이 더 보여요',
      score: 82,
      detail: '프로필 · 여백 적당 · 배경은 조금 정리 필요',
    ),
    '셀카': _Guide(
      message: '카메라를 아주 살짝만 위로 들어보세요.',
      hint: '피부톤은 자연스럽게 두는 쪽이 좋아요',
      score: 80,
      detail: '셀카 · 각도 안정 · 빛은 괜찮아요',
    ),
    '음식': _Guide(
      message: '접시를 가운데로 조금만 당겨보세요.',
      hint: '따뜻한 톤이 음식 색을 더 살려요',
      score: 78,
      detail: '음식 · 정렬 조금 필요 · 색감은 좋아요',
    ),
    '여행': _Guide(
      message: '하늘 비율 좋아요. 수평만 살짝 맞추면 돼요.',
      hint: '필름 톤이 풍경과 잘 맞아요',
      score: 86,
      detail: '여행 · 하늘 비율 좋음 · 수평 확인',
    ),
    '상품': _Guide(
      message: '제품 뒤쪽 물건만 조금 치워볼까요?',
      hint: '밝은 배경이면 상태가 더 또렷해 보여요',
      score: 81,
      detail: '상품 · 선명도 좋음 · 배경 정리 필요',
    ),
    '감성': _Guide(
      message: '왼쪽 여백은 그대로 두는 게 좋아요.',
      hint: '차분한 톤으로 분위기를 살릴 수 있어요',
      score: 84,
      detail: '무드 · 여백 좋음 · 톤만 차분하게',
    ),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedRouteArgs) {
      return;
    }
    final template = _selectedTemplate(context);
    if (template != null && guides.containsKey(template.category)) {
      selectedMode = template.category;
    }
    _appliedRouteArgs = true;
  }

  @override
  Widget build(BuildContext context) {
    final template = _selectedTemplate(context);
    final guide = _guideFor(selectedMode, template);

    return Scaffold(
      backgroundColor: AppColors.cameraBackdrop,
      body: SafeArea(
        child: Column(
          children: [
            _CameraTopBar(mode: selectedMode, template: template),
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
                    onPressed: () =>
                        _showComingSoon(context, '갤러리 연결은 Phase 4에서 다룰게요.'),
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

  EditTemplate? _selectedTemplate(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    return switch (routeArgs) {
      CameraArgs(:final template) => template,
      EditTemplate() => routeArgs,
      _ => null,
    };
  }

  _Guide _guideFor(String mode, EditTemplate? template) {
    final base = guides[mode] ?? guides['프로필']!;
    if (template == null) {
      return base;
    }
    return _Guide(
      message: template.compositionGuidance,
      hint: '${template.name} 기준으로 맞춰보는 중',
      score: template.beginnerFriendlyScore,
      detail: '${template.category} · ${template.aspectRatio} · 지금은 샘플 화면',
    );
  }
}

class _CameraTopBar extends StatelessWidget {
  const _CameraTopBar({required this.mode, required this.template});

  final String mode;
  final EditTemplate? template;

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
                  '샘플 촬영 화면',
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                if (template != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    template!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: '그리드',
            onPressed: () => _showComingSoon(context, '지금은 기본 그리드로 보여드려요.'),
            icon: const Icon(Icons.grid_3x3, color: Colors.white, size: 18),
          ),
          IconButton(
            tooltip: '설정',
            onPressed: () =>
                _showComingSoon(context, '카메라 설정은 실제 촬영 기능에서 열릴 예정이에요.'),
            icon: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(guide.message),
        color: Colors.white.withValues(alpha: 0.9),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              '${guide.score}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
                  Text(
                    guide.hint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
