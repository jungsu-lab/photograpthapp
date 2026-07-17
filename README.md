# FrameFit

FrameFit is a local-first Flutter photo editor for people who want a finished
look without learning a complex editor. Choose or capture one photo, apply a
colour preset in one tap, adjust its strength, compare it with the original,
then save or share a new file.

## What works today

- Choose a real JPEG or PNG from the system photo picker. Inputs are capped
  at 40 MB, 10,000 px per side, and 40 megapixels before full pixel decoding.
- Capture a photo with the in-app front or rear camera.
- Start either route directly from onboarding; permissions are requested only
  after the chosen action.
- Apply 15 numeric presets across Basic correction, Japan travel,
  non-infringing anime mood, Camera effects, and Monochrome categories.
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
- Browse 20 capture-composition templates for portraits, space, mood, and
  food/product shots. Four quick Shot Packs connect a composition template to
  a suggested edit preset.
- Use selected templates to prefer the matching front/rear/ultra-wide camera,
  apply a real flash setting when available, and display the corresponding
  camera overlay. Level and top-down templates use on-device accelerometer
  input only while the camera is open.

## Intentional MVP limits

- The editor performs global colour adjustments only. It does not provide
  face-aware retouching, object detection, selective masks, perspective
  correction, RAW editing, batch editing, cloud sync, analytics, or AI image
  generation.
- Camera coaching provides visual overlays, device-level feedback, and camera
  settings only. It does not claim to detect faces, objects, scene quality, or
  calculate a composition score.
- On Android 9 and later, the system picker can convert a selected HEIC image
  to JPEG for FrameFit. If a device returns unconverted HEIC bytes, FrameFit
  safely asks for JPEG or PNG instead.

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
- Android photo import uses the system picker and does not request broad photo
  library access on modern Android. Android 9 and lower retain legacy external
  storage compatibility only so a user-requested export can be saved to the
  gallery; Android's manifest merger implies the paired legacy read permission
  for those old OS versions.
- Do not commit real photos, `.env` files, signing keys, certificates, or
  service-account files.

The contributor-facing [security and privacy checklist](docs/SECURITY.md)
records the rules for future work and release handling.

## Run and verify

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

For Android, use JDK 17 or later and enable Windows Developer Mode when the
Flutter tooling requests plugin symlink support. The in-app camera supports
Android 7.0 (API 24) or later. On Windows accounts with a non-ASCII user path,
native Android builds may also require an ASCII-only temporary checkout and
`PUB_CACHE` path; Flutter tests also need an ASCII temporary directory. This
is a local build-environment workaround, not an app runtime requirement. For
example, run the commands from an ASCII-only checkout such as
`C:\\framefit-build`:

```powershell
$env:PUB_CACHE = 'C:\\flutter-pub-cache'
$env:TEMP = 'C:\\flutter-temp'
$env:TMP = 'C:\\flutter-temp'
flutter analyze
flutter test --exclude-tags golden --concurrency=1
flutter test --tags golden --concurrency=1
```

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
The matching iPhone build and device checks are in
[docs/IOS_TEST_CHECKLIST.md](docs/IOS_TEST_CHECKLIST.md).
The distinction between implemented and directly verified MVP work is tracked
in [docs/MVP_STATUS.md](docs/MVP_STATUS.md).

## Project layout

```text
lib/
  data/presets/       Built-in numeric preset catalogue
  data/composition/   Capture-template and Shot Pack catalogue
  domain/models/      Photo, preset, and edit-setting data models
  features/           Onboarding, Home, preset library, shooting, camera, and editor screens
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

The complete numeric ranges, intensity contract, and safe preset-authoring
rules are in [docs/PRESET_SCHEMA.md](docs/PRESET_SCHEMA.md).
