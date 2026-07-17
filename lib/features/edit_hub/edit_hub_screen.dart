import 'package:flutter/material.dart';

import '../../domain/services/community_repository.dart';
import '../../services/community_backend.dart';
import '../community/community_screen.dart';
import '../templates/template_screen.dart';

class EditHubScreen extends StatefulWidget {
  const EditHubScreen({super.key, this.communityRepository});

  final CommunityRepository? communityRepository;

  @override
  State<EditHubScreen> createState() => _EditHubScreenState();
}

class _EditHubScreenState extends State<EditHubScreen> {
  var _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9F8F5),
    appBar: AppBar(
      title: const Text('편집'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: SegmentedButton<int>(
            key: const ValueKey('edit-hub-segments'),
            segments: const [
              ButtonSegment(
                value: 0,
                icon: Icon(Icons.tune),
                label: Text('사진 편집'),
              ),
              ButtonSegment(
                value: 1,
                icon: Icon(Icons.people_alt_outlined),
                label: Text('커뮤니티'),
              ),
            ],
            selected: {_index},
            onSelectionChanged: (values) =>
                setState(() => _index = values.first),
            showSelectedIcon: false,
          ),
        ),
      ),
    ),
    body: IndexedStack(
      index: _index,
      children: [
        const TemplateScreen(embedded: true, showAppBar: false),
        CommunityScreen(
          repository:
              widget.communityRepository ?? CommunityBackend.createRepository(),
        ),
      ],
    ),
  );
}
