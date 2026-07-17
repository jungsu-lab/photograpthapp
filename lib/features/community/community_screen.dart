import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../data/composition/composition_catalog.dart';
import '../../data/presets/preset_catalog.dart';
import '../../domain/models/community_post.dart';
import '../../domain/services/community_repository.dart';
import '../../services/community_preferences.dart';
import '../../services/photo_input_service.dart';
import '../camera/camera_screen.dart';
import '../editor/editor_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({
    super.key,
    required this.repository,
    this.photoInput,
    this.preferences = const CommunityPreferences(),
  });

  final CommunityRepository repository;
  final PhotoInputService? photoInput;
  final CommunityPreferences preferences;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final PhotoInputService _photoInput;
  var _sort = CommunityFeedSort.recommended;
  var _posts = <CommunityPost>[];
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _photoInput = widget.photoInput ?? PhotoInputService();
    if (widget.repository.isConfigured) _loadFeed();
  }

  Future<void> _loadFeed() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await widget.repository.fetchFeed(sort: _sort);
      if (mounted) setState(() => _posts = posts);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setSort(CommunityFeedSort sort) async {
    if (_sort == sort) return;
    setState(() => _sort = sort);
    await _loadFeed();
  }

  Future<void> _createPost() async {
    final draft = await showModalBottomSheet<CommunityPostDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CreatePostSheet(
        photoInput: _photoInput,
        preferences: widget.preferences,
      ),
    );
    if (draft == null || !mounted) return;
    _showMessage('사진의 위치정보를 제거하고 게시 중이에요.');
    try {
      final post = await widget.repository.createPost(draft);
      if (!mounted) return;
      setState(() => _posts = [post, ..._posts.where((p) => p.id != post.id)]);
      _showMessage('커뮤니티에 게시했어요.');
    } catch (error) {
      if (mounted) _showMessage('게시하지 못했어요. $error');
    }
  }

  Future<void> _toggleLike(CommunityPost post) async {
    final next = !post.likedByMe;
    _replacePost(
      post.copyWith(
        likedByMe: next,
        likeCount: (post.likeCount + (next ? 1 : -1)).clamp(0, 1 << 30),
      ),
    );
    try {
      await widget.repository.setLiked(post.id, liked: next);
    } catch (error) {
      _replacePost(post);
      if (mounted) _showMessage('추천을 저장하지 못했어요. $error');
    }
  }

  Future<void> _toggleSave(CommunityPost post) async {
    final next = !post.savedByMe;
    _replacePost(
      post.copyWith(
        savedByMe: next,
        saveCount: (post.saveCount + (next ? 1 : -1)).clamp(0, 1 << 30),
      ),
    );
    try {
      await widget.repository.setSaved(post.id, saved: next);
    } catch (error) {
      _replacePost(post);
      if (mounted) _showMessage('저장을 완료하지 못했어요. $error');
    }
  }

  void _replacePost(CommunityPost post) {
    if (!mounted) return;
    setState(() {
      _posts = _posts.map((item) => item.id == post.id ? post : item).toList();
    });
  }

  Future<void> _usePreset(CommunityPost post) async {
    final preset = post.presetId == null ? null : presetById(post.presetId!);
    if (preset == null) {
      _showMessage('이 게시물에는 적용 가능한 프리셋이 없어요.');
      return;
    }
    try {
      final photo = await _photoInput.pickFromGallery();
      if (!mounted || photo == null) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.editor,
        arguments: EditorArgs(photo: photo, initialPreset: preset),
      );
    } catch (error) {
      if (mounted) _showMessage('사진을 열지 못했어요. $error');
    }
  }

  void _useComposition(CommunityPost post) {
    final template = post.compositionId == null
        ? null
        : compositionById(post.compositionId!);
    if (template == null) {
      _showMessage('이 게시물에는 연결된 구도가 없어요.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            CameraScreen(template: template, initialPresetId: post.presetId),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _showComments(CommunityPost post) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          _CommentsSheet(repository: widget.repository, postId: post.id),
    );
    if (added == true) {
      _replacePost(post.copyWith(commentCount: post.commentCount + 1));
    }
  }

  Future<void> _report(CommunityPost post) async {
    try {
      await widget.repository.reportPost(post.id, '부적절하거나 권리를 침해하는 게시물');
      if (mounted) _showMessage('신고를 접수했어요. 검토 전까지 게시물을 숨길 수 있어요.');
    } catch (error) {
      if (mounted) _showMessage('신고하지 못했어요. $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.repository.isConfigured) {
      return const _CommunitySetupState();
    }
    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: CustomScrollView(
        key: const ValueKey('community-feed'),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '사진과 촬영 노하우를 나눠보세요.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        key: const ValueKey('community-create-post'),
                        onPressed: _createPost,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('사진 올리기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '마음에 드는 색감은 편집으로, 구도는 촬영 코치로 바로 가져올 수 있어요.',
                    style: TextStyle(color: Color(0xFF686868), height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<CommunityFeedSort>(
                    segments: const [
                      ButtonSegment(
                        value: CommunityFeedSort.recommended,
                        icon: Icon(Icons.auto_awesome_outlined),
                        label: Text('추천'),
                      ),
                      ButtonSegment(
                        value: CommunityFeedSort.newest,
                        icon: Icon(Icons.schedule),
                        label: Text('최신'),
                      ),
                    ],
                    selected: {_sort},
                    onSelectionChanged: (value) => _setSort(value.first),
                    showSelectedIcon: false,
                  ),
                ],
              ),
            ),
          ),
          if (_loading && _posts.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null && _posts.isEmpty)
            SliverFillRemaining(
              child: _FeedError(message: _error!, onRetry: _loadFeed),
            )
          else if (_posts.isEmpty)
            const SliverFillRemaining(child: _EmptyFeed())
          else
            SliverList.separated(
              itemCount: _posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    index == _posts.length - 1 ? 28 : 0,
                  ),
                  child: _CommunityPostCard(
                    post: post,
                    onLike: () => _toggleLike(post),
                    onSave: () => _toggleSave(post),
                    onComments: () => _showComments(post),
                    onUsePreset: () => _usePreset(post),
                    onUseComposition: () => _useComposition(post),
                    onReport: () => _report(post),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CommunitySetupState extends StatelessWidget {
  const _CommunitySetupState();

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups_2_outlined, size: 54),
          const SizedBox(height: 16),
          const Text(
            '커뮤니티 서버 연결이 필요해요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            '공개용 서버 주소가 설정되면 실제 게시물·추천·저장·댓글이 활성화됩니다. 서버 연결 전에는 사진이 외부로 전송되지 않아요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF686868), height: 1.45),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.privacy_tip_outlined, size: 20),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '게시할 때 GPS·EXIF·원본 파일명을 제거한 축소 사진만 업로드합니다.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.onLike,
    required this.onSave,
    required this.onComments,
    required this.onUsePreset,
    required this.onUseComposition,
    required this.onReport,
  });

  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onComments;
  final VoidCallback onUsePreset;
  final VoidCallback onUseComposition;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final preset = post.presetId == null ? null : presetById(post.presetId!);
    final composition = post.compositionId == null
        ? null
        : compositionById(post.compositionId!);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xFF202020),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    post.authorNickname,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: '게시물 메뉴',
                  onSelected: (value) {
                    if (value == 'report') onReport();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'report', child: Text('게시물 신고')),
                  ],
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFFE7E7E3),
                child: Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(
              children: [
                IconButton(
                  key: ValueKey('community-like-${post.id}'),
                  onPressed: onLike,
                  tooltip: post.likedByMe ? '추천 취소' : '추천',
                  icon: Icon(
                    post.likedByMe ? Icons.favorite : Icons.favorite_border,
                    color: post.likedByMe ? const Color(0xFFC44444) : null,
                  ),
                ),
                Text('${post.likeCount}'),
                IconButton(
                  onPressed: onComments,
                  tooltip: '댓글',
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
                Text('${post.commentCount}'),
                const Spacer(),
                IconButton(
                  key: ValueKey('community-save-${post.id}'),
                  onPressed: onSave,
                  tooltip: post.savedByMe ? '저장 취소' : '저장',
                  icon: Icon(
                    post.savedByMe ? Icons.bookmark : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
          ),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: Text(post.caption, style: const TextStyle(height: 1.4)),
            ),
          if (preset != null || composition != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (preset != null)
                    Chip(
                      avatar: const Icon(Icons.tune, size: 16),
                      label: Text(
                        '${preset.name} ${(post.presetIntensity ?? preset.defaultIntensity) * 100 ~/ 1}%',
                      ),
                    ),
                  if (composition != null)
                    Chip(
                      avatar: const Icon(Icons.grid_3x3, size: 16),
                      label: Text(composition.name),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                if (preset != null)
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: onUsePreset,
                      icon: const Icon(Icons.auto_fix_high, size: 18),
                      label: const Text('이 색감으로 편집'),
                    ),
                  ),
                if (preset != null && composition != null)
                  const SizedBox(width: 8),
                if (composition != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUseComposition,
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('이 구도로 촬영'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet({required this.photoInput, required this.preferences});

  final PhotoInputService photoInput;
  final CommunityPreferences preferences;

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _captionController = TextEditingController();
  final _nicknameController = TextEditingController();
  Uint8List? _imageBytes;
  String? _presetId;
  String? _compositionId;
  double _intensity = .75;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    widget.preferences.nickname().then((value) {
      if (mounted) _nicknameController.text = value;
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final photo = await widget.photoInput.pickFromGallery();
      if (mounted && photo != null) setState(() => _imageBytes = photo.bytes);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('사진을 열지 못했어요. $error')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _submit() async {
    final image = _imageBytes;
    final nickname = _nicknameController.text.trim();
    if (image == null) {
      _message('게시할 사진을 선택해 주세요.');
      return;
    }
    if (nickname.length < 2 || nickname.length > 20) {
      _message('닉네임은 2~20자로 입력해 주세요.');
      return;
    }
    if (_captionController.text.length > 1000) {
      _message('설명은 1000자 이하로 입력해 주세요.');
      return;
    }
    await widget.preferences.saveNickname(nickname);
    if (!mounted) return;
    Navigator.pop(
      context,
      CommunityPostDraft(
        imageBytes: image,
        caption: _captionController.text.trim(),
        nickname: nickname,
        presetId: _presetId,
        presetIntensity: _presetId == null ? null : _intensity,
        compositionId: _compositionId,
      ),
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      0,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '커뮤니티에 사진 올리기',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            '게시 버튼을 누르기 전에는 사진이 외부로 전송되지 않습니다.',
            style: TextStyle(color: Color(0xFF686868)),
          ),
          const SizedBox(height: 14),
          if (_imageBytes case final bytes?)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
            )
          else
            OutlinedButton.icon(
              key: const ValueKey('community-pick-photo'),
              onPressed: _picking ? null : _pickPhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(_picking ? '사진 여는 중…' : '게시할 사진 선택'),
            ),
          if (_imageBytes != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _pickPhoto,
                child: const Text('사진 변경'),
              ),
            ),
          TextField(
            controller: _nicknameController,
            maxLength: 20,
            decoration: const InputDecoration(labelText: '닉네임'),
          ),
          TextField(
            controller: _captionController,
            maxLength: 1000,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '사진 설명과 촬영 팁',
              hintText: '어떤 상황에서 어떻게 촬영했는지 알려주세요.',
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            initialValue: _presetId,
            decoration: const InputDecoration(labelText: '사용한 프리셋 (선택)'),
            items: [
              const DropdownMenuItem(value: null, child: Text('선택 안 함')),
              ...presetCatalog.map(
                (preset) => DropdownMenuItem(
                  value: preset.id,
                  child: Text(preset.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _presetId = value),
          ),
          if (_presetId != null) ...[
            const SizedBox(height: 6),
            Text('프리셋 강도 ${(_intensity * 100).round()}'),
            Slider(
              value: _intensity,
              onChanged: (value) => setState(() => _intensity = value),
            ),
          ],
          DropdownButtonFormField<String?>(
            initialValue: _compositionId,
            decoration: const InputDecoration(labelText: '사용한 구도 (선택)'),
            items: [
              const DropdownMenuItem(value: null, child: Text('선택 안 함')),
              ...compositionCatalog.map(
                (template) => DropdownMenuItem(
                  value: template.id,
                  child: Text(template.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _compositionId = value),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '공개 게시물입니다. 얼굴·주소·차량번호 등 공개하면 안 되는 정보가 없는지 확인해 주세요. GPS와 EXIF는 자동 제거됩니다.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const ValueKey('community-publish'),
            onPressed: _submit,
            icon: const Icon(Icons.public),
            label: const Text('확인하고 공개 게시'),
          ),
        ],
      ),
    ),
  );
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.repository, required this.postId});

  final CommunityRepository repository;
  final String postId;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  var _comments = <CommunityComment>[];
  var _loading = true;
  var _added = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final comments = await widget.repository.fetchComments(widget.postId);
      if (mounted) setState(() => _comments = comments);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    try {
      final comment = await widget.repository.addComment(widget.postId, body);
      if (!mounted) return;
      setState(() {
        _comments = [..._comments, comment];
        _added = true;
      });
      _controller.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('댓글을 올리지 못했어요. $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) Navigator.pop(context, _added);
    },
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '댓글',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, _added),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : _comments.isEmpty
                  ? const Center(child: Text('첫 번째 촬영 팁을 남겨보세요.'))
                  : ListView.separated(
                      itemCount: _comments.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (_, index) {
                        final comment = _comments[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            comment.authorNickname,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(comment.body),
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: '댓글 또는 촬영 팁',
                      counterText: '',
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: _send,
                  tooltip: '댓글 게시',
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 42),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    ),
  );
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined, size: 44),
          SizedBox(height: 10),
          Text(
            '아직 게시물이 없어요.\n첫 사진과 촬영 팁을 공유해 보세요.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
