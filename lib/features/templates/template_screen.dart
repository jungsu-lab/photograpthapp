import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../data/presets/preset_catalog.dart';
import '../../data/presets/preset_preview_assets.dart';
import '../../domain/models/photo_preset.dart';
import '../../services/photo_input_service.dart';
import '../../services/preset_preferences.dart';
import '../editor/editor_screen.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  final _input = PhotoInputService();
  final _preferences = PresetPreferences();
  PresetCategory? _selectedCategory;
  Set<String> _favoriteIds = <String>{};
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await _preferences.favorites();
      if (mounted) setState(() => _favoriteIds = ids);
    } catch (_) {
      // Favorites are optional and must not block the preset library.
    }
  }

  Future<void> _toggleFavorite(String id) async {
    try {
      final ids = await _preferences.toggleFavorite(id);
      if (mounted) setState(() => _favoriteIds = ids);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('즐겨찾기를 저장하지 못했어요.')));
      }
    }
  }

  Future<void> _choosePhotoForPreset(PhotoPreset preset) async {
    if (_isOpening) return;
    setState(() => _isOpening = true);
    try {
      final photo = await _input.pickFromGallery();
      if (!mounted || photo == null) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.editor,
        arguments: EditorArgs(photo: photo, initialPreset: preset),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('사진을 열지 못했어요. $error')));
      }
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = presetCatalog
        .where(
          (preset) =>
              _selectedCategory == null || preset.category == _selectedCategory,
        )
        .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F8F5),
        elevation: 0,
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? null
            : IconButton(
                tooltip: '뒤로',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
        title: const Text('프리셋', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '사진에 맞는 분위기를 고르세요.',
                  style: TextStyle(color: Color(0xFF6B6B6B)),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: const Text('전체'),
                        selected: _selectedCategory == null,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = null),
                      ),
                      const SizedBox(width: 8),
                      ...PresetCategory.values.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category.label),
                            selected: _selectedCategory == category,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = category),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .68,
              ),
              itemCount: shown.length,
              itemBuilder: (context, index) {
                final preset = shown[index];
                return _PresetLibraryCard(
                  preset: preset,
                  favorite: _favoriteIds.contains(preset.id),
                  busy: _isOpening,
                  onOpen: () => _choosePhotoForPreset(preset),
                  onFavorite: () => _toggleFavorite(preset.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetLibraryCard extends StatelessWidget {
  const _PresetLibraryCard({
    required this.preset,
    required this.favorite,
    required this.busy,
    required this.onOpen,
    required this.onFavorite,
  });

  final PhotoPreset preset;
  final bool favorite;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: busy ? null : onOpen,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                          gradient: LinearGradient(
                            colors: [
                              const Color(0x18000000),
                              Color(preset.swatch).withValues(alpha: .35),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        tooltip: favorite ? '즐겨찾기 해제' : '즐겨찾기',
                        onPressed: onFavorite,
                        color: Colors.white,
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              preset.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              preset.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6D6D6D),
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
