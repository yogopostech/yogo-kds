// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:yogo_kds/modules/home/views/widgets/fonts_colors_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/apperance_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/display_mode_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/genaral_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/order_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/printer_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/routing_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/screen_common_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/transition_time_panel.dart';
// import '../../../providers/settings_provider.dart';

// class SettingsScreen extends ConsumerWidget {
//   const SettingsScreen({super.key});

//   static const _menuItems = [
//     (Icons.settings_outlined, 'General'),
//     (Icons.desktop_windows_outlined, 'Display Modes'),
//     (Icons.alt_route_rounded, 'Routing'),
//      (Icons.receipt_long_outlined,    'Orders'),
//     (Icons.timer_outlined, 'Transition Times'),
//     (Icons.palette_outlined, 'Appearance'),
//     (Icons.text_fields_outlined, 'Fonts & Colors'),
//     (Icons.connected_tv_outlined, 'Screen Communication'),
//     // (Icons.print_outlined, 'Printers'),
//   ];

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final selected = ref.watch(settingsMenuProvider);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.go('/'),
//         ),
//         title: const Text('Settings'),
//       ),
//       body: SafeArea(
//         child: Row(
//           children: [
//             // ══ Layer 1 — menu list ═══════════════════════════
//             Container(
//               width: 280,
//               decoration: BoxDecoration(
//                 border: Border(right: BorderSide(color: t.dividerColor)),
//               ),
//               child: ListView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 itemCount: _menuItems.length,
//                 itemBuilder: (_, i) {
//                   final (icon, label) = _menuItems[i];
//                   final isSelected = selected == i;
//                   return InkWell(
//                     onTap: () =>
//                         ref.read(settingsMenuProvider.notifier).state = i,
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 2,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? t.colorScheme.primary
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             icon,
//                             size: 22,
//                             color: isSelected
//                                 ? Colors.white
//                                 : t.colorScheme.onSurfaceVariant,
//                           ),
//                           const SizedBox(width: 14),
//                           Text(
//                             label,
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: isSelected
//                                   ? FontWeight.w700
//                                   : FontWeight.w500,
//                               color: isSelected
//                                   ? Colors.white
//                                   : t.colorScheme.onSurface,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // ══ Layer 2 — selected content ════════════════════
//             Expanded(child: _buildContent(selected)),
//           ],
//         ),
//       ),
//     );
//   }



//   Widget _buildContent(int selected) {
//     switch (selected) {
//       case 0:
//         return const GeneralPanel();
//       case 1:
//         return const DisplayModesPanel();
//       case 2:
//         return const RoutingPanel();
//          case 3: return const OrdersPanel();  
//       case 4:
//         return const TransitionTimesPanel();
//       case 5:
//         return const AppearancePanel();
//       case 6:
//         return const FontsColorsPanel();
//       case 7:
//         return const ScreenCommPanel();
//       case 8:
//         return const PrintersPanel();
//       default:
//         final (_, label) = _menuItems[selected];
//         return Center(
//           child: Text(
//             '$label — coming soon',
//             style: const TextStyle(fontSize: 16),
//           ),
//         );
//     }
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:yogo_kds/modules/home/views/widgets/fonts_colors_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/apperance_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/display_mode_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/genaral_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/order_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/printer_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/routing_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/screen_common_panel.dart';
// import 'package:yogo_kds/modules/settings/widgets/transition_time_panel.dart';
// import '../../../providers/settings_provider.dart';

// class SettingsScreen extends ConsumerWidget {
//   const SettingsScreen({super.key});

//   // (icon, label, contentIndex) — contentIndex _buildContent er case er sathe mile
//   static const _menuItems = [
//     (Icons.settings_outlined, 'General', 0),
//     (Icons.desktop_windows_outlined, 'Display Modes', 1),
//     (Icons.alt_route_rounded, 'Routing', 2),
//     (Icons.receipt_long_outlined, 'Orders', 3),
//     (Icons.timer_outlined, 'Transition Times', 4),
//     // (Icons.palette_outlined, 'Appearance', 5),            // ← hidden
//     (Icons.text_fields_outlined, 'Fonts & Colors', 6),
//     // (Icons.connected_tv_outlined, 'Screen Communication', 7), // ← hidden
//     // (Icons.print_outlined, 'Printers', 8),
//   ];

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = Theme.of(context);
//     final selected = ref.watch(settingsMenuProvider);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.go('/'),
//         ),
//         title: const Text('Settings'),
//       ),
//       body: SafeArea(
//         child: Row(
//           children: [
//             // ══ Layer 1 — menu list ═══════════════════════════
//             Container(
//               width: 280,
//               decoration: BoxDecoration(
//                 border: Border(right: BorderSide(color: t.dividerColor)),
//               ),
//               child: ListView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 itemCount: _menuItems.length,
//                 itemBuilder: (_, i) {
//                   final (icon, label, index) = _menuItems[i];
//                   final isSelected = selected == index;
//                   return InkWell(
//                     onTap: () =>
//                         ref.read(settingsMenuProvider.notifier).state = index,
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 2,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 14,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? t.colorScheme.primary
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             icon,
//                             size: 22,
//                             color: isSelected
//                                 ? Colors.white
//                                 : t.colorScheme.onSurfaceVariant,
//                           ),
//                           const SizedBox(width: 14),
//                           Text(
//                             label,
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: isSelected
//                                   ? FontWeight.w700
//                                   : FontWeight.w500,
//                               color: isSelected
//                                   ? Colors.white
//                                   : t.colorScheme.onSurface,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // ══ Layer 2 — selected content ════════════════════
//             Expanded(child: _buildContent(selected)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent(int selected) {
//     switch (selected) {
//       case 0:
//         return const GeneralPanel();
//       case 1:
//         return const DisplayModesPanel();
//       case 2:
//         return const RoutingPanel();
//       case 3:
//         return const OrdersPanel();
//       case 4:
//         return const TransitionTimesPanel();
//       case 5:
//         return const AppearancePanel();
//       case 6:
//         return const FontsColorsPanel();
//       case 7:
//         return const ScreenCommPanel();
//       case 8:
//         return const PrintersPanel();
//       default:
//         return const Center(
//           child: Text('Coming soon', style: TextStyle(fontSize: 16)),
//         );
//     }
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yogo_kds/modules/home/views/widgets/fonts_colors_panel.dart';
import 'package:yogo_kds/modules/settings/widgets/apperance_panel.dart';
import 'package:yogo_kds/modules/settings/widgets/display_mode_panel.dart';
import 'package:yogo_kds/modules/settings/widgets/genaral_panel.dart';
import 'package:yogo_kds/modules/settings/widgets/order_panel.dart';
import 'package:yogo_kds/modules/settings/widgets/printer_panel.dart';
import 'package:yogo_kds/modules/settings/widgets/routing_panel.dart';
import 'package:yogo_kds/modules/settings/widgets/screen_common_panel.dart';
import 'package:yogo_kds/modules/settings/widgets/transition_time_panel.dart';
import '../../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // (icon, label, contentIndex) — contentIndex _buildContent er case er sathe mile
  static const _menuItems = [
    (Icons.settings_outlined, 'General', 0),
    (Icons.desktop_windows_outlined, 'Display Modes', 1),
    (Icons.alt_route_rounded, 'Routing', 2),
    (Icons.receipt_long_outlined, 'Orders', 3),
    (Icons.timer_outlined, 'Transition Times', 4),
    // (Icons.palette_outlined, 'Appearance', 5),            // ← hidden
    (Icons.text_fields_outlined, 'Fonts & Colors', 6),
    // (Icons.connected_tv_outlined, 'Screen Communication', 7), // ← hidden
    // (Icons.print_outlined, 'Printers', 8),
  ];

  @override
  void initState() {
    super.initState();
    // Settings khulei prothom menu (General / index 0) select — purono selection reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsMenuProvider.notifier).state = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final selected = ref.watch(settingsMenuProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // ══ Layer 1 — menu list ═══════════════════════════
            Container(
              width: 280,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: t.dividerColor)),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _menuItems.length,
                itemBuilder: (_, i) {
                  final (icon, label, index) = _menuItems[i];
                  final isSelected = selected == index;
                  return InkWell(
                    onTap: () =>
                        ref.read(settingsMenuProvider.notifier).state = index,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? t.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 22,
                            color: isSelected
                                ? Colors.white
                                : t.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : t.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ══ Layer 2 — selected content ════════════════════
            Expanded(child: _buildContent(selected)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int selected) {
    switch (selected) {
      case 0:
        return const GeneralPanel();
      case 1:
        return const DisplayModesPanel();
      case 2:
        return const RoutingPanel();
      case 3:
        return const OrdersPanel();
      case 4:
        return const TransitionTimesPanel();
      case 5:
        return const AppearancePanel();
      case 6:
        return const FontsColorsPanel();
      case 7:
        return const ScreenCommPanel();
      case 8:
        return const PrintersPanel();
      default:
        return const Center(
          child: Text('Coming soon', style: TextStyle(fontSize: 16)),
        );
    }
  }
}