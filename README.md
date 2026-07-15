# FrameFit

FrameFit is a local-first Flutter photo editor for people who want a finished
look without learning a complex editor. Choose or capture one photo, apply a
colour preset in one tap, adjust its strength, compare it with the original,
then save or share a new file.

## What works today

- Choose a real JPEG or PNG from the system photo picker.
- Capture a photo with the in-app front or rear camera.
- Apply 12 numeric presets across Basic correction, Japan travel, Camera
  effects, and Monochrome categories.
- Use a 0–100 preset strength slider; values are interpolated from the
  original settings and strength 0 is visually unchanged.
- Make local exposure, contrast, highlights, shadows, saturation, vibrance,
  temperature, tint, sharpness, vignette, fade, and grain adjustments.
- Zoom the image and press-and-hold to compare the unmodified original.
- Use fixed centred crops: original, 1:1, 4:5, and 16:9.
- Export from the original resolution as JPEG, or preserve PNG output and
  transparency for PNG input; save to the FrameFit album or open the system
  share sheet.
- Keep favourites and recent preset use on-device. No account is required.

## Intentional MVP limits

- The editor performs global colour adjustments only. It does not provide
  face-aware retouching, object detection, selective masks, perspective
  correction, RAW editing, batch editing, cloud sync, analytics, or AI image
  generation.
- Camera guidance is a simple rule-based overlay, not real-time composition
  analysis or a composition score.
- HEIC is not currently accepted by the local processor. Convert it to JPEG or
  PNG before editing.

## Privacy and security

- Editing and rendering occur on the device. FrameFit does not upload photos,
  image paths, metadata, or edit settings to a server.
- A new export never copies JPEG EXIF/XMP/IPTC/comment metadata; this removes
  GPS location data by default. The original file is never modified.
- Temporary export files are removed after saving, sharing, or dismissing the
  export sheet.
- Photo and camera access is requested only after the user chooses that
  action. If camera access was permanently denied, the app offers a direct
  link to the application settings page.
- Do not commit real photos, `.env` files, signing keys, certificates, or
  service-account files.

## Run and verify

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

For Android, use JDK 17 or later and enable Windows Developer Mode when the
Flutter tooling requests plugin symlink support. The in-app camera supports
Android 7.0 (API 24) or later.

To make a small Android release APK for each CPU type:

```bash
flutter build apk --release --split-per-abi
```

The current Android `release` build is signed with Flutter's debug key for
device testing only. Configure a private production keystore outside the
repository before Play Store or public distribution.

Install `app-arm64-v8a-release.apk` on current Galaxy and most recent Android
phones. The checked real-device flow and remaining checks are recorded in
[docs/DEVICE_TEST_CHECKLIST.md](docs/DEVICE_TEST_CHECKLIST.md).
The distinction between implemented and directly verified MVP work is tracked
in [docs/MVP_STATUS.md](docs/MVP_STATUS.md).

## Project layout

```text
lib/
  data/presets/       Built-in numeric preset catalogue
  domain/models/      Photo, preset, and edit-setting data models
  features/           Onboarding, Home, library, camera, and editor screens
  services/           Input, processing, export, preferences, and settings
  core/               Routing, theme, and shared UI
test/                 Preset, processor, and UI-flow tests
docs/                 Device-test record and product documentation
```

## Preset processing

Recipes have bounded numeric values and use a fixed rendering order: orientation
normalisation, exposure, white balance/temperature/tint, tonal adjustments,
colour, fade, vignette, deterministic grain, sharpness, clamping, and
encoding. Preview uses a reduced proxy; export renders again from the original
resolution. See [lib/domain/models/photo_preset.dart](lib/domain/models/photo_preset.dart)
and [lib/services/photo_processor.dart](lib/services/photo_processor.dart).
