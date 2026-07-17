# FrameFit MVP 상태 기록

## Android emulator verification — 2026-07-17

- A fresh x64 debug APK was installed and launched successfully on the local
  `FrameFit_36` Android 16 emulator.
- The user flow was exercised with a generated test PNG: onboarding skip →
  Home → Android system Photo Picker → real editor → preset application →
  PNG export → Gallery save.
- Android's picker displayed its selected-photos privacy notice. The exported
  file was confirmed through MediaStore as
  `Pictures/FrameFit/FrameFit-23-20260717053442271464.png`.
- The Android system share sheet also opened with the generated image preview
  and available share targets.
- A later x64 debug build (including the latest temporary-export cleanup)
  was reinstalled and launched on the same emulator. The Home screen, the
  three-item navigation bar, and labeled photo-import/camera actions were
  confirmed through the Android accessibility tree.
- After the legacy-storage permission change, a clean Android 16 emulator
  install exposed only the ungranted camera runtime permission. No broad
  photo or external-storage runtime permission was present.
- This is emulator evidence, not a substitute for a physical-device camera,
  host-camera configuration, a receiving third-party app, or iOS validation.
- During the composition-camera flow, Android's camera permission prompt was
  reached. After permission was granted, this Android 16 x64 virtual-camera
  backend stopped responding. Camera discovery and initialization now each
  time out after 12 seconds and return a retryable in-app error rather than
  leaving a permanent loading screen. On a fresh later run, rejecting the
  Android camera prompt resulted in that retryable error after the virtual
  backend failed to return, so the bounded-error path is directly verified.
  Successful capture still requires confirmation on a responsive virtual or
  physical camera.
- The latest x64 debug APK was reinstalled after recent-preset refresh fixes.
  Choosing `도쿄 네온` before photo import opened the real editor with that
  preset applied, persisted `tokyo-neon` locally, and showed it immediately in
  Home's recent-preset chip after returning through the bottom navigation.
- GitHub Actions run #9 for commit `9245e52` completed successfully: the
  Linux Android job passed analysis, non-golden tests, and a debug APK build;
  the Windows job passed all three visual-baseline tests.

## Verification note — 2026-07-17

- The ARM64 release APK was rebuilt successfully and its APK Signature Scheme
  v2 signature was verified.
- Preset model, preset catalogue, composition catalogue, and real JPEG/PNG
  processor tests passed using the standalone Dart test runner.
- On 2026-07-17, `flutter analyze` completed with no issues and
  `flutter test --concurrency=1` completed with 54 passing tests. The suite
  now verifies that Gallery and system-share failures are propagated safely
  while temporary output cleanup remains under the caller's control, and
  protects the Android/iOS least-privilege permission configuration, and
  includes visual baselines for Home and compact/large onboarding layouts.
  It also verifies that an initially applied preset is recorded and that
  returning to Home refreshes the recent-preset list, plus safe handling of a
  system-transcoded HEIC JPEG. It also protects the iOS 13 Swift Package
  integration needed by the explicit camera-permission request.
  Both ran
  from an ASCII-only temporary checkout with `TEMP`, `TMP`, and `PUB_CACHE`
  set to ASCII paths; the default Unicode Windows user path can stall Flutter
  test compilation on this workstation.
- An earlier x64 emulator boot attempt did not finish Android's package and
  window services. A clean later boot completed, and the successful
  installation and interactive flow are recorded above.
- The current ARM64 APK was rebuilt after the initial-preset history, Home
  refresh, system-transcoded HEIC input fixes, and direct camera-permission
  handling.
  `FrameFit-arm64-permission-release-20260717.apk` is 19.6MB;
  SHA-256 is
  `B81600B38C4C862117D681C69342AF8E79473FC928A8735A9381CEF33E094EE6`,
  and its Android APK Signature Scheme v2 signature verified successfully.
- On a clean Android 16 x64 install, FrameFit requested camera access only
  after `카메라로 촬영` was tapped. Rejecting that prompt returned to the app
  with the specific retryable permission message rather than a camera-backend
  timeout. Widget tests cover the permanent-denial settings action.
- On the same emulator, granting the camera permission opened the virtual
  camera successfully. A captured JPEG reached the editor, received the
  `자연 보정` preset, and was exported at original resolution as
  `FrameFit-CAP1602257483228859603-20260717095727358313.jpg`. MediaStore
  confirmed the saved result under `Pictures/FrameFit/`.

## Accepted Android MVP boundary — 2026-07-17

- The product owner accepted Android MVP completion based on the real-device
  records, latest Android emulator flow, automated tests, and passing CI.
- GitHub repository-visibility administration and direct iPhone execution are
  tracked as separate follow-up work and are not represented as completed.

갱신일: 2026-07-16

이 문서는 구현 의도와 실제 검증을 구분한다. 체크되지 않은 항목을 완료로
표현하지 않는다.

## 구현됨

- 기기 사진 선택과 앱 내 전·후면 카메라 촬영
- JPEG/PNG 헤더 및 파일 확장자 검증, 40MB 입력 제한
- 수치 기반 12개 프리셋, 강도 조절, 수동 조정, 중앙 비율 자르기
- 실제 픽셀 미리보기, 길게 눌러 원본 비교, 원본 해상도 내보내기
- JPEG/PNG 출력, FrameFit 앨범 저장, 시스템 공유
- 내보내기 전 JPEG/PNG 형식, 원본/긴 변 2048px 크기, JPEG 품질 선택
- EXIF 방향 보정 및 새 JPEG의 EXIF/XMP/IPTC/comment 제거
- 즐겨찾기, 최근 프리셋 빠른 시작, 로컬 전용 처리
- 카메라 영구 권한 거부 시 앱 설정 화면 열기

## 자동 검증 기록

- `flutter analyze lib test`: 통과
- 20개 단위·위젯 테스트: 통과

자동 테스트는 다음을 다룬다.

- 프리셋 JSON, 값 범위, 강도 보간
- 실제 JPEG/PNG 처리, 결정적 그레인, EXIF 회전, 메타데이터 블록 제거
- 빈/과대/지원하지 않는/확장자 불일치 입력
- 임시 내보내기 파일 생성과 삭제
- 홈의 실제 사진 기반 프리셋 예시와 주 진입 동작
- 편집기의 초기화와 내보내기 설정 화면
- 360×800, 390×844, 412×915 및 글자 크기 130%에서 홈의 주요 행동 버튼

## Android 실사용 확인 기록

기존 [DEVICE_TEST_CHECKLIST.md](DEVICE_TEST_CHECKLIST.md)에 다음 확인이
기록되어 있다.

- Galaxy S23 / Android 16에서 실제 PNG, 12MP JPEG 입력
- 프리셋 적용·강도 조절·원본 비교·고해상도 내보내기
- FrameFit 앨범 저장과 시스템 공유 창
- 전면·후면 카메라 촬영 후 편집기 진입

## 최신 Android 배포 파일

- `FrameFit-arm64-heic-release-20260717.apk`: Galaxy S23 등 arm64 기기용
- 2026-07-17 생성 크기: 약 19.6MB
- ABI 분리 release 빌드라 디버그 범용 APK보다 작다.
- 현재 APK는 실기기 테스트용 디버그 키로 서명되며 공개 배포용은 아니다.

## 아직 직접 증명되지 않은 항목

- iPhone 실제 기기 전체 흐름
- 실제 갤러리의 세로 EXIF 샘플과 투명 PNG를 통한 최종 수동 확인
- 영구 권한 거부 뒤 설정 화면에서 되돌아오는 흐름의 최종 수동 확인
- 360×800, 390×844, 412×915 및 글자 크기 130%의 golden/실기기 수동 화면 검증

## 의도적인 MVP 제한

- HEIC, RAW, 일괄 편집, 사용자 정의 프리셋, 서버 동기화, 계정은 없다.
- 사진 내용 AI 추천, 얼굴/객체 분석, 실시간 구도 점수도 제공하지 않는다.
- 카메라 안내는 분석 결과가 아닌 규칙 기반 가이드다.
