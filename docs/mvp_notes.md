# FrameFit MVP Notes

This note describes the current mocked Flutter flow. The Phase 0 source-of-truth docs are `README.md`, `docs/FEATURE_SPEC.md`, `docs/DESIGN_GUIDE.md`, and `docs/TEMPLATE_SCHEMA.md`.

## Implemented Screens

- Onboarding: three-page product story with light editorial background, phone-like visual demos, working pagination, and final `시작하기` route to Home.
- Home: compact photo-app hub with profile/feed-style top area, small action tiles, shooting coach section, curated template preview, recent project photo grid, and thin bottom navigation.
- Camera: near-full camera mock preview with subtle composition grid, subject frame, compact guide panel, mode tabs, score, template hint, gallery/capture/template controls, and tap-safe overlay.
- Analysis: quiet editor summary with captured photo preview, Korean metric rows, thin progress lines, recommendation reason, and black CTA to templates.
- Template: curated preset browser with thin category tabs, `이 사진에 추천` block, thumbnail-led preset cards, ratings, usage count, beginner score, tags, and recommendation reason.
- Preview: image-first comparison flow with original/preview tiles, selected template summary, three selectable preview options, and CTA to Result.
- Result: final image-first screen with applied template, selected preview style, save/share/mock actions, `다른 템플릿 적용`, compare, and feedback chips.

## Mocked Features

- Camera feed is a photo-like mock surface, not device camera hardware.
- Capture routes to static analysis data.
- Analysis scores are local mock values.
- Template recommendations use local mock template data.
- Preview and result images are tonal mock tiles.
- Save/share/compare buttons are present but mocked.

## Real Camera TODO

- Add `camera` or platform camera integration.
- Add camera permission handling.
- Add gallery picker and imported image path handling.
- Persist captured/imported image through the edit flow.

## Real ML Analysis TODO

- Add composition, face/object, blur, brightness, and background complexity analysis.
- Replace static score rows with actual image-derived metrics.

## AI Editing API TODO

- Add server-side AI preview generation.
- Add final high-resolution export API.
- Keep API keys on a backend/proxy, not in the mobile app.

## Save/Share TODO

- Save final output to gallery/files.
- Open platform share sheet with exported image.
- Implement original/result comparison.

## How To Run

```bash
cd /home/jungsu/photograpthapp
flutter pub get
flutter run
```

For web preview:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081
```

Then open `http://localhost:8081`.

## Known Limitations

- The app is still a Flutter MVP with mocked camera, analysis, editing, save, and share.
- The visual direction has moved to light editorial/photo-app style, but uses generated tonal mock tiles instead of real production photo assets.
- WSL2 does not expose a browser screenshot target in this environment; screenshot instructions are in `docs/screenshots.md`.
