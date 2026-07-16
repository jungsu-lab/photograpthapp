import '../../domain/models/photo_preset.dart';

/// Real example imagery for the preset library. These are app-owned generated
/// fixtures, never user photos, and keep the library photo-first before a
/// user selects an image of their own.
String presetPreviewAsset(PhotoPreset preset) {
  if (preset.id == 'clear-detail') {
    return 'assets/images/preset-product-preview.webp';
  }
  return switch (preset.category) {
    PresetCategory.correction => 'assets/images/preset-portrait-preview.webp',
    PresetCategory.japanTravel => 'assets/images/japan_travel_preview.webp',
    PresetCategory.animeMood => 'assets/images/japan_travel_preview.webp',
    PresetCategory.cameraEffect => 'assets/images/preset-food-preview.webp',
    PresetCategory.monochrome => 'assets/images/preset-portrait-preview.webp',
  };
}

bool isMonochromePreview(PhotoPreset preset) =>
    preset.category == PresetCategory.monochrome;
