# FrameFit

FrameFit is a Flutter prototype for a beginner-friendly photo coaching app. The product goal is to help users choose a photo style, receive composition guidance while shooting, preview template-based edits, and save a finished result.

The current app is not a real camera or AI editing product yet. It is a product-definition and UI-flow prototype that demonstrates the intended screens with local mock data and simulated visuals.

## User Problem

Many users know the kind of photo they want, but not the composition, distance, lighting, background, or crop choices needed to get it. Traditional editing apps help after the photo is taken; FrameFit is meant to guide the shot before capture and then provide a simple template-based preview flow afterward.

## MVP Scope

The roadmap MVP focuses on validating whether a shooting coach is useful:

- Onboarding that explains the photo-coach value.
- Home screen that routes quickly to shooting or template selection.
- Template library for common use cases such as profile, selfie, food, travel, product, and mood photos.
- Camera coach UI with composition overlay and short guidance.
- Post-capture analysis summary.
- Preview and result screens for template-based edit directions.

Deferred from the MVP: social feeds, accounts, paid subscriptions, complex editors, video coaching, cloud processing, and fully automatic generative retouching.

## Current Status

This repository has completed roadmap Phases 0-3 for product definition, template data, and the Home/Template browsing flow, with a mocked UI prototype for:

- `OnboardingScreen`
- `HomeScreen`
- `TemplateScreen`
- `CameraScreen`
- `AnalysisScreen`
- `PreviewScreen`
- `ResultScreen`

Implemented today:

- Flutter app shell, routing, light editorial theme, shared UI widgets, and local mock template data.
- A Home screen that introduces FrameFit, highlights recommended templates, and links into template browsing.
- A Template Library with category filtering, data-driven sample visuals, and template cards.
- A Template Detail screen with larger previews, descriptions, capture tips, composition guidance, and a start action into the mock camera flow.
- A simulated camera surface with static composition guidance by mode.
- Static analysis scores and recommendation copy.
- Mock preview/result images using generated tonal placeholder widgets.

Not implemented yet:

- Device camera integration, camera permissions, gallery import, or captured image persistence.
- Real face/person/object detection.
- Real composition, brightness, background, blur, or focus analysis.
- Actual template rendering, AI editing, high-resolution export, gallery save, or platform share.
- User accounts, analytics, backend services, or remote configuration.

## Run The App

From the repository root:

```bash
cd /home/jungsu/photograpthapp
flutter pub get
flutter run
```

For a web preview:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081
```

Then open `http://localhost:8081`.

Useful checks:

```bash
flutter analyze
flutter test
```

## Folder Structure

```text
lib/
  main.dart                 App entry point.
  app.dart                  MaterialApp, theme, routes, initial screen.
  core/
    router/                 Named route map.
    theme/                  App colors, metrics, and text styles.
    utils/                  Small formatting helpers.
    widgets/                Shared cards, buttons, photo mocks, score UI.
  data/
    mock/                   Local template fixtures.
    models/                 Template and navigation argument models.
    repositories/           Local template repository wrapper.
  features/
    onboarding/             Product intro flow.
    home/                   Main hub.
    templates/              Template browser.
    camera/                 Mock camera coach UI.
    analysis/               Static post-capture analysis UI.
    preview/                Mock before/after and edit direction UI.
    result/                 Mock final result UI.

docs/
  FEATURE_SPEC.md           Phase 0 product and MVP boundaries.
  DESIGN_GUIDE.md           Current design direction and UI rules.
  TEMPLATE_SCHEMA.md        Current and target template data shape.
```

## Documentation

- [ROADMAP.md](ROADMAP.md) defines the long-term product plan and phase sequence.
- [docs/FEATURE_SPEC.md](docs/FEATURE_SPEC.md) summarizes the MVP feature boundaries.
- [docs/DESIGN_GUIDE.md](docs/DESIGN_GUIDE.md) documents the current visual direction.
- [docs/TEMPLATE_SCHEMA.md](docs/TEMPLATE_SCHEMA.md) documents the current mock template model and the planned richer schema.

## Important Boundary

Roadmap Phase 4 and later features are future work. Any current AI, camera, detection, save, share, and editing behavior shown in the UI is mocked unless a later implementation phase explicitly adds the real capability.
