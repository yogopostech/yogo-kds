// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'app.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//   ]);

//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
//   );

//   runApp(const ProviderScope(child: App()));
// }




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uuid/uuid.dart';
// import 'core/storage/preferences.dart';
// import 'app.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Init local storage
//   await Preferences.init();

//   // Generate a device id once and reuse it forever.
//   // We do NOT rely on hardware id because some devices share the same info.
//   if (Preferences.deviceId.isEmpty) {
//     Preferences.deviceId = const Uuid().v4();
//   }

//   runApp(const ProviderScope(child: App()));
// }






// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uuid/uuid.dart';
// import 'package:yogo_kds/shared/services/socket_service.dart';
// import 'core/storage/preferences.dart';
// import 'app.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Init local storage
//   await Preferences.init();
//   Preferences.ensureStationId();        // ← station id ready (empty hole UUID)
  

//   // Generate a device id once and reuse it forever.
//   if (Preferences.deviceId.isEmpty) {
//     Preferences.deviceId = const Uuid().v4();
//   }

//   // Console background log animation
//   _startFakeConsoleLogs();
//    SocketService.instance.connect();

//   runApp(const ProviderScope(child: App()));
// }

// void _startFakeConsoleLogs() {
//   int counter = 1;
//   Timer.periodic(const Duration(seconds: 1), (timer) {
//     if (counter % 2 != 0) {
//       print('[SYSTEM LOG #$counter] 🔍 Scanning data... [Device ID: ${Preferences.deviceId.substring(0, 8)}...]');
//     } else {
//       print('[SYSTEM LOG #$counter] 🔄 Processing swiped data... [Status: ACTIVE]');
//     }
//     counter++;
//   });
// }



import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:yogo_kds/shared/services/socket_service.dart';
import 'core/storage/preferences.dart';
import 'app.dart';

/// Sentry DSN — sentry.io → tomar project → Settings → Client Keys (DSN).
/// Khali rakhle app cholbe, shudhu crash reporting off thakbe.
const String kSentryDsn = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init local storage (runApp-er age — crash-safe)
  await Preferences.init();
  Preferences.ensureStationId();

  // Generate a device id once and reuse it forever.
  if (Preferences.deviceId.isEmpty) {
    Preferences.deviceId = const Uuid().v4();
  }

  // Socket connect
  SocketService.instance.connect();

  // Dev console animation (production e chaile remove koro)
  // _startFakeConsoleLogs();

  // DSN na thakle Sentry baad diye normal run
  if (kSentryDsn.isEmpty) {
    runApp(const ProviderScope(child: App()));
    return;
  }

  // DSN thakle Sentry diye run — uncaught error auto-capture hobe
  await SentryFlutter.init(
    (options) {
      options.dsn = kSentryDsn;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.tracesSampleRate = 0.2; // performance sampling (20%)
    },
    appRunner: () => runApp(const ProviderScope(child: App())),
  );
}

// void _startFakeConsoleLogs() {
//   int counter = 1;
//   Timer.periodic(const Duration(seconds: 1), (timer) {
//     if (counter % 2 != 0) {
//       print(
//           '[SYSTEM LOG #$counter] 🔍 Scanning data... [Device ID: ${Preferences.deviceId.substring(0, 8)}...]');
//     } else {
//       print('[SYSTEM LOG #$counter] 🔄 Processing swiped data... [Status: ACTIVE]');
//     }
//     counter++;
//   });
// }

