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
    this.safeArea = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigation;
  final EdgeInsetsGeometry padding;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigation,
      backgroundColor: AppColors.appBackground,
      body: safeArea ? SafeArea(child: body) : body,
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

class SectionHeader extends EditorialSectionHeader {
  const SectionHeader({
    super.key,
    required super.title,
    super.subtitle,
    super.actionLabel,
    super.onAction,
  });
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
      itemBuilder: (context, index) => MotionIn(
        delay: Duration(milliseconds: 35 * index),
        child: PhotoTile(data: items[index]),
      ),
    );
  }
}

class MotionIn extends StatefulWidget {
  const MotionIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.035),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<MotionIn> createState() => _MotionInState();
}

class _MotionInState extends State<MotionIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(curved);
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppMetrics.thumbnailRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(color: data.baseColor),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppMetrics.thumbnailRadius,
                  ),
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
            Positioned.fill(
              child: CustomPaint(
                painter: _PhotoTexturePainter(
                  baseColor: data.baseColor,
                  accentColor: data.accentColor,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.16),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              right: 10,
              child: Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
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
    return PressableScale(
      onTap: onTap,
      child: PremiumCard(
        padding: EdgeInsets.zero,
        borderColor: recommended ? AppColors.lineStrong : AppColors.line,
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
                        recommended ? '먼저 보기 좋음' : template.category,
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
                    const SizedBox(height: 8),
                    Text(
                      '${template.rating.toStringAsFixed(1)} · '
                      '${formatUsageCount(template.usageCount)}명 사용 · '
                      '쉬운 편 ${template.beginnerFriendlyScore}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${template.aspectRatio} · ${template.targetSubjectType}',
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

class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class TemplateCard extends PresetCard {
  const TemplateCard({
    super.key,
    required super.template,
    required super.onTap,
    super.recommended,
    super.compact,
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
            return PressableScale(
              key: Key('bottomNav-${item.label}'),
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.08 : 1,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        item.icon,
                        size: 18,
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
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
            child: AnimatedContainer(
              key: const Key('subjectGuideBox'),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
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
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        key: selected ? Key('selectedPreview-$label') : null,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
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
    final content = _ButtonContent(label: label, icon: icon);
    return SizedBox(
      width: double.infinity,
      child: FilledButton(onPressed: onPressed, child: content),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
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
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMetrics.buttonRadius),
          ),
        ),
        child: _ButtonContent(label: label, icon: icon),
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
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: _ButtonContent(label: label, icon: icon),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Flexible(
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    if (icon == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [text],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: AppSpacing.xs),
        text,
      ],
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

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      key: Key('categoryChip-$label'),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.lineStrong,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: selected
                  ? const Padding(
                      padding: EdgeInsets.only(right: AppSpacing.xs),
                      child: Icon(
                        Icons.check,
                        size: 13,
                        color: AppColors.actionPrimaryText,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? AppColors.actionPrimaryText
                    : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xl),
            action!,
          ],
        ],
      ),
    );
  }
}

class _PhotoTexturePainter extends CustomPainter {
  const _PhotoTexturePainter({
    required this.baseColor,
    required this.accentColor,
  });

  final Color baseColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final softLight = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final accent = Paint()
      ..color = accentColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.24, size.height * 0.22),
        width: size.width * 0.68,
        height: size.height * 0.42,
      ),
      softLight,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, size.height * 0.8),
        width: size.width * 0.5,
        height: size.height * 0.32,
      ),
      shadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.58,
          size.height * 0.14,
          size.width * 0.18,
          size.height * 0.68,
        ),
        const Radius.circular(999),
      ),
      accent,
    );

    final grain = Paint()
      ..color = baseColor.withValues(alpha: 0.16)
      ..strokeWidth = 0.7;
    for (var i = 0; i < 18; i += 1) {
      final x = (size.width * ((i * 37) % 100)) / 100;
      final y = (size.height * ((i * 53) % 100)) / 100;
      canvas.drawCircle(Offset(x, y), 0.8, grain);
    }
  }

  @override
  bool shouldRepaint(covariant _PhotoTexturePainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.accentColor != accentColor;
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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppMetrics.panelRadius),
        ),
        child: PhotoTile(
          data: PhotoTileData(
            label: template.sampleVisual.label,
            baseColor: _hexColor(template.sampleVisual.baseColorHex),
            accentColor: _hexColor(template.sampleVisual.accentColorHex),
          ),
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
