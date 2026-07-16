# FrameFit Feature Spec

> **Archived prototype specification (not current product behavior).**
>
> This file records the earlier mock-only UI concept. The shipped MVP now
> uses real gallery/camera input, local pixel rendering, and gallery/share
> export. See the root `README.md` and `docs/MVP_STATUS.md` for the current,
> evidence-backed feature set. The historical details below must not be used
> to describe the current app.

## Product Definition

FrameFit is a photo coach and template-preview app. A user chooses the kind of photo they want, receives simple guidance for taking it, then previews a template-based result before saving or sharing in a future phase.

## Target User Problem

Users often retake photos because composition issues are only obvious afterward: face position, subject distance, background clutter, lighting, horizon, or crop. FrameFit should reduce trial and error by turning a desired photo style into concrete shooting guidance.

## MVP Experience

1. User sees a short onboarding story.
2. User enters the home screen and chooses either shooting or templates.
3. User selects a template or shooting mode.
4. Camera coach shows an overlay and short guidance.
5. Capture moves to an analysis summary.
6. User chooses a recommended template and preview direction.
7. Result screen shows the selected template/style and mock save/share actions.

## Current Implementation

The current app implements the flow as a Flutter UI prototype:

- Local mock templates in `lib/data/mock/mock_templates.dart`.
- Template categories: `전체`, `프로필`, `셀카`, `음식`, `여행`, `상품`, `감성`.
- Simulated camera modes: `프로필`, `셀카`, `음식`, `여행`, `상품`, `감성`.
- Static analysis metrics and recommendation text.
- Mock image surfaces via Flutter widgets, not photo files.
- Navigation arguments for preview/result template state.

## MVP Feature Boundaries

In scope for the first functional MVP:

- Real camera preview and capture.
- Permission handling and capture error states.
- Template-specific guide overlays.
- Simple rule-based composition feedback.
- Persisting captured/imported image through preview/result.
- Save/share for generated or processed output.

Out of scope for the first functional MVP:

- Social feed, follows, likes, or community features.
- Account system.
- Paid subscriptions.
- Video coaching.
- Fully automatic generative image transformation.
- Cloud-scale processing pipeline.

## Not Implemented Yet

- Real device camera integration.
- Face/person/object detection.
- ML or AI analysis.
- Real image editing or template rendering.
- High-resolution export.
- Gallery save and native share sheet.
- Backend APIs.

Do not describe these as shipped until code exists and is verified.
