import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../shared/enums/order_enums.dart';

class FontsColorsPanel extends ConsumerWidget {
  const FontsColorsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final statusColors = ref.watch(statusColorsProvider);
    final typeColors = ref.watch(orderTypeColorsProvider);

    return Column(
      children: [
        // ── Header + Restore Default ────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const SizedBox(width: 120),
              Expanded(
                child: Text(
                  'Fonts & Colors',
                  textAlign: TextAlign.center,
                  style: t.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextButton(
                  onPressed: () {
                    ref.read(statusColorsProvider.notifier).restoreDefaults();
                    ref
                        .read(orderTypeColorsProvider.notifier)
                        .restoreDefaults();
                    // ref.read(fontSizeProvider.notifier).state =
                    //     KdsFontSize.medium;
                    ref.read(fontSizeProvider.notifier).set(KdsFontSize.medium);
                  },
                  child: const Text(
                    'Restore Default Colors',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: t.dividerColor),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ══ FONT SIZE ═══════════════════════════════════
              _SectionLabel('FONT SIZE'),
              Container(
                decoration: _cardDecoration(t),
                child: Column(
                  children: KdsFontSize.values.map((size) {
                    final isSelected = fontSize == size;
                    final isLast = size == KdsFontSize.values.last;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () =>
                              // ref.read(fontSizeProvider.notifier).state = size,
                              ref.read(fontSizeProvider.notifier).set(size),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: t.colorScheme.primary,
                                          size: 20,
                                        )
                                      : null,
                                ),
                                Text(
                                  size.label,
                                  style: t.textTheme.titleMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast) Divider(height: 1, color: t.dividerColor),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // ══ STATUS COLORS ═══════════════════════════════
              _SectionLabel('STATUS COLORS'),
              Container(
                decoration: _cardDecoration(t),
                child: Column(
                  children: [
                    _ColorRow(
                      label: 'On Time',
                      color: statusColors.onTime,
                      onChanged: (c) =>
                          ref.read(statusColorsProvider.notifier).setOnTime(c),
                    ),
                    Divider(height: 1, color: t.dividerColor),
                    _ColorRow(
                      label: 'Caution',
                      color: statusColors.caution,
                      onChanged: (c) =>
                          ref.read(statusColorsProvider.notifier).setCaution(c),
                    ),
                    Divider(height: 1, color: t.dividerColor),
                    _ColorRow(
                      label: 'Late',
                      color: statusColors.late,
                      onChanged: (c) =>
                          ref.read(statusColorsProvider.notifier).setLate(c),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ══ ORDER TYPE ══════════════════════════════════
              _SectionLabel('ORDER TYPE'),
              Container(
                decoration: _cardDecoration(t),
                child: Column(
                  children: List.generate(OrderType.values.length, (i) {
                    final type = OrderType.values[i];
                    final isLast = i == OrderType.values.length - 1;
                    return Column(
                      children: [
                        _ColorRow(
                          label: type.label,
                          color: typeColors[type]!,
                          onChanged: (c) => ref
                              .read(orderTypeColorsProvider.notifier)
                              .setColor(type, c),
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
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: t.textTheme.labelSmall?.copyWith(
          letterSpacing: 1,
          color: t.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Color row — tap করলে color picker ────────────────────────────────────────
class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  Future<void> _pickColor(BuildContext context) async {
    final result = await showDialog<Color>(
      context: context,
      builder: (_) => _ColorPickerDialog(current: color, label: label),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: () => _pickColor(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(label, style: t.textTheme.titleMedium)),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: t.dividerColor, width: 2),
              ),
            ),
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
  }
}

// ── Color picker dialog — preset swatches ─────────────────────────────────────
class _ColorPickerDialog extends StatelessWidget {
  const _ColorPickerDialog({required this.current, required this.label});

  final Color current;
  final String label;

  static const _swatches = [
    // greens
    Color(0xFF4CAF50), Color(0xFF81C784), Color(0xFF2E7D32), Color(0xFF00C853),
    // yellows / oranges
    Color(0xFFFFC107), Color(0xFFFF9800), Color(0xFFFFB74D), Color(0xFFF57C00),
    // reds / pinks
    Color(0xFFEF5350), Color(0xFFE53935), Color(0xFFFF8A80), Color(0xFFD81B60),
    // blues
    Color(0xFF2196F3), Color(0xFF64B5F6), Color(0xFF1565C0), Color(0xFF00B0FF),
    // purples
    Color(0xFF9C27B0), Color(0xFFBA68C8), Color(0xFF6A1B9A), Color(0xFF7C4DFF),
    // teals / cyans
    Color(0xFF009688), Color(0xFF4DB6AC), Color(0xFF00838F), Color(0xFF84FFFF),
    // greys / others
    Color(0xFF607D8B), Color(0xFF90A4AE), Color(0xFF795548), Color(0xFF9E9E9E),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                label,
                style: t.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Divider(height: 1, color: t.dividerColor),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 14,
                runSpacing: 14,
                children: _swatches.map((c) {
                  final isSelected = c.value == current.value;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(c),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? t.colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
