// // import 'package:get/get.dart';
// // import '../../../routes/app_routes.dart';
// // import '../../../services/theme_service.dart';

// // class HomeController extends GetxController {
// //   // Quick alias — avoids importing ThemeService everywhere in the view
// //   ThemeService get theme => ThemeService.to;

// //   void goToKds()      => Get.toNamed(AppRoutes.kds);
// //   void goToOrders()   => Get.toNamed(AppRoutes.orders);
// //   void goToSettings() => Get.toNamed(AppRoutes.settings);
// // }
// import 'dart:async';
// import 'package:get/get.dart';
// import '../../../data/models/kds_order.dart';
// import '../../../services/theme_service.dart';
// import '../../../shared/enums/order_enums.dart';
 
// class HomeController extends GetxController {
//   ThemeService get theme => ThemeService.to;
 
//   // ── Tab ──────────────────────────────────────────────────────────────────
//   final activeTab = KdsTab.open.obs;
 
//   void setTab(KdsTab tab) => activeTab.value = tab;
 
//   // ── Orders ────────────────────────────────────────────────────────────────
//   final RxList<KdsOrder> orders = <KdsOrder>[].obs;
 
//   List<KdsOrder> get openOrders      => orders.where((o) => !o.isCompleted && !o.isOnHold).toList();
//   List<KdsOrder> get completedOrders => orders.where((o) => o.isCompleted).toList();
//   List<KdsOrder> get holdOrders      => orders.where((o) => o.isOnHold && !o.isCompleted).toList();
 
//   int get openCount => openOrders.length;
 
//   // ── Ticker (forces elapsed timer to refresh every second) ─────────────────
//   final tick = 0.obs;
//   Timer? _timer;
 
//   // ── Action panel ─────────────────────────────────────────────────────────
//   final selectedOrderId = ''.obs;
//   final showActionPanel = false.obs;
 
//   KdsOrder? get selectedOrder =>
//       orders.firstWhereOrNull((o) => o.id == selectedOrderId.value);
 
//   void openActionPanel(String orderId) {
//     selectedOrderId.value = orderId;
//     showActionPanel.value = true;
//   }
 
//   void closeActionPanel() {
//     showActionPanel.value = false;
//     selectedOrderId.value = '';
//   }
//   // ── Drawer ────────────────────────────────────────────────────────────────
// final drawerExpanded = false.obs;
// void toggleDrawer() => drawerExpanded.value = !drawerExpanded.value;
 
//   // ── Order actions ─────────────────────────────────────────────────────────
//   void bumpOrder(String id) {
//     final idx = orders.indexWhere((o) => o.id == id);
//     if (idx == -1) return;
//     orders[idx].isCompleted = true;
//     orders.refresh();
//     closeActionPanel();
//   }
 
//   void holdOrder(String id) {
//     final idx = orders.indexWhere((o) => o.id == id);
//     if (idx == -1) return;
//     orders[idx].isOnHold = !orders[idx].isOnHold;
//     orders.refresh();
//     closeActionPanel();
//   }
 
//   void moveToFront(String id) {
//     final idx = orders.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     final order = orders.removeAt(idx);
//     orders.insert(0, order);
//     closeActionPanel();
//   }
 
//   void moveForward(String id) {
//     final idx = orders.indexWhere((o) => o.id == id);
//     if (idx <= 0) return;
//     final order = orders.removeAt(idx);
//     orders.insert(idx - 1, order);
//     closeActionPanel();
//   }
 
//   void moveBackward(String id) {
//     final idx = orders.indexWhere((o) => o.id == id);
//     if (idx == -1 || idx >= orders.length - 1) return;
//     final order = orders.removeAt(idx);
//     orders.insert(idx + 1, order);
//     closeActionPanel();
//   }
 
//   void moveToBack(String id) {
//     final idx = orders.indexWhere((o) => o.id == id);
//     if (idx == -1) return;
//     final order = orders.removeAt(idx);
//     orders.add(order);
//     closeActionPanel();
//   }
 
//   // ── Lifecycle ─────────────────────────────────────────────────────────────
//   @override
//   void onInit() {
//     super.onInit();
//     _loadMockOrders();
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick.value++);
//   }
 
//   @override
//   void onClose() {
//     _timer?.cancel();
//     super.onClose();
//   }
 
//   void _loadMockOrders() {
//     final now = DateTime.now();
//     orders.assignAll([
//       KdsOrder(
//         id: '1',
//         customerName: 'Alex',
//         type: OrderType.forHere,
//         placedAt: now.subtract(const Duration(seconds: 30)),
//         items: [
//           KdsOrderItem(name: 'Croissant', qty: 1, modifiers: ['Warm']),
//           KdsOrderItem(name: 'Tissana', qty: 1, modifiers: ['Red Fruits']),
//         ],
//       ),
//       KdsOrder(
//         id: '2',
//         customerName: 'Tim',
//         type: OrderType.toGo,
//         placedAt: now.subtract(const Duration(minutes: 4, seconds: 22)),
//         items: [
//           KdsOrderItem(name: 'Double Bacon', qty: 2, modifiers: ['Medium']),
//           KdsOrderItem(name: 'French Fries', qty: 2),
//         ],
//       ),
//       KdsOrder(
//         id: '3',
//         customerName: 'Sara',
//         type: OrderType.pickup,
//         placedAt: now.subtract(const Duration(minutes: 9, seconds: 5)),
//         items: [
//           KdsOrderItem(name: 'Mac & Cheese', qty: 1),
//           KdsOrderItem(name: 'French Fries', qty: 1),
//         ],
//       ),
//       KdsOrder(
//         id: '4',
//         customerName: 'Layla',
//         type: OrderType.delivery,
//         placedAt: now.subtract(const Duration(minutes: 4, seconds: 13)),
//         items: [
//           KdsOrderItem(name: 'Double Bacon', qty: 1, modifiers: ['Well Done', 'Ketchup', 'Onion', 'Mustard', 'Tomato']),
//           KdsOrderItem(name: 'French Fries', qty: 1),
//         ],
//       ),
//     ]);
//   }
// }