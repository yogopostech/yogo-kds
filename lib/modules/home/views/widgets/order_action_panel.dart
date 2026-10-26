// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/home_controller.dart';

// class OrderActionPanel extends GetView<HomeController> {
//   const OrderActionPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);
//     return Obx(() {
//       final visible = controller.showActionPanel.value;
//       return AnimatedSlide(
//         offset: visible ? Offset.zero : const Offset(1, 0),
//         duration: const Duration(milliseconds: 220),
//         curve: Curves.easeOutCubic,
//         child: AnimatedOpacity(
//           opacity: visible ? 1 : 0,
//           duration: const Duration(milliseconds: 180),
//           child: Container(
//             width: 180,
//             decoration: BoxDecoration(
//               color: t.colorScheme.surface,
//               border: Border(
//                 left: BorderSide(color: t.dividerColor),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   blurRadius: 16,
//                   offset: const Offset(-4, 0),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // header
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   decoration: BoxDecoration(
//                     border: Border(bottom: BorderSide(color: t.dividerColor)),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           controller.selectedOrder?.customerName ?? '',
//                           style: t.textTheme.titleMedium,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: controller.closeActionPanel,
//                         child: Icon(Icons.close, size: 18, color: t.colorScheme.onSurfaceVariant),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // actions
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       _ActionTile(
//                         icon: Icons.keyboard_double_arrow_left_rounded,
//                         label: 'TO FRONT',
//                         onTap: () => controller.moveToFront(controller.selectedOrderId.value),
//                       ),
//                       _ActionTile(
//                         icon: Icons.keyboard_arrow_left_rounded,
//                         label: 'FORWARD',
//                         onTap: () => controller.moveForward(controller.selectedOrderId.value),
//                       ),
//                       _ActionTile(
//                         icon: Icons.keyboard_arrow_right_rounded,
//                         label: 'BACKWARD',
//                         onTap: () => controller.moveBackward(controller.selectedOrderId.value),
//                       ),
//                       _ActionTile(
//                         icon: Icons.keyboard_double_arrow_right_rounded,
//                         label: 'TO BACK',
//                         onTap: () => controller.moveToBack(controller.selectedOrderId.value),
//                       ),
//                       Divider(height: 1, color: t.dividerColor),
//                       _ActionTile(
//                         icon: Icons.pause_circle_outline_rounded,
//                         label: 'HOLD',
//                         color: t.colorScheme.primary,
//                         onTap: () => controller.holdOrder(controller.selectedOrderId.value),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }

// class _ActionTile extends StatelessWidget {
//   const _ActionTile({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.color,
//   });

//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   final Color? color;

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);
//     final c = color ?? t.colorScheme.onSurface;
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         child: Row(
//           children: [
//             Icon(icon, size: 22, color: c),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: c,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../providers/home_provider.dart';

// class OrderActionPanel extends ConsumerWidget {
//   const OrderActionPanel({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final visible = ref.watch(showActionPanelProvider);
//     final selId = ref.watch(selectedOrderIdProvider);
//     final orders = ref.watch(ordersProvider);
//     final order = orders.where((o) => o.id == selId).firstOrNull;
//     final notifier = ref.read(ordersProvider.notifier);

//     void close() {
//       ref.read(showActionPanelProvider.notifier).state = false;
//       ref.read(selectedOrderIdProvider.notifier).state = '';
//     }

//     return AnimatedSlide(
//       offset: visible ? Offset.zero : const Offset(1, 0),
//       duration: const Duration(milliseconds: 220),
//       curve: Curves.easeOutCubic,
//       child: AnimatedOpacity(
//         opacity: visible ? 1 : 0,
//         duration: const Duration(milliseconds: 180),
//         child: Container(
//           width: 180,
//           decoration: BoxDecoration(
//             color: t.colorScheme.surface,
//             border: Border(left: BorderSide(color: t.dividerColor)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.15),
//                 blurRadius: 16,
//                 offset: const Offset(-4, 0),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   border: Border(bottom: BorderSide(color: t.dividerColor)),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         order?.customerName ?? '',
//                         style: t.textTheme.titleMedium,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: close,
//                       child: Icon(
//                         Icons.close,
//                         size: 18,
//                         color: t.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView(
//                   children: [
//                     _ActionTile(
//                       icon: Icons.keyboard_double_arrow_left_rounded,
//                       label: 'TO FRONT',
//                       onTap: () {
//                         notifier.moveToFront(selId);
//                         close();
//                       },
//                     ),
//                     _ActionTile(
//                       icon: Icons.keyboard_arrow_left_rounded,
//                       label: 'FORWARD',
//                       onTap: () {
//                         notifier.moveForward(selId);
//                         close();
//                       },
//                     ),
//                     _ActionTile(
//                       icon: Icons.keyboard_arrow_right_rounded,
//                       label: 'BACKWARD',
//                       onTap: () {
//                         notifier.moveBackward(selId);
//                         close();
//                       },
//                     ),
//                     _ActionTile(
//                       icon: Icons.keyboard_double_arrow_right_rounded,
//                       label: 'TO BACK',
//                       onTap: () {
//                         notifier.moveToBack(selId);
//                         close();
//                       },
//                     ),
//                     Divider(height: 1, color: t.dividerColor),

//                     // _ActionTile(icon: Icons.pause_circle_outline_rounded, label: 'HOLD',
//                     //     color: t.colorScheme.primary,
//                     //     onTap: () { notifier.toggleHold(selId); close(); }),
//                     _ActionTile(
//                       icon: Icons.pause_circle_outline_rounded,
//                       label: 'HOLD',
//                       color: t.colorScheme.primary,
//                       onTap: () {
//                         // hold dialog
//                         ref.read(holdOrderIdProvider.notifier).state = selId;
//                         ref.read(showHoldDialogProvider.notifier).state = true;
//                         close();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ActionTile extends StatelessWidget {
//   const _ActionTile({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.color,
//   });

//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   final Color? color;

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);
//     final c = color ?? t.colorScheme.onSurface;
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         child: Row(
//           children: [
//             Icon(icon, size: 22, color: c),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: c,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/home_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../shared/enums/order_enums.dart';

class OrderActionPanel extends ConsumerWidget {
  const OrderActionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final visible = ref.watch(showActionPanelProvider);
    final selId = ref.watch(selectedOrderIdProvider);
    final orders = ref.watch(ordersProvider);
    // final order    = orders.where((o) => o.id == selId).firstOrNull;
    final ordersState = ref.watch(ordersProvider);
    final allOrders = [
      ...ordersState.open,
      ...ordersState.hold,
      ...ordersState.completed,
    ];
    final order = allOrders.where((o) => o.id == selId).firstOrNull;
    final notifier = ref.read(ordersProvider.notifier);
    final typeColors = ref.watch(orderTypeColorsProvider);

    void close() {
      ref.read(showActionPanelProvider.notifier).state = false;
      ref.read(selectedOrderIdProvider.notifier).state = '';
    }

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(1, 0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: t.colorScheme.surface,
            border: Border(left: BorderSide(color: t.dividerColor)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: t.dividerColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        order?.customerName ?? '',
                        style: t.textTheme.titleMedium!.copyWith(fontSize: 28),

                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: close,
                      child: Icon(
                        Icons.close,
                        size: 35,
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Actions ─────────────────────────────────
              Expanded(
                child: ListView(
                  children: [
                    _ActionTile(
                      icon: Icons.keyboard_double_arrow_left_rounded,
                      label: 'TO FRONT',
                      onTap: () {
                        notifier.moveToFront(selId);
                        // close();
                      },
                    ),
                    _ActionTile(
                      icon: Icons.keyboard_arrow_left_rounded,
                      label: 'FORWARD',
                      onTap: () {
                        notifier.moveForward(selId);
                        // close();
                      },
                    ),
                    _ActionTile(
                      icon: Icons.keyboard_arrow_right_rounded,
                      label: 'BACKWARD',
                      onTap: () {
                        notifier.moveBackward(selId);
                        // close();
                      },
                    ),
                    _ActionTile(
                      icon: Icons.keyboard_double_arrow_right_rounded,
                      label: 'TO BACK',
                      onTap: () {
                        notifier.moveToBack(selId);
                        // close();
                      },
                    ),
                    Divider(height: 1, color: t.dividerColor),
                    _ActionTile(
                      icon: Icons.pause_circle_outline_rounded,
                      label: 'HOLD',
                      color: t.colorScheme.primary,
                      onTap: () {
                        ref.read(holdOrderIdProvider.notifier).state = selId;
                        ref.read(showHoldDialogProvider.notifier).state = true;
                        close();
                      },
                    ),
                    Divider(height: 1, color: t.dividerColor),

                    // ══ ORDER TYPE section ══════════════════
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Text(
                        'ORDER TYPE',
                        style: t.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: t.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.9,
                        children: OrderType.values.map((type) {
                          final isSelected = order?.type == type;
                          final color =
                              typeColors[type] ?? t.colorScheme.primary;
                          return InkWell(
                            onTap: () {
                              notifier.changeOrderType(selId, type);
                              close();
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color.withOpacity(
                                  isSelected ? 1.0 : 0.75,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(
                                        color: t.colorScheme.onSurface,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Text(
                                        type.label,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = color ?? t.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: c),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
