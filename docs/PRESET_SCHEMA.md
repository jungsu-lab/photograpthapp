# FrameFit preset schema

This is the current runtime schema for built-in and future local presets. It
matches `PhotoPreset` and `PresetRecipe` in
`lib/domain/models/photo_preset.dart`; the older mock-template document does
not apply to the editor.

## `PhotoPreset`

```text
id: String                       # stable, unique, kebab-case identifier
name: String                     # user-facing preset name
description: String              # concise expectation-setting copy
category: PresetCategory         # correction | portraitTone | japanTravel |
                                # animeMood | filmTone | cameraEffect |
                                # monochrome
recipe: PresetRecipe             # numeric colour recipe below
swatch: int                      # ARGB UI fallback colour
defaultIntensity: double         # 0.0 to 1.0
version: int                     # increment for a changed recipe contract
recommendedSubjects: List<String>
```

`PhotoPreset` and `PresetRecipe` support JSON round trips. Parsing clamps
numeric recipe values to the ranges below so malformed local data cannot
produce invalid channel math.

## `PresetRecipe` ranges

| Field | Range | Meaning |
| --- | --- | --- |
| `exposureEv` | -2.0 to 2.0 | exposure stops |
| `contrast` | -1.0 to 1.0 | contrast adjustment |
| `highlights`, `shadows` | -1.0 to 1.0 | bright/dark tonal recovery |
| `whites`, `blacks` | -1.0 to 1.0 | outer tonal point adjustment |
| `saturation`, `vibrance` | -1.0 to 1.0 | global and lower-saturation colour strength |
| `temperature`, `tint` | -1.0 to 1.0 | warm/cool and green/magenta balance |
| `fade`, `vignette`, `grain`, `sharpness` | 0.0 to 1.0 | non-negative finishing effects |

## Intensity and manual editing

Preset intensity is a factor from `0.0` to `1.0`. Each recipe value is scaled
before any manual adjustment is merged:

```text
effectiveRecipe = clamp((preset.recipe × intensity) + manualAdjustments)
```

At intensity `0`, a preset contributes the identity recipe. At `1`, the whole
recipe applies. Manual adjustments are stored as the same numeric recipe and
are clamped again on merge. This makes a saved edit reproducible and keeps
every pixel channel inside its valid range.

## Rendering contract

The same local processor renders preview and export. Preview downsizes only
for speed; export starts from the source resolution. The fixed order is:

1. Decode and bake EXIF orientation.
2. Apply a centred crop when selected, then resize the preview/export proxy.
3. Exposure, temperature/tint, highlight/shadow recovery, white/black points,
   and contrast.
4. Saturation and vibrance.
5. Fade, vignette, deterministic grain, and sharpness.
6. Clamp channels and encode JPEG or PNG.

Grain is coordinate-deterministic, so the same source and settings yield the
same result. JPEG export removes EXIF/XMP/IPTC/comment metadata; PNG output
retains transparency when the source and chosen output format are PNG.

## Adding a preset safely

1. Give the preset a new stable `id` and keep its `version` at `1`.
2. Start with a restrained default intensity (normally `0.55` to `0.75`).
3. Compare results on licensed fixture photos across bright, dark, portrait,
   food, travel, and high-saturation scenes. Do not add real user photos to
   the repository.
4. Verify the catalogue tests, JSON round trip, intensity-zero identity, and
   deterministic processor tests before publishing the change.
5. Update the display thumbnail through the same processor rather than using
   a different visual effect.
