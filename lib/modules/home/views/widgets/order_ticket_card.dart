// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yogo_kds/providers/settings_provider.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../data/models/kds_order.dart';
// import '../../../../providers/home_provider.dart';
// import '../../../../shared/enums/order_enums.dart';

// class OrderTicketCard extends ConsumerWidget {
//   const OrderTicketCard({
//     super.key,
//     required this.order,
//     this.dimmed = false,
//     this.fullWidth = false,
//   });

//   final KdsOrder order;
//   final bool dimmed;
//   final bool fullWidth;

//   Color _typeBadgeColor(OrderType tp) {
//     switch (tp) {
//       case OrderType.dineIn:
//         return AppColors.typeForHere;
//       case OrderType.takeOut:
//         return AppColors.typePickup;
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final isDark = t.brightness == Brightness.dark;
//     final selectedId = ref.watch(selectedOrderIdProvider);
//     final isSelected = selectedId == order.id;
//     final readyColor = t.colorScheme.onSurfaceVariant.withOpacity(0.45);
//     final scale = ref.watch(fontSizeProvider).scale;

//     // ── Orders settings ────────────────────────────────
//     final ordersSettings = ref.watch(ordersSettingsProvider);
//     final hideActions = ordersSettings.hideActionsAndType;
//     final strikeMods = ordersSettings.strikeIndividualModifiers;
//     final itemDisplay = ordersSettings.itemDisplay;

//     // Separate mode: split qty into individual lines; Combine: as-is
//     final displayItems = itemDisplay == ItemDisplayMode.separate
//         ? order.items.expand((item) {
//             return List.generate(
//               item.qty,
//               (_) => KdsOrderItem(
//                 name: item.name,
//                 qty: 1,
//                 category: item.category,
//                 modifiers: item.modifiers,
//                 variations: item.variations,
//                 kitchenNote: item.kitchenNote,
//                 isReady: item.isReady,
//               ),
//             );
//           }).toList()
//         : order.items;

//     final separateMode = itemDisplay == ItemDisplayMode.separate;

//     return Opacity(
//       opacity: dimmed ? 0.55 : 1.0,
//       child: Container(
//         width: fullWidth ? null : 290,
//         constraints: fullWidth ? null : const BoxConstraints(maxHeight: 500),
//         margin: fullWidth ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
//         decoration: BoxDecoration(
//           color: t.cardColor,
//           borderRadius: BorderRadius.zero,
//           border: Border.all(
//             color: isSelected ? t.colorScheme.primary : t.dividerColor,
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ══ Header — tap to bump ═════════════════════════
//             GestureDetector(
//               onTap: dimmed
//                   ? null
//                   : () {
//                       ref.read(ordersProvider.notifier).bump(order.id);
//                       ref.read(lastBumpedOrderProvider.notifier).state = order;
//                     },
//               child: _CardHeader(
//                 order: order,
//                 onBump: () {
//                   ref.read(ordersProvider.notifier).bump(order.id);
//                   ref.read(lastBumpedOrderProvider.notifier).state = order;
//                 },
//               ),
//             ),

//             // ══ 3-dot + Type badge row ═══════════════════════
//             if (!hideActions)
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 7,
//                 ),
//                 child: Row(
//                   children: [
//                     // ── "···" action button (type button er theke 10% choto) ──

//                     // ── Type badge ──
//                     Expanded(
//                       flex: 10, // ← reference width
//                       child: Container(
//                         height: 34,
//                         decoration: BoxDecoration(
//                           color: _typeBadgeColor(order.type),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(
//                           order.type.label,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 0.4,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(width: 15),
//                     Expanded(
//                       flex: 8, // ← 10% smaller than type badge (10)
//                       child: InkWell(
//                         onTap: () {
//                           ref.read(selectedOrderIdProvider.notifier).state =
//                               order.id;
//                           ref.read(showActionPanelProvider.notifier).state =
//                               true;
//                         },
//                         borderRadius: BorderRadius.circular(6),
//                         child: Container(
//                           height: 34,
//                           decoration: BoxDecoration(
//                             color: t.colorScheme.surfaceContainerHighest,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           alignment: Alignment.center,
//                           clipBehavior: Clip.hardEdge,
//                           child: OverflowBox(
//                             minHeight: 0,
//                             maxHeight: double.infinity,
//                             child: Icon(
//                               Icons.more_horiz,
//                               size: 40,
//                               color: t.colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 // child: Row(
//                 //   children: [
//                 //     // // ── Type badge ──
//                 //     // Expanded(
//                 //     //   child: Container(
//                 //     //     height: 34,
//                 //     //     decoration: BoxDecoration(
//                 //     //       color: _typeBadgeColor(order.type),
//                 //     //       borderRadius: BorderRadius.circular(6),
//                 //     //     ),
//                 //     //     alignment: Alignment.center,
//                 //     //     child: Text(
//                 //     //       order.type.label,
//                 //     //       style: const TextStyle(
//                 //     //         color: Colors.white,
//                 //     //         fontSize: 15,
//                 //     //         fontWeight: FontWeight.w700,
//                 //     //         letterSpacing: 0.4,
//                 //     //       ),
//                 //     //     ),
//                 //     //   ),
//                 //     // ),

//                 //     // ── "···" action button ──
//                 //     Expanded(
//                 //       child: InkWell(
//                 //         onTap: () {
//                 //           ref.read(selectedOrderIdProvider.notifier).state =
//                 //               order.id;
//                 //           ref.read(showActionPanelProvider.notifier).state =
//                 //               true;
//                 //         },
//                 //         borderRadius: BorderRadius.circular(6),
//                 //         child: Container(
//                 //           height: 34,
//                 //           decoration: BoxDecoration(
//                 //             color: t.colorScheme.surfaceContainerHighest,
//                 //             borderRadius: BorderRadius.circular(6),
//                 //           ),
//                 //           alignment: Alignment.center,
//                 //           clipBehavior: Clip.hardEdge,
//                 //           child: OverflowBox(
//                 //             minHeight: 0,
//                 //             maxHeight: double.infinity,
//                 //             child: Icon(
//                 //               Icons.more_horiz,
//                 //               size: 40,
//                 //               color: t.colorScheme.onSurfaceVariant,
//                 //             ),
//                 //           ),
//                 //         ),
//                 //       ),
//                 //     ),

//                 //     const SizedBox(width: 25),

//                 //     // ── Type badge ──
//                 //     Expanded(
//                 //       child: Container(
//                 //         height: 34,
//                 //         decoration: BoxDecoration(
//                 //           color: _typeBadgeColor(order.type),
//                 //           borderRadius: BorderRadius.circular(6),
//                 //         ),
//                 //         alignment: Alignment.center,
//                 //         child: Text(
//                 //           order.type.label,
//                 //           style: const TextStyle(
//                 //             color: Colors.white,
//                 //             fontSize: 15,
//                 //             fontWeight: FontWeight.w700,
//                 //             letterSpacing: 0.4,
//                 //           ),
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),
//               ),

//             if (!hideActions)
//               Divider(height: 1, thickness: 1, color: t.dividerColor),

//             // ══ Items — only this section scrolls ════════════
//             Flexible(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 10,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: List.generate(displayItems.length, (i) {
//                       final item = displayItems[i];
//                       final isReady = item.isReady;

//                       final itemTextColor = isReady
//                           ? readyColor
//                           : t.colorScheme.onSurface;

//                       // left column width (qty box) + 8 gap
//                       final double leadWidth = 22 * scale;
//                       final double indent = leadWidth + 8;

//                       // reusable "--" lead that sits under the qty number
//                       Widget dashLead(Color c) => SizedBox(
//                         width: leadWidth,
//                         child: Text(
//                           '--',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 14 * scale,
//                             fontWeight: FontWeight.w700,
//                             color: c,
//                           ),
//                         ),
//                       );

//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // ── Item name row (qty box + name) ──
//                             InkWell(
//                               onTap: (dimmed || separateMode)
//                                   ? null
//                                   : () => ref
//                                         .read(ordersProvider.notifier)
//                                         .toggleItemReady(order.id, i),
//                               borderRadius: BorderRadius.circular(6),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     width: leadWidth,
//                                     height: 22 * scale,
//                                     decoration: BoxDecoration(
//                                       color: isReady
//                                           ? readyColor
//                                           : t.colorScheme.onSurface,
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                     alignment: Alignment.center,
//                                     child: Text(
//                                       '${item.qty}',
//                                       style: TextStyle(
//                                         color: t.colorScheme.surface,
//                                         fontSize: 12 * scale,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       item.name.toUpperCase(),
//                                       style: TextStyle(
//                                         fontSize: 14 * scale,
//                                         fontWeight: FontWeight.w700,
//                                         color: itemTextColor,
//                                         decoration: isReady
//                                             ? TextDecoration.lineThrough
//                                             : null,
//                                         decorationColor: readyColor,
//                                         decorationThickness: 2,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // ── Variation lines ("--" + variation name) ──
//                             ...List.generate(item.variations.length, (vi) {
//                               final v = item.variations[vi];
//                               return Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     dashLead(itemTextColor),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         v.name,
//                                         style: TextStyle(
//                                           fontSize: 14 * scale,
//                                           fontWeight: FontWeight.w400,
//                                           color: itemTextColor,
//                                           decoration: isReady
//                                               ? TextDecoration.lineThrough
//                                               : null,
//                                           decorationColor: readyColor,
//                                           decorationThickness: 2,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),

//                             // ── Modifier chips ("--" + bordered box wrap) ──
//                             if (item.modifiers.isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 6),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     dashLead(itemTextColor),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Wrap(
//                                         spacing: 6,
//                                         runSpacing: 6,
//                                         children: List.generate(
//                                           item.modifiers.length,
//                                           (mi) {
//                                             final mod = item.modifiers[mi];
//                                             final modReady = mod.isReady;
//                                             final chipColor = modReady
//                                                 ? readyColor
//                                                 : itemTextColor;
//                                             return InkWell(
//                                               onTap:
//                                                   (dimmed ||
//                                                       !strikeMods ||
//                                                       separateMode)
//                                                   ? null
//                                                   : () => ref
//                                                         .read(
//                                                           ordersProvider
//                                                               .notifier,
//                                                         )
//                                                         .toggleModifierReady(
//                                                           order.id,
//                                                           i,
//                                                           mi,
//                                                         ),
//                                               borderRadius:
//                                                   BorderRadius.circular(5),
//                                               child: Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 8,
//                                                       vertical: 3,
//                                                     ),
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                     color: chipColor
//                                                         .withOpacity(0.6),
//                                                     width: 1,
//                                                   ),
//                                                   borderRadius:
//                                                       BorderRadius.circular(5),
//                                                 ),
//                                                 child: Text(
//                                                   mod.name,
//                                                   style: TextStyle(
//                                                     color: chipColor,
//                                                     fontSize: 13 * scale,
//                                                     fontWeight: FontWeight.w600,
//                                                     decoration: modReady
//                                                         ? TextDecoration
//                                                               .lineThrough
//                                                         : null,
//                                                     decorationColor: readyColor,
//                                                     decorationThickness: 2,
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                             // ── Note — "NOTE : value" at the bottom (italic) ──
//                             if (item.kitchenNote.isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 8),
//                                 child: Text(
//                                   'NOTE : ${item.kitchenNote}',
//                                   style: TextStyle(
//                                     fontSize: 13 * scale,
//                                     fontWeight: FontWeight.w700,
//                                     fontStyle: FontStyle.italic,
//                                     color: itemTextColor,
//                                   ),
//                                 ),
//                               ),
//                             SizedBox(height: 5),
//                             Divider(),

//                             SizedBox(height: 5),
//                           ],
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//               ),
//             ),

//             // ══ Release button — hold orders only ════════════
//             if (order.isOnHold)
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
//                 child: _ReleaseButton(order: order),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ══ Card header ══════════════════════════════════════════════════════════════
// class _CardHeader extends ConsumerWidget {
//   const _CardHeader({required this.order, required this.onBump});

//   final KdsOrder order;
//   final VoidCallback onBump;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.watch(tickProvider);
//     final scale = ref.watch(fontSizeProvider).scale;

//     final times = ref.watch(transitionTimesProvider)[order.type]!;
//     final statusColors = ref.watch(statusColorsProvider);
//     final mins = order.elapsed.inMinutes;

//     final Color headerColor;
//     if (mins < times.cautionMinutes) {
//       headerColor = statusColors.onTime;
//     } else if (mins < times.lateMinutes) {
//       headerColor = statusColors.caution;
//     } else {
//       headerColor = statusColors.late;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: headerColor,
//         borderRadius: BorderRadius.zero,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   order.customerName,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 17 * scale,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: onBump,
//                 child: Container(
//                   width: 22,
//                   height: 22,
//                   decoration: const BoxDecoration(
//                     color: Colors.black26,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.close, color: Colors.white, size: 14),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 3),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 order.placedAtLabel,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 15 * scale,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               Text(
//                 order.elapsedLabel,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 15 * scale,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ══ Release button ═══════════════════════════════════════════════════════════
// class _ReleaseButton extends ConsumerWidget {
//   const _ReleaseButton({required this.order});

//   final KdsOrder order;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.watch(tickProvider);
//     final t = Theme.of(context);
//     final scale = ref.watch(fontSizeProvider).scale;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 6),
//           child: Text(
//             'Releases in ${order.holdRemainingLabel}',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 15 * scale, // ← ticket top-left time er same size
//               fontWeight: FontWeight.w700,
//               color: t.colorScheme.onSurface,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 50,
//           child: ElevatedButton.icon(
//             onPressed: () =>
//                 ref.read(ordersProvider.notifier).release(order.id),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 8),
//             ),
//             icon: const Icon(Icons.play_arrow_rounded, size: 18),
//             label: const Text(
//               'Release',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yogo_kds/providers/settings_provider.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../data/models/kds_order.dart';
// import '../../../../providers/home_provider.dart';
// import '../../../../shared/enums/order_enums.dart';

// class OrderTicketCard extends ConsumerWidget {
//   const OrderTicketCard({
//     super.key,
//     required this.order,
//     this.dimmed = false,
//     this.fullWidth = false,
//   });

//   final KdsOrder order;
//   final bool dimmed;
//   final bool fullWidth;

//   Color _typeBadgeColor(OrderType tp) {
//     switch (tp) {
//       case OrderType.dineIn:
//         return AppColors.typeForHere;
//       case OrderType.takeOut:
//         return AppColors.typePickup;
//     }
//   }

//   IconData _typeIcon(OrderType tp) {
//     switch (tp) {
//       case OrderType.dineIn:
//         return Icons.restaurant_rounded;
//       case OrderType.takeOut:
//         return Icons.shopping_bag_outlined;
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final isDark = t.brightness == Brightness.dark;
//     final selectedId = ref.watch(selectedOrderIdProvider);
//     final isSelected = selectedId == order.id;
//     final readyColor = t.colorScheme.onSurfaceVariant.withOpacity(0.45);
//     final scale = ref.watch(fontSizeProvider).scale;

//     // ── Orders settings ────────────────────────────────
//     final ordersSettings = ref.watch(ordersSettingsProvider);
//     final hideActions = ordersSettings.hideActionsAndType;
//     final strikeMods = ordersSettings.strikeIndividualModifiers;
//     final itemDisplay = ordersSettings.itemDisplay;

//     // Separate mode: split qty into individual lines; Combine: as-is
//     final displayItems = itemDisplay == ItemDisplayMode.separate
//         ? order.items.expand((item) {
//             return List.generate(
//               item.qty,
//               (_) => KdsOrderItem(
//                 name: item.name,
//                 qty: 1,
//                 category: item.category,
//                 modifiers: item.modifiers,
//                 variations: item.variations,
//                 kitchenNote: item.kitchenNote,
//                 isReady: item.isReady,
//               ),
//             );
//           }).toList()
//         : order.items;

//     final separateMode = itemDisplay == ItemDisplayMode.separate;

//     return Opacity(
//       opacity: dimmed ? 0.55 : 1.0,
//       child: Container(
//         width: fullWidth ? null : 290,
//         constraints: fullWidth ? null : const BoxConstraints(maxHeight: 560),
//         margin: fullWidth ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
//         decoration: BoxDecoration(
//           color: Color(0xff181b20),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: isSelected ? t.colorScheme.primary : t.dividerColor,
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             // release pins to bottom only when the card has a real bounded
//             // height (grid). Everywhere else it sizes to content (no crash).
//             final pinBottom = fullWidth && constraints.maxHeight.isFinite;

//             final itemsScroll = SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   for (int i = 0; i < displayItems.length; i++) ...[
//                     _ItemBlock(
//                       order: order,
//                       item: displayItems[i],
//                       index: i,
//                       scale: scale,
//                       dimmed: dimmed,
//                       separateMode: separateMode,
//                       strikeMods: strikeMods,
//                       readyColor: readyColor,
//                     ),
//                     if (i != displayItems.length - 1)
//                       Divider(height: 1, thickness: 1, color: t.dividerColor),
//                   ],
//                 ],
//               ),
//             );

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               mainAxisSize: pinBottom ? MainAxisSize.max : MainAxisSize.min,
//               children: [
//                 // ══ Header — tap to bump ═════════════════════════
//                 GestureDetector(
//                   onTap: dimmed
//                       ? null
//                       : () {
//                           ref.read(ordersProvider.notifier).bump(order.id);
//                           ref.read(lastBumpedOrderProvider.notifier).state =
//                               order;
//                         },
//                   child: _CardHeader(
//                     order: order,
//                     onBump: () {
//                       ref.read(ordersProvider.notifier).bump(order.id);
//                       ref.read(lastBumpedOrderProvider.notifier).state = order;
//                     },
//                   ),
//                 ),

//                 // ══ Type button + "···" row ══════════════════════
//                 if (!hideActions)
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
//                     child: Row(
//                       children: [
//                         // ── Type button (TAKEOUT / DINE IN) ──
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 11,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _typeBadgeColor(order.type),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 _typeIcon(order.type),
//                                 color: Colors.white,
//                                 size: 18,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 order.type.label,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w800,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Spacer(),

//                         // ── "···" action button ──
//                         InkWell(
//                           onTap: () {
//                             ref.read(selectedOrderIdProvider.notifier).state =
//                                 order.id;
//                             ref.read(showActionPanelProvider.notifier).state =
//                                 true;
//                           },
//                           borderRadius: BorderRadius.circular(10),
//                           child: Container(
//                             width: 58,
//                             height: 44,
//                             decoration: BoxDecoration(
//                               color: t.colorScheme.surfaceContainerHighest
//                                   .withOpacity(0.4),
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(
//                                 color: t.dividerColor,
//                                 width: 1,
//                               ),
//                             ),
//                             alignment: Alignment.center,
//                             clipBehavior: Clip.hardEdge,
//                             child: OverflowBox(
//                               minHeight: 0,
//                               maxHeight: double.infinity,
//                               child: Icon(
//                                 Icons.more_horiz,
//                                 size: 34,
//                                 color: t.colorScheme.onSurfaceVariant,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 Divider(height: 1, thickness: 1, color: t.dividerColor),

//                 // ══ Items — Expanded (grid) pushes release to bottom;
//                 //    Flexible elsewhere sizes to content (no crash) ══
//                 pinBottom
//                     ? Expanded(child: itemsScroll)
//                     : Flexible(child: itemsScroll),

//                 // ══ Release button — hold orders only ════════════
//                 if (order.isOnHold)
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
//                     child: _ReleaseButton(order: order),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ══ One item block (qty + name + check, modifiers, note) ══════════════════════
// // ══ One item block (qty + name + check, variations, modifiers, note) ══════════
// // ══ One item block (qty + name + check, variations, modifiers, note) ══════════
// class _ItemBlock extends ConsumerWidget {
//   const _ItemBlock({
//     required this.order,
//     required this.item,
//     required this.index,
//     required this.scale,
//     required this.dimmed,
//     required this.separateMode,
//     required this.strikeMods,
//     required this.readyColor,
//   });

//   final KdsOrder order;
//   final KdsOrderItem item;
//   final int index;
//   final double scale;
//   final bool dimmed;
//   final bool separateMode;
//   final bool strikeMods;
//   final Color readyColor;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final isReady = item.isReady;
//     final itemTextColor = isReady ? readyColor : t.colorScheme.onSurface;
//     final double indent = 44 * scale + 14; // under the item name

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Qty + name + check — tap ANYWHERE here to toggle item ready ──
//           InkWell(
//             onTap: (dimmed || separateMode)
//                 ? null
//                 : () => ref
//                       .read(ordersProvider.notifier)
//                       .toggleItemReady(order.id, index),
//             borderRadius: BorderRadius.circular(8),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // qty box
//                 Container(
//                   width: 44 * scale,
//                   height: 44 * scale,
//                   decoration: BoxDecoration(
//                     color: isReady ? readyColor : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   alignment: Alignment.center,
//                   child: Text(
//                     '${item.qty}',
//                     style: TextStyle(
//                       color: isReady ? Colors.white : Colors.black,
//                       fontSize: 20 * scale,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 14),

//                 // name (strikes through when ready)
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 2),
//                     child: Text(
//                       item.name.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 20 * scale,
//                         fontWeight: FontWeight.w800,
//                         color: itemTextColor,
//                         letterSpacing: 0.3,
//                         decoration: isReady ? TextDecoration.lineThrough : null,
//                         decorationColor: readyColor,
//                         decorationThickness: 2,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),

//                 // check box (visual only — reflects ready state)
//                 Container(
//                   width: 42 * scale,
//                   height: 42 * scale,
//                   decoration: BoxDecoration(
//                     color: isReady ? t.colorScheme.primary : Colors.transparent,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: isReady
//                           ? t.colorScheme.primary
//                           : t.colorScheme.onSurfaceVariant.withOpacity(0.45),
//                       width: 2,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.check_rounded,
//                     size: 24 * scale,
//                     color: isReady
//                         ? Colors.white
//                         : t.colorScheme.onSurfaceVariant.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Variation lines (Container dash — item name er borabor) ──
//           ...item.variations.map((v) {
//             return Padding(
//               padding: EdgeInsets.only(left: indent, top: 8),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 16 * scale,
//                     height: 3,
//                     margin: EdgeInsets.only(top: 8 * scale, right: 8),
//                     decoration: BoxDecoration(
//                       color: itemTextColor,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       v.name.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 15 * scale,
//                         fontWeight: FontWeight.w500,
//                         color: itemTextColor,
//                         decoration: isReady ? TextDecoration.lineThrough : null,
//                         decorationColor: readyColor,
//                         decorationThickness: 2,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),

//           // ── Modifier chips (each tap toggles that modifier) ──
//           if (item.modifiers.isNotEmpty)
//             Padding(
//               padding: EdgeInsets.only(left: indent, top: 10),
//               child: Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: List.generate(item.modifiers.length, (mi) {
//                   final mod = item.modifiers[mi];
//                   final modReady = mod.isReady;
//                   final chipColor = modReady ? readyColor : itemTextColor;
//                   return InkWell(
//                     onTap: (dimmed || !strikeMods || separateMode)
//                         ? null
//                         : () => ref
//                               .read(ordersProvider.notifier)
//                               .toggleModifierReady(order.id, index, mi),
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: t.colorScheme.surfaceContainerHighest
//                             .withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: t.dividerColor.withOpacity(0.6),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         mod.name,
//                         style: TextStyle(
//                           color: chipColor,
//                           fontSize: 15 * scale,
//                           fontWeight: FontWeight.w500,
//                           decoration: modReady
//                               ? TextDecoration.lineThrough
//                               : null,
//                           decorationColor: readyColor,
//                           decorationThickness: 2,
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),

//           // ── NOTE box (amber) ──
//           if (item.kitchenNote.isNotEmpty)
//             Padding(
//               padding: EdgeInsets.only(left: indent, top: 10),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 9,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF4A3A12),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text.rich(
//                   TextSpan(
//                     children: [
//                       TextSpan(
//                         text: 'NOTE  ',
//                         style: TextStyle(
//                           color: const Color(0xFFD9A441),
//                           fontSize: 12 * scale,
//                           fontWeight: FontWeight.w800,
//                           letterSpacing: 1.0,
//                         ),
//                       ),
//                       TextSpan(
//                         text: item.kitchenNote,
//                         style: TextStyle(
//                           color: const Color(0xFFE9C877),
//                           fontSize: 15 * scale,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ══ Card header ══════════════════════════════════════════════════════════════
// class _CardHeader extends ConsumerWidget {
//   const _CardHeader({required this.order, required this.onBump});

//   final KdsOrder order;
//   final VoidCallback onBump;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.watch(tickProvider);
//     final scale = ref.watch(fontSizeProvider).scale;

//     final times = ref.watch(transitionTimesProvider)[order.type]!;
//     final statusColors = ref.watch(statusColorsProvider);
//     final mins = order.elapsed.inMinutes;

//     final Color headerColor;
//     if (mins < times.cautionMinutes) {
//       headerColor = statusColors.onTime;
//     } else if (mins < times.lateMinutes) {
//       headerColor = statusColors.caution;
//     } else {
//       headerColor = statusColors.late;
//     }

//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
//       color: Color(0xff3d7848),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // name + close
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   order.customerName,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22 * scale,
//                     fontWeight: FontWeight.w800,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: onBump,
//                 child: Container(
//                   width: 34,
//                   height: 34,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.22),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.close_rounded,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // time + elapsed pill
//           Row(
//             children: [
//               Icon(
//                 Icons.access_time_rounded,
//                 color: Colors.white,
//                 size: 18 * scale,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 order.placedAtLabel,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 15 * scale,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   order.elapsedLabel,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18 * scale,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ══ Release button ═══════════════════════════════════════════════════════════
// class _ReleaseButton extends ConsumerWidget {
//   const _ReleaseButton({required this.order});

//   final KdsOrder order;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.watch(tickProvider);
//     final t = Theme.of(context);
//     final scale = ref.watch(fontSizeProvider).scale;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 6),
//           child: Text(
//             'Releases in ${order.holdRemainingLabel}',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 15 * scale,
//               fontWeight: FontWeight.w700,
//               color: t.colorScheme.onSurface,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 50,
//           child: ElevatedButton.icon(
//             onPressed: () =>
//                 ref.read(ordersProvider.notifier).release(order.id),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 8),
//             ),
//             icon: const Icon(Icons.play_arrow_rounded, size: 18),
//             label: const Text(
//               'Release',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yogo_kds/providers/settings_provider.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../data/models/kds_order.dart';
// import '../../../../providers/home_provider.dart';
// import '../../../../shared/enums/order_enums.dart';

// class OrderTicketCard extends ConsumerWidget {
//   const OrderTicketCard({
//     super.key,
//     required this.order,
//     this.dimmed = false,
//     this.fullWidth = false,
//   });

//   final KdsOrder order;
//   final bool dimmed;
//   final bool fullWidth;

//   Color _typeBadgeColor(OrderType tp) {
//     switch (tp) {
//       case OrderType.dineIn:
//         return AppColors.typeForHere;
//       case OrderType.takeOut:
//         return AppColors.typePickup;
//     }
//   }

//   IconData _typeIcon(OrderType tp) {
//     switch (tp) {
//       case OrderType.dineIn:
//         return Icons.restaurant_rounded;
//       case OrderType.takeOut:
//         return Icons.shopping_bag_outlined;
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final isDark = t.brightness == Brightness.dark;
//     final selectedId = ref.watch(selectedOrderIdProvider);
//     final isSelected = selectedId == order.id;

//     // Card body hardcoded dark — tai text/line color-o fixed (light) rakha,
//     // jate light + dark dono mode-e card-ta same dekhay ar visible thake.
//     final readyColor = Colors.white.withOpacity(0.38);
//     const cardLine = Color(0x1FFFFFFF); // white 12% — divider/border

//     final scale = ref.watch(fontSizeProvider).scale;

//     // ── Orders settings ────────────────────────────────
//     final ordersSettings = ref.watch(ordersSettingsProvider);
//     final hideActions = ordersSettings.hideActionsAndType;
//     final strikeMods = ordersSettings.strikeIndividualModifiers;
//     final itemDisplay = ordersSettings.itemDisplay;

//     // Separate mode: split qty into individual lines; Combine: as-is
//     final displayItems = itemDisplay == ItemDisplayMode.separate
//         ? order.items.expand((item) {
//             return List.generate(
//               item.qty,
//               (_) => KdsOrderItem(
//                 name: item.name,
//                 qty: 1,
//                 category: item.category,
//                 modifiers: item.modifiers,
//                 variations: item.variations,
//                 kitchenNote: item.kitchenNote,
//                 isReady: item.isReady,
//               ),
//             );
//           }).toList()
//         : order.items;

//     final separateMode = itemDisplay == ItemDisplayMode.separate;

//     return Opacity(
//       opacity: dimmed ? 0.55 : 1.0,
//       child: Container(
//         width: fullWidth ? null : 290,
//         constraints: fullWidth ? null : const BoxConstraints(maxHeight: 560),
//         margin: fullWidth ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
//         decoration: BoxDecoration(
//           color: Color(0xff181b20),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: isSelected ? t.colorScheme.primary : cardLine,
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             // release pins to bottom only when the card has a real bounded
//             // height (grid). Everywhere else it sizes to content (no crash).
//             final pinBottom = fullWidth && constraints.maxHeight.isFinite;

//             final itemsScroll = SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   for (int i = 0; i < displayItems.length; i++) ...[
//                     _ItemBlock(
//                       order: order,
//                       item: displayItems[i],
//                       index: i,
//                       scale: scale,
//                       dimmed: dimmed,
//                       separateMode: separateMode,
//                       strikeMods: strikeMods,
//                       readyColor: readyColor,
//                     ),
//                     if (i != displayItems.length - 1)
//                       Divider(height: 1, thickness: 1, color: cardLine),
//                   ],
//                 ],
//               ),
//             );

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               mainAxisSize: pinBottom ? MainAxisSize.max : MainAxisSize.min,
//               children: [
//                 // ══ Header — tap to bump ═════════════════════════
//                 GestureDetector(
//                   onTap: dimmed
//                       ? null
//                       : () {
//                           ref.read(ordersProvider.notifier).bump(order.id);
//                           ref.read(lastBumpedOrderProvider.notifier).state =
//                               order;
//                         },
//                   child: _CardHeader(
//                     order: order,
//                     onBump: () {
//                       ref.read(ordersProvider.notifier).bump(order.id);
//                       ref.read(lastBumpedOrderProvider.notifier).state = order;
//                     },
//                   ),
//                 ),

//                 // ══ Type button + "···" row ══════════════════════
//                 // if (!hideActions)
//                 //   Padding(
//                 //     padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
//                 //     child: Row(
//                 //       children: [
//                 //         // ── Type button (TAKEOUT / DINE IN) ──
//                 //         Container(
//                 //           padding: const EdgeInsets.symmetric(
//                 //             horizontal: 16,
//                 //             vertical: 11,
//                 //           ),
//                 //           decoration: BoxDecoration(
//                 //             color: _typeBadgeColor(order.type),
//                 //             borderRadius: BorderRadius.circular(10),
//                 //           ),
//                 //           child: Row(
//                 //             mainAxisSize: MainAxisSize.min,
//                 //             children: [
//                 //               Icon(
//                 //                 _typeIcon(order.type),
//                 //                 color: Colors.white,
//                 //                 size: 18,
//                 //               ),
//                 //               const SizedBox(width: 8),
//                 //               Text(
//                 //                 order.type.label,
//                 //                 style: const TextStyle(
//                 //                   color: Colors.white,
//                 //                   fontSize: 15,
//                 //                   fontWeight: FontWeight.w800,
//                 //                   letterSpacing: 0.5,
//                 //                 ),
//                 //               ),
//                 //             ],
//                 //           ),
//                 //         ),
//                 //         const Spacer(),

//                 //         // ── "···" action button ──
//                 //         InkWell(
//                 //           onTap: () {
//                 //             ref.read(selectedOrderIdProvider.notifier).state =
//                 //                 order.id;
//                 //             ref.read(showActionPanelProvider.notifier).state =
//                 //                 true;
//                 //           },
//                 //           borderRadius: BorderRadius.circular(10),
//                 //           child: Container(
//                 //             width: 58,
//                 //             height: 44,
//                 //             decoration: BoxDecoration(
//                 //               color: Colors.white.withOpacity(0.06),
//                 //               borderRadius: BorderRadius.circular(10),
//                 //               border: Border.all(
//                 //                 color: cardLine,
//                 //                 width: 1,
//                 //               ),
//                 //             ),
//                 //             alignment: Alignment.center,
//                 //             clipBehavior: Clip.hardEdge,
//                 //             child: OverflowBox(
//                 //               minHeight: 0,
//                 //               maxHeight: double.infinity,
//                 //               child: Icon(
//                 //                 Icons.more_horiz,
//                 //                 size: 34,
//                 //                 color: Colors.white.withOpacity(0.7),
//                 //               ),
//                 //             ),
//                 //           ),
//                 //         ),
//                 //       ],
//                 //     ),
//                 //   ),

//                 // ══ Type button + "···" row  (height ~30% kom) ════
//                 if (!hideActions)
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(14, 7, 14, 6),
//                     child: Row(
//                       children: [
//                                       // ── "···" action button ──
//                         InkWell(
//                           onTap: () {
//                             ref.read(selectedOrderIdProvider.notifier).state =
//                                 order.id;
//                             ref.read(showActionPanelProvider.notifier).state =
//                                 true;
//                           },
//                           borderRadius: BorderRadius.circular(10),
//                           child: Container(
//                             width: 58,
//                             height: 32, // was 44
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.06),
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: cardLine, width: 1),
//                             ),
//                             alignment: Alignment.center,
//                             clipBehavior: Clip.hardEdge,
//                             child: OverflowBox(
//                               minHeight: 0,
//                               maxHeight: double.infinity,
//                               child: Icon(
//                                 Icons.more_horiz,
//                                 size: 30, // was 34
//                                 color: Colors.white.withOpacity(0.7),
//                               ),
//                             ),
//                           ),
//                         ),
//                          const Spacer(),

//                         // ── Type button (TAKEOUT / DINE IN) ──
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 7, // was 11
//                           ),
//                           decoration: BoxDecoration(
//                             color: _typeBadgeColor(order.type),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 _typeIcon(order.type),
//                                 color: Colors.white,
//                                 size: 18,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 order.type.label,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w800,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                           // const Spacer(),

//                         // ── "···" action button ──
//                         // InkWell(
//                         //   onTap: () {
//                         //     ref.read(selectedOrderIdProvider.notifier).state =
//                         //         order.id;
//                         //     ref.read(showActionPanelProvider.notifier).state =
//                         //         true;
//                         //   },
//                         //   borderRadius: BorderRadius.circular(10),
//                         //   child: Container(
//                         //     width: 58,
//                         //     height: 32, // was 44
//                         //     decoration: BoxDecoration(
//                         //       color: Colors.white.withOpacity(0.06),
//                         //       borderRadius: BorderRadius.circular(10),
//                         //       border: Border.all(color: cardLine, width: 1),
//                         //     ),
//                         //     alignment: Alignment.center,
//                         //     clipBehavior: Clip.hardEdge,
//                         //     child: OverflowBox(
//                         //       minHeight: 0,
//                         //       maxHeight: double.infinity,
//                         //       child: Icon(
//                         //         Icons.more_horiz,
//                         //         size: 30, // was 34
//                         //         color: Colors.white.withOpacity(0.7),
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),

//                 Divider(height: 1, thickness: 1, color: cardLine),

//                 // ══ Items — Expanded (grid) pushes release to bottom;
//                 //    Flexible elsewhere sizes to content (no crash) ══
//                 pinBottom
//                     ? Expanded(child: itemsScroll)
//                     : Flexible(child: itemsScroll),

//                 // ══ Release button — hold orders only ════════════
//                 if (order.isOnHold)
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
//                     child: _ReleaseButton(order: order),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ══ One item block (qty + name + check, variations, modifiers, note) ══════════
// class _ItemBlock extends ConsumerWidget {
//   const _ItemBlock({
//     required this.order,
//     required this.item,
//     required this.index,
//     required this.scale,
//     required this.dimmed,
//     required this.separateMode,
//     required this.strikeMods,
//     required this.readyColor,
//   });

//   final KdsOrder order;
//   final KdsOrderItem item;
//   final int index;
//   final double scale;
//   final bool dimmed;
//   final bool separateMode;
//   final bool strikeMods;
//   final Color readyColor;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final isReady = item.isReady;
//     // fixed light text so it stays visible on the dark card in both themes
//     final itemTextColor = isReady ? readyColor : Colors.white;
//     final double indent = 44 * scale + 14; // under the item name

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Qty + name + check — tap ANYWHERE here to toggle item ready ──
//           InkWell(
//             onTap: (dimmed || separateMode)
//                 ? null
//                 : () => ref
//                       .read(ordersProvider.notifier)
//                       .toggleItemReady(order.id, index),
//             borderRadius: BorderRadius.circular(8),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // qty box
//                 Container(
//                   width: 30 * scale,
//                   height: 30 * scale,
//                   decoration: BoxDecoration(
//                     color: isReady ? readyColor : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   alignment: Alignment.center,
//                   child: Text(
//                     '${item.qty}',
//                     style: TextStyle(
//                       color: isReady ? Colors.white : Colors.black,
//                       fontSize: 16 * scale,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 14),

//                 // name (strikes through when ready)
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 2),
//                     child: Text(
//                       item.name.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 18 * scale,
//                         fontWeight: FontWeight.w800,
//                         color: itemTextColor,
//                         letterSpacing: 0.3,
//                         decoration: isReady ? TextDecoration.lineThrough : null,
//                         decorationColor: readyColor,
//                         decorationThickness: 2,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),

//                 // check box (visual only — reflects ready state)
//                 Container(
//                   width: 30 * scale,
//                   height: 30 * scale,
//                   decoration: BoxDecoration(
//                     color: isReady ? Color.fromARGB(255, 22, 187, 0) : Colors.transparent,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: isReady
//                           ? Color.fromARGB(255, 22, 187, 0)
//                           : Colors.white.withOpacity(0.45),
//                       width: 2,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.check_rounded,
//                     size: 18 * scale,
//                     color: isReady
//                         ? Colors.white
//                         : Colors.white.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Variation lines (Container dash — item name er borabor) ──
//           ...item.variations.map((v) {
//             return Padding(
//               padding: EdgeInsets.only(left: indent, top: 8),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 16 * scale,
//                     height: 3,
//                     margin: EdgeInsets.only(top: 8 * scale, right: 8),
//                     decoration: BoxDecoration(
//                       color: itemTextColor,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       v.name.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 15 * scale,
//                         fontWeight: FontWeight.w500,
//                         color: itemTextColor,
//                         decoration: isReady ? TextDecoration.lineThrough : null,
//                         decorationColor: readyColor,
//                         decorationThickness: 2,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),

//           // ── Modifier chips (each tap toggles that modifier) ──
//           if (item.modifiers.isNotEmpty)
//             Padding(
//               padding: EdgeInsets.only(left: indent, top: 10),
//               child: Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: List.generate(item.modifiers.length, (mi) {
//                   final mod = item.modifiers[mi];
//                   final modReady = mod.isReady;
//                   final chipColor = modReady ? readyColor : itemTextColor;
//                   return InkWell(
//                     //comment modifiers ontap

//                     // onTap: (dimmed || !strikeMods || separateMode)
//                     //     ? null
//                     //     : () => ref
//                     //           .read(ordersProvider.notifier)
//                     //           .toggleModifierReady(order.id, index, mi),

//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.18),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         mod.name,
//                         style: TextStyle(
//                           color: chipColor,
//                           fontSize: 15 * scale,
//                           fontWeight: FontWeight.w500,
//                           decoration: modReady
//                               ? TextDecoration.lineThrough
//                               : null,
//                           decorationColor: readyColor,
//                           decorationThickness: 2,
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),

//           // ── NOTE box (amber) ──
//           if (item.kitchenNote.isNotEmpty)
//             Padding(
//               padding: EdgeInsets.only(left: indent, top: 10),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 5,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF4A3A12),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text.rich(
//                   TextSpan(
//                     children: [
//                       TextSpan(
//                         text: 'NOTE  ',
//                         style: TextStyle(
//                           color: const Color(0xFFD9A441),
//                           fontSize: 10 * scale,
//                           fontWeight: FontWeight.w800,
//                           letterSpacing: 1.0,
//                         ),
//                       ),
//                       TextSpan(
//                         text: item.kitchenNote,
//                         style: TextStyle(
//                           color: const Color(0xFFE9C877),
//                           fontSize: 13 * scale,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ══ Card header ══════════════════════════════════════════════════════════════
// class _CardHeader extends ConsumerWidget {
//   const _CardHeader({required this.order, required this.onBump});

//   final KdsOrder order;
//   final VoidCallback onBump;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.watch(tickProvider);
//     final scale = ref.watch(fontSizeProvider).scale;

//     final times = ref.watch(transitionTimesProvider)[order.type]!;
//     final statusColors = ref.watch(statusColorsProvider);
//     final mins = order.elapsed.inMinutes;

//     final Color headerColor;
//     if (mins < times.cautionMinutes) {
//       headerColor = statusColors.onTime;
//     } else if (mins < times.lateMinutes) {
//       headerColor = statusColors.caution;
//     } else {
//       headerColor = statusColors.late;
//     }

//     // return Container(
//     //   padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
//     //   color: Color(0xff3d7848),
//     //   child: Column(
//     //     crossAxisAlignment: CrossAxisAlignment.start,
//     //     children: [
//     //       // name + close
//     //       Row(
//     //         children: [
//     //           Expanded(
//     //             child: Text(
//     //               order.customerName,
//     //               style: TextStyle(
//     //                 color: Colors.white,
//     //                 fontSize: 22 * scale,
//     //                 fontWeight: FontWeight.w800,
//     //               ),
//     //               overflow: TextOverflow.ellipsis,
//     //             ),
//     //           ),
//     //           GestureDetector(
//     //             onTap: onBump,
//     //             child: Container(
//     //               width: 34,
//     //               height: 34,
//     //               decoration: BoxDecoration(
//     //                 color: Colors.black.withOpacity(0.22),
//     //                 shape: BoxShape.circle,
//     //               ),
//     //               child: const Icon(
//     //                 Icons.close_rounded,
//     //                 color: Colors.white,
//     //                 size: 20,
//     //               ),
//     //             ),
//     //           ),
//     //         ],
//     //       ),
//     //       const SizedBox(height: 12),

//     //       // time + elapsed pill
//     //       Row(
//     //         children: [
//     //           Icon(
//     //             Icons.access_time_rounded,
//     //             color: Colors.white,
//     //             size: 18 * scale,
//     //           ),
//     //           const SizedBox(width: 6),
//     //           Text(
//     //             order.placedAtLabel,
//     //             style: TextStyle(
//     //               color: Colors.white,
//     //               fontSize: 15 * scale,
//     //               fontWeight: FontWeight.w600,
//     //             ),
//     //           ),
//     //           const Spacer(),
//     //           Container(
//     //             padding: const EdgeInsets.symmetric(
//     //               horizontal: 14,
//     //               vertical: 6,
//     //             ),
//     //             decoration: BoxDecoration(
//     //               color: Colors.black.withOpacity(0.18),
//     //               borderRadius: BorderRadius.circular(20),
//     //             ),
//     //             child: Text(
//     //               order.elapsedLabel,
//     //               style: TextStyle(
//     //                 color: Colors.white,
//     //                 fontSize: 18 * scale,
//     //                 fontWeight: FontWeight.w800,
//     //               ),
//     //             ),
//     //           ),
//     //         ],
//     //       ),
//     //     ],
//     //   ),
//     // );

//     return Container(
//       padding: const EdgeInsets.fromLTRB(14, 8, 10, 8), // was 16,14,12,14
//       color: headerColor,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // name + close
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   order.tokenId.isNotEmpty ? order.tokenId.toUpperCase().toString() : "NA",
//                   // order.tokenId.toUpperCase().toString(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18 * scale, // was 22
//                     fontWeight: FontWeight.w800,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: onBump,
//                 child: Container(
//                   width: 28, // was 34
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.22),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.close_rounded,
//                     color: Colors.white,
//                     size: 18, // was 20
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6), // was 12
//           // time + elapsed pill
//           Row(
//             children: [
//               Icon(
//                 Icons.access_time_rounded,
//                 color: Colors.white,
//                 size: 15 * scale, // was 18
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 order.placedAtLabel,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 13 * scale, // was 15
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12, // was 14
//                   vertical: 4, // was 6
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   order.elapsedLabel,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15 * scale, // was 18
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ══ Release button ═══════════════════════════════════════════════════════════
// class _ReleaseButton extends ConsumerWidget {
//   const _ReleaseButton({required this.order});

//   final KdsOrder order;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.watch(tickProvider);
//     final scale = ref.watch(fontSizeProvider).scale;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 6),
//           child: Text(
//             'Releases in ${order.holdRemainingLabel}',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 15 * scale,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 50,
//           child: ElevatedButton.icon(
//             onPressed: () =>
//                 ref.read(ordersProvider.notifier).release(order.id),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 8),
//             ),
//             icon: const Icon(Icons.play_arrow_rounded, size: 18),
//             label: const Text(
//               'Release',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yogo_kds/providers/settings_provider.dart';
import '../../../../data/models/kds_order.dart';
import '../../../../providers/home_provider.dart';
import '../../../../shared/enums/order_enums.dart';

class OrderTicketCard extends ConsumerWidget {
  const OrderTicketCard({
    super.key,
    required this.order,
    this.dimmed = false,
    this.fullWidth = false,
  });

  final KdsOrder order;
  final bool dimmed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final selectedId = ref.watch(selectedOrderIdProvider);
    final isSelected = selectedId == order.id;

    final readyColor = Colors.white.withOpacity(0.38);
    const cardLine = Color(0x1FFFFFFF);

    final scale = ref.watch(fontSizeProvider).scale;

    final ordersSettings = ref.watch(ordersSettingsProvider);
    final strikeMods = ordersSettings.strikeIndividualModifiers;
    final itemDisplay = ordersSettings.itemDisplay;

    final displayItems = itemDisplay == ItemDisplayMode.separate
        ? order.items.expand((item) {
            return List.generate(
              item.qty,
              (_) => KdsOrderItem(
                name: item.name,
                qty: 1,
                category: item.category,
                modifiers: item.modifiers,
                variations: item.variations,
                kitchenNote: item.kitchenNote,
                isReady: item.isReady,
              ),
            );
          }).toList()
        : order.items;

    final separateMode = itemDisplay == ItemDisplayMode.separate;

    return Opacity(
      opacity: dimmed ? 0.55 : 1.0,
      child: Container(
        width: fullWidth ? null : 290,
        constraints: fullWidth ? null : const BoxConstraints(maxHeight: 560),
        margin: fullWidth ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xff181b20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? t.colorScheme.primary : cardLine,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pinBottom = fullWidth && constraints.maxHeight.isFinite;

            final itemsScroll = SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < displayItems.length; i++) ...[
                    _ItemBlock(
                      order: order,
                      item: displayItems[i],
                      index: i,
                      scale: scale,
                      dimmed: dimmed,
                      separateMode: separateMode,
                      strikeMods: strikeMods,
                      readyColor: readyColor,
                    ),
                    if (i != displayItems.length - 1)
                      Divider(height: 1, thickness: 1, color: cardLine),
                  ],
                ],
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: pinBottom ? MainAxisSize.max : MainAxisSize.min,
              children: [
                // ══ Header (type + token + count + time + vertical ⋮) ══
                _CardHeader(order: order, dimmed: dimmed),

                // ══ Cancelled banner (red) — only when cancelled ══
                if (order.isCancelled)
                  Container(
                    width: double.infinity,
                    color: const Color(0xffD32F2F),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: const Text(
                      'Cancelled',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                Divider(height: 1, thickness: 1, color: cardLine),

                // ══ Items ══
                pinBottom
                    ? Expanded(child: itemsScroll)
                    : Flexible(child: itemsScroll),

                // ══ Release button — hold orders only ══
                if (order.isOnHold)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: _ReleaseButton(order: order),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ══ Card header — Clover style ════════════════════════════════════════════════
class _CardHeader extends ConsumerWidget {
  const _CardHeader({required this.order, this.dimmed = false});

  final KdsOrder order;
  final bool dimmed;

  IconData _typeIcon(OrderType tp) {
    switch (tp) {
      case OrderType.dineIn:
        return Icons.restaurant_rounded;
      case OrderType.takeOut:
        return Icons.shopping_bag_outlined;
    }
  }

  // token: 0-index er por ekta space, baki same.  "TKN013" → "T KN013"
  String _formatToken(String raw) {
    final t = raw.trim().toUpperCase();
    if (t.length <= 1) return t;
    return '${t[0]} ${t.substring(1)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickProvider); // live elapsed
    final scale = ref.watch(fontSizeProvider).scale;

    final times = ref.watch(transitionTimesProvider)[order.type]!;
    final statusColors = ref.watch(statusColorsProvider);
    final mins = order.elapsed.inMinutes;

    final Color headerColor;
    if (mins < times.cautionMinutes) {
      headerColor = statusColors.onTime;
    } else if (mins < times.lateMinutes) {
      headerColor = statusColors.caution;
    } else {
      headerColor = statusColors.late;
    }

    // type + token
    final token = _formatToken(order.tokenId);
    final titleText = token.isNotEmpty
        ? '${order.type.label}  $token'
        : order.type.label;

    // total item count (quantity sum)
    final totalQty = order.items.fold<int>(0, (s, i) => s + i.qty);

    // elapsed — MM:SS (how long the order has been here)
    final d = order.elapsed;
    final elapsedShort =
        '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      color: headerColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LEFT — info (tap to bump) ──
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: dimmed
                  ? null
                  : () {
                      ref.read(ordersProvider.notifier).bump(order.id);
                      ref.read(lastBumpedOrderProvider.notifier).state = order;
                    },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // line 1: type + token + item count
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          titleText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // item count pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalQty',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // line 2: elapsed time
                  Row(
                    children: [
                      Text(
                        elapsedShort,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── RIGHT — vertical ⋮ in a white box ──
          InkWell(
            onTap: () {
              ref.read(selectedOrderIdProvider.notifier).state = order.id;
              ref.read(showActionPanelProvider.notifier).state = true;
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.more_vert,
                color: Color(0xFF1A1A1A),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══ One item block (UNCHANGED) ════════════════════════════════════════════════
class _ItemBlock extends ConsumerWidget {
  const _ItemBlock({
    required this.order,
    required this.item,
    required this.index,
    required this.scale,
    required this.dimmed,
    required this.separateMode,
    required this.strikeMods,
    required this.readyColor,
  });

  final KdsOrder order;
  final KdsOrderItem item;
  final int index;
  final double scale;
  final bool dimmed;
  final bool separateMode;
  final bool strikeMods;
  final Color readyColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReady = item.isReady;
    final itemTextColor = isReady ? readyColor : Colors.white;
    final double indent = 44 * scale + 14;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Qty + name + check ──
          InkWell(
            onTap: (dimmed || separateMode)
                ? null
                : () => ref
                      .read(ordersProvider.notifier)
                      .toggleItemReady(order.id, index),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30 * scale,
                  height: 30 * scale,
                  decoration: BoxDecoration(
                    color: isReady
                        ? const Color.fromARGB(255, 22, 187, 0)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isReady
                          ? const Color.fromARGB(255, 22, 187, 0)
                          : Colors.white.withOpacity(0.45),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 18 * scale,
                    color: isReady
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                  ),
                ),

                const SizedBox(width: 12),
                Container(
                  width: 30 * scale,
                  height: 30 * scale,
                  decoration: BoxDecoration(
                    color: isReady ? readyColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${item.qty}',
                    style: TextStyle(
                      color: isReady ? Colors.white : Colors.black,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w800,
                        color: itemTextColor,
                        letterSpacing: 0.3,
                        decoration: isReady ? TextDecoration.lineThrough : null,
                        decorationColor: readyColor,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Variation lines ──
          ...item.variations.map((v) {
            return Padding(
              padding: EdgeInsets.only(left: indent, top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 16 * scale,
                    height: 3,
                    margin: EdgeInsets.only(top: 8 * scale, right: 8),
                    decoration: BoxDecoration(
                      color: itemTextColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      v.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w500,
                        color: itemTextColor,
                        decoration: isReady ? TextDecoration.lineThrough : null,
                        decorationColor: readyColor,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Modifier chips (onTap commented — individual modifier off) ──
          if (item.modifiers.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: indent, top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(item.modifiers.length, (mi) {
                  final mod = item.modifiers[mi];
                  final modReady = mod.isReady;
                  final chipColor = modReady ? readyColor : itemTextColor;
                  return InkWell(
                    // onTap: (dimmed || !strikeMods || separateMode)
                    //     ? null
                    //     : () => ref
                    //           .read(ordersProvider.notifier)
                    //           .toggleModifierReady(order.id, index, mi),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        mod.name,
                        style: TextStyle(
                          color: chipColor,
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w500,
                          decoration: modReady
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: readyColor,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // ── NOTE box (amber) ──
          if (item.kitchenNote.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: indent, top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3A12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'NOTE  ',
                        style: TextStyle(
                          color: const Color(0xFFD9A441),
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      TextSpan(
                        text: item.kitchenNote,
                        style: TextStyle(
                          color: const Color(0xFFE9C877),
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══ Release button (UNCHANGED) ════════════════════════════════════════════════
class _ReleaseButton extends ConsumerWidget {
  const _ReleaseButton({required this.order});

  final KdsOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickProvider);
    final scale = ref.watch(fontSizeProvider).scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Releases in ${order.holdRemainingLabel}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () =>
                ref.read(ordersProvider.notifier).release(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text(
              'Release',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
