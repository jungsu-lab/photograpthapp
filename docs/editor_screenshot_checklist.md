# Camera, Template, And Preview Screenshot Checklist

Use this checklist to review generated screenshots for the reference-based editor screens.

## CameraScreen

- Camera/editor image surface dominates the screen.
- Top controls are minimal and monochrome.
- Composition grid and subject guide are visible but decorative.
- Mode rail is compact.
- Capture/tool dock is tappable and not blocked by the overlay.
- The screen does not read as neon or dashboard UI.

## TemplateScreen

- Screen reads as a curated preset browser.
- `PRESET STORE` header and category state are visible.
- Category tabs use thin dividers.
- Preset cards are thumbnail-led and lazy-list based.
- No giant empty placeholder areas.
- No dark neon styling.

## PreviewScreen

- Original/preview comparison is visible before the option list.
- Template rationale is compact and secondary.
- `편집 방향` section clearly contains three selectable edit directions.
- Selected option is communicated with a thin outline/check state.
- Apply CTA is compact black.

## Automated Screenshot Files

Generated at a 390x844 logical viewport through Flutter golden capture:

- `docs/generated_screenshots/camera.png`
- `docs/generated_screenshots/templates.png`
- `docs/generated_screenshots/preview.png`

Review the generated PNGs against this checklist for visual acceptance.
