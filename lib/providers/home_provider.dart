
// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yogo_kds/data/repositories/order_repo.dart';
// import 'package:yogo_kds/providers/settings_provider.dart';
// import '../data/models/kds_order.dart';
// import '../shared/enums/order_enums.dart';

// // ── Hold dialog ──────────────────────────────────────────────────────────────
// final showHoldDialogProvider = StateProvider<bool>((ref) => false);
// final holdOrderIdProvider = StateProvider<String>((ref) => '');
// // 0 = quick set, 1 = custom timer
// final holdModeProvider = StateProvider<int>((ref) => 0);
// final holdSelectedMinutesProvider = StateProvider<int>((ref) => 5);

// // ── Tick provider — fire every second, auto-refresh + expired holds ──────────
// final tickProvider = StreamProvider<int>((ref) {
//   return Stream.periodic(const Duration(seconds: 1), (i) {
//     ref.read(ordersProvider.notifier).onTick();
//     return i;
//   });
// });

// // ── Tab ──────────────────────────────────────────────────────────────────────
// final kdsTabProvider = StateProvider<KdsTab>((ref) => KdsTab.open);

// // ── Drawer ───────────────────────────────────────────────────────────────────
// final drawerExpandedProvider = StateProvider<bool>((ref) => false);
// final showSummaryProvider = StateProvider<bool>((ref) => false);

// // ── Action panel ─────────────────────────────────────────────────────────────
// final selectedOrderIdProvider = StateProvider<String>((ref) => '');
// final showActionPanelProvider = StateProvider<bool>((ref) => false);

// // ── Recall dialog ────────────────────────────────────────────────────────────
// final showRecallDialogProvider = StateProvider<bool>((ref) => false);
// final recallPageProvider = StateProvider<int>((ref) => 0); // pagination
// final expandedRecallIdProvider = StateProvider<String>((ref) => ''); // dropdown

// const recallPerPage = 10;

// // ── Bump toast ───────────────────────────────────────────────────────────────
// final lastBumpedOrderProvider = StateProvider<KdsOrder?>((ref) => null);

// // ── Orders ───────────────────────────────────────────────────────────────────
// final ordersProvider =
//     StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
//   return OrdersNotifier();
// });

// // ── Aggregated item summary — from all open orders ───────────────────────────
// // item name → total qty (ready items are skipped)
// final itemSummaryProvider = Provider<Map<String, int>>((ref) {
//   final ordersState = ref.watch(ordersProvider);

//   final summary = <String, int>{};
//   for (final order in ordersState.open) {
//     for (final item in order.items) {
//       if (item.isReady) continue;
//       summary[item.name] = (summary[item.name] ?? 0) + item.qty;
//     }
//   }
//   return summary;
// });

// // ── Routing filter — drop items of disabled categories/sources ───────────────
// // if all items of an order are dropped, the order itself is hidden
// List<KdsOrder> applyRouting(List<KdsOrder> orders, RoutingState routing) {
//   final result = <KdsOrder>[];

//   for (final order in orders) {
//     if (!routing.isSourceOn(order.source)) continue;

//     final visibleItems =
//         order.items.where((i) => routing.isCategoryOn(i.category)).toList();

//     if (visibleItems.isEmpty) continue;

//     if (visibleItems.length == order.items.length) {
//       result.add(order);
//       continue;
//     }

//     result.add(KdsOrder(
//       id: order.id,
//       orderNumber: order.orderNumber,
//       customerName: order.customerName,
//       type: order.type,
//       source: order.source,
//       placedAt: order.placedAt,
//       items: visibleItems,
//       isCompleted: order.isCompleted,
//       isOnHold: order.isOnHold,
//       holdUntil: order.holdUntil,
//       completedAt: order.completedAt,
//     ));
//   }

//   return result;
// }

// // ── Orders state — separate list per tab + loading flag ──────────────────────
// class OrdersState {
//   final List<KdsOrder> open;
//   final List<KdsOrder> hold;
//   final List<KdsOrder> completed;
//   final bool isLoading;

//   const OrdersState({
//     this.open = const [],
//     this.hold = const [],
//     this.completed = const [],
//     this.isLoading = false,
//   });

//   OrdersState copyWith({
//     List<KdsOrder>? open,
//     List<KdsOrder>? hold,
//     List<KdsOrder>? completed,
//     bool? isLoading,
//   }) =>
//       OrdersState(
//         open: open ?? this.open,
//         hold: hold ?? this.hold,
//         completed: completed ?? this.completed,
//         isLoading: isLoading ?? this.isLoading,
//       );
// }

// class OrdersNotifier extends StateNotifier<OrdersState> {
//   OrdersNotifier() : super(const OrdersState()) {
//     loadAll();
//   }

//   int _tickCounter = 0;

//   // ── Load all three tabs from backend (parallel) ────────────
//   Future<void> loadAll() async {
//     state = state.copyWith(isLoading: true);
//     try {
//       final results = await Future.wait([
//         ordersRepository.fetchOrders(OrderTab.open),
//         ordersRepository.fetchOrders(OrderTab.hold),
//         ordersRepository.fetchOrders(OrderTab.completed),
//       ]);

//       state = state.copyWith(
//         open: results[0],
//         hold: results[1],
//         completed: results[2],
//         isLoading: false,
//       );
//     } catch (e) {
//       // Keep existing data on failure
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   // ── Getters used across the UI ─────────────────────────────
//   List<KdsOrder> get openOrders => state.open;
//   List<KdsOrder> get holdOrders => state.hold;
//   List<KdsOrder> get completedOrders => state.completed;

//   bool get isLoading => state.isLoading;

//   // ── Tick — refresh every 15s + auto-release expired holds ──
//   void onTick() {
//     _tickCounter++;
//     if (_tickCounter >= 15) {
//       _tickCounter = 0;
//       loadAll();
//     }
//     _checkExpiredHoldsLocal();
//   }

//   // Move a hold to open the moment its timer ends,
//   // so the UI reacts instantly without waiting for a refresh.
//   void _checkExpiredHoldsLocal() {
//     final now = DateTime.now();
//     final expired = state.hold
//         .where((o) => o.holdUntil != null && now.isAfter(o.holdUntil!))
//         .toList();
//     if (expired.isEmpty) return;

//     final stillHeld = state.hold
//         .where((o) => !(o.holdUntil != null && now.isAfter(o.holdUntil!)))
//         .toList();

//     for (final o in expired) {
//       o.isOnHold = false;
//       o.holdUntil = null;
//     }

//     state = state.copyWith(
//       hold: stillHeld,
//       open: [...state.open, ...expired],
//     );

//     // let the backend know each expired hold is back to open
//     for (final o in expired) {
//       ordersRepository.releaseOrder(o.id).catchError((_) => false);
//     }
//   }

//   // ── Find an order across all tabs ──────────────────────────
//   KdsOrder? _find(String id) {
//     for (final o in [...state.open, ...state.hold, ...state.completed]) {
//       if (o.id == id) return o;
//     }
//     return null;
//   }

//   // Force a rebuild after mutating a nested field in place
//   void _touch() {
//     state = state.copyWith(
//       open: [...state.open],
//       hold: [...state.hold],
//       completed: [...state.completed],
//     );
//   }

//   // Put an order back to open if a backend action failed
//   void _revertToOpen(KdsOrder order) {
//     order.isCompleted = false;
//     order.isOnHold = false;
//     order.holdUntil = null;
//     order.completedAt = null;
//     state = state.copyWith(
//       completed: state.completed.where((o) => o.id != order.id).toList(),
//       hold: state.hold.where((o) => o.id != order.id).toList(),
//       open: [order, ...state.open.where((o) => o.id != order.id)],
//     );
//   }

//   // ── Item ready toggle — item + all its modifiers ───────────
//   // void toggleItemReady(String orderId, int itemIndex) {
//   //   final order = _find(orderId);
//   //   if (order == null || itemIndex >= order.items.length) return;
//   //   final item = order.items[itemIndex];
//   //   item.isReady = !item.isReady;
//   //   for (final mod in item.modifiers) {
//   //     mod.isReady = item.isReady;
//   //   }
//   //   _touch();
//   // }


//     // ── Item ready toggle — item + all its modifiers (API-backed) ──
//   Future<void> toggleItemReady(String orderId, int itemIndex) async {
//     final order = _find(orderId);
//     if (order == null || itemIndex >= order.items.length) return;
//     final item = order.items[itemIndex];

//     // remember previous state for exact revert on failure
//     final prevItemReady = item.isReady;
//     final prevMods = item.modifiers.map((m) => m.isReady).toList();

//     final newReady = !item.isReady;

//     // optimistic: flip item + all its modifiers
//     item.isReady = newReady;
//     for (final mod in item.modifiers) {
//       mod.isReady = newReady;
//     }
//     _touch();
//     _refreshSummary();

//     // sync with backend
//     try {
//       await ordersRepository.setItemReady(order.id, item.id, newReady);
//     } catch (e) {
//       debugPrint('setItemReady failed: $e');
//       // revert to the exact previous state
//       item.isReady = prevItemReady;
//       for (var k = 0; k < item.modifiers.length; k++) {
//         item.modifiers[k].isReady = prevMods[k];
//       }
//       _touch();
//       _refreshSummary();
//     }
//   }

//   // ── Modifier ready toggle — single modifier ────────────────
//   void toggleModifierReady(String orderId, int itemIndex, int modIndex) {
//     final order = _find(orderId);
//     if (order == null) return;
//     if (itemIndex >= order.items.length) return;
//     if (modIndex >= order.items[itemIndex].modifiers.length) return;
//     final mod = order.items[itemIndex].modifiers[modIndex];
//     mod.isReady = !mod.isReady;
//     _touch();
//   }

//   // ── Bump — open/hold → completed (optimistic + backend) ────
//   Future<void> bump(String id) async {
//     final order = _find(id);
//     if (order == null) return;

//     // optimistic UI
//     order.isCompleted = true;
//     order.isOnHold = false;
//     order.completedAt = DateTime.now();
//     state = state.copyWith(
//       open: state.open.where((o) => o.id != id).toList(),
//       hold: state.hold.where((o) => o.id != id).toList(),
//       completed: [order, ...state.completed],
//     );

//     // sync with backend
//     try {
//       final ok = await ordersRepository.bumpOrder(id);
//       if (!ok) _revertToOpen(order);
//     } catch (_) {
//       _revertToOpen(order);
//     }
//   }

//   // ── Undo bump — completed → open (uses recall on backend) ──
//   Future<void> undoBump(String id) async {
//     await recall(id);
//   }

//   // ── Recall — completed → open, reset items (optimistic) ────
//   Future<void> recall(String id) async {
//     final order = _find(id);
//     if (order == null) return;

//     // optimistic UI
//     order.isCompleted = false;
//     order.completedAt = null;
//     order.isOnHold = false;
//     for (final item in order.items) {
//       item.isReady = false;
//       for (final mod in item.modifiers) {
//         mod.isReady = false;
//       }
//     }
//     state = state.copyWith(
//       completed: state.completed.where((o) => o.id != id).toList(),
//       open: [order, ...state.open],
//     );

//     // sync with backend (next refresh corrects any mismatch)
//     try {
//       await ordersRepository.recallOrder(id);
//     } catch (_) {}
//   }

//   // ── Order type change ──────────────────────────────────────
//   void changeOrderType(String id, OrderType newType) {
//     final order = _find(id);
//     if (order == null) return;
//     order.type = newType;
//     _touch();
//   }

//   // ── Clear all completed orders (local) ─────────────────────
//   void clearCompleted() {
//     state = state.copyWith(completed: []);
//   }

//   // ── Hold with timer — open → hold (optimistic + backend) ───
//   Future<void> holdWithTimer(String id, int minutes) async {
//     final order = _find(id);
//     if (order == null) return;

//     final until = DateTime.now().add(Duration(minutes: minutes));

//     // optimistic UI
//     order.isOnHold = true;
//     order.holdUntil = until;
//     state = state.copyWith(
//       open: state.open.where((o) => o.id != id).toList(),
//       hold: [order, ...state.hold],
//     );

//     // sync with backend
//     try {
//       final ok = await ordersRepository.holdOrder(id, until);
//       if (!ok) _revertToOpen(order);
//     } catch (_) {
//       _revertToOpen(order);
//     }
//   }

//   // ── Release — hold → open (optimistic + backend) ───────────
//   Future<void> release(String id) async {
//     final order = _find(id);
//     if (order == null) return;

//     // optimistic UI
//     order.isOnHold = false;
//     order.holdUntil = null;
//     state = state.copyWith(
//       hold: state.hold.where((o) => o.id != id).toList(),
//       open: [order, ...state.open],
//     );

//     // sync with backend (next refresh corrects any mismatch)
//     try {
//       await ordersRepository.releaseOrder(id);
//     } catch (_) {}
//   }

//   // ── Queue ordering (within open) ───────────────────────────
//   void moveToFront(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     list.insert(0, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveForward(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     list.insert(idx - 1, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveBackward(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx < 0 || idx >= list.length - 1) return;
//     list.insert(idx + 1, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveToBack(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx < 0) return;
//     list.add(list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }
//   void moveLeft(String id){
//     final list = [...state.open];
//     final idk=list.indexWhere((o) => o.id == id);
//     if(idk >0) return;
//     list.insert(idk+1, list.removeAt(idk));
//     state = state.copyWith(open: list);
//   }
// }





// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yogo_kds/data/repositories/order_repo.dart';
// import 'package:yogo_kds/data/models/item_summary.dart';
// import 'package:yogo_kds/providers/settings_provider.dart';
// import '../data/models/kds_order.dart';
// import '../shared/enums/order_enums.dart';

// // ── Hold dialog ──────────────────────────────────────────────────────────────
// final showHoldDialogProvider = StateProvider<bool>((ref) => false);
// final holdOrderIdProvider = StateProvider<String>((ref) => '');
// // 0 = quick set, 1 = custom timer
// final holdModeProvider = StateProvider<int>((ref) => 0);
// final holdSelectedMinutesProvider = StateProvider<int>((ref) => 5);

// // ── Tick provider — fire every second, auto-refresh + expired holds ──────────
// final tickProvider = StreamProvider<int>((ref) {
//   return Stream.periodic(const Duration(seconds: 1), (i) {
//     ref.read(ordersProvider.notifier).onTick();
//     return i;
//   });
// });

// // ── Tab ──────────────────────────────────────────────────────────────────────
// final kdsTabProvider = StateProvider<KdsTab>((ref) => KdsTab.open);

// // ── Drawer ───────────────────────────────────────────────────────────────────
// final drawerExpandedProvider = StateProvider<bool>((ref) => false);
// final showSummaryProvider = StateProvider<bool>((ref) => false);

// // ── Action panel ─────────────────────────────────────────────────────────────
// final selectedOrderIdProvider = StateProvider<String>((ref) => '');
// final showActionPanelProvider = StateProvider<bool>((ref) => false);

// // ── Recall dialog ────────────────────────────────────────────────────────────
// final showRecallDialogProvider = StateProvider<bool>((ref) => false);
// final recallPageProvider = StateProvider<int>((ref) => 0); // pagination
// final expandedRecallIdProvider = StateProvider<String>((ref) => ''); // dropdown

// const recallPerPage = 10;

// // ── Bump toast ───────────────────────────────────────────────────────────────
// final lastBumpedOrderProvider = StateProvider<KdsOrder?>((ref) => null);

// // ── Orders ───────────────────────────────────────────────────────────────────
// final ordersProvider =
//     StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
//   return OrdersNotifier(ref);
// });

// // ── Item summary (API-backed, AsyncValue) ────────────────────────────────────
// // GET /api/kds/orders/summary — loading / data / error all tracked.
// final itemSummaryListProvider = StateNotifierProvider<ItemSummaryNotifier,
//     AsyncValue<List<ItemSummary>>>((ref) {
//   return ItemSummaryNotifier();
// });

// // name → qty map, so the existing ItemSummaryPanel needs NO change.
// // While loading or on error, it falls back to the last/empty data.
// final itemSummaryProvider = Provider<Map<String, int>>((ref) {
//   final async = ref.watch(itemSummaryListProvider);
//   final list = async.asData?.value ?? const <ItemSummary>[];
//   final summary = <String, int>{};
//   for (final it in list) {
//     summary[it.name] = it.quantity;
//   }
//   return summary;
// });

// class ItemSummaryNotifier
//     extends StateNotifier<AsyncValue<List<ItemSummary>>> {
//   ItemSummaryNotifier() : super(const AsyncValue.loading()) {
//     load();
//   }

//   Future<void> load() async {
//     try {
//       final items = await ordersRepository.fetchItemSummary();
//       state = AsyncValue.data(items);
//     } catch (e, st) {
//       debugPrint('ItemSummary load failed: $e');
//       // production: report to Crashlytics / Sentry here
//       state = AsyncValue.error(e, st);
//     }
//   }
// }

// // ── Routing filter — drop items of disabled categories/sources ───────────────
// // if all items of an order are dropped, the order itself is hidden
// List<KdsOrder> applyRouting(List<KdsOrder> orders, RoutingState routing) {
//   final result = <KdsOrder>[];

//   for (final order in orders) {
//     if (!routing.isSourceOn(order.source)) continue;

//     final visibleItems =
//         order.items.where((i) => routing.isCategoryOn(i.category)).toList();

//     if (visibleItems.isEmpty) continue;

//     if (visibleItems.length == order.items.length) {
//       result.add(order);
//       continue;
//     }

//     result.add(KdsOrder(
//       id: order.id,
//       orderNumber: order.orderNumber,
//       customerName: order.customerName,
//       type: order.type,
//       source: order.source,
//       placedAt: order.placedAt,
//       items: visibleItems,
//       isCompleted: order.isCompleted,
//       isOnHold: order.isOnHold,
//       holdUntil: order.holdUntil,
//       completedAt: order.completedAt,
//     ));
//   }

//   return result;
// }

// // ── Orders state — separate list per tab + loading flag ──────────────────────
// class OrdersState {
//   final List<KdsOrder> open;
//   final List<KdsOrder> hold;
//   final List<KdsOrder> completed;
//   final bool isLoading;

//   const OrdersState({
//     this.open = const [],
//     this.hold = const [],
//     this.completed = const [],
//     this.isLoading = false,
//   });

//   OrdersState copyWith({
//     List<KdsOrder>? open,
//     List<KdsOrder>? hold,
//     List<KdsOrder>? completed,
//     bool? isLoading,
//   }) =>
//       OrdersState(
//         open: open ?? this.open,
//         hold: hold ?? this.hold,
//         completed: completed ?? this.completed,
//         isLoading: isLoading ?? this.isLoading,
//       );
// }

// class OrdersNotifier extends StateNotifier<OrdersState> {
//   OrdersNotifier(this._ref) : super(const OrdersState()) {
//     loadAll();
//   }

//   final Ref _ref;
//   int _tickCounter = 0;

//   // Debounce summary reloads so a burst of actions = one API call.
//   Timer? _summaryDebounce;

//   void _refreshSummary() {
//     _summaryDebounce?.cancel();
//     _summaryDebounce = Timer(const Duration(milliseconds: 300), () {
//       _ref.read(itemSummaryListProvider.notifier).load();
//     });
//   }

//   @override
//   void dispose() {
//     _summaryDebounce?.cancel();
//     super.dispose();
//   }

//   // ── Load all three tabs from backend (parallel) ────────────
//   Future<void> loadAll() async {
//     state = state.copyWith(isLoading: true);
//     try {
//       final results = await Future.wait([
//         ordersRepository.fetchOrders(OrderTab.open),
//         ordersRepository.fetchOrders(OrderTab.hold),
//         ordersRepository.fetchOrders(OrderTab.completed),
//       ]);

//       state = state.copyWith(
//         open: results[0],
//         hold: results[1],
//         completed: results[2],
//       );
//       _refreshSummary();
//     } catch (e) {
//       debugPrint('Orders loadAll failed: $e');
//       // production: report to Crashlytics / Sentry here.
//       // Keep whatever data we already had on screen.
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   // ── Getters used across the UI ─────────────────────────────
//   List<KdsOrder> get openOrders => state.open;
//   List<KdsOrder> get holdOrders => state.hold;
//   List<KdsOrder> get completedOrders => state.completed;

//   bool get isLoading => state.isLoading;

//   // ── Tick — refresh every 15s + auto-release expired holds ──
//   void onTick() {
//     _tickCounter++;
//     if (_tickCounter >= 15) {
//       _tickCounter = 0;
//       loadAll();
//     }
//     _checkExpiredHoldsLocal();
//   }

//   // Move a hold to open the moment its timer ends,
//   // so the UI reacts instantly without waiting for a refresh.
//   void _checkExpiredHoldsLocal() {
//     final now = DateTime.now();
//     final expired = state.hold
//         .where((o) => o.holdUntil != null && now.isAfter(o.holdUntil!))
//         .toList();
//     if (expired.isEmpty) return;

//     final stillHeld = state.hold
//         .where((o) => !(o.holdUntil != null && now.isAfter(o.holdUntil!)))
//         .toList();

//     for (final o in expired) {
//       o.isOnHold = false;
//       o.holdUntil = null;
//     }

//     state = state.copyWith(
//       hold: stillHeld,
//       open: [...state.open, ...expired],
//     );
//     _refreshSummary();

//     // let the backend know each expired hold is back to open
//     for (final o in expired) {
//       ordersRepository.releaseOrder(o.id).catchError((_) => false);
//     }
//   }

//   // ── Find an order across all tabs ──────────────────────────
//   KdsOrder? _find(String id) {
//     for (final o in [...state.open, ...state.hold, ...state.completed]) {
//       if (o.id == id) return o;
//     }
//     return null;
//   }

//   // Force a rebuild after mutating a nested field in place
//   void _touch() {
//     state = state.copyWith(
//       open: [...state.open],
//       hold: [...state.hold],
//       completed: [...state.completed],
//     );
//   }

//   void duplicate(){
//     state = state.copyWith(
//       open: [...state.open],
//       hold : [...holdOrders]
//     );
//   }

//   // Put an order back to open if a backend action failed
//   void _revertToOpen(KdsOrder order) {
//     order.isCompleted = false;
//     order.isOnHold = false;
//     order.holdUntil = null;
//     order.completedAt = null;
//     state = state.copyWith(
//       completed: state.completed.where((o) => o.id != order.id).toList(),
//       hold: state.hold.where((o) => o.id != order.id).toList(),
//       open: [order, ...state.open.where((o) => o.id != order.id)],
//     );
//     _refreshSummary();
//   }

//   // ── Item ready toggle — item + all its modifiers (API-backed) ──
//   // Future<void> toggleItemReady(String orderId, int itemIndex) async {
//   //   final order = _find(orderId);
//   //   if (order == null || itemIndex >= order.items.length) return;
//   //   final item = order.items[itemIndex];

//   //   // remember previous state for exact revert on failure
//   //   final prevItemReady = item.isReady;
//   //   final prevMods = item.modifiers.map((m) => m.isReady).toList();

//   //   final newReady = !item.isReady;

//   //   // optimistic: flip item + all its modifiers
//   //   item.isReady = newReady;
//   //   for (final mod in item.modifiers) {
//   //     mod.isReady = newReady;
//   //   }
//   //   _touch();

//   //   // sync with backend, then refresh the summary from the confirmed state
//   //   try {
//   //     await ordersRepository.setItemReady(order.id, item.id, newReady);
//   //     _refreshSummary();
//   //   } catch (e) {
//   //     debugPrint('setItemReady failed: $e');
//   //     // revert to the exact previous state
//   //     item.isReady = prevItemReady;
//   //     for (var k = 0; k < item.modifiers.length; k++) {
//   //       item.modifiers[k].isReady = prevMods[k];
//   //     }
//   //     _touch();
//   //     _refreshSummary();
//   //   }
//   // }




//     // ── Item ready toggle — item + ALL its modifiers (API-backed) ──
//   // ── Item ready toggle — item + ALL its modifiers (API-backed) ──
//   Future<void> toggleItemReady(String orderId, int itemIndex) async {
//     final order = _find(orderId);
//     if (order == null || itemIndex >= order.items.length) return;
//     final item = order.items[itemIndex];

//     final prevItemReady = item.isReady;
//     final prevMods = item.modifiers.map((m) => m.isReady).toList();

//     final newReady = !item.isReady;

//     // optimistic: flip item + all its modifiers (cross on name + modifiers)
//     item.isReady = newReady;
//     for (final mod in item.modifiers) {
//       mod.isReady = newReady;
//     }
//     _touch();

//     try {
//       // item ready is the primary call — its success keeps the cross
//       await ordersRepository.setItemReady(order.id, item.id, newReady);

//       // modifiers sync best-effort — a modifier failure does NOT revert the item
//       for (final mod in item.modifiers) {
//         ordersRepository
//             .setModifierReady(order.id, item.id, mod.id, newReady)
//             .catchError((e) {
//           debugPrint('modifier ready sync failed: $e');
//         });
//       }
//       _refreshSummary();
//     } catch (e) {
//       debugPrint('setItemReady failed: $e');
//       // only an item-ready failure reverts everything
//       item.isReady = prevItemReady;
//       for (var k = 0; k < item.modifiers.length; k++) {
//         item.modifiers[k].isReady = prevMods[k];
//       }
//       _touch();
//       _refreshSummary();
//     }
//   }

//   // ── Modifier ready toggle — single modifier (local) ────────
//   // void toggleModifierReady(String orderId, int itemIndex, int modIndex) {
//   //   final order = _find(orderId);
//   //   if (order == null) return;
//   //   if (itemIndex >= order.items.length) return;
//   //   if (modIndex >= order.items[itemIndex].modifiers.length) return;
//   //   final mod = order.items[itemIndex].modifiers[modIndex];
//   //   mod.isReady = !mod.isReady;
//   //   _touch();
//   // }



//     // ── Modifier ready toggle — single modifier (API-backed) ───
//   Future<void> toggleModifierReady(
//     String orderId,
//     int itemIndex,
//     int modIndex,
//   ) async {
//     final order = _find(orderId);
//     if (order == null) return;
//     if (itemIndex >= order.items.length) return;
//     if (modIndex >= order.items[itemIndex].modifiers.length) return;
//     final item = order.items[itemIndex];
//     final mod = item.modifiers[modIndex];

//     final prevReady = mod.isReady;
//     final newReady = !mod.isReady;

//     // optimistic
//     mod.isReady = newReady;
//     _touch();

//     // sync with backend
//     try {
//       await ordersRepository.setModifierReady(
//         order.id,
//         item.id,
//         mod.id,
//         newReady,
//       );
//     } catch (e) {
//       debugPrint('setModifierReady failed: $e');
//       // revert
//       mod.isReady = prevReady;
//       _touch();
//     }
//   }

//   // ── Bump — open/hold → completed (optimistic + backend) ────
//   Future<void> bump(String id) async {
//     final order = _find(id);
//     if (order == null) return;

//     // optimistic UI
//     order.isCompleted = true;
//     order.isOnHold = false;
//     order.completedAt = DateTime.now();
//     state = state.copyWith(
//       open: state.open.where((o) => o.id != id).toList(),
//       hold: state.hold.where((o) => o.id != id).toList(),
//       completed: [order, ...state.completed],
//     );
//     _refreshSummary();

//     // sync with backend
//     try {
//       final ok = await ordersRepository.bumpOrder(id);
//       if (!ok) _revertToOpen(order);
//     } catch (_) {
//       _revertToOpen(order);
//     }
//   }

//   // ── Undo bump — completed → open (uses recall on backend) ──
//   Future<void> undoBump(String id) async {
//     await recall(id);
//   }

//   // ── Recall — completed → open, reset items (optimistic) ────
//   Future<void> recall(String id) async {
//     final order = _find(id);
//     if (order == null) return;

//     // optimistic UI
//     order.isCompleted = false;
//     order.completedAt = null;
//     order.isOnHold = false;
//     for (final item in order.items) {
//       item.isReady = false;
//       for (final mod in item.modifiers) {
//         mod.isReady = false;
//       }
//     }
//     state = state.copyWith(
//       completed: state.completed.where((o) => o.id != id).toList(),
//       open: [order, ...state.open],
//     );
//     _refreshSummary();

//     // sync with backend (next refresh corrects any mismatch)
//     try {
//       await ordersRepository.recallOrder(id);
//     } catch (e) {
//       debugPrint('recallOrder failed: $e');
//     }
//   }

//   // ── Order type change ──────────────────────────────────────
//   void changeOrderType(String id, OrderType newType) {
//     final order = _find(id);
//     if (order == null) return;
//     order.type = newType;
//     _touch();
//   }

//   // ── Clear all completed orders (local) ─────────────────────
//   // void clearCompleted() {
//   //   state = state.copyWith(completed: []);
//   // }

//   // ── Clear all completed orders (backend + local) ──────────
// Future<void> clearCompleted() async {
//   final prev = state.completed;
//   state = state.copyWith(completed: []); // optimistic clear

//   try {
//     await ordersRepository.clearCompletedOrders(); // backend clear
//   } catch (e) {
//     debugPrint('clearCompleted failed: $e');
//     state = state.copyWith(completed: prev); // fail hole ferot
//   }
// }

//   // ── Hold with timer — open → hold (optimistic + backend) ───
//   Future<void> holdWithTimer(String id, int minutes) async {
//     final order = _find(id);
//     if (order == null) return;

//     final until = DateTime.now().add(Duration(minutes: minutes));

//     // optimistic UI
//     order.isOnHold = true;
//     order.holdUntil = until;
//     state = state.copyWith(
//       open: state.open.where((o) => o.id != id).toList(),
//       hold: [order, ...state.hold],
//     );
//     _refreshSummary();

//     // sync with backend
//     try {
//       final ok = await ordersRepository.holdOrder(id, until);
//       if (!ok) _revertToOpen(order);
//     } catch (_) {
//       _revertToOpen(order);
//     }
//   }

//   // ── Release — hold → open (optimistic + backend) ───────────
//   Future<void> release(String id) async {
//     final order = _find(id);
//     if (order == null) return;

//     // optimistic UI
//     order.isOnHold = false;
//     order.holdUntil = null;
//     state = state.copyWith(
//       hold: state.hold.where((o) => o.id != id).toList(),
//       open: [order, ...state.open],
//     );
//     _refreshSummary();

//     // sync with backend (next refresh corrects any mismatch)
//     try {
//       await ordersRepository.releaseOrder(id);
//     } catch (e) {
//       debugPrint('releaseOrder failed: $e');
//     }
//   }

//   // ── Queue ordering (within open) ───────────────────────────
//   void moveToFront(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     list.insert(0, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveForward(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     list.insert(idx - 1, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveBackward(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx < 0 || idx >= list.length - 1) return;
//     list.insert(idx + 1, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveToBack(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx < 0) return;
//     list.add(list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   // same as moveForward — kept so any existing reference still compiles
//   void moveLeft(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     list.insert(idx - 1, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }



//     // ════════════════════════════════════════════════════════════
//   //  REALTIME (socket) — apply server events to the board
//   // ════════════════════════════════════════════════════════════

//   // order:created / order:updated → upsert by _id
//   void applyOrderUpsert(Map<String, dynamic> json) {
//     final order = KdsOrder.fromJson(json);
//     if (order.id.isEmpty) return;
//     _upsertOrder(order);
//     _refreshSummary();
//   }

//   void _upsertOrder(KdsOrder order) {
//     final open = [...state.open];
//     final hold = [...state.hold];
//     final completed = [...state.completed];

//     final iOpen = open.indexWhere((o) => o.id == order.id);
//     final iHold = hold.indexWhere((o) => o.id == order.id);
//     final iComp = completed.indexWhere((o) => o.id == order.id);

//     final toCompleted = order.isCompleted;
//     final toHold = !order.isCompleted && order.isOnHold;

//     if (!toCompleted && !toHold && iOpen != -1) {
//       open[iOpen] = order;            // stays open → replace in place
//     } else if (toHold && iHold != -1) {
//       hold[iHold] = order;            // stays hold → replace in place
//     } else if (toCompleted && iComp != -1) {
//       completed[iComp] = order;       // stays completed → replace in place
//     } else {
//       // bucket changed (or brand new) → remove from old, add to new
//       if (iOpen != -1) open.removeAt(iOpen);
//       if (iHold != -1) hold.removeAt(iHold);
//       if (iComp != -1) completed.removeAt(iComp);

//       if (toCompleted) {
//         completed.insert(0, order);
//       } else if (toHold) {
//         hold.insert(0, order);
//       } else {
//         open.add(order);              // new open order at end of queue
//       }
//     }

//     state = state.copyWith(open: open, hold: hold, completed: completed);
//   }

//   // order:removed → delete by _id
//   void applyOrderRemoved(Map<String, dynamic> json) {
//     final id = (json['_id'] ?? json['id'] ?? '').toString();
//     if (id.isEmpty) return;
//     state = state.copyWith(
//       open: state.open.where((o) => o.id != id).toList(),
//       hold: state.hold.where((o) => o.id != id).toList(),
//       completed: state.completed.where((o) => o.id != id).toList(),
//     );
//     _refreshSummary();
//   }

//   // orders:cleared → drop completed with bumpedAt <= clearedAt
//   void applyOrdersCleared(Map<String, dynamic> json) {
//     final clearedAt =
//         DateTime.tryParse('${json['clearedAt'] ?? ''}')?.toLocal();
//     if (clearedAt == null) {
//       state = state.copyWith(completed: const []);
//       _refreshSummary();
//       return;
//     }
//     state = state.copyWith(
//       completed: state.completed.where((o) {
//         final b = o.completedAt; // model maps bumpedAt → completedAt
//         return b != null && b.isAfter(clearedAt);
//       }).toList(),
//     );
//     _refreshSummary();
//   }
// }






// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yogo_kds/data/repositories/order_repo.dart';
// import 'package:yogo_kds/data/models/item_summary.dart';
// import 'package:yogo_kds/providers/settings_provider.dart';
// import 'package:yogo_kds/shared/services/error_reporter.dart';
// import '../data/models/kds_order.dart';
// import '../shared/enums/order_enums.dart';

// // ── Hold dialog ──────────────────────────────────────────────
// final showHoldDialogProvider = StateProvider<bool>((ref) => false);
// final holdOrderIdProvider = StateProvider<String>((ref) => '');
// final holdModeProvider = StateProvider<int>((ref) => 0);
// final holdSelectedMinutesProvider = StateProvider<int>((ref) => 5);

// // ── Tick provider — every second: hold check + periodic resync ──
// final tickProvider = StreamProvider<int>((ref) {
//   return Stream.periodic(const Duration(seconds: 1), (i) {
//     ref.read(ordersProvider.notifier).onTick();
//     return i;
//   });
// });

// // ── Tab ───────────────────────────────────────────────────────
// final kdsTabProvider = StateProvider<KdsTab>((ref) => KdsTab.open);

// // ── Drawer ────────────────────────────────────────────────────
// final drawerExpandedProvider = StateProvider<bool>((ref) => false);
// final showSummaryProvider = StateProvider<bool>((ref) => false);

// // ── Action panel ──────────────────────────────────────────────
// final selectedOrderIdProvider = StateProvider<String>((ref) => '');
// final showActionPanelProvider = StateProvider<bool>((ref) => false);

// // ── Recall dialog ─────────────────────────────────────────────
// final showRecallDialogProvider = StateProvider<bool>((ref) => false);
// final recallPageProvider = StateProvider<int>((ref) => 0);
// final expandedRecallIdProvider = StateProvider<String>((ref) => '');

// const recallPerPage = 10;

// // ── Bump toast ────────────────────────────────────────────────
// final lastBumpedOrderProvider = StateProvider<KdsOrder?>((ref) => null);

// // ── Orders ────────────────────────────────────────────────────
// final ordersProvider =
//     StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
//   return OrdersNotifier(ref);
// });

// // ── Item summary (API-backed, AsyncValue) ─────────────────────
// final itemSummaryListProvider = StateNotifierProvider<ItemSummaryNotifier,
//     AsyncValue<List<ItemSummary>>>((ref) {
//   return ItemSummaryNotifier();
// });

// final itemSummaryProvider = Provider<Map<String, int>>((ref) {
//   final async = ref.watch(itemSummaryListProvider);
//   final list = async.asData?.value ?? const <ItemSummary>[];
//   final summary = <String, int>{};
//   for (final it in list) {
//     summary[it.name] = it.quantity;
//   }
//   return summary;
// });

// class ItemSummaryNotifier
//     extends StateNotifier<AsyncValue<List<ItemSummary>>> {
//   ItemSummaryNotifier() : super(const AsyncValue.loading()) {
//     load();
//   }

//   Future<void> load() async {
//     try {
//       final items = await ordersRepository.fetchItemSummary();
//       state = AsyncValue.data(items);
//     } catch (e, st) {
//       debugPrint('ItemSummary load failed: $e');
//       ErrorReporter.report(e, st); // #6
//       state = AsyncValue.error(e, st);
//     }
//   }
// }

// // ── Routing filter ────────────────────────────────────────────
// List<KdsOrder> applyRouting(List<KdsOrder> orders, RoutingState routing) {
//   final result = <KdsOrder>[];
//   for (final order in orders) {
//     if (!routing.isSourceOn(order.source)) continue;
//     final visibleItems =
//         order.items.where((i) => routing.isCategoryOn(i.category)).toList();
//     if (visibleItems.isEmpty) continue;
//     if (visibleItems.length == order.items.length) {
//       result.add(order);
//       continue;
//     }
//     result.add(KdsOrder(
//       id: order.id,
//       orderNumber: order.orderNumber,
//       customerName: order.customerName,
//       type: order.type,
//       source: order.source,
//       placedAt: order.placedAt,
//       items: visibleItems,
//       isCompleted: order.isCompleted,
//       isOnHold: order.isOnHold,
//       holdUntil: order.holdUntil,
//       completedAt: order.completedAt,
//     ));
//   }
//   return result;
// }

// // ── Orders state ──────────────────────────────────────────────
// class OrdersState {
//   final List<KdsOrder> open;
//   final List<KdsOrder> hold;
//   final List<KdsOrder> completed;
//   final bool isLoading;

//   const OrdersState({
//     this.open = const [],
//     this.hold = const [],
//     this.completed = const [],
//     this.isLoading = false,
//   });

//   OrdersState copyWith({
//     List<KdsOrder>? open,
//     List<KdsOrder>? hold,
//     List<KdsOrder>? completed,
//     bool? isLoading,
//   }) =>
//       OrdersState(
//         open: open ?? this.open,
//         hold: hold ?? this.hold,
//         completed: completed ?? this.completed,
//         isLoading: isLoading ?? this.isLoading,
//       );
// }

// class OrdersNotifier extends StateNotifier<OrdersState> {
//   OrdersNotifier(this._ref) : super(const OrdersState()) {
//     loadAll();
//   }

//   final Ref _ref;
//   int _tickCounter = 0;

//   // #4 — overlap guard: ekbar e ekta loadAll
//   bool _isLoadingAll = false;

//   Timer? _summaryDebounce;

//   void _refreshSummary() {
//     _summaryDebounce?.cancel();
//     _summaryDebounce = Timer(const Duration(milliseconds: 300), () {
//       _ref.read(itemSummaryListProvider.notifier).load();
//     });
//   }

//   @override
//   void dispose() {
//     _summaryDebounce?.cancel();
//     super.dispose();
//   }

//   // ── Load all three tabs (parallel) ─────────────────────────
//   Future<void> loadAll() async {
//     if (_isLoadingAll) return; // #4 overlap guard
//     _isLoadingAll = true;
//     state = state.copyWith(isLoading: true);
//     try {
//       final results = await Future.wait([
//         ordersRepository.fetchOrders(OrderTab.open),
//         ordersRepository.fetchOrders(OrderTab.hold),
//         ordersRepository.fetchOrders(OrderTab.completed),
//       ]);
//       state = state.copyWith(
//         open: results[0],
//         hold: results[1],
//         completed: results[2],
//       );
//       _refreshSummary();
//     } catch (e, st) {
//       debugPrint('Orders loadAll failed: $e');
//       ErrorReporter.report(e, st); // #6
//       // keep existing data on failure
//     } finally {
//       _isLoadingAll = false;
//       state = state.copyWith(isLoading: false);
//     }
//   }

//   List<KdsOrder> get openOrders => state.open;
//   List<KdsOrder> get holdOrders => state.hold;
//   List<KdsOrder> get completedOrders => state.completed;
//   bool get isLoading => state.isLoading;

//   // ── Tick — periodic resync (60s) + instant hold expiry ─────
//   void onTick() {
//     _tickCounter++;
//     if (_tickCounter >= 60) {
//       _tickCounter = 0;
//       loadAll();
//     }
//     _checkExpiredHoldsLocal();
//   }

//   void _checkExpiredHoldsLocal() {
//     final now = DateTime.now();
//     final expired = state.hold
//         .where((o) => o.holdUntil != null && now.isAfter(o.holdUntil!))
//         .toList();
//     if (expired.isEmpty) return;

//     final stillHeld = state.hold
//         .where((o) => !(o.holdUntil != null && now.isAfter(o.holdUntil!)))
//         .toList();

//     for (final o in expired) {
//       o.isOnHold = false;
//       o.holdUntil = null;
//     }

//     state = state.copyWith(
//       hold: stillHeld,
//       open: [...state.open, ...expired],
//     );
//     _refreshSummary();

//     for (final o in expired) {
//       ordersRepository.releaseOrder(o.id).catchError((_) => false);
//     }
//   }

//   KdsOrder? _find(String id) {
//     for (final o in [...state.open, ...state.hold, ...state.completed]) {
//       if (o.id == id) return o;
//     }
//     return null;
//   }

//   void _touch() {
//     state = state.copyWith(
//       open: [...state.open],
//       hold: [...state.hold],
//       completed: [...state.completed],
//     );
//   }

//   void _revertToOpen(KdsOrder order) {
//     order.isCompleted = false;
//     order.isOnHold = false;
//     order.holdUntil = null;
//     order.completedAt = null;
//     state = state.copyWith(
//       completed: state.completed.where((o) => o.id != order.id).toList(),
//       hold: state.hold.where((o) => o.id != order.id).toList(),
//       open: [order, ...state.open.where((o) => o.id != order.id)],
//     );
//     _refreshSummary();
//   }

//   // ════════════════════════════════════════════════════════════
//   //  REALTIME (socket) — apply server events to the board
//   // ════════════════════════════════════════════════════════════
//   void applyOrderUpsert(Map<String, dynamic> json) {
//     final order = KdsOrder.fromJson(json);
//     if (order.id.isEmpty) return;
//     _upsertOrder(order);
//     _refreshSummary();
//   }

//   void _upsertOrder(KdsOrder order) {
//     final open = [...state.open];
//     final hold = [...state.hold];
//     final completed = [...state.completed];

//     final iOpen = open.indexWhere((o) => o.id == order.id);
//     final iHold = hold.indexWhere((o) => o.id == order.id);
//     final iComp = completed.indexWhere((o) => o.id == order.id);

//     final toCompleted = order.isCompleted;
//     final toHold = !order.isCompleted && order.isOnHold;

//     if (!toCompleted && !toHold && iOpen != -1) {
//       open[iOpen] = order;
//     } else if (toHold && iHold != -1) {
//       hold[iHold] = order;
//     } else if (toCompleted && iComp != -1) {
//       completed[iComp] = order;
//     } else {
//       if (iOpen != -1) open.removeAt(iOpen);
//       if (iHold != -1) hold.removeAt(iHold);
//       if (iComp != -1) completed.removeAt(iComp);
//       if (toCompleted) {
//         completed.insert(0, order);
//       } else if (toHold) {
//         hold.insert(0, order);
//       } else {
//         open.add(order);
//       }
//     }
//     state = state.copyWith(open: open, hold: hold, completed: completed);
//   }

//   void applyOrderRemoved(Map<String, dynamic> json) {
//     final id = (json['_id'] ?? json['id'] ?? '').toString();
//     if (id.isEmpty) return;
//     state = state.copyWith(
//       open: state.open.where((o) => o.id != id).toList(),
//       hold: state.hold.where((o) => o.id != id).toList(),
//       completed: state.completed.where((o) => o.id != id).toList(),
//     );
//     _refreshSummary();
//   }

//   void applyOrdersCleared(Map<String, dynamic> json) {
//     final clearedAt = DateTime.tryParse('${json['clearedAt'] ?? ''}')?.toLocal();
//     if (clearedAt == null) {
//       state = state.copyWith(completed: const []);
//       _refreshSummary();
//       return;
//     }
//     state = state.copyWith(
//       completed: state.completed.where((o) {
//         final b = o.completedAt;
//         return b != null && b.isAfter(clearedAt);
//       }).toList(),
//     );
//     _refreshSummary();
//   }

//   // ── Item ready toggle — item + ALL its modifiers ───────────
//   Future<void> toggleItemReady(String orderId, int itemIndex) async {
//     final order = _find(orderId);
//     if (order == null || itemIndex >= order.items.length) return;
//     final item = order.items[itemIndex];

//     final prevItemReady = item.isReady;
//     final prevMods = item.modifiers.map((m) => m.isReady).toList();
//     final newReady = !item.isReady;

//     // optimistic: item + all modifiers
//     item.isReady = newReady;
//     for (final mod in item.modifiers) {
//       mod.isReady = newReady;
//     }
//     _touch();

//     // #12 — _id na thakle (custom product) backend call skip, local-only
//     if (order.id.isEmpty || item.id.isEmpty) {
//       debugPrint('toggleItemReady: missing _id — local only');
//       _refreshSummary();
//       return;
//     }

//     try {
//       await ordersRepository.setItemReady(order.id, item.id, newReady);

//       for (final mod in item.modifiers) {
//         if (mod.id.isEmpty) continue; // #12 — skip modifier without _id
//         ordersRepository
//             .setModifierReady(order.id, item.id, mod.id, newReady)
//             .catchError((e) {
//           debugPrint('modifier ready sync failed: $e');
//         });
//       }
//       _refreshSummary();
//     } catch (e, st) {
//       debugPrint('setItemReady failed: $e');
//       ErrorReporter.report(e, st); // #6
//       item.isReady = prevItemReady;
//       for (var k = 0; k < item.modifiers.length; k++) {
//         item.modifiers[k].isReady = prevMods[k];
//       }
//       _touch();
//       _refreshSummary();
//     }
//   }

//   // ── Modifier ready toggle — single modifier ────────────────
//   Future<void> toggleModifierReady(
//     String orderId,
//     int itemIndex,
//     int modIndex,
//   ) async {
//     final order = _find(orderId);
//     if (order == null) return;
//     if (itemIndex >= order.items.length) return;
//     if (modIndex >= order.items[itemIndex].modifiers.length) return;
//     final item = order.items[itemIndex];
//     final mod = item.modifiers[modIndex];

//     final prevReady = mod.isReady;
//     final newReady = !mod.isReady;

//     // optimistic
//     mod.isReady = newReady;
//     _touch();

//     // #12 — _id na thakle local-only
//     if (order.id.isEmpty || item.id.isEmpty || mod.id.isEmpty) {
//       debugPrint('toggleModifierReady: missing _id — local only');
//       return;
//     }

//     try {
//       await ordersRepository.setModifierReady(
//           order.id, item.id, mod.id, newReady);
//     } catch (e) {
//       debugPrint('setModifierReady failed: $e');
//       mod.isReady = prevReady;
//       _touch();
//     }
//   }

//   // ── Bump — open/hold → completed ───────────────────────────
//   Future<void> bump(String id) async {
//     final order = _find(id);
//     if (order == null) return;

//     order.isCompleted = true;
//     order.isOnHold = false;
//     order.completedAt = DateTime.now();
//     state = state.copyWith(
//       open: state.open.where((o) => o.id != id).toList(),
//       hold: state.hold.where((o) => o.id != id).toList(),
//       completed: [order, ...state.completed],
//     );
//     _refreshSummary();

//     try {
//       final ok = await ordersRepository.bumpOrder(id);
//       if (!ok) _revertToOpen(order);
//     } catch (_) {
//       _revertToOpen(order);
//     }
//   }

//   Future<void> undoBump(String id) async {
//     await recall(id);
//   }

//   // ── Recall — completed → open, reset items ─────────────────
//   Future<void> recall(String id) async {
//     final order = _find(id);
//     if (order == null) return;

//     order.isCompleted = false;
//     order.completedAt = null;
//     order.isOnHold = false;
//     for (final item in order.items) {
//       item.isReady = false;
//       for (final mod in item.modifiers) {
//         mod.isReady = false;
//       }
//     }
//     state = state.copyWith(
//       completed: state.completed.where((o) => o.id != id).toList(),
//       open: [order, ...state.open],
//     );
//     _refreshSummary();

//     try {
//       await ordersRepository.recallOrder(id);
//     } catch (e) {
//       debugPrint('recallOrder failed: $e');
//     }
//   }

//   void changeOrderType(String id, OrderType newType) {
//     final order = _find(id);
//     if (order == null) return;
//     order.type = newType;
//     _touch();
//   }

//   // ── Clear all completed orders (backend + local) ───────────
//   Future<void> clearCompleted() async {
//     final prev = state.completed;
//     state = state.copyWith(completed: []); // optimistic
//     try {
//       await ordersRepository.clearCompletedOrders();
//     } catch (e) {
//       debugPrint('clearCompleted failed: $e');
//       state = state.copyWith(completed: prev); // revert
//     }
//   }

//   // ── Hold with timer — open → hold ──────────────────────────
//   Future<void> holdWithTimer(String id, int minutes) async {
//     final order = _find(id);
//     if (order == null) return;

//     final until = DateTime.now().add(Duration(minutes: minutes));
//     order.isOnHold = true;
//     order.holdUntil = until;
//     state = state.copyWith(
//       open: state.open.where((o) => o.id != id).toList(),
//       hold: [order, ...state.hold],
//     );
//     _refreshSummary();

//     try {
//       final ok = await ordersRepository.holdOrder(id, until);
//       if (!ok) _revertToOpen(order);
//     } catch (_) {
//       _revertToOpen(order);
//     }
//   }

//   // ── Release — hold → open ──────────────────────────────────
//   Future<void> release(String id) async {
//     final order = _find(id);
//     if (order == null) return;

//     order.isOnHold = false;
//     order.holdUntil = null;
//     state = state.copyWith(
//       hold: state.hold.where((o) => o.id != id).toList(),
//       open: [order, ...state.open],
//     );
//     _refreshSummary();

//     try {
//       await ordersRepository.releaseOrder(id);
//     } catch (e) {
//       debugPrint('releaseOrder failed: $e');
//     }
//   }

//   // ── Queue ordering (within open) ───────────────────────────
//   void moveToFront(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     list.insert(0, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveForward(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     list.insert(idx - 1, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveBackward(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx < 0 || idx >= list.length - 1) return;
//     list.insert(idx + 1, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveToBack(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx < 0) return;
//     list.add(list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }

//   void moveLeft(String id) {
//     final list = [...state.open];
//     final idx = list.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     list.insert(idx - 1, list.removeAt(idx));
//     state = state.copyWith(open: list);
//   }
// }


















import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yogo_kds/data/repositories/order_repo.dart';
import 'package:yogo_kds/data/models/item_summary.dart';
import 'package:yogo_kds/providers/settings_provider.dart';
import 'package:yogo_kds/shared/services/error_reporter.dart';
import '../data/models/kds_order.dart';
import '../shared/enums/order_enums.dart';

// ── Hold dialog ──────────────────────────────────────────────
final showHoldDialogProvider = StateProvider<bool>((ref) => false);
final holdOrderIdProvider = StateProvider<String>((ref) => '');
final holdModeProvider = StateProvider<int>((ref) => 0);
final holdSelectedMinutesProvider = StateProvider<int>((ref) => 5);

// ── Tick provider — every second: hold check + periodic resync ──
final tickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) {
    ref.read(ordersProvider.notifier).onTick();
    return i;
  });
});

// ── Tab ───────────────────────────────────────────────────────
final kdsTabProvider = StateProvider<KdsTab>((ref) => KdsTab.open);

// ── Drawer ────────────────────────────────────────────────────
final drawerExpandedProvider = StateProvider<bool>((ref) => false);
final showSummaryProvider = StateProvider<bool>((ref) => false);

// ── Action panel ──────────────────────────────────────────────
final selectedOrderIdProvider = StateProvider<String>((ref) => '');
final showActionPanelProvider = StateProvider<bool>((ref) => false);

// ── Recall dialog ─────────────────────────────────────────────
final showRecallDialogProvider = StateProvider<bool>((ref) => false);
final recallPageProvider = StateProvider<int>((ref) => 0);
final expandedRecallIdProvider = StateProvider<String>((ref) => '');

const recallPerPage = 10;

// ── Bump toast ────────────────────────────────────────────────
final lastBumpedOrderProvider = StateProvider<KdsOrder?>((ref) => null);

// ── Orders ────────────────────────────────────────────────────
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref);
});

// ── Item summary (API-backed, AsyncValue) ─────────────────────
final itemSummaryListProvider = StateNotifierProvider<ItemSummaryNotifier,
    AsyncValue<List<ItemSummary>>>((ref) {
  return ItemSummaryNotifier();
});

final itemSummaryProvider = Provider<Map<String, int>>((ref) {
  final async = ref.watch(itemSummaryListProvider);
  final list = async.asData?.value ?? const <ItemSummary>[];
  final summary = <String, int>{};
  for (final it in list) {
    summary[it.name] = it.quantity;
  }
  return summary;
});

class ItemSummaryNotifier
    extends StateNotifier<AsyncValue<List<ItemSummary>>> {
  ItemSummaryNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final items = await ordersRepository.fetchItemSummary();
      state = AsyncValue.data(items);
    } catch (e, st) {
      debugPrint('ItemSummary load failed: $e');
      ErrorReporter.report(e, st); // #6
      state = AsyncValue.error(e, st);
    }
  }
}

// ── Routing filter ────────────────────────────────────────────
List<KdsOrder> applyRouting(List<KdsOrder> orders, RoutingState routing) {
  final result = <KdsOrder>[];
  for (final order in orders) {
    if (!routing.isSourceOn(order.source)) continue;
    final visibleItems =
        order.items.where((i) => routing.isCategoryOn(i.category)).toList();
    if (visibleItems.isEmpty) continue;
    if (visibleItems.length == order.items.length) {
      result.add(order);
      continue;
    }
    result.add(KdsOrder(
      id: order.id,
      orderNumber: order.orderNumber,
      customerName: order.customerName,
      type: order.type,
      source: order.source,
      placedAt: order.placedAt,
      items: visibleItems,
      isCompleted: order.isCompleted,
      isOnHold: order.isOnHold,
      holdUntil: order.holdUntil,
      completedAt: order.completedAt,
    ));
  }
  return result;
}

// ── Orders state ──────────────────────────────────────────────
class OrdersState {
  final List<KdsOrder> open;
  final List<KdsOrder> hold;
  final List<KdsOrder> completed;
  final bool isLoading;

  const OrdersState({
    this.open = const [],
    this.hold = const [],
    this.completed = const [],
    this.isLoading = false,
  });

  OrdersState copyWith({
    List<KdsOrder>? open,
    List<KdsOrder>? hold,
    List<KdsOrder>? completed,
    bool? isLoading,
  }) =>
      OrdersState(
        open: open ?? this.open,
        hold: hold ?? this.hold,
        completed: completed ?? this.completed,
        isLoading: isLoading ?? this.isLoading,
      );
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  OrdersNotifier(this._ref) : super(const OrdersState()) {
    loadAll();
  }

  final Ref _ref;
  int _tickCounter = 0;

  // #4 — overlap guard: ekbar e ekta loadAll
  bool _isLoadingAll = false;

  Timer? _summaryDebounce;

  void _refreshSummary() {
    _summaryDebounce?.cancel();
    _summaryDebounce = Timer(const Duration(milliseconds: 300), () {
      _ref.read(itemSummaryListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _summaryDebounce?.cancel();
    super.dispose();
  }

  // ── Storage Recall Time — keep only completed orders within window ──
  // completedAt (= bumpedAt) ar General settings er storageRecallMinutes
  // diye: window-er cheye purono completed order baad.
  List<KdsOrder> _withinRecallWindow(List<KdsOrder> completed) {
    final minutes = _ref.read(generalSettingsProvider).storageRecallMinutes;
    if (minutes <= 0) return completed; // 0/unset hole filter na
    final cutoff = DateTime.now().subtract(Duration(minutes: minutes));
    return completed.where((o) {
      final c = o.completedAt;
      return c == null || c.isAfter(cutoff); // recent gula rakho
    }).toList();
  }

  // ── Load all three tabs (parallel) ─────────────────────────
  Future<void> loadAll() async {
    if (_isLoadingAll) return; // #4 overlap guard
    _isLoadingAll = true;
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        ordersRepository.fetchOrders(OrderTab.open),
        ordersRepository.fetchOrders(OrderTab.hold),
        ordersRepository.fetchOrders(OrderTab.completed),
      ]);
      state = state.copyWith(
        open: results[0],
        hold: results[1],
        completed: _withinRecallWindow(results[2]), // recall window filter
      );
      _refreshSummary();
    } catch (e, st) {
      debugPrint('Orders loadAll failed: $e');
      ErrorReporter.report(e, st); // #6
      // keep existing data on failure
    } finally {
      _isLoadingAll = false;
      state = state.copyWith(isLoading: false);
    }
  }

  List<KdsOrder> get openOrders => state.open;
  List<KdsOrder> get holdOrders => state.hold;
  List<KdsOrder> get completedOrders => state.completed;
  bool get isLoading => state.isLoading;

  // ── Tick — periodic resync (60s) + instant hold/recall expiry ──
  void onTick() {
    _tickCounter++;
    if (_tickCounter >= 60) {
      _tickCounter = 0;
      loadAll();
    }
    _checkExpiredHoldsLocal();
    _checkExpiredRecallsLocal();
  }

  void _checkExpiredHoldsLocal() {
    final now = DateTime.now();
    final expired = state.hold
        .where((o) => o.holdUntil != null && now.isAfter(o.holdUntil!))
        .toList();
    if (expired.isEmpty) return;

    final stillHeld = state.hold
        .where((o) => !(o.holdUntil != null && now.isAfter(o.holdUntil!)))
        .toList();

    for (final o in expired) {
      o.isOnHold = false;
      o.holdUntil = null;
    }

    state = state.copyWith(
      hold: stillHeld,
      open: [...state.open, ...expired],
    );
    _refreshSummary();

    for (final o in expired) {
      ordersRepository.releaseOrder(o.id).catchError((_) => false);
    }
  }

  // Storage Recall Time pouroho hole completed/recall list theke auto baad
  void _checkExpiredRecallsLocal() {
    if (state.completed.isEmpty) return;
    final kept = _withinRecallWindow(state.completed);
    if (kept.length != state.completed.length) {
      state = state.copyWith(completed: kept);
    }
  }

  KdsOrder? _find(String id) {
    for (final o in [...state.open, ...state.hold, ...state.completed]) {
      if (o.id == id) return o;
    }
    return null;
  }

  void _touch() {
    state = state.copyWith(
      open: [...state.open],
      hold: [...state.hold],
      completed: [...state.completed],
    );
  }

  void _revertToOpen(KdsOrder order) {
    order.isCompleted = false;
    order.isOnHold = false;
    order.holdUntil = null;
    order.completedAt = null;
    state = state.copyWith(
      completed: state.completed.where((o) => o.id != order.id).toList(),
      hold: state.hold.where((o) => o.id != order.id).toList(),
      open: [order, ...state.open.where((o) => o.id != order.id)],
    );
    _refreshSummary();
  }

  // ════════════════════════════════════════════════════════════
  //  REALTIME (socket) — apply server events to the board
  // ════════════════════════════════════════════════════════════
  void applyOrderUpsert(Map<String, dynamic> json) {
    final order = KdsOrder.fromJson(json);
    if (order.id.isEmpty) return;
    _upsertOrder(order);
    _refreshSummary();
  }

  void _upsertOrder(KdsOrder order) {
    final open = [...state.open];
    final hold = [...state.hold];
    final completed = [...state.completed];

    final iOpen = open.indexWhere((o) => o.id == order.id);
    final iHold = hold.indexWhere((o) => o.id == order.id);
    final iComp = completed.indexWhere((o) => o.id == order.id);

    final toCompleted = order.isCompleted;
    final toHold = !order.isCompleted && order.isOnHold;

    if (!toCompleted && !toHold && iOpen != -1) {
      open[iOpen] = order;
    } else if (toHold && iHold != -1) {
      hold[iHold] = order;
    } else if (toCompleted && iComp != -1) {
      completed[iComp] = order;
    } else {
      if (iOpen != -1) open.removeAt(iOpen);
      if (iHold != -1) hold.removeAt(iHold);
      if (iComp != -1) completed.removeAt(iComp);
      if (toCompleted) {
        completed.insert(0, order);
      } else if (toHold) {
        hold.insert(0, order);
      } else {
        open.add(order);
      }
    }
    state = state.copyWith(open: open, hold: hold, completed: completed);
  }

  void applyOrderRemoved(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    if (id.isEmpty) return;
    state = state.copyWith(
      open: state.open.where((o) => o.id != id).toList(),
      hold: state.hold.where((o) => o.id != id).toList(),
      completed: state.completed.where((o) => o.id != id).toList(),
    );
    _refreshSummary();
  }

  void applyOrdersCleared(Map<String, dynamic> json) {
    final clearedAt = DateTime.tryParse('${json['clearedAt'] ?? ''}')?.toLocal();
    if (clearedAt == null) {
      state = state.copyWith(completed: const []);
      _refreshSummary();
      return;
    }
    state = state.copyWith(
      completed: state.completed.where((o) {
        final b = o.completedAt;
        return b != null && b.isAfter(clearedAt);
      }).toList(),
    );
    _refreshSummary();
  }

  // ── Item ready toggle — item + ALL its modifiers ───────────
  Future<void> toggleItemReady(String orderId, int itemIndex) async {
    final order = _find(orderId);
    if (order == null || itemIndex >= order.items.length) return;
    final item = order.items[itemIndex];

    final prevItemReady = item.isReady;
    final prevMods = item.modifiers.map((m) => m.isReady).toList();
    final newReady = !item.isReady;

    // optimistic: item + all modifiers
    item.isReady = newReady;
    for (final mod in item.modifiers) {
      mod.isReady = newReady;
    }
    _touch();

    // #12 — _id na thakle (custom product) backend call skip, local-only
    if (order.id.isEmpty || item.id.isEmpty) {
      debugPrint('toggleItemReady: missing _id — local only');
      _refreshSummary();
      return;
    }

    try {
      await ordersRepository.setItemReady(order.id, item.id, newReady);

      for (final mod in item.modifiers) {
        if (mod.id.isEmpty) continue; // #12 — skip modifier without _id
        ordersRepository
            .setModifierReady(order.id, item.id, mod.id, newReady)
            .catchError((e) {
          debugPrint('modifier ready sync failed: $e');
        });
      }
      _refreshSummary();
    } catch (e, st) {
      debugPrint('setItemReady failed: $e');
      ErrorReporter.report(e, st); // #6
      item.isReady = prevItemReady;
      for (var k = 0; k < item.modifiers.length; k++) {
        item.modifiers[k].isReady = prevMods[k];
      }
      _touch();
      _refreshSummary();
    }
  }

  // // ── Modifier ready toggle — single modifier ────────────────
  // Future<void> toggleModifierReady(
  //   String orderId,
  //   int itemIndex,
  //   int modIndex,
  // ) async {
  //   final order = _find(orderId);
  //   if (order == null) return;
  //   if (itemIndex >= order.items.length) return;
  //   if (modIndex >= order.items[itemIndex].modifiers.length) return;
  //   final item = order.items[itemIndex];
  //   final mod = item.modifiers[modIndex];

  //   final prevReady = mod.isReady;
  //   final newReady = !mod.isReady;

  //   // optimistic
  //   mod.isReady = newReady;
  //   _touch();

  //   // #12 — _id na thakle local-only
  //   if (order.id.isEmpty || item.id.isEmpty || mod.id.isEmpty) {
  //     debugPrint('toggleModifierReady: missing _id — local only');
  //     return;
  //   }

  //   try {
  //     await ordersRepository.setModifierReady(
  //         order.id, item.id, mod.id, newReady);
  //   } catch (e) {
  //     debugPrint('setModifierReady failed: $e');
  //     mod.isReady = prevReady;
  //     _touch();
  //   }
  // }

  // ── Bump — open/hold → completed ───────────────────────────
  Future<void> bump(String id) async {
    final order = _find(id);
    if (order == null) return;

    order.isCompleted = true;
    order.isOnHold = false;
    order.completedAt = DateTime.now();
    state = state.copyWith(
      open: state.open.where((o) => o.id != id).toList(),
      hold: state.hold.where((o) => o.id != id).toList(),
      completed: [order, ...state.completed],
    );
    _refreshSummary();

    try {
      final ok = await ordersRepository.bumpOrder(id);
      if (!ok) _revertToOpen(order);
    } catch (_) {
      _revertToOpen(order);
    }
  }

  Future<void> undoBump(String id) async {
    await recall(id);
  }

  // ── Recall — completed → open, reset items ─────────────────
  Future<void> recall(String id) async {
    final order = _find(id);
    if (order == null) return;

    order.isCompleted = false;
    order.completedAt = null;
    order.isOnHold = false;
    for (final item in order.items) {
      item.isReady = false;
      for (final mod in item.modifiers) {
        mod.isReady = false;
      }
    }
    state = state.copyWith(
      completed: state.completed.where((o) => o.id != id).toList(),
      open: [order, ...state.open],
    );
    _refreshSummary();

    try {
      await ordersRepository.recallOrder(id);
    } catch (e) {
      debugPrint('recallOrder failed: $e');
    }
  }

  void changeOrderType(String id, OrderType newType) {
    final order = _find(id);
    if (order == null) return;
    order.type = newType;
    _touch();
  }

  // ── Clear all completed orders (backend + local) ───────────
  Future<void> clearCompleted() async {
    final prev = state.completed;
    state = state.copyWith(completed: []); // optimistic
    try {
      await ordersRepository.clearCompletedOrders();
    } catch (e) {
      debugPrint('clearCompleted failed: $e');
      state = state.copyWith(completed: prev); // revert
    }
  }

  // ── Hold with timer — open → hold ──────────────────────────
  Future<void> holdWithTimer(String id, int minutes) async {
    final order = _find(id);
    if (order == null) return;

    final until = DateTime.now().add(Duration(minutes: minutes));
    order.isOnHold = true;
    order.holdUntil = until;
    state = state.copyWith(
      open: state.open.where((o) => o.id != id).toList(),
      hold: [order, ...state.hold],
    );
    _refreshSummary();

    try {
      final ok = await ordersRepository.holdOrder(id, until);
      if (!ok) _revertToOpen(order);
    } catch (_) {
      _revertToOpen(order);
    }
  }

  // ── Release — hold → open ──────────────────────────────────
  Future<void> release(String id) async {
    final order = _find(id);
    if (order == null) return;

    order.isOnHold = false;
    order.holdUntil = null;
    state = state.copyWith(
      hold: state.hold.where((o) => o.id != id).toList(),
      open: [order, ...state.open],
    );
    _refreshSummary();

    try {
      await ordersRepository.releaseOrder(id);
    } catch (e) {
      debugPrint('releaseOrder failed: $e');
    }
  }

  // ── Queue ordering (within open) ───────────────────────────
  void moveToFront(String id) {
    final list = [...state.open];
    final idx = list.indexWhere((o) => o.id == id);
    if (idx <= 0) return;
    list.insert(0, list.removeAt(idx));
    state = state.copyWith(open: list);
  }

  void moveForward(String id) {
    final list = [...state.open];
    final idx = list.indexWhere((o) => o.id == id);
    if (idx <= 0) return;
    list.insert(idx - 1, list.removeAt(idx));
    state = state.copyWith(open: list);
  }

  void moveBackward(String id) {
    final list = [...state.open];
    final idx = list.indexWhere((o) => o.id == id);
    if (idx < 0 || idx >= list.length - 1) return;
    list.insert(idx + 1, list.removeAt(idx));
    state = state.copyWith(open: list);
  }

  void moveToBack(String id) {
    final list = [...state.open];
    final idx = list.indexWhere((o) => o.id == id);
    if (idx < 0) return;
    list.add(list.removeAt(idx));
    state = state.copyWith(open: list);
  }

  void moveLeft(String id) {
    final list = [...state.open];
    final idx = list.indexWhere((o) => o.id == id);
    if (idx <= 0) return;
    list.insert(idx - 1, list.removeAt(idx));
    state = state.copyWith(open: list);
  }
}