import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/settings_provider.dart';

class OrdersPanel extends ConsumerWidget {
  const OrdersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final s = ref.watch(ordersSettingsProvider);
    final notifier = ref.read(ordersSettingsProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            'Orders',
            style: t.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Divider(height: 1, color: t.dividerColor),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SectionLabel('ORDER OPTIONS'),

              // ── Hide actions & type ──────────────────────
              _ToggleCard(
                title: 'Hide Actions Button & Order Type',
                subtitle:
                    'While this saves space, we recommend leaving this off — '
                    'Hold, Print, and ticket organization are only accessible '
                    'through this button.',
                value: s.hideActionsAndType,
                onChanged: (_) => notifier.toggleHideActions(),
              ),
              const SizedBox(height: 16),

              // ── grouped card ─────────────────────────────
              Container(
                decoration: _cardDecoration(t),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Hide Employee Name'),
                      value: s.hideEmployeeName,
                      onChanged: (_) => notifier.toggleHideEmployee(),
                    ),
                    Divider(height: 1, color: t.dividerColor),

                    // item display — nav row
                    ListTile(
                      title: const Text('Item Display Options'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.itemDisplay.label,
                              style: t.textTheme.bodyMedium),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right,
                              size: 20,
                              color: t.colorScheme.onSurfaceVariant),
                        ],
                      ),
                      onTap: () => _pickItemDisplay(context, ref, s.itemDisplay),
                    ),
                    Divider(height: 1, color: t.dividerColor),

                    SwitchListTile(
                      title: const Text('Show Seat Number'),
                      value: s.showSeatNumber,
                      onChanged: (_) => notifier.toggleSeatNumber(),
                    ),
                    Divider(height: 1, color: t.dividerColor),

                    SwitchListTile(
                      title: const Text('Strike Through Individual Modifiers'),
                      value: s.strikeIndividualModifiers,
                      onChanged: (_) => notifier.toggleStrikeModifiers(),
                    ),
                    Divider(height: 1, color: t.dividerColor),

                    SwitchListTile(
                      title: const Text('Merge Order Cards by Name'),
                      value: s.mergeByName,
                      onChanged: (_) => notifier.toggleMergeByName(),
                    ),
                    Divider(height: 1, color: t.dividerColor),

                    // merge time — nav row (only when merge on)
                    Opacity(
                      opacity: s.mergeByName ? 1 : 0.4,
                      child: IgnorePointer(
                        ignoring: !s.mergeByName,
                        child: ListTile(
                          title: const Text('Merge Order Cards by Name Time'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${s.mergeByNameMinutes} Minutes',
                                  style: t.textTheme.bodyMedium),
                              const SizedBox(width: 6),
                              Icon(Icons.chevron_right,
                                  size: 20,
                                  color: t.colorScheme.onSurfaceVariant),
                            ],
                          ),
                          onTap: () => _pickMergeMinutes(
                              context, ref, s.mergeByNameMinutes),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4, bottom: 24),
                child: Text(
                  'If "Merge Order Cards by Name" is on, new items will be added '
                  'to the existing card when the order name and type are identical '
                  'and orders arrive within the configured time window.',
                  style: t.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ),

              // ── new card per send (beta) ─────────────────
              Container(
                decoration: _cardDecoration(t),
                child: SwitchListTile(
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: t.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Beta',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      const Text('Create New Order Card per Send'),
                    ],
                  ),
                  value: s.newCardPerSend,
                  onChanged: (_) => notifier.toggleNewCardPerSend(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'If on, every send or order update with new items creates a new '
                  'order card. When off, new items are added to an existing card '
                  'if one is present.',
                  style: t.textTheme.bodyMedium?.copyWith(fontSize: 12),
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

  Future<void> _pickItemDisplay(
      BuildContext context, WidgetRef ref, ItemDisplayMode current) async {
    final result = await showDialog<ItemDisplayMode>(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx);
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Item Display Options',
                      style: t.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Divider(height: 1, color: t.dividerColor),
                ...ItemDisplayMode.values.map((m) => ListTile(
                      leading: m == current
                          ? Icon(Icons.check, color: t.colorScheme.primary)
                          : const SizedBox(width: 24),
                      title: Text(m.label),
                      onTap: () => Navigator.of(ctx).pop(m),
                    )),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      ref.read(ordersSettingsProvider.notifier).setItemDisplay(result);
    }
  }

  Future<void> _pickMergeMinutes(
      BuildContext context, WidgetRef ref, int current) async {
    const options = [2, 4, 8, 15, 30, 60];
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx);
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, maxHeight: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Merge Time',
                      style: t.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Divider(height: 1, color: t.dividerColor),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: options
                        .map((m) => ListTile(
                              leading: m == current
                                  ? Icon(Icons.check,
                                      color: t.colorScheme.primary)
                                  : const SizedBox(width: 24),
                              title: Text('$m minutes'),
                              onTap: () => Navigator.of(ctx).pop(m),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      ref.read(ordersSettingsProvider.notifier).setMergeMinutes(result);
    }
  }
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

// ── Toggle card with its own subtitle ────────────────────────────────────────
class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text(title),
            value: value,
            onChanged: onChanged,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              subtitle,
              style: t.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}