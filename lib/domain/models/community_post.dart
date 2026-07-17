class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorNickname,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    this.presetId,
    this.presetIntensity,
    this.compositionId,
    this.likeCount = 0,
    this.saveCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
    this.savedByMe = false,
  });

  final String id;
  final String authorId;
  final String authorNickname;
  final String imageUrl;
  final String caption;
  final DateTime createdAt;
  final String? presetId;
  final double? presetIntensity;
  final String? compositionId;
  final int likeCount;
  final int saveCount;
  final int commentCount;
  final bool likedByMe;
  final bool savedByMe;

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    id: json['id'] as String,
    authorId: json['author_id'] as String,
    authorNickname: (json['author_nickname'] as String?) ?? 'FrameFit 사용자',
    imageUrl: json['image_url'] as String,
    caption: (json['caption'] as String?) ?? '',
    presetId: json['preset_id'] as String?,
    presetIntensity: (json['preset_intensity'] as num?)?.toDouble(),
    compositionId: json['composition_id'] as String?,
    likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    saveCount: (json['save_count'] as num?)?.toInt() ?? 0,
    commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
    likedByMe: json['liked_by_me'] as bool? ?? false,
    savedByMe: json['saved_by_me'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
  );

  CommunityPost copyWith({
    int? likeCount,
    int? saveCount,
    int? commentCount,
    bool? likedByMe,
    bool? savedByMe,
  }) => CommunityPost(
    id: id,
    authorId: authorId,
    authorNickname: authorNickname,
    imageUrl: imageUrl,
    caption: caption,
    presetId: presetId,
    presetIntensity: presetIntensity,
    compositionId: compositionId,
    likeCount: likeCount ?? this.likeCount,
    saveCount: saveCount ?? this.saveCount,
    commentCount: commentCount ?? this.commentCount,
    likedByMe: likedByMe ?? this.likedByMe,
    savedByMe: savedByMe ?? this.savedByMe,
    createdAt: createdAt,
  );
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.authorNickname,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String authorNickname;
  final String body;
  final DateTime createdAt;

  factory CommunityComment.fromJson(Map<String, dynamic> json) =>
      CommunityComment(
        id: json['id'] as String,
        authorNickname: (json['author_nickname'] as String?) ?? 'FrameFit 사용자',
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );
}

enum CommunityFeedSort { recommended, newest }

class CommunityPostDraft {
  const CommunityPostDraft({
    required this.imageBytes,
    required this.caption,
    required this.nickname,
    this.presetId,
    this.presetIntensity,
    this.compositionId,
  });

  final List<int> imageBytes;
  final String caption;
  final String nickname;
  final String? presetId;
  final double? presetIntensity;
  final String? compositionId;
}
