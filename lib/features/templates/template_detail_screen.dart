import 'package:flutter/material.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../data/models/edit_session.dart';
import '../../data/models/template.dart';
import '../../data/repositories/template_repository.dart';

class TemplateDetailScreen extends StatelessWidget {
  const TemplateDetailScreen({super.key});

  static const repository = TemplateRepository();

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final template = switch (routeArgs) {
      TemplateDetailArgs(:final template) => template,
      EditTemplate() => routeArgs,
      _ => repository.recommended().first,
    };

    return AppScaffold(
      appBar: MinimalTopBar(
        title: template.name,
        subtitle: '${template.category} · ${template.aspectRatio}',
        leading: IconButton(
          tooltip: '뒤로',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
        ),
      ),
      child: ListView(
        key: const Key('templateDetailScreen'),
        children: [
          AspectRatio(
            aspectRatio: _aspectRatioValue(template.aspectRatio),
            child: _TemplatePreview(template: template),
          ),
          const SizedBox(height: 18),
          Text(template.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            template.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              MetaChip(label: template.category),
              MetaChip(label: template.aspectRatio),
              MetaChip(label: '초보자 ${template.beginnerFriendlyScore}%'),
              for (final tag in template.tags.take(3)) MetaChip(label: tag),
            ],
          ),
          const SizedBox(height: 18),
          _InfoPanel(
            title: '화면에서 맞출 것',
            icon: Icons.grid_3x3,
            children: [template.compositionGuidance],
          ),
          const SizedBox(height: 12),
          _InfoPanel(
            title: '찍기 전에',
            icon: Icons.photo_camera_outlined,
            children: template.captureTips,
          ),
          const SizedBox(height: 12),
          _InfoPanel(
            title: '놓치기 쉬운 것',
            icon: Icons.check_circle_outline,
            children: template.feedbackHints,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            key: const Key('templateDetailStartCta'),
            label: '이 기준으로 맞춰보기',
            icon: Icons.camera_alt_outlined,
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.camera,
              arguments: CameraArgs(template: template),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '지금은 실제 카메라 대신 샘플 화면으로 흐름을 확인해요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  double _aspectRatioValue(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return 4 / 5;
    }
    final width = double.tryParse(parts.first);
    final height = double.tryParse(parts.last);
    if (width == null || height == null || height == 0) {
      return 4 / 5;
    }
    return width / height;
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.template});

  final EditTemplate template;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppMetrics.thumbnailRadius),
      child: PhotoTile(
        data: PhotoTileData(
          label: template.sampleVisual.label,
          baseColor: _hexColor(template.sampleVisual.baseColorHex),
          accentColor: _hexColor(template.sampleVisual.accentColorHex),
        ),
      ),
    );
  }

  Color _hexColor(String value) {
    final normalized = value.replaceFirst('#', '');
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) {
      return AppColors.surfaceSoft;
    }
    return Color(0xFF000000 | parsed);
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<String> children;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in children) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('· '),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (item != children.last) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}
