# FrameFit Reference Audit

## Reference Set

Source folder: `/home/jungsu/projects/framefit/design-reference`

| File | Reference Focus | Useful FrameFit Layer |
| --- | --- | --- |
| `CONTACT_SHEET_01.jpg` | App-store storytelling, phone preview panels, profile/feed previews | onboarding demo frames, camera/editor storytelling |
| `CONTACT_SHEET_02.jpg` | White profile/feed grids, studio import grid, bottom editing toolbar | home gallery, bottom nav, editor controls |
| `CONTACT_SHEET_03.jpg` | Studio tools, white canvas, selected image outlines, preset lists | preview options, template cards, analysis summary |
| `CONTACT_SHEET_04.jpg` | White profile headers, vivid image grids, red avatar accent | home identity, restrained accent use, photo grids |
| `CONTACT_SHEET_05.jpg` | Membership/detail/gallery surfaces, black preset/tool actions | preset hierarchy, compact action affordance |

## Extracted Visual System

### Palette

- Page background: off-white `#FAFAF8`.
- Default surface: white `#FFFFFF`.
- Secondary surface: warm light gray `#F4F4F2`.
- Pressed/track surface: `#EDEDEA`.
- Photo placeholder: `#ECECEA`.
- Primary text/action: near black `#111111`.
- Secondary text: `#666666`.
- Muted metadata: `#A0A0A0`.
- Divider: `#E7E7E4`.
- Strong divider: `#D4D4D0`.
- Restrained profile accent: red `#C9151B`.
- Score warnings use warm tan; low scores use muted red-brown.

Rules:

- Mint is not a primary CTA or brand token.
- Neon/glow styling is not part of the reusable system.
- The global app shell is light. Dark color is allowed only inside camera/photo preview content where it represents the captured image surface.
- Color should mostly come from photo and preset content, not app chrome.

### Typography

- Clean compact sans-serif.
- Main page title: 25 px, strong but not hero-scale.
- Section title: 18 px.
- Card/title text: 16 px.
- Body text: 13-15 px.
- Metadata: 11-12 px gray.
- Button label: 14 px semibold.
- Letter spacing stays `0`.

### Components

- Buttons are compact black or bordered white, not glowing.
- Cards are white, thin-bordered, and use small radii.
- Selection is shown with a thin black outline and optional check icon.
- Bottom navigation is icon-led, compact, and divided by a 1 px top line.
- Tabs are text labels with a thin underline.
- Photo tiles are the visual anchor; app surfaces stay quiet.
- Camera/editor overlays use thin white guides only inside the preview canvas.

### Metrics

- Outer page padding: 20 px.
- Grid gap: 8 px.
- Thumbnail radius: 8 px.
- Panel radius: 10 px.
- Button radius: 8 px.
- Button height: 46 px.
- Divider/border width: 1 px.
- Selected outline: 1.4 px.

## Screen Mapping For This Goal

This goal updates the global theme and reusable components only. It does not rebuild every screen.

| Screen Area | Reference Direction Applied Through Shared System |
| --- | --- |
| Onboarding | Light editorial shell, phone-like preview component, black CTA. |
| Home | Compact top identity, quiet action tiles, thin bottom nav, photo grid emphasis. |
| Camera | Dark preview canvas remains content-specific; shared tokens keep controls compact and monochrome. |
| Analysis | White summary surfaces, thin progress lines, black CTA. |
| Templates | Thumbnail-led preset cards, small labels, thin card borders. |
| Preview | Image-first comparison, thin selected outline, compact apply CTA. |
| Result | Final image first, minimal metadata surfaces, bordered secondary actions. |

## Old Direction Removed From Core System

- No reusable `mint` token.
- No reusable dark theme getter.
- No compatibility aliases for old dark/neon token names.
- No dark global scaffold background.
- No giant rounded dark reusable cards.
- No glowing CTA or glow selection state.

## OnboardingScreen Mapping

Updated file: `lib/features/onboarding/onboarding_screen.dart`

Reference sources:

- `CONTACT_SHEET_01.jpg`: app-store product storytelling, phone/editor preview panels.
- `CONTACT_SHEET_02.jpg`: thin app chrome and studio preview framing.
- `CONTACT_SHEET_03.jpg`: editor canvas with selected outlines and compact controls.

Applied mapping:

- Thin top bar with brand dot and `PHOTO GUIDE` label replaces the previous large decorative shell.
- The story visual is a filled editorial preview frame with top/bottom hairline dividers, not a giant empty hero rectangle.
- Page 1 uses an image-like composition preview with camera grid and guide text.
- Page 2 uses a compact preset gallery grid so the frame is content-led.
- Page 3 uses original/preview comparison plus a selected option card.
- Pagination is a thin progress rule, matching the reference's quiet editorial controls.
- CTA remains a compact black primary button and keeps `onboardingPrimaryCta`.

Acceptance notes:

- No mint CTA.
- No dark global background.
- No giant empty hero rectangle.
- Korean onboarding copy and final route to Home are preserved.

## HomeScreen Mapping

Updated file: `lib/features/home/home_screen.dart`

Reference sources:

- `CONTACT_SHEET_02.jpg`: white profile/feed grids and compact bottom editing toolbar.
- `CONTACT_SHEET_04.jpg`: restrained profile identity, red accent dot, vivid image grid.
- `CONTACT_SHEET_05.jpg`: gallery/detail surfaces and compact black preset/tool actions.

Applied mapping:

- Thin top bar with small red identity dot and `STUDIO` label replaces dashboard-style header chrome.
- First viewport is editorial/gallery-led: asymmetric photo composition, compact guide row, then black/outlined CTAs.
- Home primary CTA remains `homePrimaryCta` and routes to Camera.
- Home secondary CTA remains `homeSecondaryCta` and routes to Templates.
- Coach section uses quiet labels and thin dividers, not a heavy dashboard card.
- Recommended templates stay thumbnail-led in a horizontal rail with `homeTemplateRail`.
- Recent work remains a gallery grid lower on the page.
- Bottom navigation remains compact and icon-led with existing route behavior.

Acceptance notes:

- No dark dashboard surface is introduced.
- No mint primary action.
- No large dark rounded cards.
- Existing navigation and template data are unchanged.

## CameraScreen Mapping

Updated file: `lib/features/camera/camera_screen.dart`

Reference sources:

- `CONTACT_SHEET_02.jpg`: compact camera/editor toolbar language and bottom control rows.
- `CONTACT_SHEET_03.jpg`: studio/editor canvas, selected guides, quiet monochrome tools.
- `CONTACT_SHEET_05.jpg`: small action affordances and restrained editor chrome.

Applied mapping:

- The camera preview is the primary surface and is keyed as `cameraEditorSurface`.
- Top chrome is minimal: close control, current mode, and `LIVE COMPOSITION` editor label.
- Composition grid, subject guide, and movement hint remain decorative through `CameraGuideOverlay`'s `IgnorePointer`.
- Mode selection is a compact rail keyed as `cameraModeRail`; it does not disable lazy rendering.
- Capture/gallery/template controls sit in a compact tool dock keyed as `cameraToolDock`.
- Capture keeps `captureButton` and routes to Analysis.

Acceptance notes:

- Dark is limited to the camera preview context, not a neon dashboard.
- Overlay does not block taps.
- Existing Korean guide copy and route names are preserved.

## TemplateScreen Mapping

Updated file: `lib/features/templates/template_screen.dart`

Reference sources:

- `CONTACT_SHEET_03.jpg`: preset/library lists, selected outlines, compact tabs.
- `CONTACT_SHEET_05.jpg`: membership/preset browser hierarchy and black action language.
- `CONTACT_SHEET_02.jpg`: white studio import grid and thin dividers.

Applied mapping:

- The screen keeps a light app shell and uses `MinimalTopBar`.
- A curated store header keyed as `templateCuratedHeader` establishes preset-browser context.
- Category tabs are wrapped in thin dividers and keyed as `templateCategoryTabs`.
- Presets remain lazy-built in a `ListView.separated` keyed as `templatePresetList`.
- Recommended and regular preset cards keep unique keys such as `recommendedTemplateCard-<template-id>` and `templateCard-<template-id>`.
- Category filtering still uses `TemplateRepository.byCategory` and preserves mock data.

Acceptance notes:

- No dark neon surfaces.
- No giant empty placeholders.
- Lazy rendering stays enabled.

## PreviewScreen Mapping

Updated file: `lib/features/preview/preview_screen.dart`

Reference sources:

- `CONTACT_SHEET_03.jpg`: before/after editor comparison and selected option outlines.
- `CONTACT_SHEET_05.jpg`: compact preset details and clear action hierarchy.

Applied mapping:

- The original/preview comparison area is keyed as `previewComparisonStage`.
- Template rationale remains directly under the comparison as compact preset context.
- The three edit directions are grouped under `편집 방향` and keyed as `previewDirectionList`.
- Each option keeps a stable `previewOption-<label>` key and selected state key `selectedPreview-<label>`.
- Apply CTA keeps `previewApplyCta` and routes `ResultArgs(template, previewStyle)` to Result.

Acceptance notes:

- Users can distinguish and select one of three edit directions.
- Selected template and style route correctly to Result.
- Existing Korean copy and mock data are preserved.
