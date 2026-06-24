import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framefit/app.dart';
import 'package:framefit/data/mock/mock_templates.dart';
import 'package:framefit/data/repositories/template_repository.dart';

void main() {
  const onboardingCta = Key('onboardingPrimaryCta');
  const homePrimaryCta = Key('homePrimaryCta');
  const homeSecondaryCta = Key('homeSecondaryCta');
  const analysisTemplatesCta = Key('analysisTemplatesCta');
  const templateProfileCard = Key('recommendedTemplateCard-깔끔한-프로필');
  const bottomNavCamera = Key('bottomNav-촬영');
  const bottomNavTemplates = Key('bottomNav-템플릿');
  const previewBrightOption = Key('previewOption-밝게');
  const previewApplyCta = Key('previewApplyCta');
  const resultTryAnotherTemplateCta = Key('resultTryAnotherTemplateCta');
  const onboardingEditorialFrame = Key('onboardingEditorialFrame');
  const onboardingReferenceStrip = Key('onboardingReferenceStrip');
  const homeEditorialHeader = Key('homeEditorialHeader');
  const homeLeadGallery = Key('homeLeadGallery');
  const homeQuickActions = Key('homeQuickActions');
  const homeTemplateRail = Key('homeTemplateRail');
  const cameraEditorSurface = Key('cameraEditorSurface');
  const cameraModeRail = Key('cameraModeRail');
  const cameraToolDock = Key('cameraToolDock');
  const templateCuratedHeader = Key('templateCuratedHeader');
  const templateCategoryTabs = Key('templateCategoryTabs');
  const templatePresetList = Key('templatePresetList');
  const previewComparisonStage = Key('previewComparisonStage');
  const previewDirectionList = Key('previewDirectionList');

  Future<void> completeOnboarding(WidgetTester tester) async {
    expect(find.text('사진 찍기 전에 알려드릴게요'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    await tester.tap(find.byKey(onboardingCta));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.tap(find.byKey(onboardingCta));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);
    await tester.tap(find.byKey(onboardingCta));
    await tester.pumpAndSettle();
  }

  testWidgets('FrameFit primary flow reaches the result screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());

    await completeOnboarding(tester);
    expect(find.text('오늘 사진, 찍기 전에 먼저 맞춰볼까요?'), findsOneWidget);
    expect(find.byKey(homeEditorialHeader), findsOneWidget);
    expect(find.byKey(homeLeadGallery), findsOneWidget);

    await tester.tap(find.byKey(homePrimaryCta));
    await tester.pumpAndSettle();
    expect(find.text('프로필'), findsWidgets);
    expect(find.text('얼굴을 살짝 오른쪽으로 옮기면 여백이 더 자연스러워요.'), findsOneWidget);
    expect(find.byKey(const Key('cameraGridOverlay')), findsOneWidget);
    expect(find.byKey(const Key('subjectGuideBox')), findsOneWidget);
    expect(find.byKey(const Key('movementHintArrow')), findsOneWidget);
    expect(find.textContaining('프로필 모드'), findsOneWidget);
    expect(find.textContaining('템플릿 추천'), findsWidgets);
    expect(find.byTooltip('갤러리'), findsOneWidget);
    expect(find.byTooltip('템플릿'), findsOneWidget);
    await tester.tap(find.text('음식'));
    await tester.pumpAndSettle();
    expect(find.text('접시가 화면 왼쪽으로 치우쳤어요. 중앙에 조금만 맞춰보세요.'), findsOneWidget);
    expect(find.textContaining('음식 모드'), findsOneWidget);

    await tester.tap(find.byKey(const Key('captureButton')));
    await tester.pumpAndSettle();
    expect(find.text('사진 분석 완료'), findsOneWidget);
    expect(find.text('초점'), findsOneWidget);
    expect(find.text('구도'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(analysisTemplatesCta),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -80));
    await tester.pumpAndSettle();
    expect(find.text('추천 이유'), findsOneWidget);
    expect(find.text('추천 템플릿 보기'), findsOneWidget);

    await tester.tap(find.byKey(analysisTemplatesCta));
    await tester.pumpAndSettle();
    expect(find.text('템플릿'), findsOneWidget);
    expect(find.text('깔끔한 프로필'), findsWidgets);
    expect(find.text('프로필'), findsWidgets);
    expect(find.textContaining('12,830명 사용'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(templateProfileCard),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(templateProfileCard));
    await tester.pumpAndSettle();
    expect(find.text('시안 미리보기'), findsOneWidget);
    expect(find.text('자연스럽게'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(previewBrightOption),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(previewBrightOption));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('selectedPreview-밝게')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(previewApplyCta),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(previewApplyCta));
    await tester.pumpAndSettle();
    expect(find.text('완성됐어요'), findsOneWidget);
    expect(find.textContaining('깔끔한 프로필'), findsWidgets);
    expect(find.textContaining('밝게'), findsWidgets);
    expect(find.text('저장하기'), findsOneWidget);
    expect(find.text('다른 템플릿 적용'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('결과가 마음에 드나요?'), 120);
    expect(find.text('좋아요'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
    expect(find.text('별로'), findsOneWidget);
  });

  testWidgets('onboarding uses editorial reference composition and CTA works', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());

    expect(find.byKey(onboardingEditorialFrame), findsOneWidget);
    expect(find.byKey(onboardingReferenceStrip), findsOneWidget);
    expect(find.text('사진 찍기 전에 알려드릴게요'), findsOneWidget);

    await tester.tap(find.byKey(onboardingCta));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(onboardingCta));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(onboardingCta));
    await tester.pumpAndSettle();

    expect(find.byKey(homeEditorialHeader), findsOneWidget);
  });

  testWidgets('home uses editorial gallery layout and CTAs work', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());
    await completeOnboarding(tester);

    expect(find.byKey(homeEditorialHeader), findsOneWidget);
    expect(find.byKey(homeLeadGallery), findsOneWidget);
    expect(find.byKey(homeQuickActions), findsOneWidget);
    expect(find.byKey(homeTemplateRail), findsOneWidget);

    await tester.tap(find.byKey(homePrimaryCta));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('captureButton')), findsOneWidget);

    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(homeSecondaryCta));
    await tester.pumpAndSettle();
    expect(find.text('템플릿'), findsOneWidget);
  });

  testWidgets('camera uses editor surface and overlay does not block taps', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());
    await completeOnboarding(tester);
    await tester.tap(find.byKey(homePrimaryCta));
    await tester.pumpAndSettle();

    expect(find.byKey(cameraEditorSurface), findsOneWidget);
    expect(find.byKey(cameraModeRail), findsOneWidget);
    expect(find.byKey(cameraToolDock), findsOneWidget);
    expect(find.byKey(const Key('cameraGridOverlay')), findsOneWidget);

    await tester.tap(find.text('음식'));
    await tester.pumpAndSettle();
    expect(find.text('접시가 화면 왼쪽으로 치우쳤어요. 중앙에 조금만 맞춰보세요.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('captureButton')));
    await tester.pumpAndSettle();
    expect(find.text('사진 분석 완료'), findsOneWidget);
  });

  testWidgets('template browser filters categories and opens selected preset', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());
    await completeOnboarding(tester);
    await tester.tap(find.byKey(homeSecondaryCta));
    await tester.pumpAndSettle();

    expect(find.byKey(templateCuratedHeader), findsOneWidget);
    expect(find.byKey(templateCategoryTabs), findsOneWidget);
    expect(find.byKey(templatePresetList), findsOneWidget);

    await tester.tap(find.text('음식'));
    await tester.pumpAndSettle();
    expect(find.text('맛있어 보이는 음식'), findsWidgets);
    expect(find.text('깔끔한 프로필'), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const Key('recommendedTemplateCard-맛있어-보이는-음식')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.byKey(const Key('recommendedTemplateCard-맛있어-보이는-음식')),
    );
    await tester.pumpAndSettle();

    expect(find.text('시안 미리보기'), findsOneWidget);
    expect(find.text('맛있어 보이는 음식'), findsWidgets);
  });

  testWidgets('preview directions select style and route result arguments', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());
    await completeOnboarding(tester);
    await tester.tap(find.byKey(homeSecondaryCta));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(templateProfileCard),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(templateProfileCard));
    await tester.pumpAndSettle();

    expect(find.byKey(previewComparisonStage), findsOneWidget);
    expect(find.byKey(previewDirectionList), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(previewBrightOption),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(previewBrightOption));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('selectedPreview-밝게')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(previewApplyCta),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(previewApplyCta));
    await tester.pumpAndSettle();

    expect(find.text('완성됐어요'), findsOneWidget);
    expect(find.textContaining('깔끔한 프로필'), findsWidgets);
    expect(find.textContaining('밝게'), findsWidgets);
  });

  test('mock template catalog contains beginner trust signals', () {
    expect(mockTemplates.length, greaterThanOrEqualTo(20));

    for (final template in mockTemplates) {
      expect(template.id, isNotEmpty);
      expect(template.name, isNotEmpty);
      expect(template.description, isNotEmpty);
      expect([
        '프로필',
        '셀카',
        '음식',
        '여행',
        '상품',
        '감성',
      ], contains(template.category));
      expect(template.rating, greaterThanOrEqualTo(4.0));
      expect(template.usageCount, greaterThan(0));
      expect(template.beginnerFriendlyScore, inInclusiveRange(0, 100));
      expect(template.tags, isNotEmpty);
      expect(template.recommendationReason, isNotEmpty);
      expect(template.editRecipe.brightness, isNotEmpty);
      expect(template.editRecipe.tone, isNotEmpty);
    }
  });

  test('template repository filters categories correctly', () {
    const repository = TemplateRepository();

    expect(repository.byCategory('전체'), hasLength(mockTemplates.length));

    for (final category in ['프로필', '셀카', '음식', '여행', '상품', '감성']) {
      final filtered = repository.byCategory(category);
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((template) => template.category == category),
        isTrue,
      );
    }
  });

  testWidgets('template category filtering shows only selected category', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());
    await completeOnboarding(tester);
    await tester.tap(find.byKey(homeSecondaryCta));
    await tester.pumpAndSettle();

    await tester.tap(find.text('음식'));
    await tester.pumpAndSettle();

    expect(find.text('맛있어 보이는 음식'), findsWidgets);
    expect(find.text('깔끔한 프로필'), findsNothing);
  });

  testWidgets('home bottom navigation tabs route to camera and templates', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());
    await completeOnboarding(tester);

    await tester.tap(find.byKey(bottomNavCamera));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('captureButton')), findsOneWidget);

    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(bottomNavTemplates));
    await tester.pumpAndSettle();
    expect(find.text('깔끔한 프로필'), findsWidgets);
  });

  testWidgets('result action routes back to template screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());
    await completeOnboarding(tester);
    await tester.tap(find.byKey(homeSecondaryCta));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(templateProfileCard),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(templateProfileCard));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(previewApplyCta),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(previewApplyCta));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(resultTryAnotherTemplateCta));
    await tester.pumpAndSettle();

    expect(find.text('템플릿'), findsOneWidget);
    expect(find.text('깔끔한 프로필'), findsWidgets);
  });
}
