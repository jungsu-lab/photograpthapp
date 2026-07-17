import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:framefit/domain/models/community_post.dart';
import 'package:framefit/domain/services/community_repository.dart';
import 'package:framefit/features/community/community_screen.dart';
import 'package:framefit/features/edit_hub/edit_hub_screen.dart';
import 'package:framefit/services/community_backend.dart';

void main() {
  testWidgets('edit hub separates photo editing from the community', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EditHubScreen(
          communityRepository: UnavailableCommunityRepository(),
        ),
      ),
    );

    expect(find.text('사진 편집'), findsOneWidget);
    expect(find.text('커뮤니티'), findsOneWidget);

    await tester.tap(find.text('커뮤니티'));
    await tester.pumpAndSettle();
    expect(find.text('커뮤니티 서버 연결이 필요해요.'), findsOneWidget);
  });

  testWidgets('community feed recommends and saves a real repository post', (
    tester,
  ) async {
    final repository = _FakeCommunityRepository();
    await tester.pumpWidget(
      MaterialApp(home: CommunityScreen(repository: repository)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('사진가 민지'), findsOneWidget);
    expect(find.text('이 색감으로 편집'), findsOneWidget);
    expect(find.text('이 구도로 촬영'), findsOneWidget);

    final likeButton = find.byKey(const ValueKey('community-like-post-1'));
    await tester.ensureVisible(likeButton);
    await tester.pumpAndSettle();
    await tester.tap(likeButton);
    await tester.pump();
    expect(repository.liked, isTrue);

    final saveButton = find.byKey(const ValueKey('community-save-post-1'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pump();
    expect(repository.saved, isTrue);
  });
}

class _FakeCommunityRepository implements CommunityRepository {
  bool liked = false;
  bool saved = false;

  @override
  bool get isConfigured => true;

  @override
  Future<List<CommunityPost>> fetchFeed({
    CommunityFeedSort sort = CommunityFeedSort.recommended,
  }) async => [
    CommunityPost(
      id: 'post-1',
      authorId: 'user-1',
      authorNickname: '사진가 민지',
      imageUrl: 'https://invalid.framefit.local/photo.jpg',
      caption: '골목의 리딩 라인을 활용했어요.',
      presetId: 'kyoto-film',
      presetIntensity: .78,
      compositionId: 'leading-lines',
      likeCount: 4,
      saveCount: 2,
      createdAt: DateTime(2026, 7, 17),
    ),
  ];

  @override
  Future<void> setLiked(String postId, {required bool liked}) async {
    this.liked = liked;
  }

  @override
  Future<void> setSaved(String postId, {required bool saved}) async {
    this.saved = saved;
  }

  @override
  Future<CommunityComment> addComment(String postId, String body) =>
      throw UnimplementedError();

  @override
  Future<CommunityPost> createPost(CommunityPostDraft draft) =>
      throw UnimplementedError();

  @override
  Future<List<CommunityComment>> fetchComments(String postId) async => [];

  @override
  Future<void> reportPost(String postId, String reason) async {}
}
