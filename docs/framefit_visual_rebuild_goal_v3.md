# FrameFit Visual Rebuild Goal V3

## 0. Mission Summary

This is a strict correction and rebuild task for the Flutter app `FrameFit`.

The current implementation is not acceptable.

The app currently has these critical problems:

1. It visually looks like a generic dark AI tool.
2. It uses a dark neon / mint-glow direction that does not match the provided reference images.
3. It feels like stacked placeholder cards rather than a polished photo app.
4. Buttons and taps are broken or unreliable.
5. The design reference images were documented, but they were not genuinely translated into the UI.
6. The camera screen does not feel like a believable camera coach product.
7. The onboarding screen uses a giant empty rectangle and lacks real visual storytelling.
8. The template screen does not feel like a curated preset/editor experience.
9. The preview and result flow does not feel image-first or product-grade.

Your task is to fix both:

* functional interaction issues
* visual design direction

This is not a small polish pass.
This is a visual correction and interaction recovery pass.

The final result must look much closer to the uploaded reference images.

---

## 1. Product Definition

FrameFit is a beginner-friendly camera coach and photo editing app.

The app helps users:

1. Take better photos before capture.
2. Get real-time composition, lighting, distance, and focus guidance.
3. Analyze the photo after capture.
4. Receive recommended editing templates.
5. Preview multiple edit directions.
6. Apply a final result.

FrameFit should feel like:

* a premium mobile photo app
* a creator tool
* a minimal editorial gallery app
* a refined preset/editor app
* a calm, image-first product

FrameFit should not feel like:

* a futuristic AI dashboard
* a neon SaaS app
* a generic dark Flutter app
* a tech demo
* a plain prototype with cards stacked vertically

---

## 2. Current Visual Direction Is Wrong

The current UI direction is incorrect.

Current wrong direction:

* dark background
* mint glowing buttons
* large rounded black cards
* thick borders
* dashboard-like layout
* generic AI-tool mood
* empty hero rectangles
* oversized CTA cards
* not enough image/content-first layout

This must be replaced.

Correct direction from the references:

* mostly light theme
* white or off-white surfaces
* minimal editorial layout
* VSCO-like photo app mood
* gallery/profile/feed patterns
* creator-tool / editing-tool patterns
* thin icons
* subtle dividers
* restrained typography
* small black controls
* image-first layout
* calm spacing
* clean tab rows
* thin bottom navigation
* selective accent colors only
* content carries the color, not the app chrome

The app should feel closer to a premium photo/editor app than an AI dashboard.

---

## 3. Required Reference Folder

Use this folder as the primary visual source:

`/home/jungsu/projects/framefit/design-reference`

Also support these possible relative locations if needed:

1. `./design-reference/`
2. `./design/`
3. `./designs/`
4. `./reference/`
5. `./references/`
6. `./assets/design-reference/`
7. `./assets/reference/`
8. `./assets/images/reference/`

Reference image types to inspect:

* png
* jpg
* jpeg
* webp

The reference folder contains contact sheets and app screenshots.
These are not decoration.
They are the primary design direction.

---

## 4. Absolute Rule: Do Not Touch UI Before Re-Auditing References

Before editing the UI, inspect the design reference images again.

Create or update:

`docs/reference_audit.md`

This document must include the following sections.

### 4.1 Reference Inventory

List every reference image found.

For each image, include:

* file name
* dimensions if available
* what type of reference it is
* which app/screen family it appears to show
* what parts are useful for FrameFit

### 4.2 Reference Groups

Group the references into these categories:

#### A. Profile / Feed / Gallery References

Use these for:

* HomeScreen
* Recent projects
* Recommended template browsing
* image grids
* profile-like calm top sections
* bottom navigation

Visual patterns to extract:

* white/off-white background
* tiny top icons
* compact profile/info areas
* thin tab row
* gallery grid
* lots of breathing room
* very restrained visual chrome

#### B. Studio / Editing Tool References

Use these for:

* CameraScreen
* PreviewScreen
* ResultScreen
* editing toolbar
* aspect ratio selector
* image action controls
* bottom mini-toolbar

Visual patterns to extract:

* tool-like bottom action bar
* small monochrome icons
* selected state with thin outline
* image/content area as the hero
* minimal controls
* clean white canvas
* no heavy cards

#### C. App Store Preview / Storytelling References

Use these for:

* OnboardingScreen
* feature explanation panels
* product demo storytelling
* preview option presentation

Visual patterns to extract:

* phone-like framed visuals
* tall preview cards
* large image areas
* short strong feature copy
* black/dark panels only when image preview requires it
* not generic empty rectangles

#### D. Membership / Preset / Recommendation References

Use these for:

* TemplateScreen
* template recommendation cards
* preset details
* trust badges
* preview options
* curated template sections

Visual patterns to extract:

* clean section titles
* small labels like premium / tool / preset
* black CTA pills or small buttons
* image thumbnails as anchors
* clear hierarchy between title, description, and action
* curated list feeling

### 4.3 Extracted Visual System

Write a concrete design system based on the references.

Include:

#### Colors

Use a light editorial palette.

Required palette direction:

* App background: off-white or pure white
* Surface: white
* Secondary surface: very pale gray
* Primary text: near black
* Secondary text: medium gray
* Muted text: light gray
* Divider: very light gray
* Border: light gray
* Primary action: black or near black
* Secondary action: white with gray border
* Accent: extremely limited, only where useful
* Optional accent examples from references:

  * red circular profile marker
  * thin rainbow/progress line
  * content-driven photo colors

Do not use mint neon as the main identity.
Do not use glowing CTA buttons.
Do not make the whole app dark.

#### Typography

Extract this direction:

* clean sans-serif
* compact but readable
* strong titles with restrained weight
* small metadata text
* thin labels
* no huge dashboard headings
* no overly playful display typography

Use Korean UI text.
Make text hierarchy calm and refined.

#### Spacing

Extract this direction:

* generous outer margins
* tight but readable section spacing
* image grids with consistent gaps
* small control rows
* bottom navigation compact
* avoid massive vertical empty areas

#### Shapes

Extract this direction:

* minimal radius for image thumbnails
* medium radius for panels only when needed
* no giant pill cards everywhere
* no thick borders
* thin outlines for selection states
* subtle dividers

#### Icons

Extract this direction:

* tiny monochrome icons
* low visual noise
* simple outline style
* icons should not dominate text or image content

### 4.4 Screen To Reference Mapping

Create a table:

| Screen | Reference Group | Specific Visual Patterns Used | What Must Change From Current UI |
| ------ | --------------- | ----------------------------- | -------------------------------- |

Required mappings:

* OnboardingScreen → App Store Preview / Storytelling
* HomeScreen → Profile / Feed / Gallery
* CameraScreen → Studio / Editing Tool + App Preview
* AnalysisScreen → Studio / Editing Tool + Summary
* TemplateScreen → Membership / Preset / Recommendation
* PreviewScreen → Studio / Editing Tool + App Preview
* ResultScreen → Studio / Editing Tool + Gallery

### 4.5 Why Previous Direction Failed

Write a clear section explaining why the previous design was wrong:

* it used dark neon despite light references
* it turned reference images into generic colors instead of layout logic
* it overused rounded cards
* it ignored gallery/editor structures
* it did not make content the hero
* it did not create a real photo-app identity

Do not skip this section.

---

## 5. Interaction Bug Fix Must Happen Before Visual Rebuild

Before redesigning, fix all broken taps and navigation.

The user reported that buttons do not respond.

You must identify the root cause.

Create:

`docs/tap_root_cause.md`

This file must include:

1. Which screens had broken taps.
2. Which widgets or layers were blocking taps.
3. Exact file and widget names involved.
4. What caused the issue.
5. What code change fixed it.
6. How it was verified.

Check for these common causes:

* `Stack` overlays
* `Positioned.fill`
* transparent full-screen `Container`
* `GestureDetector` swallowing taps
* `AbsorbPointer`
* `IgnorePointer`
* `ModalBarrier`
* `PageView` or `Scrollable` conflicts
* full-screen decoration layers in front of buttons
* custom scaffold layer placed above child content
* bottom navigation overlay blocking body
* camera overlay intercepting pointer events

Fix tap behavior before moving to visual redesign.

Required interactions that must work:

1. Onboarding CTA routes to HomeScreen.
2. Home primary CTA routes to CameraScreen.
3. Home secondary CTA routes to TemplateScreen or import/edit flow.
4. Bottom navigation tabs switch correctly.
5. Camera capture button routes to AnalysisScreen.
6. Analysis CTA routes to TemplateScreen.
7. Template cards route to PreviewScreen.
8. Preview option cards are selectable.
9. Preview CTA routes to ResultScreen.
10. Result action for another template routes back to TemplateScreen.

Use `IgnorePointer(ignoring: true)` only for decorative overlays that must not capture taps.

Do not place decorative `Positioned.fill` widgets above interactive widgets unless they ignore pointer events.

---

## 6. Theme Rebuild Requirements

Update the global theme.

Likely files:

* `lib/core/theme/app_theme.dart`
* `lib/core/widgets/premium_widgets.dart`
* any constants file
* app scaffold
* bottom navigation widget

Replace the current dark neon theme.

New theme direction:

### 6.1 Color Tokens

Create or update design tokens similar to:

* `appBackground`
* `surface`
* `surfaceSoft`
* `textPrimary`
* `textSecondary`
* `textMuted`
* `line`
* `lineStrong`
* `actionPrimary`
* `actionPrimaryText`
* `actionSecondary`
* `actionSecondaryText`
* `dangerOrProfileAccent`
* `subtleAccent`
* `photoPlaceholder`

Suggested values are allowed but can be adjusted:

* background: `#FAFAF8` or `#FFFFFF`
* surface: `#FFFFFF`
* surfaceSoft: `#F4F4F2`
* textPrimary: `#111111`
* textSecondary: `#666666`
* textMuted: `#A0A0A0`
* line: `#E7E7E4`
* lineStrong: `#D4D4D0`
* actionPrimary: `#111111`
* actionPrimaryText: `#FFFFFF`
* actionSecondary: `#FFFFFF`
* actionSecondaryText: `#111111`
* profileAccent: `#C9151B` or a restrained red only if needed

Do not use bright mint as the primary brand color.
Mint can remain only as a tiny optional accent if there is already code relying on it, but it must not dominate.

### 6.2 Typography Tokens

Create or update:

* large title
* section title
* body
* body small
* caption
* metadata
* button label

Rules:

* avoid huge oversized text
* titles should be elegant and compact
* metadata should be small and gray
* Korean text must remain readable

### 6.3 Component Style Tokens

Define:

* page padding
* section spacing
* grid gap
* thumbnail radius
* panel radius
* button height
* bottom nav height
* thin border width
* selected outline width

---

## 7. Required Reusable Components

Create or rebuild reusable widgets so screens do not duplicate messy UI.

Likely file:

`lib/core/widgets/premium_widgets.dart`

Rename if useful, but keep structure clean.

Required reusable components:

### 7.1 MinimalTopBar

Purpose:

* quiet top navigation inspired by reference profile/feed screens

Props:

* title
* optional subtitle
* leading icon or back
* trailing icons
* compact mode

Visual:

* white/off-white background
* black text
* tiny icons
* no giant header block

### 7.2 EditorialSectionHeader

Purpose:

* small section title with optional action

Props:

* title
* optional subtitle
* optional action label

Visual:

* compact
* black title
* gray subtitle
* optional thin action

### 7.3 ThinTabRow

Purpose:

* category tabs similar to gallery/journal/collection references

Props:

* list of labels
* selected index
* on tap

Visual:

* text tabs
* thin underline
* no bulky pill chips unless a screen specifically needs it

### 7.4 PhotoGrid

Purpose:

* gallery-like grid for recent projects or visual samples

Props:

* list of mock image items
* columns
* gap
* aspect ratio

Visual:

* clean image tiles
* very light placeholder tiles
* minimal radius

### 7.5 PresetCard

Purpose:

* template cards inspired by membership/preset references

Props:

* template
* selected or recommended flag
* on tap

Visual:

* image/thumbnail area or tonal placeholder
* small metadata label
* title
* short description
* rating and usage
* beginner score
* reason
* small black action affordance

Do not make it look like a generic dark feature card.

### 7.6 EditorActionBar

Purpose:

* bottom tool bar inspired by studio/editing-tool references

Props:

* actions
* selected action
* on tap

Visual:

* white/off-white
* small icons
* tiny labels
* thin top divider

### 7.7 CameraGuideOverlay

Purpose:

* subtle camera guide overlay

Props:

* mode
* score
* message
* on mode changed
* on capture

Visual:

* thin lines
* subtle grid
* subject guide frame
* tiny hint panel
* capture control
* no heavy neon

Important:
Decorative overlay elements must not block taps.
Use `IgnorePointer` correctly.

### 7.8 PreviewOptionCard

Purpose:

* selectable preview option

Props:

* title
* description
* selected
* thumbnail or tonal preview
* on tap

Visual:

* clean bordered card
* image-first
* selected state via thin black outline or small check
* no glowing selection

### 7.9 PrimaryButton and SecondaryButton

Primary:

* black background
* white text
* modest radius
* compact height

Secondary:

* white background
* gray border
* black text

No glowing mint CTA.

---

## 8. Screen Rebuild Requirements

Rebuild the following screens.

Do not only change colors.
Rework layout composition, hierarchy, and component use.

---

# 8.1 OnboardingScreen

## Reference Direction

Use App Store Preview / Storytelling references.

The onboarding should feel like:

* product storytelling
* elegant app intro
* preview of the camera/editor experience
* minimal but visually informative

It must not be:

* giant empty rectangle
* dark neon slide
* generic placeholder panel

## Required Structure

Three onboarding pages.

### Page 1

Title:
`사진 찍기 전에 알려드릴게요`

Body:
`구도, 조명, 거리, 초점을 촬영 전에 먼저 확인해요.`

Visual:

* phone-like preview frame or editorial image panel
* show a mock camera composition grid
* show tiny guide label
* use light background
* use subtle black/gray UI

### Page 2

Title:
`템플릿만 고르면 끝`

Body:
`어려운 프롬프트 없이 원하는 분위기를 고르면 돼요.`

Visual:

* show preset/template cards
* small labels like profile, film, product, mood
* curated editor feel

### Page 3

Title:
`적용 전 시안을 먼저 확인`

Body:
`결과를 먼저 보고 마음에 드는 방향만 고화질로 완성해요.`

Visual:

* show original/preview comparison
* 3 preview direction mini cards
* selected state should be subtle

## Required Interactions

* pagination works
* next button works
* final start button routes to HomeScreen
* skip or close is optional
* dots or numeric indicator must reflect current page

## Visual Rules

* background should be light
* avoid dark mint CTA
* primary CTA should be black
* use compact copy
* content panel should be meaningful, not empty

---

# 8.2 HomeScreen

## Reference Direction

Use Profile / Feed / Gallery references.

The home screen should feel like:

* a refined photo app home
* a creator workflow hub
* image-first and gallery-like
* calm, compact, editorial

It must not feel like:

* a dashboard
* a SaaS landing page
* a giant CTA card stack
* a generic dark app

## Required Content

Top area:

* compact app title or date-like identity
* optional small profile/avatar circle
* tiny icon buttons

Main copy:

`오늘 사진, 찍기 전에 먼저 맞춰볼까요?`

Subcopy:

`촬영 목적에 맞춰 구도와 편집 템플릿을 이어서 추천해요.`

Primary actions:

* `사진 찍기`
* `사진 편집하기`

But these must not be giant glowing blocks.
They should feel like refined action rows or compact tool cards.

Required sections:

1. `촬영 코치`

   * compact summary
   * mode previews
   * small action

2. `추천 템플릿`

   * show curated preset cards
   * not huge generic cards

3. `최근 작업`

   * show gallery-like empty state or mock grid
   * reference gallery layouts

4. Bottom navigation:

   * `홈`
   * `촬영`
   * `템플릿`
   * `내 사진`

## Layout Direction

* Use thin section headers
* Use image/preset thumbnails
* Use restrained buttons
* Use compact modules
* Use gallery grid for recent work
* Keep bottom nav thin

## Required Interactions

* `사진 찍기` routes to CameraScreen
* `사진 편집하기` routes to TemplateScreen or edit flow
* tapping recommended template routes to PreviewScreen if route data exists
* bottom nav works

---

# 8.3 CameraScreen

## Reference Direction

Use Studio / Editing Tool references plus App Preview references.

This is the most important screen.

The CameraScreen must become the hero screen of FrameFit.

It should feel like:

* a real photo tool
* a minimal camera interface
* an elegant coaching overlay
* image/camera first
* thin line UI

It must not feel like:

* a dark generic camera placeholder
* a dashboard card
* a neon game UI
* a giant empty panel

## Required Camera Composition

Use full or near-full screen camera/photo preview area.

If real camera is unavailable, use a high-quality mock camera surface that still feels believable.

Required elements:

1. Top tool row

   * back or close
   * current mode
   * small icons for grid, flash/mock, settings

2. Preview area

   * image-like background or camera placeholder
   * rule-of-thirds grid
   * subtle center frame
   * subject guide frame
   * thin line composition markers
   * no thick glow

3. Guide message

   * compact overlay label
   * example:
     `빛은 좋아요. 얼굴을 살짝 오른쪽으로 옮겨보세요.`

4. Score

   * compact score such as `82`
   * not a huge card
   * include small score breakdown optionally

5. Mode selector

   * horizontal text tabs or tiny chips:

     * 프로필
     * 셀카
     * 음식
     * 여행
     * 상품
     * 감성

6. Bottom capture area

   * gallery icon
   * capture button
   * template/edit shortcut
   * inspired by camera/editor controls
   * must be tappable

## Mode Behavior

Mode switching must update:

* guide message
* score
* suggested template hint
* small scoring detail

Mode-specific copy:

### 프로필

Message:
`얼굴을 살짝 오른쪽으로 옮기면 여백이 더 자연스러워요.`

Hint:
`배경 흐림 인물 템플릿 추천`

### 셀카

Message:
`카메라를 조금 위로 올리면 얼굴 비율이 안정돼요.`

Hint:
`자연 셀카 템플릿 추천`

### 음식

Message:
`접시가 화면 왼쪽으로 치우쳤어요. 중앙에 조금만 맞춰보세요.`

Hint:
`맛있어 보이는 음식 템플릿 추천`

### 여행

Message:
`하늘과 피사체 비율이 좋아요. 수평만 살짝 맞춰보세요.`

Hint:
`필름 여행 템플릿 추천`

### 상품

Message:
`제품 배경이 조금 복잡해요. 밝은 배경 쪽으로 옮겨보세요.`

Hint:
`흰 배경 상품컷 추천`

### 감성

Message:
`왼쪽 여백을 살리면 더 감성적인 구도가 돼요.`

Hint:
`시네마틱 무드 템플릿 추천`

## Important Tap Safety

Camera guide overlay must not block:

* mode selector taps
* capture button
* gallery button
* top controls

Any decorative grid or frame layer must use `IgnorePointer`.

---

# 8.4 AnalysisScreen

## Reference Direction

Use Studio / Editing Tool and clean summary references.

The AnalysisScreen should feel like a quiet editor summary.

It should not be flashy.

## Required Structure

Top:

* compact top bar
* title:
  `사진 분석 완료`
* subtitle:
  `촬영 상태를 확인하고 어울리는 템플릿을 추천했어요.`

Main:

* photo preview
* score summary
* recommendation reason

Scores:

* `초점`
* `구도`
* `조명`
* `배경`
* `안정감`

Score UI:

* small rows or compact metric blocks
* thin progress lines
* avoid big dark cards

Recommendation:

Text:
`배경이 살짝 복잡해서 배경 흐림 인물 템플릿을 추천해요.`

CTA:

* `추천 템플릿 보기`

Primary CTA style:

* black button
* modest size
* no glow

Required interaction:

* CTA routes to TemplateScreen

---

# 8.5 TemplateScreen

## Reference Direction

Use Membership / Preset / Recommendation references.

The TemplateScreen should feel like:

* curated preset store
* film preset selector
* photo editor template browser
* trustworthy recommendation list

It must not feel like:

* generic grid of cards
* dark dashboard cards
* random list

## Required Structure

Top:

* compact top bar
* title:
  `템플릿`
* subtitle:
  `사진에 맞는 편집 방향을 골라보세요.`

Category row:

* use thin tab row or subtle chips
* categories:

  * 전체
  * 프로필
  * 셀카
  * 음식
  * 여행
  * 상품
  * 감성

Recommended block:

* maybe first card larger
* label:
  `이 사진에 추천`
* should feel like curated preset

Template list:

Each template card must show:

* thumbnail or tonal preview block
* small category label
* template name
* short description
* rating
* usage count
* beginner-friendly score
* recommendation reason
* tags
* small action affordance

Required template data:

At least 20 Korean templates:

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

Required template fields:

* id
* name
* category
* description
* tags
* rating
* usageCount
* beginnerFriendlyScore
* recommendationReason
* editRecipe
* optional thumbnailTone or sampleAsset

## Required Interactions

* category filtering works
* template card tap routes to PreviewScreen
* selected template data is passed correctly
* no tap blocking

---

# 8.6 PreviewScreen

## Reference Direction

Use App Preview and Studio / Editing Tool references.

The PreviewScreen should feel like:

* choosing a preset output
* comparing editing directions
* image-first editor flow

It must not feel like:

* generic list of options
* dark cards with no visual difference
* unclear selection

## Required Structure

Top:

* compact top bar
* title:
  `시안 미리보기`
* subtitle:
  selected template name

Main:

* original image or mock image preview
* selected template summary
* three preview options

Preview options:

1. `자연스럽게`
   Description:
   `얼굴 밝기와 피부톤만 부드럽게 정리해요.`

2. `밝게`
   Description:
   `어두운 부분을 살리고 SNS용으로 환하게 맞춰요.`

3. `무드있게`
   Description:
   `색온도와 대비를 조절해 분위기를 더해요.`

Each option must have:

* preview thumbnail
* title
* description
* selected state
* on tap

Selected state:

* thin black border
* small check
* subtle background
* no glow

CTA:

* `고화질로 적용하기`

Required interaction:

* preview option selection works
* CTA routes to ResultScreen
* selected template and preview style are passed to ResultScreen

---

# 8.7 ResultScreen

## Reference Direction

Use Studio / Editing Tool and Gallery references.

The ResultScreen should feel:

* image-first
* calm
* finished
* ready to save/share
* minimal and product-grade

## Required Structure

Top:

* compact top bar
* title:
  `완성됐어요`

Main:

* final image preview
* applied template
* applied preview style

Info:

* `적용 템플릿`
* `선택한 시안`

Actions:

* `저장하기`
* `공유하기`
* `다른 템플릿 적용`
* `원본과 비교`

Review prompt:

`결과가 마음에 드나요?`

Options:

* `좋아요`
* `보통`
* `별로`

Required interaction:

* `다른 템플릿 적용` routes back to TemplateScreen
* other actions can be mocked but must not crash

---

## 9. Navigation Requirements

Check router files.

Likely locations:

* `lib/core/router/`
* `lib/app.dart`
* screen files

Required route flow:

1. OnboardingScreen → HomeScreen
2. HomeScreen → CameraScreen
3. HomeScreen → TemplateScreen
4. CameraScreen → AnalysisScreen
5. AnalysisScreen → TemplateScreen
6. TemplateScreen → PreviewScreen
7. PreviewScreen → ResultScreen
8. ResultScreen → TemplateScreen

Make sure route arguments work:

TemplateScreen → PreviewScreen must pass:

* selected template id
* selected template name
* category
* recommendation reason

PreviewScreen → ResultScreen must pass:

* selected template
* selected preview style
* original/mock image info

Do not silently use null placeholders where real route args should exist.

Fallback values are allowed only for direct debug route opening.

---

## 10. Mock Image And Asset Strategy

The reference app is image-first.
The current FrameFit UI must not show empty blocks everywhere.

Use one or more of these strategies:

1. Use local assets if already available.
2. Use simple generated gradient/tonal blocks only when no assets exist.
3. Use abstract photo-like placeholders with texture/color blocks.
4. Use the reference images only for design inspiration, not necessarily as production app content unless explicitly allowed by existing asset setup.
5. Use colored photo tiles inspired by the contact sheets:

   * texture tile
   * portrait-like tile
   * food-like tile
   * sunset-like tile
   * product-like tile

Do not leave giant empty rectangles.

Photo placeholders must feel intentional.

---

## 11. Data Requirements

Check mock template data.

Likely file:

`lib/data/mock/mock_templates.dart`

Make sure all templates have complete fields.

Example template model fields:

```dart
class FrameFitTemplate {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> tags;
  final double rating;
  final int usageCount;
  final int beginnerFriendlyScore;
  final String recommendationReason;
  final EditRecipe editRecipe;
  final String? thumbnailTone;
}
```

Edit recipe can include:

* brightness
* contrast
* saturation
* warmth
* skin
* background
* sharpness
* mood

The UI must use this data.
Do not create hardcoded template cards in the screen.

---

## 12. Testing Requirements

Run:

```bash
flutter pub get
flutter analyze
flutter test
```

Add or update tests.

Minimum required tests:

### Test 1: Mock template data

Verify:

* at least 20 templates
* all template names are non-empty
* all template categories are valid
* rating is within valid range
* beginner score is within valid range

### Test 2: Category filtering

Verify:

* filtering by a category returns only templates in that category
* all category returns all templates

### Test 3: Onboarding CTA tap

Verify:

* OnboardingScreen renders CTA
* tapping final/start CTA triggers route or callback

If router test is difficult, expose a callback or test navigational behavior safely.

### Test 4: Home CTA tap

Verify:

* HomeScreen renders `사진 찍기`
* tapping it triggers navigation or callback
* HomeScreen renders `사진 편집하기`
* tapping it triggers navigation or callback

### Test 5: Template card tap

Verify:

* TemplateScreen renders at least one template
* tapping a template triggers route or callback

Do not claim interaction is fixed without tests or explicit manual verification notes.

---

## 13. Documentation Requirements

Create or update these files.

### 13.1 `docs/reference_audit.md`

Must include:

* reference inventory
* grouped visual patterns
* extracted visual system
* screen-to-reference mapping
* why previous direction failed
* how the Flutter UI now uses the references

### 13.2 `docs/tap_root_cause.md`

Must include:

* broken interactions found
* root cause
* exact widgets/files
* fix explanation
* verification

### 13.3 `docs/mvp_notes.md`

Must include:

* implemented screens
* mocked features
* real camera TODO
* real ML analysis TODO
* AI editing API TODO
* save/share TODO
* known limitations
* how to run the app

### 13.4 `docs/design_acceptance_checklist.md`

Create a checklist with these items:

* app no longer uses dark neon as main direction
* theme is light/editorial/photo-app inspired
* onboarding has meaningful visual storytelling
* home feels like photo workflow hub
* camera screen is camera-first
* template screen feels like curated presets
* preview options are clearly selectable
* result screen is image-first
* main taps work
* tests pass
* reference mapping completed

Mark each item with pass/fail and notes.

### 13.5 `docs/screenshots.md`

If screenshots can be generated, list paths.

If screenshots cannot be generated in WSL2, document why.

Do not falsely claim screenshots exist.

---

## 14. Screenshot Or Visual Proof Strategy

Try to generate screenshots if possible.

Possible methods:

1. Flutter integration test screenshot
2. Flutter web with browser screenshot
3. Android emulator screenshot
4. Widget render capture
5. Manual screenshot instructions

If no screenshot system works, write:

* what was attempted
* why it failed
* what command the user should run manually
* which screens the user should capture

Required manual screenshot checklist:

* onboarding page 1
* home
* camera
* template
* preview
* result

---

## 15. File Investigation Requirements

Before editing, inspect relevant files.

Use shell commands like:

```bash
find lib -maxdepth 4 -type f | sort
find docs -maxdepth 2 -type f | sort
grep -R "AbsorbPointer\|IgnorePointer\|GestureDetector\|Positioned.fill\|Stack" -n lib || true
grep -R "mint\|neon\|dark\|Color(" -n lib/core lib/features || true
```

Inspect at least:

* `lib/main.dart`
* `lib/app.dart`
* `lib/core/theme/app_theme.dart`
* router files
* reusable widget files
* all feature screen files
* mock template data
* existing tests
* docs/reference_audit.md

Do not blindly rewrite without understanding current structure.

---

## 16. Work Plan

Follow this order exactly.

### Phase 1: Repository Audit

1. List existing screens.
2. List UI files.
3. List routing files.
4. List reusable widget files.
5. List test files.
6. List docs.
7. List reference images.
8. Identify tap-blocking suspects.

Output a short audit summary before edits.

### Phase 2: Tap Bug Fix

1. Find root cause.
2. Fix hit testing and navigation.
3. Add or update interaction tests.
4. Run analyze/test.
5. Write `docs/tap_root_cause.md`.

Do not start the major visual rebuild until basic taps work.

### Phase 3: Reference Re-Audit

1. Inspect reference images.
2. Update `docs/reference_audit.md`.
3. Define new visual system.
4. Write screen-to-reference mapping.

Do not redesign without this mapping.

### Phase 4: Theme And Components

1. Replace dark neon theme with light editorial theme.
2. Rebuild reusable components.
3. Ensure all components are tap-safe.
4. Avoid default Flutter look.

### Phase 5: Screen Rebuild

Rebuild screens in this order:

1. OnboardingScreen
2. HomeScreen
3. CameraScreen
4. TemplateScreen
5. PreviewScreen
6. AnalysisScreen
7. ResultScreen

CameraScreen and TemplateScreen deserve the most attention.

### Phase 6: Routing And Data

1. Verify navigation flow.
2. Verify route arguments.
3. Verify template data.
4. Verify selected preview state.
5. Verify result receives data.

### Phase 7: Validation

Run:

```bash
flutter pub get
flutter analyze
flutter test
```

Fix all critical issues.

### Phase 8: Documentation

Update:

* `docs/reference_audit.md`
* `docs/tap_root_cause.md`
* `docs/mvp_notes.md`
* `docs/design_acceptance_checklist.md`
* `docs/screenshots.md`

### Phase 9: Final Report

Report:

1. root cause of tap issue
2. exact files changed
3. screen-by-screen redesign summary
4. reference mapping summary
5. tests added
6. validation results
7. limitations
8. manual screenshot instructions if needed

---

## 17. Acceptance Criteria

Do not mark this task complete unless all conditions are true.

### Functional Acceptance

* Onboarding CTA works.
* Home primary CTA works.
* Home secondary CTA works.
* Bottom navigation works.
* Camera capture works.
* Analysis CTA works.
* Template card tap works.
* Category filtering works.
* Preview option selection works.
* Preview CTA works.
* Result receives selected template and preview style.
* Result `다른 템플릿 적용` works.

### Visual Acceptance

* App no longer looks like dark neon AI dashboard.
* App uses light or off-white editorial photo-app style.
* UI clearly borrows from reference images.
* Onboarding is not a giant empty rectangle.
* Home is not a stack of generic feature cards.
* CameraScreen feels like a real camera coach.
* TemplateScreen feels like curated presets.
* PreviewScreen makes selection obvious.
* ResultScreen is image-first.
* Bottom navigation is thin and understated.
* Icons are small and clean.
* Dividers and tabs are subtle.
* Content carries color, not app chrome.

### Documentation Acceptance

* `docs/reference_audit.md` exists and is updated.
* `docs/tap_root_cause.md` exists.
* `docs/mvp_notes.md` exists and is updated.
* `docs/design_acceptance_checklist.md` exists.
* `docs/screenshots.md` exists.

### Validation Acceptance

* `flutter pub get` succeeds.
* `flutter analyze` has no critical errors.
* `flutter test` passes.
* Interaction tests are added or updated.
* Any unavailable screenshot method is documented honestly.

---

## 18. Explicit Design Do And Do Not

### Do

* Use light theme.
* Use off-white background.
* Use black primary action.
* Use thin dividers.
* Use compact top bars.
* Use gallery/photo grid logic.
* Use small icons.
* Use editorial spacing.
* Use image-first composition.
* Use template/preset language.
* Use subtle selected states.
* Use Korean UI copy.
* Use reusable components.
* Keep the app calm and premium.

### Do Not

* Do not use mint neon as brand identity.
* Do not use glowing buttons.
* Do not use giant dark rounded cards.
* Do not use empty hero rectangles.
* Do not use default Flutter blue.
* Do not create generic dashboards.
* Do not use thick borders everywhere.
* Do not overuse shadows.
* Do not block taps with overlays.
* Do not claim reference usage without mapping.
* Do not mark complete just because analyze/test pass.
* Do not skip documentation.

---

## 19. Korean UI Copy Bank

Use these Korean phrases where helpful.

### General

* `오늘 사진, 찍기 전에 먼저 맞춰볼까요?`
* `촬영 목적에 맞춰 구도와 편집 템플릿을 이어서 추천해요.`
* `사진 찍기`
* `사진 편집하기`
* `추천 템플릿`
* `최근 작업`
* `내 사진`
* `템플릿`
* `촬영`

### Onboarding

* `사진 찍기 전에 알려드릴게요`
* `구도, 조명, 거리, 초점을 촬영 전에 먼저 확인해요.`
* `템플릿만 고르면 끝`
* `어려운 프롬프트 없이 원하는 분위기를 고르면 돼요.`
* `적용 전 시안을 먼저 확인`
* `결과를 먼저 보고 마음에 드는 방향만 고화질로 완성해요.`
* `시작하기`

### Camera

* `프로필`
* `셀카`
* `음식`
* `여행`
* `상품`
* `감성`
* `얼굴을 살짝 오른쪽으로 옮기면 여백이 더 자연스러워요.`
* `카메라를 조금 위로 올리면 얼굴 비율이 안정돼요.`
* `접시가 화면 왼쪽으로 치우쳤어요. 중앙에 조금만 맞춰보세요.`
* `하늘과 피사체 비율이 좋아요. 수평만 살짝 맞춰보세요.`
* `제품 배경이 조금 복잡해요. 밝은 배경 쪽으로 옮겨보세요.`
* `왼쪽 여백을 살리면 더 감성적인 구도가 돼요.`

### Analysis

* `사진 분석 완료`
* `촬영 상태를 확인하고 어울리는 템플릿을 추천했어요.`
* `초점`
* `구도`
* `조명`
* `배경`
* `안정감`
* `배경이 살짝 복잡해서 배경 흐림 인물 템플릿을 추천해요.`
* `추천 템플릿 보기`

### Template

* `사진에 맞는 편집 방향을 골라보세요.`
* `전체`
* `프로필`
* `셀카`
* `음식`
* `여행`
* `상품`
* `감성`
* `이 사진에 추천`
* `초보자 추천`
* `사용`
* `추천 이유`

### Preview

* `시안 미리보기`
* `자연스럽게`
* `밝게`
* `무드있게`
* `얼굴 밝기와 피부톤만 부드럽게 정리해요.`
* `어두운 부분을 살리고 SNS용으로 환하게 맞춰요.`
* `색온도와 대비를 조절해 분위기를 더해요.`
* `고화질로 적용하기`

### Result

* `완성됐어요`
* `적용 템플릿`
* `선택한 시안`
* `저장하기`
* `공유하기`
* `다른 템플릿 적용`
* `원본과 비교`
* `결과가 마음에 드나요?`
* `좋아요`
* `보통`
* `별로`

---

## 20. Final Output Format

When finished, respond with this exact structure:

```text
Completed FrameFit Visual Rebuild V3.

1. Tap issue root cause
- ...

2. Files changed
- ...

3. Reference mapping
- OnboardingScreen: ...
- HomeScreen: ...
- CameraScreen: ...
- AnalysisScreen: ...
- TemplateScreen: ...
- PreviewScreen: ...
- ResultScreen: ...

4. Visual redesign summary
- ...

5. Tests added or updated
- ...

6. Validation
- flutter pub get: ...
- flutter analyze: ...
- flutter test: ...

7. Documentation
- docs/reference_audit.md: ...
- docs/tap_root_cause.md: ...
- docs/mvp_notes.md: ...
- docs/design_acceptance_checklist.md: ...
- docs/screenshots.md: ...

8. Remaining limitations
- ...

9. Manual screenshot instructions
- ...
```

Do not provide a vague completion summary.
Be specific.
