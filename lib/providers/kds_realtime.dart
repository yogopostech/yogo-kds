// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../shared/services/socket_service.dart';
// import '../core/storage/preferences.dart';
// import 'auth_provider.dart';
// import 'home_provider.dart';

// /// Wires the 5 socket events into the orders board.
// /// Kept alive for the whole app session (plain Provider = cached).
// final kdsRealtimeProvider = Provider<KdsRealtime>((ref) {
//   final r = KdsRealtime(ref)..bind();
//   ref.onDispose(r.unbind);
//   return r;
// });

// class KdsRealtime {
//   KdsRealtime(this._ref);
//   final Ref _ref;

//   void bind() {
//     final s = SocketService.instance;
//     final orders = _ref.read(ordersProvider.notifier);

//     // reconnect / first connect → full REST resync (catch missed events)
//     s.onResync = () => orders.loadAll();

//     s.onOrderCreated = (j) => orders.applyOrderUpsert(j);
//     s.onOrderUpdated = (j) => orders.applyOrderUpsert(j);
//     s.onOrderRemoved = (j) => orders.applyOrderRemoved(j);
//     s.onOrdersCleared = (j) => orders.applyOrdersCleared(j);
//     s.onDeviceUnpaired = (_) => _handleUnpaired();
//   }

//   void unbind() {
//     final s = SocketService.instance;
//     s.onResync = null;
//     s.onOrderCreated = null;
//     s.onOrderUpdated = null;
//     s.onOrderRemoved = null;
//     s.onOrdersCleared = null;
//     s.onDeviceUnpaired = null;
//   }

//   // device:unpaired → clear local + flip auth → router sends to /pairing
//   Future<void> _handleUnpaired() async {
//     SocketService.instance.disconnect();
//     await Preferences.clearAuth();
//     await _ref.read(authProvider.notifier).logout();
//   }
// }




import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/services/socket_service.dart';
import '../shared/services/notification_sound_service.dart';
import '../core/storage/preferences.dart';
import 'auth_provider.dart';
import 'settings_provider.dart';
import 'home_provider.dart';

final kdsRealtimeProvider = Provider<KdsRealtime>((ref) {
  final r = KdsRealtime(ref)..bind();
  ref.onDispose(r.unbind);
  return r;
});

class KdsRealtime {
  KdsRealtime(this._ref);
  final Ref _ref;

  // startup / resync burst-e sound off (server start e 24h order replay kore —
  // oigula tei sound bajle spam hobe)
  DateTime _soundGateUntil =
      DateTime.now().add(const Duration(seconds: 5));

  void bind() {
    final s = SocketService.instance;
    final orders = _ref.read(ordersProvider.notifier);

    s.onResync = () {
      _soundGateUntil = DateTime.now().add(const Duration(seconds: 5));
      orders.loadAll();
    };

    s.onOrderCreated = (j) {
      orders.applyOrderUpsert(j);
      _maybePlayNewOrderSound();
    };
    s.onOrderUpdated = (j) => orders.applyOrderUpsert(j);
    s.onOrderRemoved = (j) => orders.applyOrderRemoved(j);
    s.onOrdersCleared = (j) => orders.applyOrdersCleared(j);
    s.onDeviceUnpaired = (_) => _handleUnpaired();
  }

  void _maybePlayNewOrderSound() {
    // startup/resync burst suppress
    if (DateTime.now().isBefore(_soundGateUntil)) return;
    // toggle off hole sound na
    if (!_ref.read(notificationSoundProvider)) return;
    NotificationSoundService.instance.playNewOrder();
  }

  void unbind() {
    final s = SocketService.instance;
    s.onResync = null;
    s.onOrderCreated = null;
    s.onOrderUpdated = null;
    s.onOrderRemoved = null;
    s.onOrdersCleared = null;
    s.onDeviceUnpaired = null;
  }

  Future<void> _handleUnpaired() async {
    SocketService.instance.disconnect();
    await Preferences.clearAuth();
    await _ref.read(authProvider.notifier).logout();
  }
}