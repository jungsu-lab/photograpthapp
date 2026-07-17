import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/utils/edit_history.dart';
import '../../data/presets/preset_catalog.dart';
import '../../domain/models/photo_preset.dart';
import '../../domain/models/selected_photo.dart';
import '../../services/photo_export_service.dart';
import '../../services/photo_processor.dart';
import '../../services/preset_preferences.dart';
import 'crop_panel.dart';

class EditorArgs {
  const EditorArgs({required this.photo, this.initialPreset});
  final SelectedPhoto photo;
  final PhotoPreset? initialPreset;
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    this.args,
    this.processor = const PhotoProcessor(),
    this.exporter,
    this.presetPreferences,
  });

  /// Supplying arguments directly keeps the screen easy to exercise in widget
  /// tests, while production navigation continues to use route arguments.
  final EditorArgs? args;
  final PhotoProcessor processor;
  final PhotoExportService? exporter;
  final PresetPreferences? presetPreferences;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final PhotoProcessor _processor;
  late final PhotoExportService _exporter;
  late final PresetPreferences _presetPreferences;
  EditSettings _settings = const EditSettings();
  Uint8List? _previewBytes;
  String? _error;
  bool _isProcessing = true;
  bool _showOriginal = false;
  bool _isExporting = false;
  int _tab = 0;
  int _requestId = 0;
  Timer? _previewDebounce;
  final EditHistory<EditSettings> _history = EditHistory<EditSettings>();
  final Map<String, Future<Uint8List>> _presetThumbnails = {};
  Set<String> _favoriteIds = <String>{};
  bool _appliedArgs = false;

  EditorArgs get _args =>
      widget.args ?? (ModalRoute.of(context)?.settings.arguments as EditorArgs);

  SelectedPhoto get _photo => _args.photo;

  PhotoOutputFormat get _preferredOutputFormat =>
      _photo.name.toLowerCase().endsWith('.png')
      ? PhotoOutputFormat.png
      : PhotoOutputFormat.jpeg;

  Future<Uint8List> _thumbnailFor(PhotoPreset preset) =>
      _presetThumbnails.putIfAbsent(
        preset.id,
        () => _processor.render(
          PhotoProcessRequest(
            sourceBytes: _photo.bytes,
            recipe: preset.recipe.scaled(preset.defaultIntensity),
            maxDimension: 192,
            quality: 82,
            outputFormat: _preferredOutputFormat,
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    _processor = widget.processor;
    _exporter = widget.exporter ?? PhotoExportService();
    _presetPreferences = widget.presetPreferences ?? PresetPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) => _renderPreview());
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedArgs) return;
    final preset = _args.initialPreset;
    if (preset != null) {
      _settings = EditSettings(
        preset: preset,
        intensity: preset.defaultIntensity,
      );
      unawaited(_recordPresetUse(preset.id));
    }
    _appliedArgs = true;
  }

  Future<void> _recordPresetUse(String id) async {
    try {
      await _presetPreferences.recordUse(id);
    } catch (_) {
      // Recent history is optional and must never interrupt photo editing.
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _presetPreferences.favorites();
      if (mounted) setState(() => _favoriteIds = favorites);
    } catch (_) {
      // A storage error must not block editing or export.
    }
  }

  Future<void> _toggleFavorite() async {
    final preset = _settings.preset;
    if (preset == null) return;
    try {
      final favorites = await _presetPreferences.toggleFavorite(preset.id);
      if (mounted) setState(() => _favoriteIds = favorites);
    } catch (_) {
      if (mounted) _message('즐겨찾기를 저장하지 못했어요.');
    }
  }

  Future<void> _renderPreview() async {
    _previewDebounce?.cancel();
    final requestId = ++_requestId;
    await _renderPreviewRequest(requestId);
  }

  void _schedulePreview() {
    _previewDebounce?.cancel();
    final requestId = ++_requestId;
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    _previewDebounce = Timer(const Duration(milliseconds: 140), () {
      unawaited(_renderPreviewRequest(requestId));
    });
  }

  Future<void> _renderPreviewRequest(int requestId) async {
    if (!mounted || requestId != _requestId) return;
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    try {
      final bytes = await _processor.render(
        PhotoProcessRequest(
          sourceBytes: _photo.bytes,
          recipe: _settings.effectiveRecipe,
          maxDimension: 1440,
          outputFormat: _preferredOutputFormat,
          cropAspectRatio: _settings.cropAspectRatio,
        ),
      );
      if (!mounted || requestId != _requestId) return;
      setState(() => _previewBytes = bytes);
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _changeSettings(EditSettings settings, {bool addToHistory = true}) {
    if (_sameSettings(_settings, settings)) return;
    final previous = _settings;
    final priorPreset = _settings.preset?.id;
    setState(() {
      if (addToHistory) {
        _history.record(previous);
      }
      _settings = settings;
    });
    if (settings.preset != null && settings.preset!.id != priorPreset) {
      unawaited(_recordPresetUse(settings.preset!.id));
    }
    _schedulePreview();
  }

  bool _sameSettings(EditSettings left, EditSettings right) =>
      left.preset?.id == right.preset?.id &&
      left.intensity == right.intensity &&
      left.manual == right.manual &&
      left.cropAspectRatio == right.cropAspectRatio;

  void _undo() {
    final previous = _history.undo(_settings);
    if (previous == null) return;
    _changeSettings(previous, addToHistory: false);
  }

  void _redo() {
    final next = _history.redo(_settings);
    if (next == null) return;
    _changeSettings(next, addToHistory: false);
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    super.dispose();
  }

  Future<void> _prepareExport() async {
    final options = await showModalBottomSheet<_ExportOptions>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _ExportOptionsSheet(
        initial: _ExportOptions(format: _preferredOutputFormat),
      ),
    );
    if (!mounted || options == null) return;
    setState(() => _isExporting = true);
    ExportedPhoto? exported;
    var wasHandedOff = false;
    try {
      final bytes = await _processor.render(
        PhotoProcessRequest(
          sourceBytes: _photo.bytes,
          recipe: _settings.effectiveRecipe,
          maxDimension: options.maxDimension,
          quality: options.quality,
          outputFormat: options.format,
          cropAspectRatio: _settings.cropAspectRatio,
        ),
      );
      exported = await _exporter.createImage(
        bytes,
        sourceName: _photo.name,
        format: options.format,
      );
      // A route can disappear while the full-resolution render is running.
      // Do not retain a private temporary photo merely because there is no
      // longer a sheet to offer it to.
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => _ExportSheet(
          options: options,
          onSave: () {
            wasHandedOff = true;
            Navigator.pop(sheetContext);
            return _save(exported!);
          },
          onShare: () {
            wasHandedOff = true;
            Navigator.pop(sheetContext);
            return _share(exported!);
          },
        ),
      );
    } catch (error) {
      if (mounted) _message('내보내기에 실패했어요. ${_cleanError(error)}');
    } finally {
      if (exported != null && !wasHandedOff) {
        await _exporter.deleteTemporary(exported);
      }
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _save(ExportedPhoto photo) async {
    try {
      await _exporter.saveToGallery(photo);
      if (mounted) _message('FrameFit 앨범에 저장했어요.');
    } catch (error) {
      if (mounted) _message('사진첩 저장에 실패했어요. ${_cleanError(error)}');
    } finally {
      await _exporter.deleteTemporary(photo);
    }
  }

  Future<void> _share(ExportedPhoto photo) async {
    try {
      await _exporter.share(photo);
    } catch (error) {
      if (mounted) _message('공유 창을 열지 못했어요. ${_cleanError(error)}');
    } finally {
      await _exporter.deleteTemporary(photo);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext context) {
    final photo = _photo;
    final displayed = _showOriginal
        ? photo.bytes
        : (_previewBytes ?? photo.bytes);
    final selectedPreset = _settings.preset;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: '뒤로',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '편집',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text(
              selectedPreset?.name ?? '원본',
              style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('undoButton'),
            tooltip: '실행 취소',
            onPressed: !_history.canUndo || _isProcessing ? null : _undo,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            key: const Key('redoButton'),
            tooltip: '다시 실행',
            onPressed: !_history.canRedo || _isProcessing ? null : _redo,
            icon: const Icon(Icons.redo),
          ),
          if (selectedPreset != null)
            IconButton(
              tooltip: _favoriteIds.contains(selectedPreset.id)
                  ? '즐겨찾기 해제'
                  : '즐겨찾기',
              onPressed: _toggleFavorite,
              icon: Icon(
                _favoriteIds.contains(selectedPreset.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
            ),
          TextButton.icon(
            key: const Key('exportButton'),
            onPressed: _isProcessing || _isExporting ? null : _prepareExport,
            icon: _isExporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share_outlined),
            label: const Text('내보내기'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: GestureDetector(
                      onLongPressStart: (_) =>
                          setState(() => _showOriginal = true),
                      onLongPressEnd: (_) =>
                          setState(() => _showOriginal = false),
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Image.memory(
                          displayed,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          semanticLabel: _showOriginal
                              ? '원본 사진'
                              : '${selectedPreset?.name ?? '편집'} 적용 사진. 길게 눌러 원본을 확인하세요.',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          _showOriginal ? '원본' : (selectedPreset?.name ?? '원본'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  if (_error != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: _ErrorPanel(
                        message: _error!,
                        onRetry: _renderPreview,
                      ),
                    ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14,
                    child: Center(
                      child: Text(
                        '길게 눌러 원본 보기',
                        style: TextStyle(
                          color: Color(0xFFDDDDDD),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFF1C1C1C),
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      _EditorTab(
                        label: '프리셋',
                        icon: Icons.auto_awesome_outlined,
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                      _EditorTab(
                        label: '고급 보정',
                        icon: Icons.tune,
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                      _EditorTab(
                        label: '자르기',
                        icon: Icons.crop,
                        selected: _tab == 2,
                        onTap: () => setState(() => _tab = 2),
                      ),
                      _EditorTab(
                        label: '초기화',
                        icon: Icons.refresh,
                        selected: false,
                        onTap: () => _changeSettings(const EditSettings()),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 216,
                    child: _tab == 0
                        ? _PresetPanel(
                            settings: _settings,
                            originalBytes: photo.bytes,
                            thumbnailFor: _thumbnailFor,
                            onSelect: (preset) => _changeSettings(
                              _settings.copyWith(
                                preset: preset,
                                intensity: preset.defaultIntensity,
                              ),
                            ),
                            onOriginal: () => _changeSettings(
                              _settings.copyWith(clearPreset: true),
                            ),
                            onIntensity: (value) => _changeSettings(
                              _settings.copyWith(intensity: value),
                            ),
                          )
                        : _tab == 1
                        ? _AdjustPanel(
                            recipe: _settings.manual,
                            onChanged: (recipe) => _changeSettings(
                              _settings.copyWith(manual: recipe),
                            ),
                          )
                        : CropPanel(
                            aspectRatio: _settings.cropAspectRatio,
                            onChanged: (aspectRatio) => _changeSettings(
                              _settings.copyWith(
                                cropAspectRatio: aspectRatio,
                                clearCrop: aspectRatio == null,
                              ),
                            ),
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

class _EditorTab extends StatelessWidget {
  const _EditorTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF9B9B9B),
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF9B9B9B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PresetPanel extends StatefulWidget {
  const _PresetPanel({
    required this.settings,
    required this.originalBytes,
    required this.thumbnailFor,
    required this.onSelect,
    required this.onOriginal,
    required this.onIntensity,
  });
  final EditSettings settings;
  final Uint8List originalBytes;
  final Future<Uint8List> Function(PhotoPreset preset) thumbnailFor;
  final ValueChanged<PhotoPreset> onSelect;
  final VoidCallback onOriginal;
  final ValueChanged<double> onIntensity;

  @override
  State<_PresetPanel> createState() => _PresetPanelState();
}

class _PresetPanelState extends State<_PresetPanel> {
  PresetCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final originalBytes = widget.originalBytes;
    final thumbnailFor = widget.thumbnailFor;
    final onSelect = widget.onSelect;
    final onOriginal = widget.onOriginal;
    final onIntensity = widget.onIntensity;
    final orderedPresets = presetCatalog
        .where(
          (preset) =>
              _selectedCategory == null || preset.category == _selectedCategory,
        )
        .toList();
    final selectedPreset = settings.preset;
    if (selectedPreset != null &&
        (_selectedCategory == null ||
            selectedPreset.category == _selectedCategory)) {
      orderedPresets.removeWhere((preset) => preset.id == selectedPreset.id);
      orderedPresets.insert(0, selectedPreset);
    }

    return Column(
      children: [
        SizedBox(
          height: 38,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              ChoiceChip(
                label: const Text('전체'),
                selected: _selectedCategory == null,
                selectedColor: Colors.white,
                labelStyle: TextStyle(
                  color: _selectedCategory == null
                      ? const Color(0xFF111111)
                      : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: const Color(0xFF333333),
                side: BorderSide.none,
                onSelected: (_) => setState(() => _selectedCategory = null),
              ),
              const SizedBox(width: 8),
              ...PresetCategory.values.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category.label),
                    selected: _selectedCategory == category,
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? const Color(0xFF111111)
                          : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: const Color(0xFF333333),
                    side: BorderSide.none,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = category),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: orderedPresets.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final isOriginal = index == 0;
              final preset = isOriginal ? null : orderedPresets[index - 1];
              final selected = isOriginal
                  ? settings.preset == null
                  : settings.preset?.id == preset!.id;
              return GestureDetector(
                onTap: isOriginal ? onOriginal : () => onSelect(preset!),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: isOriginal
                              ? const Color(0xFF444444)
                              : Color(preset!.swatch),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isOriginal
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  originalBytes,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FutureBuilder<Uint8List>(
                                  future: thumbnailFor(preset!),
                                  builder: (context, snapshot) {
                                    final bytes = snapshot.data;
                                    if (bytes == null) {
                                      return ColoredBox(
                                        color: Color(preset.swatch),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Image.memory(
                                      bytes,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                    );
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isOriginal ? '원본' : preset!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFFB4B4B4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (settings.preset != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  '강도',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: Slider(
                    value: settings.intensity,
                    min: 0,
                    max: 1,
                    divisions: 20,
                    activeColor: Colors.white,
                    inactiveColor: const Color(0xFF555555),
                    onChanged: onIntensity,
                  ),
                ),
                Text(
                  '${(settings.intensity * 100).round()}',
                  style: const TextStyle(color: Colors.white, fontFeatures: []),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AdjustPanel extends StatefulWidget {
  const _AdjustPanel({required this.recipe, required this.onChanged});
  final PresetRecipe recipe;
  final ValueChanged<PresetRecipe> onChanged;

  @override
  State<_AdjustPanel> createState() => _AdjustPanelState();
}

class _AdjustPanelState extends State<_AdjustPanel> {
  var _selectedGroup = 0;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final controls = <_AdjustmentControl>[
      _AdjustmentControl(
        '노출',
        recipe.exposureEv,
        -2,
        2,
        (value) => recipe.copyWith(exposureEv: value),
      ),
      _AdjustmentControl(
        '대비',
        recipe.contrast,
        -1,
        1,
        (value) => recipe.copyWith(contrast: value),
      ),
      _AdjustmentControl(
        '하이라이트',
        recipe.highlights,
        -1,
        1,
        (value) => recipe.copyWith(highlights: value),
      ),
      _AdjustmentControl(
        '그림자',
        recipe.shadows,
        -1,
        1,
        (value) => recipe.copyWith(shadows: value),
      ),
      _AdjustmentControl(
        '흰색',
        recipe.whites,
        -1,
        1,
        (value) => recipe.copyWith(whites: value),
      ),
      _AdjustmentControl(
        '검정',
        recipe.blacks,
        -1,
        1,
        (value) => recipe.copyWith(blacks: value),
      ),
      _AdjustmentControl(
        '채도',
        recipe.saturation,
        -1,
        1,
        (value) => recipe.copyWith(saturation: value),
      ),
      _AdjustmentControl(
        '생동감',
        recipe.vibrance,
        -1,
        1,
        (value) => recipe.copyWith(vibrance: value),
      ),
      _AdjustmentControl(
        '색온도',
        recipe.temperature,
        -1,
        1,
        (value) => recipe.copyWith(temperature: value),
      ),
      _AdjustmentControl(
        '틴트',
        recipe.tint,
        -1,
        1,
        (value) => recipe.copyWith(tint: value),
      ),
      _AdjustmentControl(
        '선명도',
        recipe.sharpness,
        0,
        1,
        (value) => recipe.copyWith(sharpness: value),
      ),
      _AdjustmentControl(
        '비네트',
        recipe.vignette,
        0,
        1,
        (value) => recipe.copyWith(vignette: value),
      ),
      _AdjustmentControl(
        '페이드',
        recipe.fade,
        0,
        1,
        (value) => recipe.copyWith(fade: value),
      ),
      _AdjustmentControl(
        '그레인',
        recipe.grain,
        0,
        1,
        (value) => recipe.copyWith(grain: value),
      ),
    ];
    final groups = <({String label, List<_AdjustmentControl> controls})>[
      (label: '빛', controls: controls.sublist(0, 6)),
      (label: '색', controls: controls.sublist(6, 10)),
      (label: '질감', controls: controls.sublist(10)),
    ];
    final shown = groups[_selectedGroup].controls;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: List.generate(
              groups.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(groups[index].label),
                  selected: _selectedGroup == index,
                  selectedColor: const Color(0xFFF1F1F1),
                  labelStyle: TextStyle(
                    color: _selectedGroup == index
                        ? const Color(0xFF111111)
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: const Color(0xFF333333),
                  side: BorderSide.none,
                  onSelected: (_) => setState(() => _selectedGroup = index),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: shown.length,
            itemBuilder: (context, index) {
              final item = shown[index];
              return SizedBox(
                width: 170,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        IconButton(
                          key: Key('adjustReset-$index'),
                          tooltip: '${item.label} 초기화',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints.tightFor(
                            width: 44,
                            height: 44,
                          ),
                          onPressed: item.value == 0
                              ? null
                              : () => widget.onChanged(item.update(0)),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          color: Colors.white,
                          disabledColor: const Color(0xFF626262),
                        ),
                      ],
                    ),
                    Slider(
                      value: item.value,
                      min: item.min,
                      max: item.max,
                      activeColor: Colors.white,
                      inactiveColor: const Color(0xFF555555),
                      onChanged: (value) =>
                          widget.onChanged(item.update(value)),
                    ),
                    Text(
                      item.value.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Color(0xFFB4B4B4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdjustmentControl {
  const _AdjustmentControl(
    this.label,
    this.value,
    this.min,
    this.max,
    this.update,
  );
  final String label;
  final double value;
  final double min;
  final double max;
  final PresetRecipe Function(double value) update;
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFDECEA),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB3261E)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF6A1B16), fontSize: 12),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    ),
  );
}

class _ExportOptions {
  const _ExportOptions({
    required this.format,
    this.maxDimension,
    this.quality = 95,
  });

  final PhotoOutputFormat format;
  final int? maxDimension;
  final int quality;

  String get sizeLabel =>
      maxDimension == null ? '원본 해상도' : '긴 변 ${maxDimension}px';
}

class _ExportOptionsSheet extends StatefulWidget {
  const _ExportOptionsSheet({required this.initial});

  final _ExportOptions initial;

  @override
  State<_ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<_ExportOptionsSheet> {
  late PhotoOutputFormat _format = widget.initial.format;
  late int? _maxDimension = widget.initial.maxDimension;
  late double _quality = widget.initial.quality.toDouble();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('내보내기 설정', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text('원본 파일은 바꾸지 않고 새 파일을 만들어요.'),
            const SizedBox(height: 18),
            Text('형식', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: PhotoOutputFormat.values
                  .map(
                    (format) => ChoiceChip(
                      label: Text(
                        format == PhotoOutputFormat.png ? 'PNG' : 'JPEG',
                      ),
                      selected: _format == format,
                      onSelected: (_) => setState(() => _format = format),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('출력 크기', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  [
                        (label: '원본 해상도', dimension: null),
                        (label: '긴 변 2048px', dimension: 2048),
                      ]
                      .map(
                        (option) => ChoiceChip(
                          label: Text(option.label),
                          selected: _maxDimension == option.dimension,
                          onSelected: (_) =>
                              setState(() => _maxDimension = option.dimension),
                        ),
                      )
                      .toList(),
            ),
            if (_format == PhotoOutputFormat.jpeg) ...[
              const SizedBox(height: 16),
              Text(
                'JPEG 품질 ${_quality.round()}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Slider(
                value: _quality,
                min: 80,
                max: 100,
                divisions: 4,
                label: _quality.round().toString(),
                onChanged: (value) => setState(() => _quality = value),
              ),
            ],
            const SizedBox(height: 8),
            const Text('위치정보와 촬영 메타데이터는 항상 제거됩니다.'),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('createExportButton'),
              onPressed: () => Navigator.pop(
                context,
                _ExportOptions(
                  format: _format,
                  maxDimension: _maxDimension,
                  quality: _quality.round(),
                ),
              ),
              child: const Text('파일 만들기'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ExportSheet extends StatelessWidget {
  const _ExportSheet({
    required this.options,
    required this.onSave,
    required this.onShare,
  });
  final _ExportOptions options;
  final Future<void> Function() onSave;
  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('사진을 준비했어요', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            '${options.sizeLabel} · '
            '${options.format == PhotoOutputFormat.png ? 'PNG' : 'JPEG'}'
            '${options.format == PhotoOutputFormat.jpeg ? ' 품질 ${options.quality}' : ''} · '
            '위치정보 제거',
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.download),
            label: const Text('사진첩에 저장'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.ios_share),
            label: const Text('다른 앱으로 공유'),
          ),
        ],
      ),
    ),
  );
}
