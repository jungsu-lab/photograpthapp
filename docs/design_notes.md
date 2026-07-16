# FrameFit Design Notes

> **Archived mock-prototype notes.** The current app is a local-first photo
> editor with real camera/gallery input and rendering. Use `README.md`,
> `docs/MVP_STATUS.md`, and the current source under `lib/` rather than the
> historical statements below.

## Current Direction

- Mostly light editorial/photo-app UI.
- Thin dividers, restrained typography, compact controls.
- Image-first home, template, preview, and result screens.
- Dark color is limited to the camera preview context.
- Shared tokens live in `lib/core/theme/app_theme.dart`.

## Current Boundary

Real camera frames, real photo assets, AI generation, and image editing are intentionally deferred. The app currently uses generated Flutter mock photo surfaces and static guidance data.
