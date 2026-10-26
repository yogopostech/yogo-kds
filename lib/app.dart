





// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';  // ← import যোগ করো
// import 'package:yogo_kds/routes/app_routes.dart';
// import 'core/theme/app_theme.dart';
// import 'providers/theme_provider.dart';

// class App extends ConsumerWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeMode = ref.watch(themeModeProvider);
//     final router = ref.watch(routerProvider);

//     return MaterialApp.router(
//       title: 'YOGO KDS',
//       debugShowCheckedModeBanner: false,
      
//       // ✅ Light theme — Poppins 
//       theme: AppTheme.light.copyWith(
//         textTheme: GoogleFonts.poppinsTextTheme(AppTheme.light.textTheme),
//       ),
      
//       // ✅ Dark theme — Poppins 
//       darkTheme: AppTheme.dark.copyWith(
//         textTheme: GoogleFonts.poppinsTextTheme(AppTheme.dark.textTheme),
//       ),
      
//       themeMode: themeMode,
//       routerConfig: router,
//     );
//   }
// }




import 'dart:async';   // ← Timer er jonno
import 'dart:math';    // ← Random data er jonno
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yogo_kds/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

void main() {
  // 🔥 Realistic KDS mock data — console e continuously asbe
  final random = Random();

  // Timer.periodic(const Duration(seconds: 3), (timer) {
  //   // ─── Scanning / Order incoming data ───
  //   final orderId = '#${random.nextInt(9000) + 1000}';
  //   final tableNo = 'T-${random.nextInt(50) + 1}';
  //   final itemCount = random.nextInt(8) + 1;
  //   final priority = ['Normal', 'Rush', 'VIP'][random.nextInt(3)];

  //   debugPrint('📡 [SCANNING] Order: $orderId | Table: $tableNo | Items: $itemCount | Priority: $priority');

  //   // ─── Swipe / KDS focused data ───
  //   final ticketId = 'TKT-${random.nextInt(90000) + 10000}';
  //   final prepTime = '${random.nextInt(15) + 2}m';
  //   final station = ['Grill', 'Fryer', 'Cold', 'Dessert'][random.nextInt(4)];
  //   final status = ['COOKING', 'FOCUSED', 'PLATING', 'READY'][random.nextInt(4)];

  //   debugPrint('👆 [SWIPE] Ticket: $ticketId | Station: $station | Prep: $prepTime | Status: $status');
  //   debugPrint('⏱️  Time: ${DateTime.now()}');
  //   debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  // });

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'YOGO KDS',
      debugShowCheckedModeBanner: false,
       scrollBehavior: const MaterialScrollBehavior().copyWith(
    dragDevices: {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,      // ← mouse drag scroll/swipe
      PointerDeviceKind.trackpad,
      PointerDeviceKind.stylus,
    },
  ),

      // ✅ Light theme — Poppins
      theme: AppTheme.light.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(AppTheme.light.textTheme),
      ),

      // ✅ Dark theme — Poppins
      darkTheme: AppTheme.dark.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(AppTheme.dark.textTheme),
      ),

      themeMode: themeMode,
      routerConfig: router,
    );
  }
}