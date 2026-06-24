import 'package:flutter/material.dart';

import '../../data/models/template.dart';
import '../theme/app_theme.dart';
import '../utils/number_formatters.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigation,
    this.padding = const EdgeInsets.all(AppMetrics.pagePadding),
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigation;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigation,
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class MinimalTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MinimalTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing = const [],
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> trailing;
  final bool compact;

  @override
  Size get preferredSize => Size.fromHeight(compact ? 54 : 68);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.appBackground,
        padding: const EdgeInsets.fromLTRB(16, 6, 12, 8),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null && !compact) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            for (final item in trailing)
              Padding(padding: const EdgeInsets.only(left: 4), child: item),
          ],
        ),
      ),
    );
  }
}

class EditorialSectionHeader extends StatelessWidget {
  const EditorialSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class ThinTabRow extends StatelessWidget {
  const ThinTabRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return InkWell(
            onTap: () => onTap(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[index],
                    style: TextStyle(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 1.5,
                    width: 22,
                    color: selected
                        ? AppColors.textPrimary
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemCount: labels.length,
      ),
    );
  }
}

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.items,
    this.columns = 2,
    this.gap = AppMetrics.gridGap,
    this.aspectRatio = 0.78,
  });

  final List<PhotoTileData> items;
  final int columns;
  final double gap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        childAspectRatio: aspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => PhotoTile(data: items[index]),
    );
  }
}

class PhotoTile extends StatelessWidget {
  const PhotoTile({super.key, required this.data});

  final PhotoTileData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tile = _PhotoTileBody(data: data);
        if (!constraints.hasBoundedHeight) {
          return AspectRatio(aspectRatio: 4 / 5, child: tile);
        }
        return tile;
      },
    );
  }
}

class _PhotoTileBody extends StatelessWidget {
  const _PhotoTileBody({required this.data});

  final PhotoTileData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: data.baseColor,
        borderRadius: BorderRadius.circular(AppMetrics.thumbnailRadius),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppMetrics.thumbnailRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.baseColor.withValues(alpha: 0.95),
                    data.accentColor.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoTileData {
  const PhotoTileData({
    required this.label,
    required this.baseColor,
    required this.accentColor,
  });

  final String label;
  final Color baseColor;
  final Color accentColor;
}

class PresetCard extends StatelessWidget {
  const PresetCard({
    super.key,
    required this.template,
    required this.onTap,
    this.recommended = false,
    this.compact = false,
  });

  final EditTemplate template;
  final VoidCallback onTap;
  final bool recommended;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppMetrics.panelRadius),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppMetrics.panelRadius),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PresetThumbnail(template: template, compact: compact),
            Padding(
              padding: EdgeInsets.all(compact ? 12 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        recommended ? '이 사진에 추천' : template.category,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: recommended
                              ? AppColors.profileAccent
                              : AppColors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    template.name,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    template.description,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 9),
                    Text(
                      '${template.rating.toStringAsFixed(1)} · '
                      '${formatUsageCount(template.usageCount)}명 사용 · '
                      '초보자 추천 ${template.beginnerFriendlyScore}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      '추천 이유: ${template.recommendationReason}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: template.tags
                          .take(3)
                          .map((tag) => MetaChip(label: tag))
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TemplateCard extends PresetCard {
  const TemplateCard({
    super.key,
    required super.template,
    required super.onTap,
  });
}

class EditorActionBar extends StatelessWidget {
  const EditorActionBar({
    super.key,
    required this.actions,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<EditorActionItem> actions;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(actions.length, (index) {
            final item = actions[index];
            final selected = selectedIndex == index;
            return InkWell(
              key: Key('bottomNav-${item.label}'),
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class EditorActionItem {
  const EditorActionItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class CameraGuideOverlay extends StatelessWidget {
  const CameraGuideOverlay({
    super.key,
    required this.mode,
    this.score,
    this.message,
  });

  final String mode;
  final int? score;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              key: const Key('cameraGridOverlay'),
              painter: _CameraGridPainter(),
            ),
          ),
          Center(
            child: Container(
              key: const Key('subjectGuideBox'),
              width: mode == '음식' ? 178 : 118,
              height: mode == '음식' ? 112 : 166,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(mode == '음식' ? 12 : 58),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.88),
                  width: AppMetrics.selectedOutline,
                ),
              ),
            ),
          ),
          Positioned(
            key: const Key('movementHintArrow'),
            right: 70,
            top: 250,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.arrow_forward, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewOptionCard extends StatelessWidget {
  const PreviewOptionCard({
    super.key,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppMetrics.panelRadius),
      child: Container(
        key: selected ? Key('selectedPreview-$label') : null,
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppMetrics.panelRadius),
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.line,
            width: selected
                ? AppMetrics.selectedOutline
                : AppMetrics.thinBorder,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _MiniPreview(label: label),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (selected) const Icon(Icons.check, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppMetrics.buttonHeight,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 17),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.actionPrimary,
          foregroundColor: AppColors.actionPrimaryText,
          textStyle: Theme.of(context).textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMetrics.buttonRadius),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppMetrics.buttonHeight,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 17),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.actionSecondaryText,
          backgroundColor: AppColors.actionSecondary,
          side: const BorderSide(color: AppColors.lineStrong),
          textStyle: Theme.of(context).textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMetrics.buttonRadius),
          ),
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor = AppColors.line,
    this.backgroundColor,
    this.radius = AppMetrics.panelRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color? backgroundColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      padding: padding,
      child: child,
    );
  }
}

class GlassCard extends PremiumCard {
  const GlassCard({
    super.key,
    required super.child,
    super.padding,
    super.borderColor,
    super.radius,
  }) : super(backgroundColor: AppColors.overlayPanel);
}

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.label,
    required this.score,
    this.caption,
  });

  final String label;
  final int score;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(12),
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('$score', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              SizedBox(
                width: 42,
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 2,
                  backgroundColor: AppColors.line,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(caption!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.modes,
    required this.selectedMode,
    required this.onChanged,
  });

  final Iterable<String> modes;
  final String selectedMode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = modes.toList(growable: false);
    return ThinTabRow(
      labels: labels,
      selectedIndex: labels.indexOf(selectedMode),
      onTap: (index) => onChanged(labels[index]),
    );
  }
}

class MetaChip extends StatelessWidget {
  const MetaChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _PresetThumbnail extends StatelessWidget {
  const _PresetThumbnail({required this.template, required this.compact});

  final EditTemplate template;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 84 : 128,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: PhotoTile(
          data: PhotoTileData(
            label: template.category,
            baseColor: _baseColor(template.category),
            accentColor: _accentColor(template.category),
          ),
        ),
      ),
    );
  }

  Color _baseColor(String category) => switch (category) {
    '프로필' => const Color(0xFFB8AAA0),
    '셀카' => const Color(0xFFD3B7A5),
    '음식' => const Color(0xFFC9824A),
    '여행' => const Color(0xFF7FA9C8),
    '상품' => const Color(0xFFE8E5DE),
    _ => const Color(0xFF9A768C),
  };

  Color _accentColor(String category) => switch (category) {
    '프로필' => const Color(0xFF2B2B2B),
    '셀카' => const Color(0xFF8D6658),
    '음식' => const Color(0xFF6C3E20),
    '여행' => const Color(0xFFE0A45B),
    '상품' => const Color(0xFFB8B8B2),
    _ => const Color(0xFF352A35),
  };
}

class _MiniPreview extends StatelessWidget {
  const _MiniPreview({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = switch (label) {
      '밝게' => [const Color(0xFFEFE3CA), const Color(0xFFB8C9D4)],
      '무드있게' => [const Color(0xFF6F6570), const Color(0xFF222222)],
      _ => [const Color(0xFFC7B7A6), const Color(0xFF8EA0A8)],
    };
    return Container(
      width: 58,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(colors: colors),
      ),
    );
  }
}

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..strokeWidth = 0.8;
    for (final x in [size.width / 3, size.width * 2 / 3]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (final y in [size.height / 3, size.height * 2 / 3]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
