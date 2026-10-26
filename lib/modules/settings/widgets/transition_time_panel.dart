import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../shared/enums/order_enums.dart';

class TransitionTimesPanel extends ConsumerWidget {
  const TransitionTimesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final times = ref.watch(transitionTimesProvider);

    return Column(
      children: [
        // header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            'Transition Times',
            style: t.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Divider(height: 1, color: t.dividerColor),

        // per-type sections
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: OrderType.values.map((type) {
              final time = times[type]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // section label
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      type.label,
                      style: t.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1,
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  // caution + late rows
                  Container(
                    decoration: BoxDecoration(
                      color: t.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.dividerColor),
                    ),
                    child: Column(
                      children: [
                        _TimeRow(
                          label: 'Caution Time',
                          minutes: time.cautionMinutes,
                          onChanged: (v) => ref
                              .read(transitionTimesProvider.notifier)
                              .setCaution(type, v),
                        ),
                        Divider(height: 1, color: t.dividerColor),
                        _TimeRow(
                          label: 'Late Time',
                          minutes: time.lateMinutes,
                          onChanged: (v) => ref
                              .read(transitionTimesProvider.notifier)
                              .setLate(type, v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── একটা time row — tap করলে minute picker ────────────────────────────────────
class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.minutes,
    required this.onChanged,
  });

  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;

  Future<void> _pickMinutes(BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _MinutePickerDialog(current: minutes, label: label),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: () => _pickMinutes(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: t.textTheme.titleMedium),
            ),
            Text(
              '$minutes:00 min',
              style: t.textTheme.bodyMedium,
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right,
                size: 20, color: t.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Minute picker dialog ──────────────────────────────────────────────────────
class _MinutePickerDialog extends StatelessWidget {
  const _MinutePickerDialog({required this.current, required this.label});

  final int current;
  final String label;

  static const _options = [1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 15, 20, 25, 30];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                label,
                style: t.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Divider(height: 1, color: t.dividerColor),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _options.map((m) {
                  final isSelected = m == current;
                  return ListTile(
                    leading: isSelected
                        ? Icon(Icons.check, color: t.colorScheme.primary)
                        : const SizedBox(width: 24),
                    title: Text('$m minutes'),
                    onTap: () => Navigator.of(context).pop(m),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}