import '../models/community_post.dart';

abstract interface class CommunityRepository {
  bool get isConfigured;

  Future<List<CommunityPost>> fetchFeed({
    CommunityFeedSort sort = CommunityFeedSort.recommended,
  });

  Future<CommunityPost> createPost(CommunityPostDraft draft);

  Future<void> setLiked(String postId, {required bool liked});

  Future<void> setSaved(String postId, {required bool saved});

  Future<List<CommunityComment>> fetchComments(String postId);

  Future<CommunityComment> addComment(String postId, String body);

  Future<void> reportPost(String postId, String reason);
}

class CommunityUnavailableException implements Exception {
  const CommunityUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}
