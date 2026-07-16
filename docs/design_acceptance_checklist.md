# FrameFit Design Acceptance Checklist

> **Archived visual-rebuild checklist.** It evaluated the earlier
> placeholder-based prototype. It is not a statement of the present editor,
> camera, input, or export behavior; refer to `README.md` and
> `docs/MVP_STATUS.md` for current status.

## Old Tokens Removed

| Old token or pattern | Status | Replacement |
| --- | --- | --- |
| `AppTheme.dark` as app theme | Removed | `AppTheme.light` in `lib/app.dart` |
| `AppColors.mint` | Removed | `AppColors.actionPrimary` / `AppColors.textPrimary` |
| `AppColors.elevated` | Removed | `AppColors.surfacePressed` or `AppColors.surfaceSoft` |
| `AppColors.background` | Removed | `AppColors.appBackground` |
| `AppColors.border` | Removed | `AppColors.line` |
| `AppColors.amber` | Removed | `AppColors.warningAccent` |
| `AppColors.error` | Removed | `AppColors.lowScoreAccent` |
| `AppColors.dangerOrProfileAccent` | Removed | `AppColors.profileAccent` |
| `AppColors.cameraDark` | Removed | `AppColors.cameraBackdrop` for preview-only camera canvas |
| `AppColors.cameraPanel` | Removed | `AppColors.overlayPanel` |
| dark gradient mock photo surface | Removed | light editorial photo placeholder gradient |
| giant shared panel radius | Removed | `AppMetrics.panelRadius = 10.0` |

## New Tokens Applied

| New token | Value | Usage |
| --- | --- | --- |
| `appBackground` | `#FAFAF8` | global scaffold/app bars |
| `surface` | `#FFFFFF` | cards, buttons, sheets |
| `surfaceSoft` | `#F4F4F2` | selected preview option, chips |
| `surfacePressed` | `#EDEDEA` | progress tracks |
| `photoPlaceholder` | `#ECECEA` | light mock image placeholders |
| `textPrimary` | `#111111` | text, selected states, black CTA |
| `textSecondary` | `#666666` | body copy |
| `textMuted` | `#A0A0A0` | metadata |
| `line` | `#E7E7E4` | thin borders and dividers |
| `lineStrong` | `#D4D4D0` | stronger secondary borders |
| `profileAccent` | `#C9151B` | small identity/recommended accent only |
| `warningAccent` | `#D8A868` | mid-score indicators |
| `lowScoreAccent` | `#9B3A34` | low-score indicators |
| `cameraBackdrop` | `#161616` | camera preview screen only |
| `overlayPanel` | `0xEEFFFFFF` | camera/editor overlay panels |

## Component Acceptance

| Component layer | Status | Evidence |
| --- | --- | --- |
| Global app theme is light editorial | Pass | `lib/app.dart` uses `AppTheme.light`; `AppTheme` is `Brightness.light`. |
| Primary CTA is black, not mint | Pass | `PrimaryButton` uses `AppColors.actionPrimary = #111111`. |
| Secondary CTA is white with thin border | Pass | `SecondaryButton` uses white background and `lineStrong` border. |
| Shared cards are thin-bordered light surfaces | Pass | `PremiumCard` defaults to `surface`, `line`, and 10 px radius. |
| Selected states use thin outline | Pass | `PreviewOptionCard` uses `selectedOutline` and `textPrimary`. |
| Bottom nav is compact and divided | Pass | `EditorActionBar` uses white surface and 1 px top border. |
| Mock photo surfaces are light | Pass | `MockPhotoSurface` now uses white/light gray gradient. |
| Old token names are gone from app code | Pass | `rg "AppColors\\.(mint|elevated|background|border|amber|error|dangerOrProfileAccent|cameraDark|cameraPanel)|AppTheme\\.dark|neon|glow|mint" lib test` returns no matches. |
| Navigation tests remain unchanged in behavior | Pass | Existing widget tests still exercise the same routes and tap flow. |

## Verification Commands

Required before completion:

```bash
flutter analyze
flutter test
```
