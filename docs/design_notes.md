# FrameFit Design Notes

This note is retained as a short history pointer. The current design source of truth is `docs/DESIGN_GUIDE.md`.

## Current Direction

- Mostly light editorial/photo-app UI.
- Thin dividers, restrained typography, compact controls.
- Image-first home, template, preview, and result screens.
- Dark color is limited to the camera preview context.
- Shared tokens live in `lib/core/theme/app_theme.dart`.

## Current Boundary

Real camera frames, real photo assets, AI generation, and image editing are intentionally deferred. The app currently uses generated Flutter mock photo surfaces and static guidance data.
