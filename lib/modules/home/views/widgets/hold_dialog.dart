import 'package:flutter/material.dart';
import '../../../../shared/enums/order_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/home_provider.dart';

class HoldDialog extends ConsumerStatefulWidget {
  const HoldDialog({super.key});

  @override
  ConsumerState<HoldDialog> createState() => _HoldDialogState();
}

class _HoldDialogState extends ConsumerState<HoldDialog> {
  final _hhController = TextEditingController(text: '00');
  final _mmController = TextEditingController(text: '10');

  static const _presets = [5, 10, 15, 30, 45, 60];

  @override
  void dispose() {
    _hhController.dispose();
    _mmController.dispose();
    super.dispose();
  }

  void _close() {
    ref.read(showHoldDialogProvider.notifier).state = false;
    ref.read(holdOrderIdProvider.notifier).state = '';
    ref.read(holdModeProvider.notifier).state = 0;
    ref.read(holdSelectedMinutesProvider.notifier).state = 5;
  }

  void _confirm() {
    final orderId = ref.read(holdOrderIdProvider);
    final mode = ref.read(holdModeProvider);

    int minutes;
    if (mode == 0) {
      minutes = ref.read(holdSelectedMinutesProvider);
    } else {
      final hh = int.tryParse(_hhController.text) ?? 0;
      final mm = int.tryParse(_mmController.text) ?? 0;
      minutes = hh * 60 + mm;
    }

    if (minutes <= 0) return; // invalid

    ref.read(ordersProvider.notifier).holdWithTimer(orderId, minutes);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final mode = ref.watch(holdModeProvider);
    final selectedMin = ref.watch(holdSelectedMinutesProvider);

    // dialog title এর জন্য order info
    final orderId = ref.watch(holdOrderIdProvider);
    ref.watch(ordersProvider);
    final order = ref
        .read(ordersProvider.notifier)
        .openOrders
        .where((o) => o.id == orderId)
        .firstOrNull;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                    SizedBox(
                  height: 70,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: _close,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancell',
                      style: TextStyle(fontWeight: FontWeight.w700,fontSize: 22),
                    ),
                  ),
                ),
                // TextButton(onPressed: _close, child: const Text('Cancel')),
                Expanded(
                  child: Text(
                    order == null
                        ? 'Put Order on Hold'
                        : 'Put Order on Hold: ${order.customerName} | ${order.placedAtLabel} | ${order.type.label}',
                    textAlign: TextAlign.center,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.w700,fontSize: 22),
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: _confirm,
                //   child: Text(
                //     'Confirm',
                //     style: TextStyle(
                //       color: t.colorScheme.primary,
                //       fontWeight: FontWeight.w700,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          Divider(height: 1, color: t.dividerColor),

          // ── Mode selector ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _ModeCard(
                    icon: Icons.notifications_paused_outlined,
                    title: 'Quick Set Time',
                    subtitle: 'Select from preset times',
                    isSelected: mode == 0,
                    onTap: () => ref.read(holdModeProvider.notifier).state = 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ModeCard(
                    icon: Icons.timer_outlined,
                    title: 'Custom Timer',
                    subtitle: 'Set amount of time hh:mm',
                    isSelected: mode == 1,
                    onTap: () => ref.read(holdModeProvider.notifier).state = 1,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: t.dividerColor),

          // ── Body — mode  ───────────────────────────
          Flexible(
            child: mode == 0
                // Quick set — preset list
                ? ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    children: _presets.map((m) {
                      final label = m == 60 ? '1 Hour' : '$m Minutes';
                      final isSel = selectedMin == m;
                      return InkWell(
                        onTap: () =>
                            ref
                                    .read(holdSelectedMinutesProvider.notifier)
                                    .state =
                                m,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: t.dividerColor),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: isSel
                                    ? Icon(
                                        Icons.check,
                                        color: t.colorScheme.primary,
                                        size: 20,
                                      )
                                    : null,
                              ),
                              Text(
                                label,
                                style: t.textTheme.titleMedium?.copyWith(
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                // Custom timer — hh:mm input
                : Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _hhController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: t.textTheme.displayMedium,
                            decoration: const InputDecoration(
                              counterText: '',
                              labelText: 'HH',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(':', style: t.textTheme.displayMedium),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _mmController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: t.textTheme.displayMedium,
                            decoration: const InputDecoration(
                              counterText: '',
                              labelText: 'MM',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Mode selection card ───────────────────────────────────────────────────────
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? t.colorScheme.primary : t.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? t.colorScheme.primary
                  : t.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
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
