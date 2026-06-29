# FrameFit Template Schema

## Current Model

The app uses `EditTemplate` in `lib/data/models/template.dart`. Phase 2 keeps
the existing preview/result/edit-recipe contract stable and enriches the same
model with photo-template data for future camera coaching.

```text
EditTemplate
- id: String
- title: String
- name: String
- description: String
- category: String
- rating: double
- usageCount: int
- beginnerFriendlyScore: int
- tags: List<String>
- recommendationReason: String
- thumbnailTone: String?
- sampleVisual: TemplateSampleVisual
- aspectRatio: String
- targetSubjectType: String
- compositionGuidance: String
- captureTips: List<String>
- feedbackHints: List<String>
- editRecipe: EditRecipe
```

`title` currently aliases `name` so existing screens and tests that read
`EditTemplate.name` continue to work. `id` can be supplied explicitly, otherwise
it is generated from the display name.

```text
TemplateSampleVisual
- label: String
- baseColorHex: String
- accentColorHex: String
- assetPath: String?
```

```text
EditRecipe
- brightness: String
- contrast: String
- saturation: String
- warmth: String
- tone: String
- skin: String
- background: String
- sharpness: String
- mood: String
```

Current templates are local fixtures in `lib/data/mock/mock_templates.dart`.
They are used for browsing, recommendation copy, preview labels, and result
labels. The app does not currently execute the `EditRecipe` fields against
image pixels.

## Current Categories

- 프로필
- 셀카
- 여행
- 음식
- 상품
- 감성

## Required Phase 2 Templates

The catalog includes the roadmap-required templates:

- 기본 프로필
- 상반신 프로필
- 전신 샷
- 푸드 포토
- 상품 사진
- 여행 인물
- 카페 무드샷
- 미니멀 배경 샷

Each one carries sample placeholder visual data, aspect ratio, target subject
type, composition guidance, capture tips, future feedback hints, and an
edit-recipe-compatible preset.

## Repository Access

Templates should be consumed through `TemplateRepository` instead of duplicating
lists in screens.

```text
TemplateRepository
- all(): List<EditTemplate>
- byCategory(String category): List<EditTemplate>
- categories: List<String>
- recommended({int limit = 3}): List<EditTemplate>
- byId(String id): EditTemplate?
```

## Migration Notes

- Keep `EditTemplate.name`, `description`, `category`, `rating`, `usageCount`,
  `beginnerFriendlyScore`, `beginnerScore`, `tags`, `recommendationReason`,
  `thumbnailTone`, `editRecipe`, and `id` compatible with existing UI/tests.
- Treat `feedbackHints` as data-only guidance for future camera coaching. The
  current app does not claim live detection or AI analysis from these fields.
- Prefer local fixtures first, then move to remote configuration only when
  product iteration needs it.
