// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:toastification/toastification.dart';
// import 'package:yogo_pos/app/helper/app_helper.dart';
// import 'package:yogo_pos/app/helper/data_update_helper.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/pos/delivery/controllers/delivery_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_table_reservation_print_receipt.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
// import 'package:yogo_pos/app/modules/pos/onlineOrder/controllers/online_order_controller.dart';
// import 'package:yogo_pos/app/modules/pos/tableReservations/models/table_reservations_model.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
// import 'package:yogo_pos/app/modules/setting/repo/incoming_call_dialog.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/utils/logger.dart';
// import 'package:yogo_pos/app/utils/print_utils.dart';
// import 'package:yogo_pos/app/utils/urls.dart';
// import 'package:yogo_pos/app/widgets/moneris_dialog.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import 'package:yogo_pos/app/widgets/search_check_dialog.dart';

// import '../../modules/pos/order/models/order_model.dart';

// enum SocketEvent {
//   tableBooking('tableBooking'),
//   onlineOrderPlaced('onlineOrderPlaced'),
//   deliveryOrderPlaced('deliveryOrderPlaced'),
//   deviceDisconnect('deviceDisconnect'),
//   monerisPayment('monerisPayment'),
//   callBroadcast('callBroadcast');

//   final String value;
//   const SocketEvent(this.value);
// }

// class SocketController extends GetxController {
//   IO.Socket? _socket;

//   void connect() {
//     HttpOverrides.global = MyHttpOverrides();
//     _socket = IO.io(URLS.socketServer, <String, dynamic>{
//       "transports": ["websocket"],
//       "autoConnect": false,
//     });

//     _socket!.connect();

//     _socket!.onConnect((_) {
//       BaseController.to.onChangeSocketConnection(true);
//       _socket?.emit("register", {
//         "userId": BaseController.to.restaurantDetails?.id ?? "",
//         "stationId": Preferences.stationId,
//       });
//       if (kDebugMode) {
//         kLogger.i("✅ Connected to Socket.IO Server:${_socket?.id}");
//         kLogger.i("Restaurant: ${BaseController.to.restaurantDetails?.id}");
//         kLogger.i("Station: ${Preferences.stationId}");
//       }
//     });
//     // tableBooking Event
//     _socket!.on("tableBooking", (data) async {
//       if (kDebugMode) {
//         kLogger.i("tableBooking Placed: $data");
//       }

//       dynamic tableBookingData;
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         tableBookingData = data[0];
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       } else {
//         tableBookingData = data;
//       }

//       try {
//         // Parse order
//         Reservations reservationData = Reservations.fromJson(tableBookingData);

//         // Notification Sound
//         if (Preferences.isNotificationSound) {
//           BaseController.to.playNotificationSound();
//         }

//         // Show notification
//         toastification.show(
//           title: const Text("Table Reservation Received", maxLines: 1),
//           description: Text(
//             "Reservation Id #${reservationData.tableBookId}",
//             maxLines: 4,
//           ),
//           type: ToastificationType.info,
//           autoCloseDuration: const Duration(seconds: 5),
//         );

//         // Todo : add toggle btn
//         // if (Preferences.isOloPrint) {

//         // }
//         await _reservationDataPrint(reservationData);
//         // Send SUCCESS callback to backend
//         callback?.call({"status": "SUCCESS"});

//         if (kDebugMode) {
//           kLogger.i(
//             "✅ Table Reservation Sent SUCCESS acknowledgment#${reservationData.tableBookId}",
//           );
//         }
//       } catch (e) {
//         PopupDialog.showErrorMessage(
//           "Table Reservation data format is not correct",
//         );
//         if (kDebugMode) {
//           kLogger.e('Error from %%%% Table Reservation data format %%%%=> $e');
//         }

//         // Send ERROR callback to backend
//         callback?.call({"status": "ERROR", "message": e.toString()});

//         if (kDebugMode) {
//           kLogger.e("❌ Sent ERROR acknowledgment for online order");
//         }
//       }
//     });

//     // Online Order Event
//     _socket!.on("onlineOrderPlaced", (data) {
//       if (kDebugMode) {
//         kLogger.i("Online Order Placed: $data");
//       }

//       dynamic orderData;
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         orderData = data[0];
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       } else {
//         orderData = data;
//       }

//       try {
//         // Parse order
//         OrderModel order = OrderModel.fromJson(orderData);

//         // Notification Sound
//         if (Preferences.isNotificationSound) {
//           BaseController.to.playNotificationSound();
//         }

//         // Show notification
//         toastification.show(
//           title: const Text("Online Order Received", maxLines: 1),
//           description: Text(
//             "Order #${order.orderId} - Amount: \$${order.totalOrderAmount.toStringAsFixed(2)}",
//             maxLines: 4,
//           ),
//           type: ToastificationType.info,
//           autoCloseDuration: const Duration(seconds: 5),
//         );

//         // Print the order
//         if (Preferences.isOloPrint) {
//           kitchenPrint(order);
//         }
//         if (Preferences.oloCustomerReceipt) {
//           var printData = escOrderPrintReceipt(order: order);
//           PrintUtils().directPrint(
//             data: printData,
//             printerName: Preferences.counterPrinter,
//           );
//         }

//         // Get orders
//         if (Get.currentRoute != '/auth') {
//           OnlineOrderController.to.getOrders();
//         }

//         // Send SUCCESS callback to backend
//         callback?.call({"status": "SUCCESS"});

//         if (kDebugMode) {
//           kLogger.i(
//             "✅ Sent SUCCESS acknowledgment for online order #${order.orderId}",
//           );
//         }
//       } catch (e) {
//         PopupDialog.showErrorMessage("OLO data format is not correct");
//         if (kDebugMode) {
//           kLogger.e('Error from %%%% online order data format %%%% => $e');
//         }

//         // Send ERROR callback to backend
//         callback?.call({"status": "ERROR", "message": e.toString()});

//         if (kDebugMode) {
//           kLogger.e("❌ Sent ERROR acknowledgment for online order");
//         }
//       }
//     });

//     // Delivery Order Event
//     _socket!.on("deliveryOrderPlaced", (data) {
//       if (kDebugMode) {
//         kLogger.i("Delivery Order Placed: $data");
//       }

//       dynamic orderData;
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         orderData = data[0];
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       } else {
//         orderData = data;
//       }

//       try {
//         // Parse order
//         OrderModel order = OrderModel.fromJson(orderData);

//         // Notification Sound
//         if (Preferences.isNotificationSound) {
//           BaseController.to.playNotificationSound();
//         }

//         // Show notification
//         toastification.show(
//           title: const Text("Delivery Order Received", maxLines: 1),
//           description: Text(
//             "Order #${order.orderId} - Amount: \$${order.totalOrderAmount.toStringAsFixed(2)}",
//             maxLines: 4,
//           ),
//           type: ToastificationType.info,
//           autoCloseDuration: const Duration(seconds: 5),
//         );

//         // kitchen Print
//         if (Preferences.isDeliveryOrderPrint) {
//           kitchenPrint(order);
//         }
//         // Customer Receipt

//         if (Preferences.deliveryCustomerReceipt) {
//           var printData = escOrderPrintReceipt(order: order);
//           PrintUtils().directPrint(
//             data: printData,
//             printerName: Preferences.counterPrinter,
//           );
//         }

//         // Get orders
//         if (Get.currentRoute != '/auth') {
//           DeliveryController.to.getOrders();
//         }

//         // Send SUCCESS callback to backend
//         callback?.call({"status": "SUCCESS"});

//         if (kDebugMode) {
//           kLogger.i(
//             "✅ Sent SUCCESS acknowledgment for delivery order #${order.orderId}",
//           );
//         }
//       } catch (e) {
//         PopupDialog.showErrorMessage("Delivery data format is not correct");
//         if (kDebugMode) {
//           kLogger.e('Error from %%%% Delivery order data format %%%% => $e');
//         }

//         // Send ERROR callback to backend
//         callback?.call({"status": "ERROR", "message": e.toString()});

//         if (kDebugMode) {
//           kLogger.e("❌ Sent ERROR acknowledgment for delivery order");
//         }
//       }
//     });

//     // Device Disconnect Event
//     _socket!.on("deviceDisconnect", (data) {
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       }

//       if (kDebugMode) {
//         kLogger.w("⚠️ Device disconnect event received");
//       }

//       // Send SUCCESS callback before exiting
//       callback?.call({"status": "SUCCESS"});

//       AppHelper.exitApp();
//     });

//     // Moneris Payment Event
//     _socket!.on("monerisPayment", (data) {
//       dynamic paymentData;
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         paymentData = data[0];
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       } else {
//         paymentData = data;
//       }

//       try {
//         String status = paymentData['status'] ?? 'unknown';
//         String message = paymentData['message'] ?? 'unknown';
//         OrderModel? order = paymentData['order'] != null
//             ? OrderModel.fromJson(paymentData['order'])
//             : null;
//         debugPrint('Moneris payment status: $status');
//         if (order != null) {
//           debugPrint(
//             "Moneris Payment - Order status : ${order.orderStatus}, Amount: ${order.totalOrderAmount}",
//           );
//         } else {
//           debugPrint("Moneris Payment - No order data received.");
//         }
//         if (status == 'processing') {
//           debugPrint('Moneris payment is processing...');

//           // PopupDialog.showLoadingDialog();
//         } else if (status == 'success') {
//           PosController.to.clearCartList();
//           Get.back();
//           monerisDialog(
//             status: PurchaseDialogStatus.success,
//             message: message,
//             order: order,
//           );
//         } else if (status == 'failed') {
//           PosController.to.myOrder.payment = null;
//           Get.back();
//           monerisDialog(status: PurchaseDialogStatus.error, message: message);
//         } else if (status == 'error') {
//           PosController.to.myOrder.payment = null;
//           Get.back();
//           monerisDialog(status: PurchaseDialogStatus.error, message: message);
//         } else {
//           PosController.to.myOrder.payment = null;
//           Get.back();
//           monerisDialog(status: PurchaseDialogStatus.error, message: message);
//         }

//         if (Get.currentRoute != '/auth') {
//           DataUpdateHelper.getDataByCheckType(type: order?.orderType);
//         }

//         debugPrint("Moneris Payment Update: $paymentData");

//         // Send SUCCESS callback to backend
//         callback?.call({"status": "SUCCESS"});

//         if (kDebugMode) {
//           kLogger.i("✅ Sent SUCCESS acknowledgment for Moneris payment");
//         }
//       } catch (e) {
//         if (kDebugMode) {
//           kLogger.e('Error processing Moneris payment: $e');
//         }

//         // Send ERROR callback to backend
//         callback?.call({"status": "ERROR", "message": e.toString()});

//         if (kDebugMode) {
//           kLogger.e("❌ Sent ERROR acknowledgment for Moneris payment");
//         }
//       }
//     });

//     // callBroadcast Event
//     _socket!.on("callBroadcast", (data) {
//       if (kDebugMode) {
//         kLogger.e("Caller id data: $data");
//       }

//       final callerData = CallerIdData.fromJson(data);
//       if (Get.currentRoute == "/auth" || Get.currentRoute == "/login") {
//         // showDialog(
//         //   context: Get.context!,
//         //   barrierDismissible: true,
//         //   builder: (_) => CallerInfoDialog(callerData: callerData),
//         // );
//       } else {
//         if (Get.isRegistered<PosController>()) {
          
         
//         } else {
//           debugPrint(
//             '[CallerID] PosController not ready — skipping guest assign',
//           );
//         }
//       }
//     });
    
    
//     _socket!.onDisconnect((_) {
//       BaseController.to.onChangeSocketConnection(false);
//       kLogger.e("❌ Disconnected from Server");
//     });

//     _socket!.onError((err) {
//       BaseController.to.onChangeSocketConnection(false);
//       kLogger.e("Error: $err");
//     });
//   }

//   void disconnect() {
//     try {
//       _socket?.disconnect();
//       _socket?.close();
//       BaseController.to.onChangeSocketConnection(false);
//       kLogger.i("🛑 Disconnected from Socket.IO Server");
//     } catch (e, stack) {
//       BaseController.to.onChangeSocketConnection(false);
//       kLogger.e("❌ Error during socket disconnect: $e\n$stack");
//     }
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     connect();
//   }

//   @override
//   void onClose() {
//     disconnect();
//     super.onClose();
//   }
// }

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     final client = super.createHttpClient(context);
//     client.badCertificateCallback =
//         (X509Certificate cert, String host, int port) => true;
//     return client;
//   }
// }

// Future _reservationDataPrint(Reservations reservationData) async {
//   // todo:print
//   var printData = escTableReservationReceipt(data: reservationData);
//   PrintUtils().directPrint(
//     data: printData,
//     printerName: Preferences.kitchenPrinter,
//   );
// }



// import 'package:flutter/foundation.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;
// import 'package:yogo_kds/core/constants/urls.dart';
// import 'package:yogo_kds/core/storage/preferences.dart';

// /// KDS app er Socket.IO connection ek jaygay.
// /// SHUDHU connection + register ekhane. Event pore add korbe —
// /// niche "ADD YOUR EVENTS HERE" section e, ba [on] diye.
// class SocketService {
//   SocketService._();
//   static final SocketService instance = SocketService._();

//   io.Socket? _socket;

//   final ValueNotifier<bool> connected = ValueNotifier<bool>(false);

//   bool get isConnected => _socket?.connected ?? false;

//   // ── Connect + register ─────────────────────────────────────
//   void connect() {
//     if (_socket != null) {
//       _log('socket already created → reconnect');
//       _socket!.connect();
//       return;
//     }

//     _log('connecting to ${Urls.socketServer} ...');

//     _socket = io.io(
//       Urls.socketServer,
//       io.OptionBuilder()
//           // ngrok (r onek proxy) websocket-only te upgrade dei na —
//           // polling diye handshake kore tারpor websocket e upgrade hoy
//           .setTransports(['polling', 'websocket'])
//           // ngrok free er browser-warning page bypass (critical for ngrok)
//           .setExtraHeaders({'ngrok-skip-browser-warning': 'true'})
//           .disableAutoConnect()
//           .enableReconnection()
//           .setReconnectionAttempts(9999)
//           .setReconnectionDelay(2000)
//           .setReconnectionDelayMax(10000)
//           .build(),
//     );

//     _socket!.onConnect((_) {
//       connected.value = true;
//       _log('✅ CONNECTED   (id: ${_socket?.id})');
//       _register();
//     });

//     _socket!.onDisconnect((_) {
//       connected.value = false;
//       _log('❌ DISCONNECTED');
//     });

//     _socket!.onConnectError((e) => _log('⚠️ CONNECT ERROR: $e'));
//     _socket!.onError((e) => _log('⚠️ ERROR: $e'));

//     // ════════════════════════════════════════════════════════════
//     //  👇  ADD YOUR EVENTS HERE  (pore event add korbe ekhane)
//     //
//     //  _socket!.on('kds:order:new', (data) {
//     //    _log('event kds:order:new → $data');
//     //  });
//     //
//     // ════════════════════════════════════════════════════════════

//     _socket!.connect();
//   }

//   // backend ke janai ke connect holo (registration)
//   void _register() {
//     final userId = Preferences.userId;
//     final stationId = Preferences.stationId;
//     _socket?.emit('register', {
//       'userId': userId,
//       'stationId': stationId,
//     });
//     _log('📤 register → userId: $userId   stationId: $stationId');
//   }

//   // ── Pore event add / send korar helper ─────────────────────
//   void on(String event, void Function(dynamic data) handler) {
    
//     _socket?.on(event, handler);
//     _log('👂 listening for "$event"');
//   }

//   void emit(String event, [dynamic data]) {
//     _socket?.emit(event, data);
//     _log('📤 emit "$event" → $data');
//   }

//   void disconnect() {
//     try {
//       _socket?.disconnect();
//       _socket?.close();
//       connected.value = false;
//       _log('🛑 disconnected (manual)');
//     } catch (e) {
//       _log('❌ disconnect error: $e');
//     }
//   }

//   void _log(String msg) => debugPrint('[SOCKET] $msg');
// }



import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:yogo_kds/core/constants/urls.dart';
import 'package:yogo_kds/core/storage/preferences.dart';

/// KDS realtime socket — connection, register, and the 5 KDS events.
/// This class only forwards frames; orders logic lives in KdsRealtime.
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;
  bool _handlersBound = false;

  final ValueNotifier<bool> connected = ValueNotifier<bool>(false);
  bool get isConnected => _socket?.connected ?? false;

  // ── Callbacks (set once from KdsRealtime) ───────────────────
  void Function(Map<String, dynamic> order)? onOrderCreated;
  void Function(Map<String, dynamic> order)? onOrderUpdated;
  void Function(Map<String, dynamic> data)? onOrderRemoved;
  void Function(Map<String, dynamic> data)? onOrdersCleared;
  void Function(Map<String, dynamic> data)? onDeviceUnpaired;

  /// Fires on every (re)connect — do a full REST resync here.
  void Function()? onResync;

  // ── Connect ─────────────────────────────────────────────────
  // void connect() {
  //   if (_socket != null) {
  //     _socket!.connect();
  //     return;
  //   }

  //   _log('connecting to ${Urls.socketServer} ...');

  //   _socket = io.io(
  //     Urls.socketServer,
  //     io.OptionBuilder()
  //         .setTransports(['polling', 'websocket'])
  //         .setExtraHeaders({'ngrok-skip-browser-warning': 'true'})
  //         .disableAutoConnect()
  //         .enableReconnection()
  //         .setReconnectionAttempts(1 << 30) // effectively forever
  //         .setReconnectionDelay(2000)
  //         .setReconnectionDelayMax(10000)
  //         .build(),
  //   );

  //   _socket!.onConnect((_) {
  //     connected.value = true;
  //     _log('✅ CONNECTED (id: ${_socket?.id})');
  //     _register();
  //     onResync?.call(); // initial + every reconnect → recover missed events
  //   });

  //   _socket!.onReconnect((_) => _log('🔁 reconnected'));
  //   _socket!.onDisconnect((_) {
  //     connected.value = false;
  //     _log('❌ DISCONNECTED');
  //   });
  //   _socket!.onConnectError((e) => _log('⚠️ CONNECT ERROR: $e'));
  //   _socket!.onError((e) => _log('⚠️ ERROR: $e'));

  //   _bindEventHandlers(); // once — socket.io keeps them across reconnects
  //   _socket!.connect();
  // }


  void connect() {
  if (_socket != null) {
    _socket!.connect();
    return;
  }

  _log('connecting to ${Urls.socketServer} ...');

  _socket = io.io(
    Urls.socketServer,
    io.OptionBuilder()
        .setTransports(['websocket']) // s1 real server — direct websocket
        .disableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(1 << 30)
        .setReconnectionDelay(2000)
        .setReconnectionDelayMax(10000)
        .setTimeout(15000) // 15s e response na ele error dibe (hang na)
        .build(),
  );

  _socket!.onConnect((_) {
    connected.value = true;
    _log('✅ CONNECTED (id: ${_socket?.id})');
    _register();
    onResync?.call();
  });

  _socket!.onReconnect((_) => _log('🔁 reconnected'));
  _socket!.onDisconnect((r) {
    connected.value = false;
    _log('❌ DISCONNECTED: $r');
  });
  _socket!.onConnectError((e) => _log('⚠️ CONNECT ERROR: $e'));
  _socket!.onError((e) => _log('⚠️ ERROR: $e'));

  _bindEventHandlers();
  _socket!.connect();
}

  void _bindEventHandlers() {
    if (_handlersBound) return;
    _handlersBound = true;
    final s = _socket!;

    s.on('order:created', (d) {
      final m = _asMap(d);
      if (m.isEmpty) return;
      _log('order:created → ${m['_id'] ?? m['orderId']}');
      onOrderCreated?.call(m);
    });

    s.on('order:updated', (d) {
      final m = _asMap(d);
      if (m.isEmpty) return;
      _log('order:updated → ${m['_id'] ?? m['orderId']}');
      onOrderUpdated?.call(m);
    });

    s.on('order:removed', (d) {
      final m = _asMap(d);
      if (m.isEmpty) return;
      _log('order:removed → ${m['_id'] ?? m['orderId']}');
      onOrderRemoved?.call(m);
    });

    s.on('orders:cleared', (d) {
      final m = _asMap(d);
      _log('orders:cleared → ${m['clearedAt']}');
      onOrdersCleared?.call(m);
    });

    s.on('device:unpaired', (d) {
      final m = _asMap(d);
      _log('device:unpaired → ${m['id']}');
      onDeviceUnpaired?.call(m);
    });
  }

  // ── Register this tablet (restaurant/station scope) ──────────
  void _register() {
    final payload = {
      'userId': Preferences.userId,
      'stationId': Preferences.stationId,
      'deviceId': Preferences.deviceDbId,
    };
    _socket?.emit('register', payload);
    _log('📤 register → $payload');
  }

  /// Call after a successful (re)pair so the server re-scopes this socket.
  void reRegister() {
    if (_socket?.connected == true) _register();
  }

  Map<String, dynamic> _asMap(dynamic d) =>
      d is Map ? Map<String, dynamic>.from(d) : const {};

  void disconnect() {
    try {
      _socket?.disconnect();
      _socket?.close();
      _socket = null;
      _handlersBound = false;
      connected.value = false;
      _log('🛑 disconnected (manual)');
    } catch (e) {
      _log('❌ disconnect error: $e');
    }
  }

  void _log(String msg) => debugPrint('[SOCKET] $msg');
}