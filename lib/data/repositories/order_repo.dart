// import '../../core/network/dio_client.dart';
// import '../../core/constants/urls.dart';
// import '../models/kds_order.dart';

// class OrdersRepository {
//   Future<List<KdsOrder>> fetchOrders() async {
//     final response = await DioClient.instance.get(Urls.orders);

//     final body = response.data;
//     if (body['success'] == true && body['data'] is List) {
//       final raw = body['data'] as List;

//       return raw
//           .where((o) {
//             // KDS এ দেখানোর যোগ্য order গুলোই রাখো
//             final status = o['orderStatus']?.toString() ?? '';
//             final isDeleted = o['isDeleted'] == true;
//             final isVoid = o['isVoid'] == true;

//             // cancelled / void / deleted order kitchen এ দেখানোর দরকার নেই
//             if (isDeleted || isVoid) return false;
//             if (status == 'CANCELLED') return false;

//             return true;
//           })
//           .map((o) => KdsOrder.fromJson(o as Map<String, dynamic>))
//           .toList();
//     }
//     return [];
//   }
// }

// final ordersRepository = OrdersRepository();

import 'package:dio/dio.dart';
import 'package:yogo_kds/core/storage/preferences.dart';
import 'package:yogo_kds/data/models/item_summary.dart';

import '../../core/network/dio_client.dart';
import '../../core/constants/urls.dart';
import '../models/kds_order.dart';

// Which tab we are fetching
enum OrderTab { open, hold, completed }

extension OrderTabX on OrderTab {
  String get query {
    switch (this) {
      case OrderTab.open:
        return 'OPEN';
      case OrderTab.hold:
        return 'HOLD';
      case OrderTab.completed:
        return 'COMPLETED';
    }
  }
}

class OrdersRepository {
  Future<List<KdsOrder>> fetchOrders(OrderTab tab) async {
    final response = await DioClient.instance.get(
      Urls.orders,
      queryParameters: {'tab': tab.query},
    );

    final body = response.data;
    if (body['success'] == true && body['data'] is List) {
      final raw = body['data'] as List;
      return raw
          .where((o) {
            // Skip deleted / voided orders — the kitchen never needs these
            final isDeleted = o['isDeleted'] == true;
            final isVoid = o['isVoid'] == true;
            return !isDeleted && !isVoid;
          })
          .map((o) => KdsOrder.fromJson(o as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── Item summary — GET /api/kds/orders/summary ───────────────
  // Response: { success, data: { items: [{name, quantity, itemId}], totalQuantity } }
  Future<List<ItemSummary>> fetchItemSummary() async {
    final res = await DioClient.instance.get(Urls.itemSummary);
    final data = res.data['data'];
    final rawItems = (data?['items'] as List?) ?? const [];
    return rawItems
        .map((e) => ItemSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Item ready — PATCH /kds/orders/:orderId/items/:itemId/ready ──
  Future<void> setItemReady(String orderId, String itemId, bool ready) async {
    await DioClient.instance.patch(
      Urls.itemReady(orderId),
      data: {
        'ready': ready,
        'itemId': itemId,
        'action': "ITEM_READY"
      
      },
    );
  }

  // ── Modifier ready — PATCH .../items/:itemId/modifiers/:modId/ready ──
  Future<void> setModifierReady(
    String orderId,
    String itemId,
    String modifierId,
    bool ready,
  ) async {
    await DioClient.instance.patch(
      Urls.modifierReady(orderId, itemId, modifierId),
      data: {'ready': ready},
    );
  }

  // ── Bump — OPEN → COMPLETED ────────────────────────────────
  // Future<bool> bumpOrder(String id) async {
  //   final res = await DioClient.instance.patch(Urls.bump(id),);
  //   return res.data['success'] == true;
  // }
  // ── Bump — OPEN → COMPLETED ────────────────────────────────
  Future<bool> bumpOrder(String id) async {
    final res = await DioClient.instance.patch(
      Urls.bump(id),
      data: {'action': 'BUMP'},
    );
    return res.data['success'] == true;
  }

  // ── Recall — COMPLETED → OPEN ──────────────────────────────
  Future<bool> recallOrder(String id) async {
    final res = await DioClient.instance.patch(
      Urls.recall(id),
      data: {'resetItems': true,
      'action':'RECALL'
      },
    );
    return res.data['success'] == true;
  }

  // ── Hold — OPEN → HOLD ─────────────────────────────────────
  Future<bool> holdOrder(String id, DateTime holdUntil) async {
    final res = await DioClient.instance.patch(
      Urls.hold(id),
      data: {
        'holdUntil': holdUntil.toUtc().toIso8601String(),
        'action': 'HOLD',
      },
    );
    return res.data['success'] == true;
  }

  // ── Release — HOLD → OPEN ──────────────────────────────────
  Future<bool> releaseOrder(String id) async {
    final res = await DioClient.instance.patch(
      Urls.release(id),
      data: {'action':'RELEASE'}
    
    );
    return res.data['success'] == true;
  }

  // ── Rename device — PATCH /api/kds-devices/:deviceId ─────────
  // Response: { success, data: { id, name, ... } }
  // Future<String?> renameDevice(String deviceId, String name) async {
  //   final res = await DioClient.instance.patch(
  //     Urls.renameDevice(deviceId),
  //     data: {'name': name},
  //   );
  //   final body = res.data;
  //   if (body['success'] == true && body['data'] is Map) {
  //     return (body['data']['name'] ?? name).toString();
  //   }
  //   return null;
  // }

  Future<String?> renameDevice(String deviceId, String name) async {
    final res = await DioClient.instance.patch(
      Urls.renameDevice(deviceId),
      data: {'name': name},
      options: Options(
        headers: {
          'Authorization': 'Bearer ${Preferences.token}',
        }, // device token
      ),
    );
    final body = res.data;
    if (body['success'] == true && body['data'] is Map) {
      return (body['data']['name'] ?? name).toString();
    }
    return null;
  }

  /// Current device info (auth token diye). device map ferot dey, na pele null.
  Future<Map<String, dynamic>?> fetchDeviceInfo() async {
    final res = await DioClient.instance.get(Urls.deviceMe);
    final body = res.data;
    if (body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data']);
    }
    return null;
  }

  // ── Unpair / logout — backend e device INACTIVE kore ──
  Future<bool> unpairDevice() async {
    final res = await DioClient.instance.post(Urls.unpair);
    return res.data['success'] == true;
  }

  // ── Completed orders clear — koto ta clear holo ferot dey ──
  Future<int> clearCompletedOrders() async {
    final res = await DioClient.instance.post(Urls.clearCompleted);
    final body = res.data;
    if (body['success'] == true && body['data'] is Map) {
      return (body['data']['cleared'] ?? 0) as int;
    }
    return 0;
  }
}

final ordersRepository = OrdersRepository();
