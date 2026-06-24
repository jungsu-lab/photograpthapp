# FrameFit V3 Screenshots

## Screenshot Attempts

Screenshot generation was checked during the V3 rebuild.

Available devices/tools:

- `flutter devices` found only `Linux (desktop) • linux • linux-x64 • Ubuntu 24.04.4 LTS 6.18.33.1-microsoft-standard-WSL2`.
- No `google-chrome`, `chromium-browser`, `chromium`, or `microsoft-edge` executable was available on `PATH`.
- Node Playwright is not installed in this project environment.

Previous widget-render capture attempts in this WSL2 environment hung and produced no valid PNG files, so no automated screenshot file is claimed.

## Generated Screenshot Files

None.

## Manual Screenshot Instructions

Run the app as a web server:

```bash
cd /home/jungsu/projects/framefit
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081
```

Open:

```text
http://localhost:8081
```

Capture these screens manually:

1. Onboarding page 1: `사진 찍기 전에 알려드릴게요`
2. Home: `오늘 사진, 찍기 전에 먼저 맞춰볼까요?`
3. Camera: tap `사진 찍기`
4. Template: tap `사진 편집하기` or bottom nav `템플릿`
5. Preview: tap `깔끔한 프로필`
6. Result: tap `고화질로 적용하기`

Expected manual output paths if captured later:

- `docs/screenshots/onboarding.png`
- `docs/screenshots/home.png`
- `docs/screenshots/camera.png`
- `docs/screenshots/template.png`
- `docs/screenshots/preview.png`
- `docs/screenshots/result.png`
