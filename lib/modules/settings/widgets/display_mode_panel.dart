import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../shared/enums/order_enums.dart';

class DisplayModesPanel extends ConsumerWidget {
  const DisplayModesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final layout = ref.watch(kdsLayoutProvider);
    final visibility = ref.watch(orderTypeVisibilityProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            'Display Modes',
            style: t.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Divider(height: 1, color: t.dividerColor),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ══ Theme toggle ════════════════════════════════
              Container(
                decoration: _cardDecoration(t),
                child: SwitchListTile(
                  title: const Text('KDS Dark Theme'),
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),
              ),
              const SizedBox(height: 24),

              // ══ Item Summary Position ═══════════════════════
              Container(
                decoration: _cardDecoration(t),
                child: Consumer(
                  builder: (context, ref, _) {
                    final pos = ref.watch(summaryPositionProvider);
                    return InkWell(
                      onTap: () => _pickSummaryPosition(context, ref, pos),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Item Summary Position',
                                style: t.textTheme.titleMedium,
                              ),
                            ),
                            Text(pos.label, style: t.textTheme.bodyMedium),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: t.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // ══ Screen layout ═══════════════════════════════
              const _SectionHeader(
                icon: Icons.grid_view_rounded,
                title: 'Screen Layout',
                subtitle: 'Choose how order tickets are arranged',
              ),
              const SizedBox(height: 12),
              Container(
                decoration: _cardDecoration(t),
                child: Column(
                  children: List.generate(KdsLayout.values.length, (i) {
                    final l = KdsLayout.values[i];
                    final isSelected = layout == l;
                    final isLast = i == KdsLayout.values.length - 1;
                    return Column(
                      children: [
                        _LayoutTile(
                          layout: l,
                          isSelected: isSelected,
                          onTap: () =>
                              ref.read(kdsLayoutProvider.notifier).set(l),
                        ),
                        if (!isLast)
                          Divider(height: 1, indent: 76, color: t.dividerColor),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),

              // ══ Order type visibility ═══════════════════════
              const _SectionHeader(
                icon: Icons.visibility_outlined,
                title: 'Order Types',
                subtitle: 'Hidden order types will not appear on the screen',
              ),
              const SizedBox(height: 12),
              Container(
                decoration: _cardDecoration(t),
                child: Column(
                  children: List.generate(OrderType.values.length, (i) {
                    final type = OrderType.values[i];
                    final isLast = i == OrderType.values.length - 1;
                    return Column(
                      children: [
                        SwitchListTile(
                          title: Text(type.label),
                          value: visibility[type] ?? true,
                          onChanged: (_) => ref
                              .read(orderTypeVisibilityProvider.notifier)
                              .toggle(type),
                        ),
                        if (!isLast) Divider(height: 1, color: t.dividerColor),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(ThemeData t) => BoxDecoration(
    color: t.cardColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: t.dividerColor),
  );

  Future<void> _pickSummaryPosition(
    BuildContext context,
    WidgetRef ref,
    SummaryPosition current,
  ) async {
    final result = await showDialog<SummaryPosition>(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Item Summary Position',
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Divider(height: 1, color: t.dividerColor),
                ...SummaryPosition.values.map(
                  (p) => ListTile(
                    leading: p == current
                        ? Icon(Icons.check, color: t.colorScheme.primary)
                        : const SizedBox(width: 24),
                    title: Text(p.label),
                    onTap: () => Navigator.of(ctx).pop(p),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      ref.read(summaryPositionProvider.notifier).state = result;
    }
  }
}

// ── Section header — icon + title + subtitle ─────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: t.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 20, color: t.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: t.textTheme.bodyMedium?.copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Layout tile — horizontal list style ──────────────────────────────────────
class _LayoutTile extends StatelessWidget {
  const _LayoutTile({
    required this.layout,
    required this.isSelected,
    required this.onTap,
  });

  final KdsLayout layout;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _MiniPreview(layout: layout, isSelected: isSelected),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        layout.label,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? t.colorScheme.primary : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: t.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          layout.highlight,
                          style: t.textTheme.labelSmall?.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    layout.description,
                    style: t.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? t.colorScheme.primary
                  : t.colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini layout preview ───────────────────────────────────────────────────────
class _MiniPreview extends StatelessWidget {
  const _MiniPreview({required this.layout, required this.isSelected});

  final KdsLayout layout;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final blockColor = isSelected
        ? t.colorScheme.primary.withOpacity(0.7)
        : t.colorScheme.onSurfaceVariant.withOpacity(0.4);

    Widget block(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: blockColor,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );

    Widget preview;
    switch (layout) {
      case KdsLayout.tiled:
        preview = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [block(9, 15), const SizedBox(height: 2), block(9, 9)],
            ),
            const SizedBox(width: 2),
            Column(
              children: [block(9, 10), const SizedBox(height: 2), block(9, 14)],
            ),
            const SizedBox(width: 2),
            Column(
              children: [block(9, 12), const SizedBox(height: 2), block(9, 7)],
            ),
          ],
        );
        break;
      case KdsLayout.classic:
        preview = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            block(9, 18),
            const SizedBox(width: 2),
            block(9, 12),
            const SizedBox(width: 2),
            block(9, 21),
            const SizedBox(width: 2),
            block(9, 15),
          ],
        );
        break;
      case KdsLayout.split:
        preview = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                block(9, 9),
                const SizedBox(width: 2),
                block(9, 9),
                const SizedBox(width: 2),
                block(9, 9),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [block(9, 9), const SizedBox(width: 2), block(9, 9)],
            ),
          ],
        );
        break;
      case KdsLayout.fullColumns:
        preview = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            block(8, 22),
            const SizedBox(width: 3),
            block(8, 22),
            const SizedBox(width: 3),
            block(8, 22),
            const SizedBox(width: 3),
            block(8, 22),
          ],
        );
        break;
      case KdsLayout.grid:
        preview = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                block(8, 8),
                const SizedBox(width: 2),
                block(8, 8),
                const SizedBox(width: 2),
                block(8, 8),
                const SizedBox(width: 2),
                block(8, 8),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                block(8, 8),
                const SizedBox(width: 2),
                block(8, 8),
                const SizedBox(width: 2),
                block(8, 8),
                const SizedBox(width: 2),
                block(8, 8),
              ],
            ),
          ],
        );
        break;
    }

    return Container(
      width: 52,
      height: 44,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? t.colorScheme.primary : t.dividerColor,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: preview),
    );
  }
}
