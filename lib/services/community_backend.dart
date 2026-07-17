import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/community_post.dart';
import '../domain/services/community_repository.dart';
import 'community_photo_service.dart';

class CommunityBackend {
  CommunityBackend._();

  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured =>
      _url.trim().isNotEmpty && _publishableKey.trim().isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    await Supabase.initialize(url: _url, publishableKey: _publishableKey);
  }

  static CommunityRepository createRepository() => isConfigured
      ? SupabaseCommunityRepository(Supabase.instance.client)
      : const UnavailableCommunityRepository();
}

class UnavailableCommunityRepository implements CommunityRepository {
  const UnavailableCommunityRepository();

  static const _message =
      '커뮤니티 서버 연결이 아직 설정되지 않았어요. 앱 빌드에 공개용 Supabase 주소와 키를 설정해 주세요.';

  @override
  bool get isConfigured => false;

  Never _unavailable() => throw const CommunityUnavailableException(_message);

  @override
  Future<CommunityComment> addComment(String postId, String body) async =>
      _unavailable();

  @override
  Future<CommunityPost> createPost(CommunityPostDraft draft) async =>
      _unavailable();

  @override
  Future<List<CommunityComment>> fetchComments(String postId) async =>
      _unavailable();

  @override
  Future<List<CommunityPost>> fetchFeed({
    CommunityFeedSort sort = CommunityFeedSort.recommended,
  }) async => _unavailable();

  @override
  Future<void> reportPost(String postId, String reason) async => _unavailable();

  @override
  Future<void> setLiked(String postId, {required bool liked}) async =>
      _unavailable();

  @override
  Future<void> setSaved(String postId, {required bool saved}) async =>
      _unavailable();
}

class SupabaseCommunityRepository implements CommunityRepository {
  SupabaseCommunityRepository(
    this._client, {
    CommunityPhotoService photoService = const CommunityPhotoService(),
  }) : _photoService = photoService;

  final SupabaseClient _client;
  final CommunityPhotoService _photoService;

  @override
  bool get isConfigured => true;

  Future<User> _ensureUser({String? nickname}) async {
    var user = _client.auth.currentUser;
    if (user == null) {
      final response = await _client.auth.signInAnonymously();
      user = response.user;
    }
    if (user == null) {
      throw const CommunityUnavailableException('커뮤니티 계정을 만들지 못했어요.');
    }
    final safeNickname = _normalizeNickname(nickname);
    final existing = await _client
        .from('profiles')
        .select('nickname')
        .eq('id', user.id)
        .maybeSingle();
    if (existing == null || safeNickname != null) {
      await _client.from('profiles').upsert({
        'id': user.id,
        'nickname':
            safeNickname ??
            'Frame${user.id.replaceAll('-', '').substring(0, 6)}',
      });
    }
    return user;
  }

  @override
  Future<List<CommunityPost>> fetchFeed({
    CommunityFeedSort sort = CommunityFeedSort.recommended,
  }) async {
    await _ensureUser();
    final response = await _client.rpc(
      'get_community_feed',
      params: {
        'feed_sort': sort == CommunityFeedSort.newest
            ? 'newest'
            : 'recommended',
        'page_limit': 30,
        'page_offset': 0,
      },
    );
    return (response as List<dynamic>)
        .map(
          (item) =>
              CommunityPost.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<CommunityPost> createPost(CommunityPostDraft draft) async {
    final user = await _ensureUser(nickname: draft.nickname);
    final prepared = await _photoService.prepareForUpload(draft.imageBytes);
    final objectPath =
        '${user.id}/${DateTime.now().toUtc().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}.jpg';
    await _client.storage
        .from('community-photos')
        .uploadBinary(
          objectPath,
          prepared,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            cacheControl: '31536000',
            upsert: false,
          ),
        );
    final imageUrl = _client.storage
        .from('community-photos')
        .getPublicUrl(objectPath);
    try {
      final row = await _client
          .from('community_posts')
          .insert({
            'author_id': user.id,
            'image_path': objectPath,
            'image_url': imageUrl,
            'caption': draft.caption.trim(),
            'preset_id': draft.presetId,
            'preset_intensity': draft.presetIntensity,
            'composition_id': draft.compositionId,
          })
          .select('id')
          .single();
      final posts = await fetchFeed(sort: CommunityFeedSort.newest);
      return posts.firstWhere((post) => post.id == row['id']);
    } catch (_) {
      await _client.storage.from('community-photos').remove([objectPath]);
      rethrow;
    }
  }

  @override
  Future<void> setLiked(String postId, {required bool liked}) async {
    final user = await _ensureUser();
    if (liked) {
      await _client.from('post_likes').upsert({
        'post_id': postId,
        'user_id': user.id,
      });
    } else {
      await _client
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
    }
  }

  @override
  Future<void> setSaved(String postId, {required bool saved}) async {
    final user = await _ensureUser();
    if (saved) {
      await _client.from('post_saves').upsert({
        'post_id': postId,
        'user_id': user.id,
      });
    } else {
      await _client
          .from('post_saves')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
    }
  }

  @override
  Future<List<CommunityComment>> fetchComments(String postId) async {
    await _ensureUser();
    final response = await _client.rpc(
      'get_post_comments',
      params: {'target_post_id': postId},
    );
    return (response as List<dynamic>)
        .map(
          (item) =>
              CommunityComment.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<CommunityComment> addComment(String postId, String body) async {
    final user = await _ensureUser();
    final normalized = body.trim();
    if (normalized.isEmpty || normalized.length > 500) {
      throw const CommunityUnavailableException('댓글은 1~500자로 입력해 주세요.');
    }
    final row = await _client
        .from('post_comments')
        .insert({'post_id': postId, 'author_id': user.id, 'body': normalized})
        .select('id')
        .single();
    final comments = await fetchComments(postId);
    return comments.firstWhere((comment) => comment.id == row['id']);
  }

  @override
  Future<void> reportPost(String postId, String reason) async {
    final user = await _ensureUser();
    await _client.from('post_reports').upsert({
      'post_id': postId,
      'reporter_id': user.id,
      'reason': reason.trim().substring(0, min(300, reason.trim().length)),
    });
  }
}

String? _normalizeNickname(String? nickname) {
  final value = nickname?.trim();
  if (value == null || value.isEmpty) return null;
  if (value.length < 2 || value.length > 20) {
    throw const CommunityUnavailableException('닉네임은 2~20자로 입력해 주세요.');
  }
  return value;
}
