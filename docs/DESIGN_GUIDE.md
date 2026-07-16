# FrameFit Design Guide

## Direction

FrameFit should feel like a calm photo/editor app, not a generic AI dashboard. The current UI uses a mostly light editorial direction with thin dividers, restrained typography, image-first layouts, and small black controls.

Dark surfaces are reserved for the camera preview context, where they represent a camera/photo canvas rather than the global app theme.

## Current Tokens

Source: `lib/core/theme/app_theme.dart`

- App background: `#FAFAF8`
- Surface: `#FFFFFF`
- Soft surface: `#F4F4F2`
- Primary text/action: `#111111`
- Secondary text: `#666666`
- Muted text: `#A0A0A0`
- Divider: `#E7E7E4`
- Strong divider: `#D4D4D0`
- Profile accent: `#C9151B`
- Warning accent: `#D8A868`
- Camera backdrop: `#161616`
- Overlay panel: white with opacity

## Layout Rules

- Keep each screen focused on one primary action.
- Prioritize large image or camera surfaces over explanatory cards.
- Use thin dividers and compact sections instead of heavy panels.
- Keep card and button radius close to 8 px unless a component already defines otherwise.
- Use short Korean copy that sounds like coaching, not scoring or judgment.
- Keep camera overlays readable but secondary to the preview.

## Screen Intent

- Onboarding: direct entry to importing a photo or opening the camera.
- Home: begin editing within one primary action, with recent presets nearby.
- Presets: curated numeric preset browser with real processed thumbnails.
- Shooting: composition-template library and Shot Packs that lead into camera.
- Camera: real camera preview, template overlay, optional device-level guidance,
  camera settings, and capture.
- Editor: original/processed comparison, presets, advanced adjustments, crop,
  undo/redo, and export.
- Export: format, output size, JPEG quality, gallery save, and system sharing.

## Copy Tone

Use direct, action-oriented guidance:

- Good: `얼굴을 살짝 오른쪽으로 옮기면 여백이 더 자연스러워요.`
- Good: `카메라를 조금 위로 올리면 얼굴 비율이 안정돼요.`
- Avoid: `현재 피사체의 위치가 템플릿의 권장 구도와 일치하지 않습니다.`

## Current Limitations

The editor is intentionally local-first and uses global pixel adjustments. It
does not claim live scene analysis, composition scoring, face/object detection,
or AI-generated editing. Refer to `README.md` for the full supported-feature
and privacy boundary.
