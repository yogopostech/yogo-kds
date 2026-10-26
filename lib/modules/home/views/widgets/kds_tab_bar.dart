// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../shared/enums/order_enums.dart';
// import '../../controllers/home_controller.dart';

// class KdsTabBar extends GetView<HomeController> {
//   const KdsTabBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);
//     return Obx(() {
//       final active = controller.activeTab.value;
//       final openCount = controller.openCount;
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: t.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         padding: const EdgeInsets.all(4),
//         child: Row(
//           children: [
//             _Tab(
//               label: 'Completed',
//               count: controller.completedOrders.length,
//               isActive: active == KdsTab.completed,
//               onTap: () => controller.setTab(KdsTab.completed),
//             ),
//             _Tab(
//               label: 'Open',
//               count: openCount,
//               isActive: active == KdsTab.open,
//               onTap: () => controller.setTab(KdsTab.open),
//               showBadge: true,
//             ),
//             _Tab(
//               label: 'Hold',
//               count: controller.holdOrders.length,
//               isActive: active == KdsTab.hold,
//               onTap: () => controller.setTab(KdsTab.hold),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

// class _Tab extends StatelessWidget {
//   const _Tab({
//     required this.label,
//     required this.count,
//     required this.isActive,
//     required this.onTap,
//     this.showBadge = false,
//   });

//   final String label;
//   final int count;
//   final bool isActive;
//   final VoidCallback onTap;
//   final bool showBadge;

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);
//     final primary = t.colorScheme.primary;

//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: isActive ? t.colorScheme.surface : Colors.transparent,
//             borderRadius: BorderRadius.circular(7),
//             boxShadow: isActive
//                 ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1))]
//                 : null,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
//                   color: isActive ? primary : t.colorScheme.onSurfaceVariant,
//                 ),
//               ),
//               if (count > 0) ...[
//                 const SizedBox(width: 6),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: isActive ? primary : t.colorScheme.onSurfaceVariant.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '$count',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: isActive ? Colors.white : t.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../providers/home_provider.dart';
// import '../../../../shared/enums/order_enums.dart';

// class KdsTabBar extends ConsumerWidget {
//   const KdsTabBar({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final active = ref.watch(kdsTabProvider);
//     final ordersState = ref.watch(ordersProvider);

// final openCount = ordersState.open.length;
// final holdCount = ordersState.hold.length;
// final completedCount = ordersState.completed.length;
//     // final orders     = ref.watch(ordersProvider.notifier);
//     ref.watch(ordersProvider); // orders list বদলালে tab bar rebuild হবে
//     final orders = ref.read(ordersProvider.notifier);

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: t.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       padding: const EdgeInsets.all(4),
//       child: Row(
//         children: [
//           _Tab(
//             label: 'Completed',
//             count: orders.completedOrders.length,
//             isActive: active == KdsTab.completed,
//             onTap: () =>
//                 ref.read(kdsTabProvider.notifier).state = KdsTab.completed,
//           ),
//           _Tab(
//             label: 'Open',
//             count: orders.openOrders.length,
//             isActive: active == KdsTab.open,
//             onTap: () => ref.read(kdsTabProvider.notifier).state = KdsTab.open,
//           ),
//           _Tab(
//             label: 'Hold',
//             count: orders.holdOrders.length,
//             isActive: active == KdsTab.hold,
//             onTap: () => ref.read(kdsTabProvider.notifier).state = KdsTab.hold,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _Tab extends StatelessWidget {
//   const _Tab({
//     required this.label,
//     required this.count,
//     required this.isActive,
//     required this.onTap,
//   });

//   final String label;
//   final int count;
//   final bool isActive;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);
//     final primary = t.colorScheme.primary;
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: isActive ? t.colorScheme.surface : Colors.transparent,
//             borderRadius: BorderRadius.circular(7),
//             boxShadow: isActive
//                 ? [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 4,
//                       offset: const Offset(0, 1),
//                     ),
//                   ]
//                 : null,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: isActive ? FontWeight.w700 : FontWeight.w700,
//                   color: isActive ? primary : t.colorScheme.onSurfaceVariant,
//                 ),
//               ),
//               if (count > 0) ...[
//                 const SizedBox(width: 6),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 7,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isActive
//                         ? primary
//                         : t.colorScheme.onSurfaceVariant.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '$count',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: isActive
//                           ? Colors.white
//                           : t.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/home_provider.dart';
import '../../../../shared/enums/order_enums.dart';

class KdsTabBar extends ConsumerWidget {
  const KdsTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final active = ref.watch(kdsTabProvider);

    // Watch the state so the tab bar rebuilds when any list changes
    final ordersState = ref.watch(ordersProvider);
    final openCount = ordersState.open.length;
    final holdCount = ordersState.hold.length;
    final completedCount = ordersState.completed.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Tab(
            label: 'Completed',
            count: completedCount,
            isActive: active == KdsTab.completed,
            onTap: () =>
                ref.read(kdsTabProvider.notifier).state = KdsTab.completed,
          ),
          _Tab(
            label: 'Open',
            count: openCount,
            isActive: active == KdsTab.open,
            onTap: () => ref.read(kdsTabProvider.notifier).state = KdsTab.open,
          ),
          _Tab(
            label: 'Hold',
            count: holdCount,
            isActive: active == KdsTab.hold,
            onTap: () => ref.read(kdsTabProvider.notifier).state = KdsTab.hold,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final primary = t.colorScheme.primary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? t.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isActive ? primary : t.colorScheme.onSurfaceVariant,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? primary
                        : t.colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}