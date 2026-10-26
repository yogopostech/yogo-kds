// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:yogo_kds/modules/auth/views/login_screen.dart';
// import '../modules/home/views/home_screen.dart';
// import '../modules/settings/views/settings_screen.dart';

// import '../providers/auth_provider.dart';

// final routerProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: '/',
//     redirect: (context, state) {
//       final paired = ref.read(authProvider);
//       final goingToPairing = state.matchedLocation == '/pairing';

//       if (!paired && !goingToPairing) return '/pairing';
//       if (paired && goingToPairing) return '/';
//       return null;
//     },
//     routes: [
//       GoRoute(
//         path: '/pairing',
//         builder: (context, state) => const PairingScreen(),
//       ),
//       GoRoute(
//         path: '/',
//         builder: (context, state) => const HomeScreen(),
//       ),
//       GoRoute(
//         path: '/settings',
//         builder: (context, state) => const SettingsScreen(),
//       ),
//     ],
//   );
// });


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yogo_kds/modules/auth/views/login_screen.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/settings/views/settings_screen.dart';

import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final paired = ref.read(authProvider);
      final goingToPairing = state.matchedLocation == '/pairing';

      if (!paired && !goingToPairing) return '/pairing';
      if (paired && goingToPairing) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/pairing',
        builder: (context, state) => const PairingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  // auth state (paired) bodlale redirect abar cholbe → unpair hole /pairing
  ref.listen<bool>(authProvider, (_, __) => router.refresh());

  return router;
});