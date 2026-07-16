# FrameFit MVP 상태 기록

## Verification note — 2026-07-17

- The ARM64 release APK was rebuilt successfully and its APK Signature Scheme
  v2 signature was verified.
- Preset model, preset catalogue, composition catalogue, and real JPEG/PNG
  processor tests passed using the standalone Dart test runner.
- On 2026-07-17, `flutter analyze` completed with no issues and
  `flutter test --concurrency=1` completed with 37 passing tests. Both ran
  from an ASCII-only temporary checkout with `TEMP`, `TMP`, and `PUB_CACHE`
  set to ASCII paths; the default Unicode Windows user path can stall Flutter
  test compilation on this workstation.
- A local x64 debug APK was built successfully on 2026-07-17. Its emulator
  image did not finish starting Android's package and window services, so no
  emulator installation or interactive-flow result is claimed from that run.
- The current ARM64 APK was rebuilt successfully after compact-screen
  onboarding responsiveness was fixed. Its SHA-256 is
  `EEB0BDBD286BEFD36CFE90B9E258E99AE0251F4258C39E2A3E34620515514600`,
  and its Android APK Signature Scheme v2 signature verified successfully.

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

- `FrameFit-arm64-release.apk`: Galaxy S23 등 arm64 기기용
- 2026-07-16 생성 크기: 약 19.2MB
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
