import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/kds_order.dart';
import '../../../../providers/home_provider.dart';

class RecallDialog extends ConsumerWidget {
  const RecallDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    ref.watch(ordersProvider); // completed list বদলালে rebuild
    final completed = ref.watch(ordersProvider.notifier).completedOrders;
    final page = ref.watch(recallPageProvider);
    final expandedId = ref.watch(expandedRecallIdProvider);

    final totalPages = (completed.length / recallPerPage).ceil().clamp(1, 999);
    final start = page * recallPerPage;
    final pageOrders = completed.skip(start).take(recallPerPage).toList();

    void close() {
      ref.read(showRecallDialogProvider.notifier).state = false;
      ref.read(recallPageProvider.notifier).state = 0;
      ref.read(expandedRecallIdProvider.notifier).state = '';
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                IconButton(
                  onPressed: close,
                  icon: const Icon(Icons.close, size: 35),
                ),
                Expanded(
                  child: Text(
                    'Recall Closed Orders',
                    textAlign: TextAlign.center,
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: completed.isEmpty
                //       ? null
                //       : () {
                //           ref.read(ordersProvider.notifier).clearCompleted();
                //           ref.read(recallPageProvider.notifier).state = 0;
                //         },
                //   child: Text(
                //     'Clear Orders',
                //     style: TextStyle(
                //       fontSize: 28,
                //       color: completed.isEmpty
                //           ? t.disabledColor
                //           : t.colorScheme.error,
                //     ),
                //   ),
                // ),
                // TextButton(
                //   onPressed: completed.isEmpty
                //       ? null
                //       : () async {
                //           await ref
                //               .read(ordersProvider.notifier)
                //               .clearCompleted();
                //           ref.read(recallPageProvider.notifier).state = 0;
                //           if (context.mounted) {
                //             ScaffoldMessenger.of(context).showSnackBar(
                //               const SnackBar(
                //                 content: Text('Completed orders cleared'),
                //               ),
                //             );
                //           }
                //         },
                //   child: Text(
                //     'Clear Orders',
                //     style: TextStyle(
                //       fontSize: 28,
                //       color: completed.isEmpty
                //           ? t.disabledColor
                //           : t.colorScheme.error,
                //     ),
                //   ),
                // ),
                TextButton(
                  onPressed: completed.isEmpty
                      ? null
                      : () async {
                          // permission dialog
                          final yes = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Clear Completed Orders'),
                              content: const Text(
                                'This will remove all completed orders. This cannot be undone. Continue?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text(
                                    'No',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                       fontSize: 20,
                                      color: Theme.of(ctx).colorScheme.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (yes != true) return; // No / cancel hole kichu na

                          // Yes hole clear
                          await ref
                              .read(ordersProvider.notifier)
                              .clearCompleted();
                          ref.read(recallPageProvider.notifier).state = 0;
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Completed orders cleared'),
                              ),
                            );
                          }
                        },
                  child: Text(
                    'Clear Orders',
                    style: TextStyle(
                      fontSize: 28,
                      color: completed.isEmpty
                          ? t.disabledColor
                          : t.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: t.dividerColor),

          // ── Order list ────────────────────────────────────
          Expanded(
            child: completed.isEmpty
                ? const Center(
                    child: Text(
                      'No closed orders',
                      style: TextStyle(fontSize: 28),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pageOrders.length,
                    itemBuilder: (_, i) {
                      final order = pageOrders[i];
                      final isExpanded = expandedId == order.id;
                      return _RecallRow(
                        order: order,
                        isExpanded: isExpanded,
                        onRecall: () {
                          ref.read(ordersProvider.notifier).recall(order.id);
                        },
                        onToggleExpand: () {
                          ref.read(expandedRecallIdProvider.notifier).state =
                              isExpanded ? '' : order.id;
                        },
                      );
                    },
                  ),
          ),

          Divider(height: 1, color: t.dividerColor),

          // ── Pagination ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
                  onPressed: page > 0
                      ? () => ref.read(recallPageProvider.notifier).state = 0
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: page > 0
                      ? () => ref.read(recallPageProvider.notifier).state =
                            page - 1
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: t.dividerColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${page + 1}'),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: page < totalPages - 1
                      ? () => ref.read(recallPageProvider.notifier).state =
                            page + 1
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_right_rounded),
                  onPressed: page < totalPages - 1
                      ? () => ref.read(recallPageProvider.notifier).state =
                            totalPages - 1
                      : null,
                ),
                const SizedBox(width: 12),
                const Text(
                  '$recallPerPage Per Page',
                  style: TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single recall row ─────────────────────────────────────────────────────────
class _RecallRow extends StatelessWidget {
  const _RecallRow({
    required this.order,
    required this.isExpanded,
    required this.onRecall,
    required this.onToggleExpand,
  });

  final KdsOrder order;
  final bool isExpanded;
  final VoidCallback onRecall;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final firstItem = order.items.isNotEmpty ? order.items.first.name : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.dividerColor),
      ),
      child: Column(
        children: [
          // main row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Recall button
                ElevatedButton(
                  onPressed: onRecall,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Recall', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),

                // customer name
                Expanded(
                  flex: 2,
                  child: Text(
                    order.customerName,
                    style: const TextStyle(fontSize: 28),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // completed time
                Expanded(
                  flex: 3,
                  child: Text(
                    order.completedAtLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),

                // first item + dropdown
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: onToggleExpand,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            firstItem,
                            style: const TextStyle(fontSize: 28),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // expanded details — সব item + modifier
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.qty}  ${item.name}',
                          style: t.textTheme.titleMedium?.copyWith(
                            fontSize: 28,
                          ),
                        ),
                        // ...item.modifiers.map(
                        //   (m) => Padding(
                        //     padding: const EdgeInsets.only(left: 20, top: 2),
                        //     child: Text(m, style:  const TextStyle(fontSize: 28)),
                        //   ),
                        // ),
                        ...item.modifiers.map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(left: 20, top: 2),
                            child: Text(m.name, style: t.textTheme.bodyMedium),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
