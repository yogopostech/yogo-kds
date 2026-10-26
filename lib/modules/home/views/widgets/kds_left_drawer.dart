// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/home_controller.dart';

// class KdsLeftDrawer extends GetView<HomeController> {
//   const KdsLeftDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);
//     return Obx(() {
//       final expanded = controller.drawerExpanded.value;
//       return AnimatedContainer(
//         duration: const Duration(milliseconds: 220),
//         curve: Curves.easeOutCubic,
//         width: expanded ? 130 : 60,
//         decoration: BoxDecoration(
//           color: t.colorScheme.surface,
//           border: Border(right: BorderSide(color: t.dividerColor)),
//         ),
//         child: Column(
//           children: [
//             // ── Toggle button ──────────────────────────────
//             InkWell(
//               onTap: controller.toggleDrawer,
//               child: Container(
//                 height: 56,
//                 alignment: Alignment.center,
//                 child: AnimatedRotation(
//                   turns: expanded ? 0.5 : 0,
//                   duration: const Duration(milliseconds: 220),
//                   child: Icon(
//                     Icons.chevron_right_rounded,
//                     color: t.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ),
//             ),
//             Divider(height: 1, color: t.dividerColor),

//             // ── Nav items ──────────────────────────────────
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   _DrawerItem(
//                     icon: Icons.grid_view_rounded,
//                     label: 'OPEN',
//                     badge: controller.openCount,
//                     expanded: expanded,
//                     onTap: () {},
//                   ),
//                   _DrawerItem(
//                     icon: Icons.wifi_rounded,
//                     label: 'ONLINE',
//                     expanded: expanded,
//                     onTap: () {},
//                   ),
//                   _DrawerItem(
//                     icon: Icons.swap_horiz_rounded,
//                     label: 'TAKE OUT',
//                     expanded: expanded,
//                     onTap: () {},
//                   ),
//                   _DrawerItem(
//                     icon: Icons.history_rounded,
//                     label: 'RECALL',
//                     expanded: expanded,
//                     onTap: () {},
//                   ),
//                   _DrawerItem(
//                     icon: Icons.pause_circle_outline_rounded,
//                     label: 'HOLDS',
//                     badge: controller.holdOrders.length,
//                     expanded: expanded,
//                     onTap: () {},
//                   ),
//                   _DrawerItem(
//                     icon: Icons.pause_rounded,
//                     label: 'PAUSE',
//                     expanded: expanded,
//                     onTap: () {},
//                   ),
//                   Divider(height: 1, color: t.dividerColor),
//                   _DrawerItem(
//                     icon: Icons.settings_outlined,
//                     label: 'SETTINGS',
//                     expanded: expanded,
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

// class _DrawerItem extends StatelessWidget {
//   const _DrawerItem({
//     required this.icon,
//     required this.label,
//     required this.expanded,
//     required this.onTap,
//     this.badge = 0,
//   });

//   final IconData icon;
//   final String label;
//   final bool expanded;
//   final VoidCallback onTap;
//   final int badge;

// @override
// Widget build(BuildContext context) {
//   final t = Theme.of(context);
//   return InkWell(
//     onTap: onTap,
//     child: SizedBox(
//       height: 56,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: expanded ? 14 : 10),
//         child: Row(
//           mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
//           children: [
//             SizedBox(
//                 width: 28,
//                 height: 28,
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   Icon(icon, size: 22, color: t.colorScheme.onSurfaceVariant),
//                   if (badge > 0)
//                     Positioned(
//                       top: -5,
//                       right: -6,
//                       child: Container(
//                         width: 14,
//                         height: 14,
//                         decoration: BoxDecoration(
//                           color: t.colorScheme.primary,
//                           shape: BoxShape.circle,
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(
//                           '$badge',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 8,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (expanded) ...[
//               const SizedBox(width: 10),
//               Flexible(
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: t.colorScheme.onSurfaceVariant,
//                     letterSpacing: 0.3,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     ),
//   );
// }
// }

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yogo_kds/providers/auth_provider.dart';
// import '../../../../providers/home_provider.dart';

// class KdsLeftDrawer extends ConsumerWidget {
//   const KdsLeftDrawer({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final expanded = ref.watch(drawerExpandedProvider);
//     // final openCount = ref.watch(ordersProvider.notifier).openOrders.length;
//     // final holdCount = ref.watch(ordersProvider.notifier).holdOrders.length;
//     ref.watch(ordersProvider); // ← list watch —  rebuild
//     final openCount = ref.read(ordersProvider.notifier).openOrders.length;
//     final holdCount = ref.read(ordersProvider.notifier).holdOrders.length;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 220),
//       curve: Curves.easeOutCubic,
//       width: expanded ? 130 : 56,
//       decoration: BoxDecoration(
//         color: t.colorScheme.surface,
//         border: Border(right: BorderSide(color: t.dividerColor)),
//       ),
//       // ← LayoutBuilder দিয়ে actual width check করে label দেখাবে
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final showLabel = constraints.maxWidth > 90;
//           return Column(
//             children: [
//               InkWell(
//                 onTap: () =>
//                     ref.read(drawerExpandedProvider.notifier).state = !expanded,
//                 child: SizedBox(
//                   height: 56,
//                   width: double.infinity,
//                   child: Center(
//                     child: AnimatedRotation(
//                       turns: expanded ? 0.5 : 0,
//                       duration: const Duration(milliseconds: 220),
//                       child: Icon(
//                         Icons.chevron_right_rounded,
//                         color: t.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Divider(height: 1, color: t.dividerColor),
//               Expanded(
//                 child: ListView(
//                   padding: EdgeInsets.zero,
//                   children: [
//                     _DrawerItem(
//                       // icon: Icons.grid_view_rounded,
//                       label: 'OPEN',
//                       showLabel: showLabel,
//                       badge: openCount,
//                       onTap: () {},
//                     ),
//                     Divider(height: 1, color: t.dividerColor),
//                     _DrawerItem(
//                       icon: ref.watch(showSummaryProvider)
//                           ? Icons.visibility_off_outlined
//                           : Icons.list_alt_rounded,
//                       label: ref.watch(showSummaryProvider)
//                           ? 'HIDE\nSUMMARY'
//                           : 'SHOW\nSUMMARY',
//                       showLabel: showLabel,
//                       onTap: () =>
//                           ref.read(showSummaryProvider.notifier).state = !ref
//                               .read(showSummaryProvider),
//                     ),

//                     // _DrawerItem(
//                     //   icon: Icons.list_alt_rounded,
//                     //   label: ref.watch(showSummaryProvider)
//                     //       ? 'HIDE\nSUMMARY'
//                     //       : 'SHOW\nSUMMARY',
//                     //   showLabel: showLabel,
//                     //   onTap: () =>
//                     //       ref.read(showSummaryProvider.notifier).state = !ref
//                     //           .read(showSummaryProvider),
//                     // ),
//                     Divider(height: 1, color: t.dividerColor),
//                     // _DrawerItem(
//                     //   icon: Icons.wifi_rounded,
//                     //   label: 'ONLINE',
//                     //   showLabel: showLabel,
//                     //   onTap: () {},
//                     // ),
//                     // _DrawerItem(
//                     //   icon: Icons.swap_horiz_rounded,
//                     //   label: 'TAKE OUT',
//                     //   showLabel: showLabel,
//                     //   onTap: () {},
//                     // ),
//                     _DrawerItem(
//                       icon: Icons.history_rounded,
//                       label: 'RECALL',
//                       showLabel: showLabel,
//                       onTap: () =>
//                           ref.read(showRecallDialogProvider.notifier).state =
//                               true,
//                     ),
//                     Divider(height: 1, color: t.dividerColor),
//                     // _DrawerItem(
//                     //   icon: Icons.pause_circle_outline_rounded,
//                     //   label: 'HOLDS',
//                     //   showLabel: showLabel,
//                     //   badge: holdCount,
//                     //   onTap: () {},
//                     // ),
//                     // _DrawerItem(
//                     //   icon: Icons.pause_rounded,
//                     //   label: 'PAUSE',
//                     //   showLabel: showLabel,
//                     //   onTap: () {},
//                     // ),
//                     // Divider(height: 1, color: t.dividerColor),
//                     _DrawerItem(
//                       icon: Icons.refresh_rounded,
//                       label: 'REFRESH',
//                       showLabel: showLabel,
//                       onTap: () =>
//                           ref.read(ordersProvider.notifier).loadOrders(),
//                     ),
//                     _DrawerItem(
//                       icon: Icons.settings_outlined,
//                       label: 'SETTINGS',
//                       showLabel: showLabel,
//                       onTap: () => context.go('/settings'),
//                     ),
//                     Divider(height: 1, color: t.dividerColor),
//                     _DrawerItem(
//                       icon: Icons.logout_rounded,
//                       label: 'LOGOUT',
//                       showLabel: showLabel,
//                       onTap: () async {
//                         await ref.read(authProvider.notifier).logout();
//                         if (context.mounted) context.go('/pairing');
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _DrawerItem extends StatelessWidget {
//   const _DrawerItem({
//     this.icon,
//     required this.label,
//     required this.showLabel,
//     required this.onTap,
//     this.badge = 0,
//   });

//   final IconData? icon;
//   final String label;
//   final bool showLabel;
//   final VoidCallback onTap;
//   final int badge;

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);

//     final iconWidget = SizedBox(
//       width: 28,
//       height: 28,
//       child: Stack(
//         children: [
//           Positioned(
//             top: 3,
//             left: 3,
//             child: Icon(icon, size: 22, color: t.colorScheme.onSurfaceVariant),
//           ),
//           if (badge > 0)
//             Positioned(
//               top: 0,
//               right: 0,
//               child: Text(
//                 '$badge',
//                 style: const TextStyle(
//                   // color: Colors.white,
//                   fontSize: 25,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );

//     return InkWell(
//       onTap: onTap,
//       child: SizedBox(
//         height: 80,
//         width: double.infinity,
//         child: showLabel
//             ? Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                 child: Column(
//                   children: [
//                     iconWidget,
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         label,
//                         textAlign: TextAlign.center, // ← center align
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: t.colorScheme.onSurface,
//                           letterSpacing: 0.5,
//                           height: 1.2, // ← line spacing
//                         ),
//                         // overflow: TextOverflow.ellipsis,   ← এইটা থাকলে সরাবি, নাহলে দুই লাইন কাটবে
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             : Center(child: iconWidget),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yogo_kds/providers/auth_provider.dart';
// import '../../../../providers/home_provider.dart';

// class KdsLeftDrawer extends ConsumerWidget {
//   const KdsLeftDrawer({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final expanded = ref.watch(drawerExpandedProvider);

//     // Watch the state so badges update when any list changes
//     final ordersState = ref.watch(ordersProvider);
//     final openCount = ordersState.open.length;
//     final holdCount = ordersState.hold.length;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 220),
//       curve: Curves.easeOutCubic,
//       width: expanded ? 130 : 56,
//       decoration: BoxDecoration(
//         color: t.colorScheme.surface,
//         border: Border(right: BorderSide(color: t.dividerColor)),
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final showLabel = constraints.maxWidth > 90;
//           return Column(
//             children: [
//               InkWell(
//                 onTap: () =>
//                     ref.read(drawerExpandedProvider.notifier).state = !expanded,
//                 child: SizedBox(
//                   height: 56,
//                   width: double.infinity,
//                   child: Center(
//                     child: AnimatedRotation(
//                       turns: expanded ? 0.5 : 0,
//                       duration: const Duration(milliseconds: 220),
//                       child: Icon(
//                         Icons.chevron_right_rounded,
//                         color: t.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Divider(height: 1, color: t.dividerColor),
//               Expanded(
//                 child: ListView(
//                   padding: EdgeInsets.zero,
//                   children: [
//                     _DrawerItem(
//                       label: 'OPEN',
//                       showLabel: showLabel,
//                       badge: openCount,
//                       onTap: () {},
//                     ),
//                     Divider(height: 1, color: t.dividerColor),
//                     _DrawerItem(
//                       icon: ref.watch(showSummaryProvider)
//                           ? Icons.visibility_off_outlined
//                           : Icons.list_alt_rounded,
//                       label: ref.watch(showSummaryProvider)
//                           ? 'HIDE\nSUMMARY'
//                           : 'SHOW\nSUMMARY',
//                       showLabel: showLabel,
//                       onTap: () =>
//                           ref.read(showSummaryProvider.notifier).state = !ref
//                               .read(showSummaryProvider),
//                     ),
//                     Divider(height: 1, color: t.dividerColor),
//                     _DrawerItem(
//                       icon: Icons.history_rounded,
//                       label: 'RECALL',
//                       showLabel: showLabel,
//                       onTap: () =>
//                           ref.read(showRecallDialogProvider.notifier).state =
//                               true,
//                     ),
//                     Divider(height: 1, color: t.dividerColor),
//                     _DrawerItem(
//                       icon: Icons.refresh_rounded,
//                       label: 'REFRESH',
//                       showLabel: showLabel,
//                       onTap: () => ref.read(ordersProvider.notifier).loadAll(),
//                     ),
//                     _DrawerItem(
//                       icon: Icons.settings_outlined,
//                       label: 'SETTINGS',
//                       showLabel: showLabel,
//                       onTap: () => context.go('/settings'),
//                     ),
//                     Divider(height: 1, color: t.dividerColor),
//                     _DrawerItem(
//                       icon: Icons.logout_rounded,
//                       label: 'LOGOUT',
//                       showLabel: showLabel,
//                       onTap: () async {
//                         await ref.read(authProvider.notifier).logout();
//                         if (context.mounted) context.go('/pairing');
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _DrawerItem extends StatelessWidget {
//   const _DrawerItem({
//     this.icon,
//     required this.label,
//     required this.showLabel,
//     required this.onTap,
//     this.badge = 0,
//   });

//   final IconData? icon;
//   final String label;
//   final bool showLabel;
//   final VoidCallback onTap;
//   final int badge;

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);

//     final iconWidget = SizedBox(
//       width: 28,
//       height: 28,
//       child: Stack(
//         children: [
//           Positioned(
//             top: 3,
//             left: 3,
//             child: Icon(icon, size: 22, color: t.colorScheme.onSurfaceVariant),
//           ),
//           if (badge > 0)
//             Positioned(
//               top: 0,
//               right: 0,
//               child: Text(
//                 '$badge',
//                 style: const TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );

//     return InkWell(
//       onTap: onTap,
//       child: SizedBox(
//         height: 80,
//         width: double.infinity,
//         child: showLabel
//             ? Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                 child: Column(
//                   children: [
//                     iconWidget,
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         label,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: t.colorScheme.onSurface,
//                           letterSpacing: 0.5,
//                           height: 1.2,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             : Center(child: iconWidget),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yogo_kds/providers/auth_provider.dart';
import '../../../../providers/home_provider.dart';
import '../../../../data/repositories/order_repo.dart';
import '../../../../shared/services/socket_service.dart';

class KdsLeftDrawer extends ConsumerWidget {
  const KdsLeftDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final expanded = ref.watch(drawerExpandedProvider);

    final ordersState = ref.watch(ordersProvider);
    final openCount = ordersState.open.length;
    final holdCount = ordersState.hold.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: expanded ? 130 : 56,
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        border: Border(right: BorderSide(color: t.dividerColor)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showLabel = constraints.maxWidth > 90;
          return Column(
            children: [
              InkWell(
                onTap: () =>
                    ref.read(drawerExpandedProvider.notifier).state = !expanded,
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: Center(
                    child: AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: t.dividerColor),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerItem(
                      label: 'OPEN',
                      showLabel: showLabel,
                      badge: openCount,
                      onTap: () {},
                    ),
                    Divider(height: 1, color: t.dividerColor),
                    _DrawerItem(
                      icon: ref.watch(showSummaryProvider)
                          ? Icons.visibility_off_outlined
                          : Icons.list_alt_rounded,
                      label: ref.watch(showSummaryProvider)
                          ? 'HIDE\nSUMMARY'
                          : 'SHOW\nSUMMARY',
                      showLabel: showLabel,
                      onTap: () =>
                          ref.read(showSummaryProvider.notifier).state = !ref
                              .read(showSummaryProvider),
                    ),
                    Divider(height: 1, color: t.dividerColor),
                    _DrawerItem(
                      icon: Icons.history_rounded,
                      label: 'RECALL',
                      showLabel: showLabel,
                      onTap: () =>
                          ref.read(showRecallDialogProvider.notifier).state =
                              true,
                    ),
                    Divider(height: 1, color: t.dividerColor),
                    _DrawerItem(
                      icon: Icons.refresh_rounded,
                      label: 'REFRESH',
                      showLabel: showLabel,
                      onTap: () => ref.read(ordersProvider.notifier).loadAll(),
                    ),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'SETTINGS',
                      showLabel: showLabel,
                      onTap: () => context.go('/settings'),
                    ),
                    Divider(height: 1, color: t.dividerColor),
                    _DrawerItem(
                      icon: Icons.logout_rounded,
                      label: 'LOGOUT',
                      showLabel: showLabel,
                      onTap: () => _logoutFlow(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Logout / Unpair flow ────────────────────────────────────
  Future<void> _logoutFlow(BuildContext context, WidgetRef ref) async {
    // confirm (unpair destructive)
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout / Unpair'),
        content: const Text(
          'This will unpair this screen. You will need a pairing code to set it up again. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Logout',
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.error,
                fontWeight: FontWeight.w700,
                fontSize: 20
              ),
            ),
          ),
        ],
      ),
    );
    if (yes != true) return;

    // 1) backend unpair — device INACTIVE (fail korleo logout cholbe)
    try {
      await ordersRepository.unpairDevice();
    } catch (e) {
      debugPrint('unpair failed (still logging out locally): $e');
    }

    // 2) socket bondho
    SocketService.instance.disconnect();

    // 3) local auth clear (tomar existing provider logic)
    await ref.read(authProvider.notifier).logout();

    // 4) pairing screen e
    if (context.mounted) context.go('/pairing');
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    this.icon,
    required this.label,
    required this.showLabel,
    required this.onTap,
    this.badge = 0,
  });

  final IconData? icon;
  final String label;
  final bool showLabel;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final iconWidget = SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        children: [
          Positioned(
            top: 3,
            left: 3,
            child: Icon(icon, size: 22, color: t.colorScheme.onSurfaceVariant),
          ),
          if (badge > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                '$badge',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 80,
        width: double.infinity,
        child: showLabel
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    iconWidget,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: t.colorScheme.onSurface,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(child: iconWidget),
      ),
    );
  }
}
