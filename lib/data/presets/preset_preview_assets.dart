import '../../domain/models/photo_preset.dart';

/// The sample is rendered offline with the same [PhotoProcessor] used in the
/// editor. It is deliberately stored per preset instead of recolouring one
/// generic card at runtime.
String presetPreviewAsset(PhotoPreset preset) => preset.thumbnailAsset;

/// Monochrome conversion is already part of the rendered asset. Applying a
/// widget-level filter here would make the library disagree with the editor.
bool isMonochromePreview(PhotoPreset preset) => false;
