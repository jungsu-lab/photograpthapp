import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../data/presets/preset_catalog.dart';
import '../../data/presets/preset_preview_assets.dart';
import '../../domain/models/photo_preset.dart';
import '../../services/photo_input_service.dart';
import '../../services/preset_preferences.dart';
import '../editor/editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenShoot,
    this.onOpenEdit,
    this.autoOpenPicker = false,
  });

  final VoidCallback? onOpenShoot;
  final VoidCallback? onOpenEdit;
  final bool autoOpenPicker;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _input = PhotoInputService();
  final _presetPreferences = PresetPreferences();
  bool _openingPhoto = false;
  List<PhotoPreset> _recentPresets = const [];

  @override
  void initState() {
    super.initState();
    _loadRecentPresets();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final recovered = await _recoverLostPhoto();
      if (!recovered && widget.autoOpenPicker && mounted) {
        await _startEditor();
      }
    });
  }

  Future<bool> _recoverLostPhoto() async {
    try {
      final photo = await _input.retrieveLostPhoto();
      if (!mounted || photo == null) return false;
      await Navigator.pushNamed(
        context,
        AppRoutes.editor,
        arguments: EditorArgs(photo: photo),
      );
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이전에 선택한 사진을 복원하지 못했어요. 다시 선택해 주세요.')),
        );
      }
      return false;
    }
  }

  Future<void> _loadRecentPresets() async {
    try {
      final ids = await _presetPreferences.recentIds();
      final presetsById = {
        for (final preset in presetCatalog) preset.id: preset,
      };
      final recent = ids
          .map((id) => presetsById[id])
          .whereType<PhotoPreset>()
          .toList();
      if (mounted) setState(() => _recentPresets = recent);
    } catch (_) {
      // Preference history is optional; photo editing stays usable.
    }
  }

  Future<void> _startEditor({PhotoPreset? initialPreset}) async {
    if (_openingPhoto) return;
    setState(() => _openingPhoto = true);
    try {
      final photo = await _input.pickFromGallery();
      if (!mounted || photo == null) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.editor,
        arguments: EditorArgs(photo: photo, initialPreset: initialPreset),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '사진을 열지 못했어요. ${error.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _openingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9F8F5),
    appBar: AppBar(
      backgroundColor: const Color(0xFFF9F8F5),
      elevation: 0,
      title: const Row(
        children: [
          _BrandDot(),
          SizedBox(width: 8),
          Text(
            'FrameFit',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: '프리셋 보기',
          onPressed:
              widget.onOpenEdit ??
              () => Navigator.pushNamed(context, AppRoutes.templates),
          icon: const Icon(Icons.auto_awesome_outlined),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        children: [
          Text(
            '사진 한 장으로\n오늘의 분위기를 바꿔보세요.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.13,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '복잡한 보정 대신 마음에 드는 프리셋을 고르고, 강도만 조절하세요.',
            style: TextStyle(color: Color(0xFF656565), height: 1.45),
          ),
          const SizedBox(height: 26),
          _PhotoEntryCard(
            busy: _openingPhoto,
            onGallery: _startEditor,
            onCamera:
                widget.onOpenShoot ??
                () => Navigator.pushNamed(context, AppRoutes.camera),
          ),
          const SizedBox(height: 30),
          _SectionHeader(
            title: '바로 써보기',
            action: '모두 보기',
            onAction:
                widget.onOpenEdit ??
                () => Navigator.pushNamed(context, AppRoutes.templates),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: presetCatalog.take(6).length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _PresetPreviewCard(
                preset: presetCatalog[index],
                busy: _openingPhoto,
                onTap: () => _startEditor(initialPreset: presetCatalog[index]),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const _SectionHeader(title: '최근 작업'),
          const SizedBox(height: 12),
          _RecentPresetPanel(
            presets: _recentPresets,
            busy: _openingPhoto,
            onSelect: (preset) => _startEditor(initialPreset: preset),
          ),
          const SizedBox(height: 26),
          TextButton.icon(
            onPressed:
                widget.onOpenShoot ??
                () => Navigator.pushNamed(context, AppRoutes.camera),
            icon: const Icon(Icons.grid_view_outlined),
            label: const Text('촬영 전에 구도 코치 열기'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RecentPresetPanel extends StatelessWidget {
  const _RecentPresetPanel({
    required this.presets,
    required this.busy,
    required this.onSelect,
  });

  final List<PhotoPreset> presets;
  final bool busy;
  final ValueChanged<PhotoPreset> onSelect;

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.history, color: Color(0xFF747474)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '아직 사용한 프리셋이 없어요. 사진을 불러와 첫 프리셋을 적용해 보세요.',
                style: TextStyle(color: Color(0xFF5F5F5F), height: 1.35),
              ),
            ),
          ],
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets
          .map(
            (preset) => ActionChip(
              avatar: const Icon(Icons.history, size: 16),
              label: Text(preset.name),
              tooltip: '${preset.name} 프리셋으로 사진 선택',
              onPressed: busy ? null : () => onSelect(preset),
            ),
          )
          .toList(),
    );
  }
}

class _BrandDot extends StatelessWidget {
  const _BrandDot();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
    child: SizedBox(width: 12, height: 12),
  );
}

class _PhotoEntryCard extends StatelessWidget {
  const _PhotoEntryCard({
    required this.busy,
    required this.onGallery,
    required this.onCamera,
  });
  final bool busy;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xFF181818),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.auto_awesome, color: Color(0xFFF1D591)),
        const SizedBox(height: 14),
        const Text(
          '실제 사진에\n프리셋을 적용하세요.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '원본은 그대로 보존하고, 결과만 새 사진으로 저장해요.',
          style: TextStyle(color: Color(0xFFBFBFBF), height: 1.4),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const Key('importPhotoButton'),
          onPressed: busy ? null : onGallery,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('사진 불러오기'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF171717),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: busy ? null : onCamera,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('카메라로 촬영'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF181818),
            side: const BorderSide(color: Color(0xFF626262)),
          ),
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      const Spacer(),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
    ],
  );
}

class _PresetPreviewCard extends StatelessWidget {
  const _PresetPreviewCard({
    required this.preset,
    required this.busy,
    required this.onTap,
  });
  final PhotoPreset preset;
  final bool busy;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${preset.name} 프리셋으로 사진 선택',
    child: GestureDetector(
      onTap: busy ? null : onTap,
      child: SizedBox(
        width: 126,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: isMonochromePreview(preset)
                          ? const ColorFilter.matrix(<double>[
                              .33,
                              .33,
                              .33,
                              0,
                              0,
                              .33,
                              .33,
                              .33,
                              0,
                              0,
                              .33,
                              .33,
                              .33,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ])
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.dst,
                            ),
                      child: Image.asset(
                        presetPreviewAsset(preset),
                        fit: BoxFit.cover,
                        semanticLabel: '${preset.name} 프리셋 적용 예시',
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(preset.swatch).withValues(alpha: .18),
                      ),
                    ),
                    if (preset.category == PresetCategory.japanTravel)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0x22000000),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          preset.category.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preset.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
