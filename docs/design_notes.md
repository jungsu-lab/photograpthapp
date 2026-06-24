# FrameFit Design Notes

## References Used

- Local attachment reference: `/home/jungsu/.codex/attachments/b830c146-db2a-4936-9560-510030157ec4/image-1.jpg`
- The expected project folder `design-reference/` was searched for under the Flutter project, but no such source folder exists yet.
- Figma was available and used. A design file was created:
  - `https://www.figma.com/design/yawH44oXTILEoAyqiwW8O9`
  - Page: `FrameFit MVP`

## Visual Patterns Observed

The reference image is strongly VSCO-like:

- Photo-first surfaces with sparse chrome.
- Black and near-white editorial sections.
- Thin top bars and minimal bottom toolbars.
- Large image previews, comparison cards, and grid-based galleries.
- Small, quiet labels instead of heavy explanatory panels.
- Simple rectangular cards with restrained radius.
- Editing controls presented as preset choices, color swatches, and compact action bars.

## Flutter Design Decisions

- Kept the app dark and camera/editor focused.
- Used a restrained premium palette:
  - Background: `#080A0D`
  - Surface: `#12161C`
  - Elevated: `#171D25`
  - Border: `#242A33`
  - Text: `#F4F7FA`
  - Muted text: `#9AA4B2`
  - Guide accent: `#42F5C8`
  - AI/template accent: `#9B7CFF`
- Used 8 px card/button radius to stay close to the reference's utilitarian mobile UI.
- Kept camera and preview screens image-first with compact control areas.
- Used template cards as trusted preset choices instead of prompt input.
- Added reusable widgets for cards, buttons, score rows, and mock photo surfaces.

## Assumptions

- The first MVP should not depend on remote image URLs.
- The provided reference image is sufficient visual guidance until a project `design-reference/` folder is added.
- Real camera and AI generation are intentionally deferred so the demo flow remains stable.
