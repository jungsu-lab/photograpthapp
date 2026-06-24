# Onboarding And Home Screenshot Checklist

Use this checklist for manual review of the generated or device screenshots for `OnboardingScreen` and `HomeScreen`.

## OnboardingScreen

- Background is light/off-white.
- Top bar is thin and editorial, with small FrameFit identity and no heavy app chrome.
- Main story area is filled with meaningful camera/preset/preview content.
- There is no giant empty hero rectangle.
- Page indicator is a thin progress rule.
- Primary CTA is compact black, not mint.
- Korean copy is unchanged and readable.
- Tapping the final CTA routes to Home.

## HomeScreen

- Background is light/off-white.
- First viewport reads as a photo-app home/feed, not a dark dashboard.
- Top bar is thin with a restrained red identity dot.
- Lead gallery is image-led with asymmetric photo tiles.
- Primary CTA is compact black and secondary CTA is bordered white.
- Coach strip uses thin dividers and compact chips.
- Template rail is thumbnail-led and editorial.
- Bottom navigation stays compact and tappable.

## Automated Screenshot Files

Generated at a 390x844 logical viewport through Flutter golden capture:

- `docs/generated_screenshots/onboarding.png`
- `docs/generated_screenshots/home.png`

Current capture status:

- `flutter test --update-goldens test/_golden_capture_test.dart` produced both PNGs.
- The temporary capture test was removed after generation so the normal test suite remains unchanged.
- Review the generated PNGs against this checklist for visual acceptance.
