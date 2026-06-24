# FrameFit Tap Root Cause

## Exact Root Cause

The app routes for the requested tap flow were present, but the widget tests were using visible text as the tap target. That made the interaction checks fragile because several labels appear more than once (`깔끔한 프로필`, `프로필`, `템플릿`) and some targets are inside lazy `ListView` content that must be scrolled into view before tapping.

The first red test failed because the main CTAs did not expose stable keys:

```text
Found 0 widgets with key [<'onboardingPrimaryCta'>]
```

After adding keys, the next red test exposed a second verifier failure: the template card key was duplicated between the recommended card and the first list card, so `scrollUntilVisible` could not resolve a single element:

```text
Bad state: Too many elements
```

No visual design or app flow change was required. The fix was to add stable, unique keys to the existing tappable widgets and update tests to use those keys plus `scrollUntilVisible` for lazy content.

## Changed Files

- `lib/features/onboarding/onboarding_screen.dart`
  - Added `onboardingPrimaryCta` to the onboarding CTA.
- `lib/features/home/home_screen.dart`
  - Added `homePrimaryCta`, `homeSecondaryCta`, and `homeTemplateCard-<template-id>` keys.
- `lib/features/analysis/analysis_screen.dart`
  - Added `analysisTemplatesCta` to the analysis CTA.
- `lib/features/templates/template_screen.dart`
  - Added unique `recommendedTemplateCard-<template-id>` and `templateCard-<template-id>` keys.
- `lib/features/preview/preview_screen.dart`
  - Added `previewOption-<label>` keys and `previewApplyCta`.
- `lib/features/result/result_screen.dart`
  - Added `resultTryAnotherTemplateCta`.
- `lib/core/widgets/premium_widgets.dart`
  - Added `bottomNav-<label>` keys to bottom navigation items.
- `test/framefit_flow_test.dart`
  - Updated interaction tests to tap by key and use `scrollUntilVisible` for lazy template/apply targets.
- `docs/tap_root_cause.md`
  - Replaced the prior note with the current verified root cause and file list.

## Verified Tap Surface

- Onboarding CTA -> home.
- Home primary CTA -> camera.
- Home secondary CTA -> templates.
- Bottom nav `촬영` -> camera.
- Bottom nav `템플릿` -> templates.
- Camera capture -> analysis.
- Analysis CTA -> templates.
- Template card tap -> preview.
- Preview option tap -> selected preview state.
- Preview apply CTA -> result.
- Result `다른 템플릿 적용` -> templates.

## Verification

```bash
flutter analyze
```

Result:

```text
No issues found! (ran in 1.2s)
```

```bash
flutter test
```

Result:

```text
All tests passed! 6/6
```
