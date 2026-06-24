# FrameFit Goal V2

## Mission

Rework the current Flutter app into a premium dark mobile MVP for FrameFit.

FrameFit is not a generic photo app. It is a beginner-friendly AI camera coach and photo editor.

Core product flow:

1. User chooses a shooting purpose.
2. App shows camera guidance before taking the photo.
3. App analyzes the photo after capture.
4. App recommends trustworthy AI-style editing templates.
5. User previews multiple edit drafts before final apply.
6. User sees a finished result screen.

The app must feel like:
- premium
- dark
- camera-first
- beginner-friendly
- template-driven
- polished enough for a product demo

## Critical Problem To Fix

The previous implementation was too shallow.

Do not merely create placeholder pages.
Do not merely create generic cards.
Do not mark the task complete just because screens exist.

The goal is to make the app visually and structurally close to the provided design reference images.

## Required Design Reference Folder

There is a local folder containing design reference images.

Search for the folder in this order:

1. ./design-reference/
2. ./design/
3. ./designs/
4. ./reference/
5. ./references/
6. ./assets/design-reference/
7. ./assets/reference/
8. ./assets/images/reference/

The folder must contain image files such as:
- png
- jpg
- jpeg
- webp

## Hard Rule: Design Reference Must Be Audited First

Before editing UI code, inspect the design reference folder.

Create:

docs/reference_audit.md

This file must include:

1. Exact folder path found.
2. List of every reference image file.
3. Visual notes for each image:
   - dominant colors
   - layout style
   - card shape
   - border radius feeling
   - button style
   - typography feeling
   - spacing density
   - icon style
   - special UI patterns
4. Extracted design decisions:
   - app background color
   - surface/card colors
   - primary accent color
   - secondary accent color
   - border color
   - text hierarchy
   - card radius
   - button radius
   - navigation style
5. A section named:
   "How the Flutter UI uses these references"

If the folder is missing or empty, stop implementation and report the issue.
Do not continue with generic UI.

## Figma Requirement

If a Figma tool, Figma MCP, or Figma integration is available, use it.

Try to create or update a Figma file/page named:

FrameFit MVP

The Figma work should include:
- color tokens
- typography tokens
- button component
- card component
- camera overlay component
- home screen concept
- camera screen concept
- template screen concept

If Figma is not available, do not fake it.
Write this clearly in docs/reference_audit.md:

"Figma integration was not available in this environment."

Then continue using the local design reference images.

## UI Quality Bar

The UI must not look like default Flutter.

Required visual qualities:
- premium dark theme
- deep layered background
- large rounded cards
- clean Korean typography
- soft but visible borders
- camera-like overlay elements
- glowing or highlighted primary CTA
- polished bottom navigation or tab structure
- template cards with real hierarchy
- visual rhythm based on the reference images

Avoid:
- default blue Flutter widgets
- plain white backgrounds
- boring rectangular cards
- tiny cramped UI
- too many placeholder boxes
- all content stuffed into one screen
- messy main.dart code

## Required Screens

### 1. OnboardingScreen

Three polished onboarding pages.

Page 1:
Title: 사진 찍기 전에 알려드릴게요
Body: 구도, 조명, 거리, 초점을 실시간으로 안내해요.

Page 2:
Title: 템플릿만 고르면 끝
Body: 어려운 프롬프트 없이 원하는 분위기를 고르면 돼요.

Page 3:
Title: 적용 전 시안을 먼저 확인
Body: 결과를 먼저 보고 마음에 드는 방향만 고화질로 완성해요.

Requirements:
- visually premium
- use reference-inspired background
- include progress indicator
- include CTA button
- route to HomeScreen

### 2. HomeScreen

Home must clearly communicate the product.

Required sections:
- top greeting area
- large primary CTA card: 사진 찍기
- secondary CTA: 사진 편집하기
- camera coach summary card
- recommended templates preview
- recent projects placeholder
- bottom navigation or clean tab layout

Required Korean copy:
- 오늘 사진, 찍기 전에 먼저 맞춰볼까요?
- 사진 찍기
- 사진 편집하기
- 추천 템플릿
- 최근 작업

### 3. CameraScreen

This is the most important screen.

It must look like a camera coach, not a normal blank page.

Required elements:
- camera preview area or high-quality mock camera surface
- rule-of-thirds grid
- center guide
- subject frame box
- directional arrow or movement hint
- shooting score card
- mode selector
- capture button
- gallery button
- guide message panel

Modes:
- 프로필
- 셀카
- 음식
- 여행
- 상품
- 감성

Mode switching must change:
- guide message
- score details
- recommended template hint

Example guide messages:
- 조금 뒤로 가면 얼굴 비율이 자연스러워요
- 빛은 좋아요. 얼굴을 살짝 오른쪽으로 옮겨보세요
- 지금 구도 좋아요. 촬영해도 됩니다
- 배경이 조금 복잡해요. 오른쪽으로 한 걸음 이동해보세요

Capture button routes to AnalysisScreen.

If real camera integration is not already working, create a polished mock camera surface, but it must visually look like an actual app demo.

### 4. AnalysisScreen

Show:
- image preview or mock photo card
- title: 사진 분석 완료
- score cards:
  - 초점
  - 구도
  - 조명
  - 배경
  - 안정감
- recommendation summary
- recommended template chips
- CTA: 추천 템플릿 보기

Example recommendation:
배경이 살짝 복잡해서 배경 흐림 템플릿을 추천해요.

### 5. TemplateScreen

Show at least 20 templates from mock data.

Categories:
- 프로필
- 셀카
- 음식
- 여행
- 상품
- 감성

Each template card must show:
- name
- category
- description
- rating
- usage count
- beginner-friendly score
- tags
- recommendation reason

The cards must look premium and reference-inspired.

Filtering by category must work.

Selecting a template routes to PreviewScreen.

### 6. PreviewScreen

Show:
- original photo area
- selected template info
- three preview options:
  - 자연스럽게
  - 밝게
  - 무드있게
- each preview option must explain changes
- selected option must be visually obvious
- CTA: 고화질로 적용하기

Routes to ResultScreen.

### 7. ResultScreen

Show:
- final edited mock image area
- selected template
- selected preview style
- buttons:
  - 저장하기
  - 공유하기
  - 다른 템플릿 적용
  - 원본과 비교
- review prompt:
  결과가 마음에 드나요?
  좋아요 / 보통 / 별로

## Required Mock Template Data

Create at least 20 templates.

Required fields:
- id
- name
- category
- description
- tags
- rating
- usageCount
- beginnerFriendlyScore
- recommendationReason
- editRecipe

Template names:

1. 깔끔한 프로필
2. 소개팅 프로필
3. 전문적인 프로필
4. 배경 흐림 인물
5. 자연 셀카
6. 인스타 셀카
7. 밝은 셀카
8. 따뜻한 실내
9. 필름 여행
10. 푸른 하늘 여행
11. 노을 감성
12. 도시 시네마틱
13. 맛있어 보이는 음식
14. 카페 디저트
15. 한식 색감 보정
16. 흰 배경 상품컷
17. 중고거래 깔끔컷
18. 액세서리 상세컷
19. 시네마틱 무드
20. 빈티지 필름

## Required Architecture

Use clean Flutter structure.

Preferred structure:

lib/
  main.dart
  app.dart
  core/
    theme/
    router/
    widgets/
    constants/
  features/
    onboarding/
    home/
    camera/
    analysis/
    templates/
    preview/
    result/
  data/
    models/
    mock/
    repositories/

Do not put all UI in main.dart.

Create reusable widgets:
- AppScaffold
- PrimaryButton
- SecondaryButton
- GlassCard or PremiumCard
- TemplateCard
- ScoreCard
- CameraGuideOverlay
- ModeSelector
- PreviewOptionCard

## Required Documentation

Update or create:

docs/mvp_notes.md

Must include:
- implemented screens
- mocked features
- real camera TODO
- ML analysis TODO
- AI editing API TODO
- save/share TODO
- how to run
- known limitations

Update or create:

docs/reference_audit.md

Must include the reference image audit described above.

## Validation

Run:

flutter pub get
flutter analyze
flutter test

If no tests exist, add minimal tests for:
- mock template data has at least 20 items
- category filtering works
- template model fields are valid

## Screenshot Requirement

After implementation, attempt to run the app or build web/desktop preview if possible and capture screenshots.

Create:

docs/screenshots.md

Include:
- how screenshots were generated
- list of available screenshots
- if screenshots could not be generated, explain why

If possible, save screenshots under:

docs/screenshots/

Required target screenshots:
- home screen
- camera screen
- template screen
- preview screen

## Completion Criteria

Do not mark this goal complete until all are true:

1. Design reference folder was found and audited.
2. docs/reference_audit.md exists and contains per-image notes.
3. UI design tokens were updated based on the reference audit.
4. App is not generic default Flutter UI.
5. All required screens exist.
6. All screens are reachable.
7. Camera screen has a visible guide overlay.
8. Mode switching changes the guidance.
9. Template screen shows at least 20 templates.
10. Category filtering works.
11. Preview option selection works.
12. Result screen displays selected template and preview style.
13. Code is organized into reusable widgets.
14. flutter analyze runs with no critical errors.
15. flutter test runs, or limitations are documented.
16. docs/mvp_notes.md exists.
17. docs/screenshots.md exists.
18. Any unavailable capability is documented instead of silently ignored.

## Important Behavior

Do not finish in under 20 minutes unless all validation, docs, and screenshots are genuinely complete.

When uncertain, inspect files before changing them.

Prefer fewer polished screens over many shallow screens, but all required navigation must exist.
