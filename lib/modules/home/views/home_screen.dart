import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yogo_kds/data/models/kds_order.dart';
import 'package:yogo_kds/modules/home/views/widgets/hold_dialog.dart';
import 'package:yogo_kds/modules/settings/widgets/bump_toast.dart';
import 'package:yogo_kds/providers/kds_realtime.dart';
import 'package:yogo_kds/providers/settings_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../shared/enums/order_enums.dart';
import 'widgets/item_summary_panel.dart';
import 'widgets/kds_left_drawer.dart';
import 'widgets/kds_tab_bar.dart';
import 'widgets/order_action_panel.dart';
import 'widgets/order_ticket_card.dart';
import 'widgets/recall_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(kdsRealtimeProvider);
    final showRecall = ref.watch(showRecallDialogProvider);
    final showHold = ref.watch(showHoldDialogProvider);
    final showSummary = ref.watch(showSummaryProvider);
    final summaryPos = ref.watch(summaryPositionProvider);

    return GestureDetector(
      // let children (PageView swipe, card taps) get gestures first;
      // this only catches taps on empty areas to close the action panel
      behavior: HitTestBehavior.deferToChild,
      onTap: () {
        if (ref.read(showActionPanelProvider)) {
          ref.read(showActionPanelProvider.notifier).state = false;
          ref.read(selectedOrderIdProvider.notifier).state = '';
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text('YOGO KDS', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.notifications_outlined, size: 30),
            //   onPressed: () {
            //     // notification action — wire later
            //   },
            // ),
            Consumer(
              builder: (context, ref, _) {
                final soundOn = ref.watch(notificationSoundProvider);
                return IconButton(
                  tooltip: soundOn
                      ? 'Notification sound on'
                      : 'Notification sound off',
                  icon: Icon(
                    soundOn
                        ? Icons
                              .notifications_rounded // on → bell
                        : Icons.notifications_off_rounded, // off → muted bell
                    color: soundOn
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => ref
                      .read(notificationSoundProvider.notifier)
                      .set(!soundOn),
                );
              },
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  const KdsLeftDrawer(),

                  // summary — Left position
                  if (showSummary && summaryPos == SummaryPosition.left)
                    const ItemSummaryPanel(),

                  Expanded(
                    child: Column(
                      children: [
                        const KdsTabBar(),
                        const Expanded(child: _OrdersArea()),
                        // summary — Bottom position
                        if (showSummary && summaryPos == SummaryPosition.bottom)
                          const ItemSummaryPanel(),
                      ],
                    ),
                  ),

                  // summary — Right position
                  if (showSummary && summaryPos == SummaryPosition.right)
                    const ItemSummaryPanel(),
                ],
              ),

              const Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: OrderActionPanel(),
              ),

              // Bump toast — top right
              const Positioned(top: 12, right: 16, child: BumpToast()),

              // ── Recall dialog overlay ────────────────────
              if (showRecall)
                Container(
                  color: Colors.black54,
                  child: const Center(child: RecallDialog()),
                ),

              // ── Hold dialog overlay ──────────────────────
              if (showHold)
                Container(
                  color: Colors.black54,
                  child: const Center(child: HoldDialog()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersArea extends ConsumerWidget {
  const _OrdersArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(kdsTabProvider);
    final ordersState = ref.watch(ordersProvider);
    final visibility = ref.watch(orderTypeVisibilityProvider);
    final routing = ref.watch(routingProvider);

    // Apply order-type visibility and routing filters
    List<KdsOrder> visible(List<KdsOrder> list) {
      final byType = list.where((o) => visibility[o.type] ?? true).toList();
      return applyRouting(byType, routing);
    }

    switch (tab) {
      case KdsTab.open:
        return _OrderList(
          orders: visible(ordersState.open),
          emptyLabel: 'No open orders',
        );
      case KdsTab.completed:
        return _OrderList(
          orders: visible(ordersState.completed),
          emptyLabel: 'No completed orders',
          dimmed: true,
        );
      case KdsTab.hold:
        return _OrderList(
          orders: visible(ordersState.hold),
          emptyLabel: 'No orders on hold',
        );
    }
  }
}

class _OrderList extends ConsumerWidget {
  const _OrderList({
    required this.orders,
    required this.emptyLabel,
    this.dimmed = false,
  });

  final List<KdsOrder> orders;
  final String emptyLabel;
  final bool dimmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Text(emptyLabel, style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    final layout = ref.watch(kdsLayoutProvider);

    switch (layout) {
      // ── Classic — one row, horizontal scroll ──────────────
      case KdsLayout.classic:
        return Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: orders
                  .map((o) => OrderTicketCard(order: o, dimmed: dimmed))
                  .toList(),
            ),
          ),
        );

      // ── Tiled — fills top to bottom, vertical scroll ──────
      case KdsLayout.tiled:
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 16),
          child: Wrap(
            spacing: 0,
            runSpacing: 12,
            children: orders
                .map((o) => OrderTicketCard(order: o, dimmed: dimmed))
                .toList(),
          ),
        );

      // ── Split — two rows by order type ────────────────────
      // case KdsLayout.split:
      //   final topRow =
      //       orders.where((o) => o.type == OrderType.dineIn).toList();
      //   final bottomRow =
      //       orders.where((o) => o.type == OrderType.takeOut).toList();

      //   Widget row(List<KdsOrder> list) => Align(
      //         alignment: Alignment.topLeft,
      //         child: SingleChildScrollView(
      //           scrollDirection: Axis.horizontal,
      //           padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
      //           child: SingleChildScrollView(
      //             scrollDirection: Axis.vertical,
      //             child: IntrinsicHeight(
      //               child: Row(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: list
      //                     .map((o) =>
      //                         OrderTicketCard(order: o, dimmed: dimmed))
      //                     .toList(),
      //               ),
      //             ),
      //           ),
      //         ),
      //       );

      //   return Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.only(left: 16, top: 8),
      //         child: Align(
      //           alignment: Alignment.centerLeft,
      //           child: Text(
      //             'DINE IN',
      //             style: Theme.of(context).textTheme.labelSmall?.copyWith(
      //                   letterSpacing: 1,
      //                   fontWeight: FontWeight.w700,
      //                 ),
      //           ),
      //         ),
      //       ),
      //       Expanded(child: row(topRow)),
      //       Divider(height: 1, color: Theme.of(context).dividerColor),
      //       Padding(
      //         padding: const EdgeInsets.only(left: 16, top: 8),
      //         child: Align(
      //           alignment: Alignment.centerLeft,
      //           child: Text(
      //             'TAKE OUT',
      //             style: Theme.of(context).textTheme.labelSmall?.copyWith(
      //                   letterSpacing: 1,
      //                   fontWeight: FontWeight.w700,
      //                 ),
      //           ),
      //         ),
      //       ),
      //       Expanded(child: row(bottomRow)),
      //     ],
      //   );

      // ── Split — two rows by order type ────────────────────
      case KdsLayout.split:
        final topRow = orders.where((o) => o.type == OrderType.dineIn).toList();
        final bottomRow = orders
            .where((o) => o.type == OrderType.takeOut)
            .toList();

        // IntrinsicHeight baad — card er LayoutBuilder er sathe conflict kore
        // (blank hoye jeto). Classic er moto shudhu horizontal scroll + Row.
        Widget row(List<KdsOrder> list) => Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list
                  .map((o) => OrderTicketCard(order: o, dimmed: dimmed))
                  .toList(),
            ),
          ),
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DINE IN',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(child: row(topRow)),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'TAKE OUT',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(child: row(bottomRow)),
          ],
        );

      // ── Full Columns — 4 per page, full height, swipe ─────
      case KdsLayout.fullColumns:
        const cols = 4;
        const spacing = 12.0;
        final pageCount = (orders.length / cols).ceil();

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardMinHeight = constraints.maxHeight - 24;

            return PageView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: pageCount,
              itemBuilder: (context, pageIndex) {
                final start = pageIndex * cols;
                final end = (start + cols).clamp(0, orders.length);
                final pageOrders = orders.sublist(start, end);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(cols, (i) {
                      if (i >= pageOrders.length) {
                        return const Expanded(child: SizedBox());
                      }
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i < cols - 1 ? spacing : 0,
                          ),
                          child: SizedBox(
                            height:
                                cardMinHeight, // fixed height → release bottom e
                            child: OrderTicketCard(
                              order: pageOrders[i],
                              dimmed: dimmed,
                              fullWidth: true,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            );
          },
        );

      // ── Grid — 4x2 per page, full height, horizontal swipe ─
      case KdsLayout.grid:
        const cols = 4;
        const rows = 2;
        const perPage = cols * rows;
        const spacing = 12.0;
        final pageCount = (orders.length / perPage).ceil();

        return LayoutBuilder(
          builder: (context, constraints) {
            final availW = constraints.maxWidth - 32;
            final availH = constraints.maxHeight - 24;
            final cellW = (availW - spacing * (cols - 1)) / cols;
            final cellH = (availH - spacing * (rows - 1)) / rows;

            return PageView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: pageCount,
              itemBuilder: (context, pageIndex) {
                final start = pageIndex * perPage;
                final end = (start + perPage).clamp(0, orders.length);
                final pageOrders = orders.sublist(start, end);

                // manual row/column grid so PageView can catch drags
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(rows, (rowIndex) {
                      final rowStart = rowIndex * cols;
                      if (rowStart >= pageOrders.length) {
                        return const SizedBox.shrink();
                      }
                      final rowEnd = (rowStart + cols).clamp(
                        0,
                        pageOrders.length,
                      );
                      final rowItems = pageOrders.sublist(rowStart, rowEnd);

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: rowIndex < rows - 1 ? spacing : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(cols, (colIndex) {
                            if (colIndex >= rowItems.length) {
                              return SizedBox(width: cellW);
                            }
                            return Padding(
                              padding: EdgeInsets.only(
                                right: colIndex < cols - 1 ? spacing : 0,
                              ),
                              child: SizedBox(
                                width: cellW,
                                height: cellH,
                                child: OrderTicketCard(
                                  order: rowItems[colIndex],
                                  dimmed: dimmed,
                                  fullWidth: true,
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                );
              },
            );
          },
        );
    }
  }
}
