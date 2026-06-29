import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framefit/app.dart';
import 'package:framefit/core/router/app_routes.dart';
import 'package:framefit/data/mock/mock_templates.dart';
import 'package:framefit/data/models/edit_session.dart';
import 'package:framefit/data/repositories/template_repository.dart';
import 'package:framefit/features/preview/preview_screen.dart';
import 'package:framefit/features/result/result_screen.dart';

void main() {
  const onboardingCta = Key('onboardingPrimaryCta');
  const homePrimaryCta = Key('homePrimaryCta');
  const homeSecondaryCta = Key('homeSecondaryCta');
  const analysisTemplatesCta = Key('analysisTemplatesCta');
  const templateProfileCard = Key('recommendedTemplateCard-깔끔한-프로필');
  const templateDetailStartCta = Key('templateDetailStartCta');
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
  const cameraEditorSurface = Key('cameraEditorSurface');
  const cameraModeRail = Key('cameraModeRail');
  const cameraToolDock = Key('cameraToolDock');
  const templateCuratedHeader = Key('templateCuratedHeader');
  const templateCategoryTabs = Key('templateCategoryTabs');
  const templatePresetList = Key('templatePresetList');
  const previewComparisonStage = Key('previewComparisonStage');
  const previewDirectionList = Key('previewDirectionList');

  Future<void> completeOnboarding(WidgetTester tester) async {
    expect(find.text('찍기 전에 한 번만 맞춰요'), findsOneWidget);
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

  testWidgets('FrameFit primary flow reaches template detail and mock camera', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());

    await completeOnboarding(tester);
    expect(find.textContaining('오늘 찍을 사진'), findsOneWidget);
    expect(find.byKey(homeEditorialHeader), findsOneWidget);
    expect(find.byKey(homeLeadGallery), findsOneWidget);

    await tester.tap(find.byKey(homePrimaryCta));
    await tester.pumpAndSettle();
    expect(find.text('프로필'), findsWidgets);
    expect(find.text('얼굴을 조금만 오른쪽으로 옮겨볼까요?'), findsOneWidget);
    expect(find.byKey(const Key('cameraGridOverlay')), findsOneWidget);
    expect(find.byKey(const Key('subjectGuideBox')), findsOneWidget);
    expect(find.byKey(const Key('movementHintArrow')), findsOneWidget);
    expect(find.textContaining('프로필 · 여백 적당'), findsOneWidget);
    expect(find.textContaining('배경을 살짝 흐리면'), findsWidgets);
    expect(find.byTooltip('갤러리'), findsOneWidget);
    expect(find.byTooltip('템플릿'), findsOneWidget);
    await tester.tap(find.text('음식'));
    await tester.pumpAndSettle();
    expect(find.text('접시를 가운데로 조금만 당겨보세요.'), findsOneWidget);
    expect(find.textContaining('음식'), findsWidgets);

    await tester.tap(find.byKey(const Key('captureButton')));
    await tester.pumpAndSettle();
    expect(find.text('이 사진은 이렇게 보정해볼게요'), findsOneWidget);
    expect(find.text('초점'), findsOneWidget);
    expect(find.text('구도'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(analysisTemplatesCta),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -80));
    await tester.pumpAndSettle();
    expect(find.text('왜 이 스타일인가요?'), findsOneWidget);
    expect(find.text('어울리는 스타일 보기'), findsOneWidget);

    await tester.tap(find.byKey(analysisTemplatesCta));
    await tester.pumpAndSettle();
    expect(find.text('스타일 고르기'), findsOneWidget);
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
    expect(find.byKey(const Key('templateDetailScreen')), findsOneWidget);
    expect(find.textContaining('깔끔한 프로필'), findsWidgets);
    expect(find.text('찍기 전에'), findsOneWidget);
    expect(find.text('화면에서 맞출 것'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(templateDetailStartCta),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(templateDetailStartCta));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('captureButton')), findsOneWidget);
    expect(find.text('깔끔한 프로필'), findsWidgets);
    expect(find.textContaining('기준으로 맞춰보는 중'), findsOneWidget);
    expect(find.textContaining('LIVE AI'), findsNothing);
  });

  testWidgets('onboarding uses editorial reference composition and CTA works', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const FrameFitApp());

    expect(find.byKey(onboardingEditorialFrame), findsOneWidget);
    expect(find.byKey(onboardingReferenceStrip), findsOneWidget);
    expect(find.text('찍기 전에 한 번만 맞춰요'), findsOneWidget);

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
    expect(find.byKey(const Key('homeCategoryEntryRail')), findsOneWidget);
    expect(find.text('촬영 전 체크'), findsOneWidget);

    await tester.tap(find.byKey(const Key('categoryChip-음식')));
    await tester.pumpAndSettle();
    expect(find.text('스타일 고르기'), findsOneWidget);
    expect(find.text('음식'), findsWidgets);
    expect(find.text('맛있어 보이는 음식'), findsWidgets);
    expect(find.text('깔끔한 프로필'), findsNothing);

    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(homePrimaryCta));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('captureButton')), findsOneWidget);

    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(homeSecondaryCta));
    await tester.pumpAndSettle();
    expect(find.text('스타일 고르기'), findsOneWidget);
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
    expect(find.text('접시를 가운데로 조금만 당겨보세요.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('captureButton')));
    await tester.pumpAndSettle();
    expect(find.text('이 사진은 이렇게 보정해볼게요'), findsOneWidget);
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

    expect(find.byKey(const Key('templateDetailScreen')), findsOneWidget);
    expect(find.text('맛있어 보이는 음식'), findsWidgets);
    expect(find.textContaining('따뜻하고 먹음직스럽게'), findsWidgets);
  });

  testWidgets('preview directions select style and route result arguments', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final template = mockTemplates.first;
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.preview: (_) => const PreviewScreen(),
          AppRoutes.result: (_) => const ResultScreen(),
        },
        initialRoute: AppRoutes.preview,
        onGenerateInitialRoutes: (initialRoute) => [
          MaterialPageRoute(
            settings: RouteSettings(
              name: AppRoutes.preview,
              arguments: PreviewArgs(template: template),
            ),
            builder: (_) => const PreviewScreen(),
          ),
        ],
      ),
    );
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

    expect(find.text('이렇게 나왔어요'), findsOneWidget);
    expect(find.textContaining('깔끔한 프로필'), findsWidgets);
    expect(find.textContaining('밝게'), findsWidgets);
  });

  test('mock template catalog contains beginner trust signals', () {
    expect(mockTemplates.length, greaterThanOrEqualTo(20));

    for (final template in mockTemplates) {
      expect(template.id, isNotEmpty);
      expect(template.title, template.name);
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
      expect(template.sampleVisual.label, isNotEmpty);
      expect(
        template.sampleVisual.baseColorHex,
        matches(RegExp(r'^#[0-9A-F]{6}$')),
      );
      expect(
        template.sampleVisual.accentColorHex,
        matches(RegExp(r'^#[0-9A-F]{6}$')),
      );
      expect(template.aspectRatio, isNotEmpty);
      expect(template.targetSubjectType, isNotEmpty);
      expect(template.compositionGuidance, isNotEmpty);
      expect(template.captureTips, isNotEmpty);
      expect(template.feedbackHints, isNotEmpty);
      expect(template.editRecipe.brightness, isNotEmpty);
      expect(template.editRecipe.tone, isNotEmpty);
    }
  });

  test('mock template catalog includes required roadmap templates', () {
    final names = mockTemplates.map((template) => template.name).toSet();

    expect(
      names,
      containsAll([
        '기본 프로필',
        '상반신 프로필',
        '전신 샷',
        '푸드 포토',
        '상품 사진',
        '여행 인물',
        '카페 무드샷',
        '미니멀 배경 샷',
      ]),
    );
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

  test('template repository exposes useful catalog queries', () {
    const repository = TemplateRepository();
    final all = repository.all();
    final expectedRecommended = all.toList()
      ..sort((a, b) {
        final scoreComparison = b.beginnerFriendlyScore.compareTo(
          a.beginnerFriendlyScore,
        );
        if (scoreComparison != 0) {
          return scoreComparison;
        }
        return b.rating.compareTo(a.rating);
      });

    expect(repository.categories.first, '전체');
    expect(repository.categories, containsAll(['프로필', '여행', '음식', '상품', '감성']));
    expect(repository.byId(all.first.id), all.first);
    expect(repository.byId('missing-template-id'), isNull);
    expect(repository.recommended(), hasLength(3));
    expect(
      repository.recommended(limit: 5),
      orderedEquals(expectedRecommended.take(5)),
    );
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

  testWidgets('template detail uses repository data and starts mock camera', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const repository = TemplateRepository();
    final template = repository.byId('food-photo')!;

    await tester.pumpWidget(const FrameFitApp());
    await completeOnboarding(tester);
    await tester.tap(find.byKey(homeSecondaryCta));
    await tester.pumpAndSettle();
    await tester.tap(find.text('음식'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(Key('templateCard-${template.id}')),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.byKey(Key('templateCard-${template.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('templateCard-${template.id}')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('templateDetailScreen')), findsOneWidget);
    expect(find.text(template.name), findsWidgets);
    expect(find.text(template.description), findsWidgets);
    expect(find.text(template.compositionGuidance), findsOneWidget);
    expect(find.text(template.captureTips.first), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(templateDetailStartCta),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(templateDetailStartCta));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(templateDetailStartCta));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('captureButton')), findsOneWidget);
    expect(find.text(template.name), findsWidgets);
    expect(find.textContaining('기준으로 맞춰보는 중'), findsOneWidget);
    expect(find.textContaining('실시간 탐지'), findsNothing);
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
      find.byKey(templateDetailStartCta),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    Navigator.of(tester.element(find.byKey(templateDetailStartCta))).pushNamed(
      AppRoutes.preview,
      arguments: PreviewArgs(template: mockTemplates.first),
    );
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

    expect(find.text('스타일 고르기'), findsOneWidget);
    expect(find.text('깔끔한 프로필'), findsWidgets);
  });
}
