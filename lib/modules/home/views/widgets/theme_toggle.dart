// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../services/theme_service.dart';

// class ThemeToggle extends StatelessWidget {
//   const ThemeToggle({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = ThemeService.to;
//     return Obx(
//       () => Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.light_mode_outlined,
//             size: 18,
//             color: theme.isDark
//                 ? Theme.of(context).iconTheme.color?.withOpacity(0.4)
//                 : Theme.of(context).colorScheme.primary,
//           ),
//           const SizedBox(width: 6),
//           Switch(
//             value: theme.isDark,
//             onChanged: (_) => theme.toggle(),
//           ),
//           const SizedBox(width: 6),
//           Icon(
//             Icons.dark_mode_outlined,
//             size: 18,
//             color: theme.isDark
//                 ? Theme.of(context).colorScheme.primary
//                 : Theme.of(context).iconTheme.color?.withOpacity(0.4),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/theme_provider.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.light_mode_outlined,
          size: 18,
          color: isDark
              ? Theme.of(context).iconTheme.color?.withOpacity(0.4)
              : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Switch(
          value: isDark,
          onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.dark_mode_outlined,
          size: 18,
          color: isDark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).iconTheme.color?.withOpacity(0.4),
        ),
      ],
    );
  }
}