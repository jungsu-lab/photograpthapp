import 'package:flutter/material.dart';

import '../../data/composition/composition_catalog.dart';
import '../../domain/models/composition_template.dart';
import '../camera/camera_screen.dart';

class ShootingLibraryScreen extends StatefulWidget {
  const ShootingLibraryScreen({super.key});

  @override
  State<ShootingLibraryScreen> createState() => _ShootingLibraryScreenState();
}

class _ShootingLibraryScreenState extends State<ShootingLibraryScreen> {
  CompositionCategory? _category;

  void _openCamera([CompositionTemplate? template]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraScreen(template: template),
        fullscreenDialog: true,
      ),
    );
  }

  void _openShotPack(ShotPack pack) {
    final template = compositionById(pack.templateId);
    if (template == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraScreen(
          template: template,
          initialPresetId: pack.defaultPresetId,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showTemplate(CompositionTemplate template) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                template.shortDescription,
                style: const TextStyle(color: Color(0xFF626262), height: 1.4),
              ),
              const SizedBox(height: 18),
              const Text(
                '촬영 전에 확인',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...template.captureChecklist.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openCamera(template);
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('이 구도로 촬영'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = compositionCatalog
        .where((item) => _category == null || item.category == _category)
        .toList(growable: false);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F8F5),
        elevation: 0,
        title: const Text('촬영', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton.icon(
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('빠른 촬영'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '원하는 사진부터 고르세요.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '구도와 촬영 팁을 고르면 카메라가 맞는 기준선을 보여줘요.',
                  style: TextStyle(color: Color(0xFF656565), height: 1.4),
                ),
                const SizedBox(height: 16),
                const Text(
                  '바로 써보기',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 82,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: shotPacks.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => _ShotPackCard(
                      pack: shotPacks[index],
                      onTap: () => _openShotPack(shotPacks[index]),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: const Text('전체'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      const SizedBox(width: 8),
                      ...CompositionCategory.values.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category.label),
                            selected: _category == category,
                            onSelected: (_) =>
                                setState(() => _category = category),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .70,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) => _CompositionCard(
                template: templates[index],
                onTap: () => _showTemplate(templates[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShotPackCard extends StatelessWidget {
  const _ShotPackCard({required this.pack, required this.onTap});

  final ShotPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF1C1C1C),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 168,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                pack.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pack.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CompositionCard extends StatelessWidget {
  const _CompositionCard({required this.template, required this.onTap});

  final CompositionTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(template.exampleAsset, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: .48),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: Text(
                          template.category.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              template.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              template.shortDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF686868),
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
